[CmdletBinding()]
[OutputType([void])]
param()

Get-ChildItem $PSScriptRoot -Filter "*.ps1" | ForEach-Object {
    . $_.FullName
}
