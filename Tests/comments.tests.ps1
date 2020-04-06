$ErrorActionPreference = "Stop"

Describe "Comments" {
    $Env:SYSTEM_DEBUG = 'false'
    $Env:INPUT_COMMENTS = "Some comments..."
    Mock "Write-Output" -ParameterFilter { $InputObject -notmatch "^##vso\b" }

    It "shows nothing when includeCommentsInLog is false" {
        $Env:INPUT_INCLUDECOMMENTSINLOG = 'false'
        & "$PSScriptRoot\..\PipelineToolsComments\comments.ps1"
        Assert-MockCalled "Write-Output" -Scope It -Times 0
    }

    It "shows comments when includeCommentsInLog is true" {
        $Env:INPUT_INCLUDECOMMENTSINLOG = 'true'
        & "$PSScriptRoot\..\PipelineToolsComments\comments.ps1"
        Assert-MockCalled "Write-Output" -Scope It
    }

    It "escapes comments in debug messages when required" {
        $Env:SYSTEM_DEBUG = 'true'
        $Env:INPUT_COMMENTS = "A;`r`n]Z"
        Mock "Write-Output" -ParameterFilter { $InputObject -match "A%3B%0D%0A%5DZ" } -Verifiable
        & "$PSScriptRoot\..\PipelineToolsComments\comments.ps1"
        Assert-VerifiableMock
    }
}
