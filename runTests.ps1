[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$arguments = @{
    Script = "$PSScriptRoot/Tests/*"
    OutputFile = "results.xml"
    OutputFormat = "NUnitXml"
    CodeCoverage = Get-ChildItem "$PSScriptRoot" -Exclude "Tests" -Directory | ForEach-Object {
        Get-ChildItem $_ -Filter "*.ps1" | Select-Object -ExpandProperty "FullName"
    }
    CodeCoverageOutputFile = "coverage.xml"
    CodeCoverageOutputFileFormat = "JaCoCo"
}
Invoke-Pester @arguments -EnableExit
