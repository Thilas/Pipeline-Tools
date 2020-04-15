[CmdletBinding(DefaultParameterSetName="Build")]
[OutputType([void])]
param(
    [Parameter(ParameterSetName="Build")]
    [switch] $Build,
    [Parameter(ParameterSetName="Rebuild")]
    [switch] $Rebuild,
    [switch] $UnitTests,
    [switch] $IntegrationTests,
    [switch] $CodeCoverage,
    [switch] $Clear
)
$ErrorActionPreference = "Stop"

if ($Env:SYSTEM_DEBUG -eq "true") {
    $VerbosePreference = "Continue"
}

if ($Rebuild) { $Build = $true }

if (!($Build -or $UnitTests -or $IntegrationTests -or $Clear)) {
    $Build = $true
}

function Clear-Directory {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory=$true)]
        [string] $Path
    )
    Get-ChildItem $Path -Include "Tests", "Sources" -Recurse -Depth 1 -Directory | Remove-Item -Recurse
    Get-ChildItem $Path -Include "build.json", "*.md" -Recurse -Depth 1 -File | Remove-Item
}

if ($Build) {
    # Initialize the build
    $buildPath = "$PSScriptRoot/_build"
    if ($Rebuild -and (Test-Path $buildPath)) {
        Remove-Item $buildPath -Recurse
    }
    if (!(Test-Path $buildPath)) {
        New-Item $buildPath -ItemType Directory | Out-Null
    }

    $Script:rebuilds = @{ }

    function Restore-Task {
        [CmdletBinding(PositionalBinding=$false)]
        [OutputType([void])]
        param(
            [Parameter(Mandatory=$true)]
            [string] $Path,
            [string] $TaskPath = $(Split-Path $Path),
            [switch] $Rebuild
        )
        Write-Verbose "Reading $Path..."
        $json = Get-Content $Path | ConvertFrom-Json
        $json.resources | Where-Object { $_ } `
        | Restore-Resource -TaskPath $TaskPath -Rebuild:$Rebuild
        $json.common | Where-Object { $_ } `
        | Restore-CommonModule -TaskPath $TaskPath
        $json.nuget | Where-Object { $_ } `
        | Restore-NuGetPackage -TaskPath $TaskPath -Rebuild:$Rebuild
    }

    function Restore-Resource {
        [CmdletBinding(PositionalBinding=$false)]
        [OutputType([void])]
        param(
            [Parameter(Mandatory=$true)]
            [string] $TaskPath,
            [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
            [string] $Url,
            [Parameter(ValueFromPipelineByPropertyName=$true)]
            [string] $Destination,
            [switch] $Rebuild
        )
        process {
            $resourceFile = Split-Path $Url -Leaf
            $resourceDirectory = if ($Destination) { Join-Path $TaskPath $Destination } else { $TaskPath }
            $resourcePath = Join-Path $resourceDirectory $resourceFile
            if ($Rebuild -and (Test-Path $resourcePath)) {
                Remove-Item $resourcePath -Recurse
            }
            if (Test-Path $resourcePath) {
                Write-Verbose "$Url already downloaded: $resourcePath"
            } else {
                Write-Host "  Downloading $Url..."
                if (!(Test-Path $resourceDirectory)) {
                    New-Item $resourceDirectory -ItemType Directory | Out-Null
                }
                # Enable latest security protocols
                [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor "Tls12,Tls13"
                $webClient = [System.Net.WebClient]::new()
                try {
                    $webClient.DownloadFile($Url, $resourcePath)
                } finally {
                    $webClient.Dispose()
                }
            }
        }
    }

    function Restore-CommonModule {
        [CmdletBinding(PositionalBinding=$false)]
        [OutputType([void])]
        param(
            [Parameter(Mandatory=$true)]
            [string] $TaskPath,
            [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
            [string] $Name,
            [Parameter(ValueFromPipelineByPropertyName=$true)]
            [string] $Destination
        )
        process {
            $modulePath = "$PSScriptRoot/Common/$Name"
            if (!(Test-Path $modulePath)) {
                throw "Common module $name not found."
            }
            Restore-Module @PSBoundParameters -Path $modulePath -Rebuild -Clear
        }
    }

    function Initialize-NuGet {
        [CmdletBinding()]
        [OutputType([string])]
        param()
        $Script:nuget = "$buildPath/nuget.exe"
        Write-Verbose "NuGet: $Script:nuget"
        if (Test-Path $Script:nuget) {
            $nugetVersion = & $Script:nuget "help" | Select-Object -First 1
            Write-Host "  Using $nugetVersion"
        } else {
            Write-Warning "NuGet not found."
        }
    }

    function Restore-NuGetPackage {
        [CmdletBinding(PositionalBinding=$false)]
        [OutputType([void])]
        param(
            [Parameter(Mandatory=$true)]
            [string] $TaskPath,
            [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
            [string] $Name,
            [Parameter(ValueFromPipelineByPropertyName=$true)]
            [string] $Version,
            [Parameter(ValueFromPipelineByPropertyName=$true)]
            [string] $Source,
            [Parameter(ValueFromPipelineByPropertyName=$true)]
            [string] $Destination,
            [switch] $Rebuild
        )
        process {
            $packagesPath = "$buildPath/packages"
            if (!(Test-Path $packagesPath)) {
                New-Item $packagesPath -ItemType Directory | Out-Null
            }
            if ($Source) {
                $sourceParameters = "-Source", $Source
            }

            if (!$Version -or !(Test-Path "$packagesPath/$Name.$Version")) {
                if ($Version) {
                    Write-Host "  Checking $Name v$Version..."
                } else {
                    Write-Host "  Checking $Name..."
                }
                $parameters = "list", $Name + $sourceParameters
                if ($Version) { $parameters += "-AllVersions" }
                Write-Verbose "Executing command: nuget $parameters"
                $versions = & $Script:nuget $parameters | ForEach-Object {
                    if ($_ -match '^(?<package>\S+)\s+(?<version>\S+)$' -and $Matches.package -eq $Name -and (!$Version -or $Matches.version -eq $Version)) {
                        $Matches.version
                    }
                }
                if ($Version -and !$versions) {
                    throw "Package $Name or version $Version not found."
                } elseif (!$versions) {
                    throw "Package $Name not found."
                } elseif ($versions | Select-Object -Skip 1) {
                    throw "Package $Name unexpected issue."
                }
                if (!$Version) {
                    $Version = $versions
                }
            }
            $packagePath = "$packagesPath/$Name.$Version"
            if (Test-Path $packagePath) {
                Write-Verbose "Package $Name v$Version already downloaded: $packagePath"
                if (!$Rebuild -and $Script:rebuilds.$packagePath) {
                    $Rebuild = $true
                }
            } else {
                Write-Host "  Downloading $Name v$Version..."
                $parameters = "install", $Name, "-OutputDirectory", $packagesPath + $sourceParameters + "-Version", $version
                $parameters += if ($VerbosePreference -eq "Continue") { "-Verbosity", "Detailed" }
                Write-Verbose "Executing command: nuget $parameters"
                & $Script:nuget $parameters | Write-Verbose
                $nupkg = "$packagePath/$Name.$version.nupkg"
                if (Test-Path $nupkg) {
                    Remove-Item $nupkg
                }
                $patch = $Script:patches.$Name
                if ($patch) {
                    & $patch $packagePath | Out-Null
                }
                $Rebuild = $Script:rebuilds.$packagePath = $true
            }
            Restore-Module -TaskPath $TaskPath -Name $Name -Path $packagePath -Destination $Destination -Rebuild:$Rebuild
        }
    }

    function Restore-Module {
        [CmdletBinding(PositionalBinding=$false)]
        [OutputType([void])]
        param(
            [Parameter(Mandatory=$true)]
            [string] $TaskPath,
            [Parameter(Mandatory=$true)]
            [string] $Name,
            [Parameter(Mandatory=$true)]
            [string] $Path,
            [string] $Destination,
            [switch] $Rebuild,
            [switch] $Clear
        )
        $Destination = "$TaskPath/$Destination/$Name"
        if ($Rebuild -and (Test-Path $Destination)) {
            Get-Module $Name | Remove-Module
            Remove-Item $Destination -Recurse
        }
        if (Test-Path $Destination) {
            Write-Verbose "Module $Name already restored: $Destination"
        } else {
            Write-Host "  Restoring $Name..."
            Copy-Item $Path $Destination -Recurse
            if ($Clear) {
                Clear-Directory $Destination
            }
        }
    }

    $Script:patches = @{
        VstsTaskSdk = {
            param(
                [Parameter(Mandatory=$true)]
                [string] $Path
            )
            $Path = "$Path/FindFunctions.ps1"
            if (Test-Path $Path) {
                $content = Get-Content $Path | Out-String
                if ($content) {
                    $newContent = $content -replace `
                        "({\s+Write-Verbose 'Path not found\.'\s+return)(\s+})", `
                        '$1 ,@( )$2'
                    if ($newContent -ne $content) {
                        Write-Host "  Patching VstsTaskSdk Find-VstsMatch..."
                        Set-Content $Path -Value $newContent -NoNewline
                    }
                }
            }
        }
    }

    # Initialize build
    Write-Host "Initializing..."
    Restore-Task -Path "$PSScriptRoot/build.json" -TaskPath $buildPath -Rebuild:$Rebuild
    Initialize-NuGet | Out-Null

    # Build tasks
    Get-ChildItem $PSScriptRoot -Include "build.json" -Recurse -File `
    | Where-Object "DirectoryName" -NE $PSScriptRoot `
    | ForEach-Object {
        $task = $_.DirectoryName.Substring($PSScriptRoot.Length + 1)
        Write-Host "Building $task..."
        Restore-Task -Path $_ -Rebuild:$Rebuild
    }
}

if ($UnitTests) {
    # Run unit tests
    & "$PSScriptRoot/test.ps1" -CodeCoverage:$CodeCoverage -EnableExit
}

if ($IntegrationTests) {
    # Run integration tests
    & "$PSScriptRoot/test.ps1" -Integration -CodeCoverage:$CodeCoverage -EnableExit
}

if ($Clear) {
    # Clear task directories
    Get-ChildItem $PSScriptRoot -Include "task.json" -Recurse -File | ForEach-Object {
        Clear-Directory $_.DirectoryName
    }
}
