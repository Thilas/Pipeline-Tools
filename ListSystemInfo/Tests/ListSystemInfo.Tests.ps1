$sut = . "$PSScriptRoot/../../Tests/Initialize-Tests.ps1" $MyInvocation -PassThru

Describe "List System Info Task" {
    # Arrange
    Mock "New-CimSession" { New-MockObject ([CimSession]) }
    Mock "Get-CimInstance" { @([pscustomobject] @{ Id = 1 }) }
    Mock "Remove-CimSession"

    It "lists system info when debugOnly is false" {
        # Arrange
        Mock "Get-VstsInput" -ParameterFilter { $Name -eq "debugOnly" -and $AsBool } { $false } -Verifiable
        # Act
        & $sut
        # Assert
        Assert-VerifiableMock
        Assert-MockCalled "New-CimSession" -Scope It
        Assert-MockCalled "Get-CimInstance" -Scope It
        Assert-MockCalled "Remove-CimSession" -Scope It
    }

    It "lists nothing when debugOnly is true and system.debug is false" {
        # Arrange
        Mock "Get-VstsInput" -ParameterFilter { $Name -eq "debugOnly" -and $AsBool } { $true } -Verifiable
        Mock "Get-VstsTaskVariable" -ParameterFilter { $Name -eq "system.debug" -and $AsBool } { $false } -Verifiable
        # Act
        & $sut
        # Assert
        Assert-VerifiableMock
        Assert-MockCalled "New-CimSession" -Times 0 -Scope It
        Assert-MockCalled "Get-CimInstance" -Times 0 -Scope It
        Assert-MockCalled "Remove-CimSession" -Times 0 -Scope It
    }

    It "lists system info when debugOnly is true and system.debug is true" {
        # Arrange
        Mock "Get-VstsTaskVariable" -ParameterFilter { $Name -eq "system.debug" -and $AsBool } { $true } -Verifiable
        # Act
        & $sut
        # Assert
        Assert-VerifiableMock
        Assert-MockCalled "New-CimSession" -Scope It
        Assert-MockCalled "Get-CimInstance" -Scope It
        Assert-MockCalled "Remove-CimSession" -Scope It
    }
}
