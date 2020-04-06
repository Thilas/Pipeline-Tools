[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

[string] $rootDir   = $Env:INPUT_ROOTDIR
[string] $debugOnly = $Env:INPUT_DEBUGONLY

if ($Env:SYSTEM_DEBUG -eq "true") {
    Write-Output "##vso[task.debug]Entering: listFiles.ps1"
    Write-Output "##vso[task.debug]  rootDir: $rootDir"
    Write-Output "##vso[task.debug]  debugOnly: $debugOnly"
}

if (!$rootDir) {
    $rootDir = "."
    Write-Output " "
    Write-Output "Setting root directory to $rootDir"
}

if ($debugOnly -ne "true" -or ($debugOnly -eq "true" -and $Env:SYSTEM_DEBUG -eq "true")) {
    $count = 0
    Write-Output " "
    Write-Output "Files and Directories"
    Write-Output "---------------------"
    Get-ChildItem $rootDir -Recurse `
    | ForEach-Object {
        $count++
        $directorySeparator = if ($_.PsIsContainer) { [System.IO.Path]::DirectorySeparatorChar }
        "{0}$directorySeparator" -f $_.FullName | Write-Output
    }
    Write-Output "---------------------"
    Write-Output "$count files and directories."
}
