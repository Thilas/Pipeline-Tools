$sut = . "$PSScriptRoot/../../Tests/Initialize-Tests.ps1" $MyInvocation -PassThru

Describe "Comment" {
    # Arrange
    $FakeComments = "Some comments..."
    Mock "Write-Output" -ParameterFilter { $InputObject -eq $FakeComments }

    It "does nothing when includeCommentsInLog is false" {
        # Act
        & $sut
        # Assert
        Assert-MockCalled "Write-Output" -Times 0 -Scope It
    }

    It "writes comments when includeCommentsInLog is true" {
        # Arrange
        Mock "Get-VstsInput" -ParameterFilter { $Name -eq "comments" } { $FakeComments } -Verifiable
        Mock "Get-VstsInput" -ParameterFilter { $Name -eq "includeCommentsInLog" -and $AsBool } { $true } -Verifiable
        # Act
        & $sut
        # Assert
        Assert-VerifiableMock
        Assert-MockCalled "Write-Output" -Scope It
    }
}
