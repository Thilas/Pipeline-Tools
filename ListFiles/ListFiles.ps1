[CmdletBinding(PositionalBinding=$false)]
[OutputType([void])]
param()

Trace-VstsEnteringInvocation $MyInvocation
try {
    $rootDir   = Get-VstsInput -Name "rootDir"
    $debugOnly = Get-VstsInput -Name "debugOnly" -AsBool

    if (!$rootDir) {
        $rootDir = Get-VstsTaskVariable -Name "System.DefaultWorkingDirectory" -Require
        Write-Verbose "Using default root directory: $rootDir"
    }

    $debug = Get-VstsTaskVariable -Name "System.Debug" -AsBool
    if (!$debugOnly -or ($debugOnly -and $debug)) {
        Import-Module "$PSScriptRoot/ps_modules/Tools" -NoClobber

        Get-ChildItem $rootDir -Recurse `
        | Sort-Object "FullName" `
        | Format-Table @(
            New-Property {
                $directorySeparator = if ($_.PsIsContainer) { [System.IO.Path]::DirectorySeparatorChar }
                "{0}$directorySeparator" -f $_.FullName
            } -Name "Path"
            "Length" | New-Property -Name "Size" | ConvertTo-Unit KB
        ) -AutoSize -Wrap | Write-Output
    }
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
