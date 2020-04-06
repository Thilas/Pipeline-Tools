[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

[string] $comments             = $Env:INPUT_COMMENTS
[string] $includeCommentsInLog = $Env:INPUT_INCLUDECOMMENTSINLOG

if ($Env:SYSTEM_DEBUG -eq "true") {
    Write-Output "##vso[task.debug]Entering: comments.ps1"
    "##vso[task.debug]  comments: {0}" -f ($comments -replace ";", "%3B" -replace "`r", "%0D" -replace "`n", "%0A" -replace "]", "%5D") | Write-Output
    Write-Output "##vso[task.debug]  includeCommentsInLog: $includeCommentsInLog"
}

if ($includeCommentsInLog -eq "true") {
    Write-Output " "
    Write-Output "Comments"
    Write-Output "--------"
    Write-Output $comments
}
