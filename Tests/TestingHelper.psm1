[CmdletBinding()]
[OutputType([void])]
param()

function Backup-EnvironmentVariables {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()
    $result = @{ }
    Get-ChildItem "Env:/" `
    | ForEach-Object {
        $result.Add($_.Key, $_.Value)
    }
    return $result
}

function Restore-EnvironmentVariables {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory=$true)]
        [hashtable] $EnvironmentVariables
    )
    $EnvironmentVariables.Keys `
    | ForEach-Object {
        $item = Get-Item "Env:/$_"
        if ($EnvironmentVariables.$_ -ne $item.Value) {
            "Set '$_' back to: {0}" -f $EnvironmentVariables.$_ | Write-Verbose
            $EnvironmentVariables.$_ | Set-Item "Env:/$_"
        }
    }
    Get-ChildItem "Env:/" `
    | Where-Object "Key" -NotIn $EnvironmentVariables.Keys `
    | ForEach-Object {
        "Remove '{0}'" -f $_.Key | Write-Verbose
        $_ | Remove-Item
    }
}

function Use-Module {
    [CmdletBinding(PositionalBinding=$false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $Name,
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $Path,
        [object[]] $ArgumentList,
        [switch] $Force,
        [switch] $AsCustomObject
    )
    process {
        Get-Module $Name `
        | Where-Object { $Force -or $_.ModuleBase -ne (Get-Item $Path) } `
        | Remove-Module
        Import-Module $Path -Global -ArgumentList $ArgumentList -AsCustomObject:$AsCustomObject
    }
}

Export-ModuleMember -Function @(
    "Backup-EnvironmentVariables"
    "Restore-EnvironmentVariables"
    "Use-Module"
)
