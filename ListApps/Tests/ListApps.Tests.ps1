$sut = . "$PSScriptRoot/../../Tests/Initialize-Tests.ps1" $MyInvocation -PassThru

Describe "List Apps" {
    # Arrange
    Mock "Get-ChildItem" { @([pscustomobject] @{ FullName = 1 }) }
    Mock "Get-ItemProperty" { @([pscustomobject] @{ DisplayName = 1 }) }

    It "lists apps when debugOnly is false" {
        # Act
        & $sut
        # Assert
        Assert-MockCalled "Get-ChildItem" -Scope It
    }

    It "lists nothing when debugOnly is true and System.Debug is false" {
        # Arrange
        Mock "Get-VstsInput" -ParameterFilter { $Name -eq "debugOnly" -and $AsBool } { $true } -Verifiable
        # Act
        & $sut
        # Assert
        Assert-VerifiableMock
        Assert-MockCalled "Get-ChildItem" -Times 0 -Scope It
    }

    It "lists apps when debugOnly is true and System.Debug is true" {
        # Arrange
        Mock "Get-VstsTaskVariable" -ParameterFilter { $Name -eq "System.Debug" -and $AsBool } { $true } -Verifiable
        # Act
        & $sut
        # Assert
        Assert-VerifiableMock
        Assert-MockCalled "Get-ChildItem" -Scope It
    }
}
