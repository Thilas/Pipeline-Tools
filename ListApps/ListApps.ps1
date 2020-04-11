[CmdletBinding(PositionalBinding=$false)]
[OutputType([void])]
param()

Trace-VstsEnteringInvocation $MyInvocation
try {
    $debugOnly = Get-VstsInput -Name "debugOnly" -AsBool

    $debug = Get-VstsTaskVariable -Name "System.Debug" -AsBool
    if (!$debugOnly -or ($debugOnly -and $debug)) {
        Import-Module "$PSScriptRoot/ps_modules/Tools" -NoClobber

        $applications = @()
        $applications += Get-ChildItem "HKCU:/Software/Microsoft/Windows/CurrentVersion/Uninstall"
        $applications += Get-ChildItem "HKLM:/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall"

        $applications `
        | Get-ItemProperty `
        | Where-Object { $_.DisplayName } `
        | Sort-Object "DisplayName" `
        | Format-Table @(
            "DisplayName" | New-Property -Name "Application"
            "DisplayVersion" | New-Property -Name "Version"
            "EstimatedSize" | New-Property -Name "Size" | ConvertTo-Unit MB -From KB
        ) -AutoSize -Wrap | Write-Output
    }
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
