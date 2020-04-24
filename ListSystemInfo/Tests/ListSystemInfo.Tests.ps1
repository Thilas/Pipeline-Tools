$sut = . "$PSScriptRoot/../../Tests/Initialize-Tests.ps1" $MyInvocation -PassThru

Describe "List System Info" {
    # Arrange
    Mock "Get-CimInstance" { @([pscustomobject] @{ Id = 1 }) }

    It "lists system info when debugOnly is false" {
        # Act
        & $sut
        # Assert
        Assert-MockCalled "Get-CimInstance" -Scope It
    }

    It "lists nothing when debugOnly is true and system.debug is false" {
        # Arrange
        Mock "Get-VstsInput" -ParameterFilter { $Name -eq "debugOnly" -and $AsBool } { $true } -Verifiable
        # Act
        & $sut
        # Assert
        Assert-VerifiableMock
        Assert-MockCalled "Get-CimInstance" -Times 0 -Scope It
    }

    It "lists system info when debugOnly is true and system.debug is true" {
        # Arrange
        Mock "Get-VstsTaskVariable" -ParameterFilter { $Name -eq "system.debug" -and $AsBool } { $true } -Verifiable
        # Act
        & $sut
        # Assert
        Assert-VerifiableMock
        Assert-MockCalled "Get-CimInstance" -Scope It
    }
}
