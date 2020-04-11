$sut = . "$PSScriptRoot/../../Tests/Initialize-Tests.ps1" $MyInvocation -PassThru

Describe "Retain Run" {
    # Arrange
    Mock "Get-VstsTaskVariable"
    Mock "Invoke-RestMethod" -ParameterFilter { $Method -eq "Get" } { @{ count = 1 } }

    It "retains the run when debugOnly is false" {
        # Arrange
        Mock "Write-Warning" -Verifiable
        # Act
        & $sut
        # Assert
        Assert-VerifiableMock
        Assert-MockCalled "Invoke-RestMethod" -Scope It
    }

    It "does nothing when debugOnly is true and System.Debug is false" {
        # Arrange
        Mock "Get-VstsInput" -ParameterFilter { $Name -eq "debugOnly" -and $AsBool } { $true } -Verifiable
        # Act
        & $sut
        # Assert
        Assert-VerifiableMock
        Assert-MockCalled "Invoke-RestMethod" -Times 0 -Scope It
    }

    It "retains the run when debugOnly is true and System.Debug is true" {
        # Arrange
        Mock "Get-VstsTaskVariable" -ParameterFilter { $Name -eq "System.Debug" -and $AsBool } { $true } -Verifiable
        Mock "Invoke-RestMethod" -ParameterFilter { $Method -eq "Get" } { @{ count = 0 } } -Verifiable
        Mock "Invoke-RestMethod" -ParameterFilter { $Method -eq "Post" } -Verifiable
        # Act
        & $sut
        # Assert
        Assert-VerifiableMock
    }
}
