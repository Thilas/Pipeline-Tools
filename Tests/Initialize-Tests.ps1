[CmdletBinding()]
param(
    [Management.Automation.InvocationInfo] $Invocation,
    [switch] $PassThru
)
$ErrorActionPreference = "Stop"

# Import Testing Helper module
Import-Module "$PSScriptRoot/TestingHelper.psm1" -Force

if ($Invocation) {
    $sutPath = $Invocation.MyCommand.Path -replace "\b.Tests\b", "" | Get-Item -ErrorAction SilentlyContinue
    if (!$sutPath) {
        throw ("Unable to find source code to test for '{0}'." -f $Invocation.MyCommand.Path)
    }
}

# Import VstsTaskSdk module
$vstsTaskSdkModule = "VstsTaskSdk"
$vstsTaskSdkPath = "$PSScriptRoot/ps_modules/$vstsTaskSdkModule"
if (Test-Path $vstsTaskSdkPath) {
    $Env:SYSTEM_CULTURE = "en_US" # Required in order to import the module successfully
    Use-Module -Name $vstsTaskSdkModule -Path $vstsTaskSdkPath
} else {
    throw "Unable to import VstsTaskSdk. Please build the project first."
}

# Gather Common modules
$commonModules = Get-ChildItem "$PSScriptRoot/../Common" -Include "*.psd1", "*.psm1" -Recurse -File `
| Select-Object -ExpandProperty "DirectoryName" -Unique `
| ForEach-Object { [pscustomobject] @{
    Name = Split-Path $_ -Leaf
    Path = $_
} }

if ($sutPath) {
    # Import whole module if part of one
    $sutDirectory = Split-Path $sutPath
    $module = $commonModules | Where-Object "Path" -EQ $sutDirectory
    if ($module) {
        return $module | Use-Module -Force -AsCustomObject:$PassThru
    }

    # Otherwise, dot source tested file
    if ($PassThru) {
        return [scriptblock]::Create(". '{0}'" -f ($sutPath -replace "'", "''"))
    } else {
        return . $sutPath
    }
}

# Import all Common modules
$commonModules | Use-Module -Force
