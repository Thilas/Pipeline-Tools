[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

[string] $debugOnly = $Env:INPUT_DEBUGONLY

if ($Env:SYSTEM_DEBUG -eq "true") {
    Write-Output "##vso[task.debug]Entering: listApps.ps1"
    Write-Output "##vso[task.debug]  debugOnly: $debugOnly"
}

if ($debugOnly -ne "true" -or ($debugOnly -eq "true" -and $Env:SYSTEM_DEBUG -eq "true")) {
    $count = 0
    Write-Output " "
    Write-Output "Installed Applications"
    Write-Output "----------------------"
    Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" `
    | Get-ItemProperty `
    | Where-Object "DisplayName" -NE $null `
    | Sort-Object "DisplayName" `
    | ForEach-Object {
        $count++
        $version = if ($_.DisplayVersion) { " [{0}]" -f $_.DisplayVersion }
        "{0}$version" -f $_.DisplayName
    } | Write-Output
    Write-Output "----------------------"
    Write-Output "$count applications installed."
}
