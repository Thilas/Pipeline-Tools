$ErrorActionPreference = "Stop"

Describe "ListSystemInfo" {
    Mock "Write-Output"

    It "shows files when debugOnly is false" {
        $Env:INPUT_DEBUGONLY = 'false'
        & "$PSScriptRoot\..\PipelineToolsListSystemInfo\listSystemInfo.ps1"
        Assert-MockCalled "Write-Output" -Scope It
    }

    It "shows nothing when debugOnly is true and system.debug is false" {
        $Env:INPUT_DEBUGONLY = 'true'
        $Env:SYSTEM_DEBUG = 'false'
        & "$PSScriptRoot\..\PipelineToolsListSystemInfo\listSystemInfo.ps1"
        Assert-MockCalled "Write-Output" -Scope It -Times 0
    }

    It "shows apps when debugOnly is true and system.debug is true" {
        $Env:INPUT_DEBUGONLY = 'true'
        $Env:SYSTEM_DEBUG = 'true'
        & "$PSScriptRoot\..\PipelineToolsListSystemInfo\listSystemInfo.ps1"
        Assert-MockCalled "Write-Output" -Scope It
    }
}
