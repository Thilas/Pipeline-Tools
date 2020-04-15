[CmdletBinding(PositionalBinding=$false)]
[OutputType([void])]
param()

Trace-VstsEnteringInvocation $MyInvocation
try {
    $comments             = Get-VstsInput -Name "comments"
    $includeCommentsInLog = Get-VstsInput -Name "includeCommentsInLog" -AsBool

    if ($includeCommentsInLog) {
        Write-Output ""
        Write-Output "Comments"
        Write-Output "--------"
        Write-Output $comments
        Write-Output ""
    }
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
