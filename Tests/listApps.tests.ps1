$ErrorActionPreference = "Stop"

Describe "ListApps" {
    $Env:SYSTEM_DEBUG = 'false'
    Mock "Write-Output" -ParameterFilter { $InputObject -notmatch "^##vso\b" }

    It "shows apps when debugOnly is false" {
        $Env:INPUT_DEBUGONLY = 'false'
        & "$PSScriptRoot\..\PipelineToolsListApps\listApps.ps1"
        Assert-MockCalled "Write-Output" -Scope It
    }

    It "shows nothing when debugOnly is true and system.debug is false" {
        $Env:INPUT_DEBUGONLY = 'true'
        & "$PSScriptRoot\..\PipelineToolsListApps\listApps.ps1"
        Assert-MockCalled "Write-Output" -Scope It -Times 0
    }

    It "shows apps when debugOnly is true and system.debug is true" {
        $Env:SYSTEM_DEBUG = 'true'
        & "$PSScriptRoot\..\PipelineToolsListApps\listApps.ps1"
        Assert-MockCalled "Write-Output" -Scope It
    }
}
