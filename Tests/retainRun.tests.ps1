$ErrorActionPreference = "Stop"

Describe "RetainRun" {
    $Env:SYSTEM_DEBUG = 'false'
    $Env:BUILD_SOURCEBRANCHNAME = 'branch'
    Mock "Invoke-RestMethod"

    It "retain the run when debugOnly is false" {
        $Env:INPUT_DEBUGONLY = 'false'
        & "$PSScriptRoot\..\PipelineToolsRetainRun\retainrun.ps1"
        Assert-MockCalled "Invoke-RestMethod" -Scope It
    }

    It "does nothing when debugOnly is true and system.debug is false" {
        $Env:INPUT_DEBUGONLY = 'true'
        $Env:SYSTEM_DEBUG = 'false'
        & "$PSScriptRoot\..\PipelineToolsRetainRun\retainrun.ps1"
        Assert-MockCalled "Invoke-RestMethod" -Scope It -Times 0
    }

    It "retain the run when debugOnly is true and system.debug is true" {
        $Env:INPUT_DEBUGONLY = 'true'
        $Env:SYSTEM_DEBUG = 'true'
        & "$PSScriptRoot\..\PipelineToolsRetainRun\retainrun.ps1"
        Assert-MockCalled "Invoke-RestMethod" -Scope It
    }
}
