[CmdletBinding(PositionalBinding=$false)]
[OutputType([void])]
param()

Trace-VstsEnteringInvocation $MyInvocation
try {
    $debugOnly = Get-VstsInput -Name "debugOnly" -AsBool

    if ($debugOnly) {
        $debug = Get-VstsTaskVariable -Name "system.debug" -AsBool
    }

    if (!$debugOnly -or ($debugOnly -and $debug)) {
        Import-Module "$PSScriptRoot/ps_modules/Tools" -NoClobber

        Set-HostBufferSize -Width 300

        $uninstallPaths = @(
            "HKCU:/Software/Microsoft/Windows/CurrentVersion/Uninstall"
            "HKLM:/SOFTWARE/Microsoft/Windows/CurrentVersion/Uninstall"
            "HKLM:/SOFTWARE/WOW6432Node/Microsoft/Windows/CurrentVersion/Uninstall"
        )

        $uninstallPaths | ForEach-Object { { Get-ChildItem $_ }} `
        | Get-UnsafeData "Applications" `
        | Get-ItemProperty `
        | Where-Object { $_.DisplayName } `
        | Sort-Object "DisplayName", "DisplayVersion" `
        | Format-Table @(
            "DisplayName"    | New-Property -Name "Application"
            "DisplayVersion" | New-Property -Name "Version"
            "EstimatedSize"  | New-Property -Name "Size" | ConvertTo-Unit MB -From KB
        ) -AutoSize -Wrap | Write-Output
    }
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
