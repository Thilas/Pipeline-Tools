[CmdletBinding(PositionalBinding = $false)]
[OutputType([void])]
param(
    [switch] $Integration,
    [string] $TestName,
    [string] $Tag,
    [switch] $CodeCoverage
)
$ErrorActionPreference = "Stop"

# Import Pester module
$pesterModule = "Pester"
$pesterPath = Get-Item "$PSScriptRoot/Tests/ps_modules/$pesterModule" -ErrorAction SilentlyContinue
if ($pesterPath) {
    $module = Get-Module $pesterModule
    if ($module -and $module.ModuleBase -ne $pesterPath) {
        Remove-Module $module
        $module = $null
    }
    if (!$module) {
        Import-Module $pesterPath
    }
} else {
    throw "Unable to import Pester. Please build the project first."
}

$name = if ($Integration) { "IntegrationTests" } else { "UnitTests" }

$parameters = @{
    OutputFile   = "$PSScriptRoot/TestResults-$name.xml"
    OutputFormat = "NUnitXML"
}

if ($Integration) {
    $parameters += @{
        Script = "$PSScriptRoot/Tests/Integration-Tests.ps1"
    }
}

if ($TestName) {
    $parameters += @{
        TestName = $TestName
    }
}

if ($Tag) {
    $parameters += @{
        Tag = $Tag
    }
}

if ($CodeCoverage) {
    $excludedFiles  = Get-Item "$PSScriptRoot/build.ps1", "$PSScriptRoot/test.ps1"
    $excludedDirectories  = Get-Item "$PSScriptRoot/_build", "$PSScriptRoot/Tests"
    $excludedDirectories += Get-ChildItem "$PSScriptRoot/*/packages", "$PSScriptRoot/*/ps_modules" -Directory
    $excludedDirectories += Join-Path $excludedDirectories "*"

    $parameters += @{
        CodeCoverage = Get-ChildItem -Include "*.ps1" -Exclude "*.Tests.ps1" -Recurse | Where-Object {
            $file = $_.FullName
            if ($excludedFiles | Where-Object { $file -like $_ }) { return $false }
            $directory = $_.DirectoryName
            if ($excludedDirectories | Where-Object { $directory -like $_ }) { return $false }
            return $true
        }
        CodeCoverageOutputFile       = "$PSScriptRoot/Coverage-$name.xml"
        CodeCoverageOutputFileFormat = "JaCoCo"
    }
}

Invoke-Pester @parameters -EnableExit
