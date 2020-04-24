[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string] $File
)

$workingDirectory = Split-Path $File
if (!(Test-Path "$workingDirectory/task.json")) {
    throw "This file is not task: $File."
}

. "$PSScriptRoot/../Tests/Initialize-Tests.ps1"

$debug = Get-VstsTaskVariable -Name "system.debug" -AsBool

Invoke-VstsTaskScript { . $File } -Verbose:$debug
