[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

[string] $debugOnly = $Env:INPUT_DEBUGONLY

if ($Env:SYSTEM_DEBUG -eq "true") {
    Write-Output "##vso[task.debug]Entering: listVariables.ps1"
    Write-Output "##vso[task.debug]  debugOnly: $debugOnly"
}

if ($debugOnly -ne "true" -or ($debugOnly -eq "true" -and $Env:SYSTEM_DEBUG -eq "true")) {
    $count = 0
    Write-Output " "
    Write-Output "Environment Variables"
    Write-Output "---------------------"
    Get-ChildItem "Env:" `
    | ForEach-Object {
        $count++
        "{0,-32} {1}" -f $_.Key, $_.Value
    } | Write-Output
    Write-Output "---------------------"
    Write-Output "$count environment variables."
}
