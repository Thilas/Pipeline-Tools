$sut = . "$PSScriptRoot/../../Tests/Initialize-Tests.ps1" $MyInvocation -PassThru

Describe "List Files Task" {
    # Arrange
    $FakeRoot = "$PSScriptRoot/.."
    Mock "Get-ChildItem" { @([pscustomobject] @{ FullName = 1; PsIsContainer = $true }) }

    It "lists files in system.defaultWorkingDirectory when rootDir is null and debugOnly is false" {
        # Arrange
        Mock "Get-VstsInput" -ParameterFilter { $Name -eq "rootDir" } -Verifiable
        Mock "Get-VstsInput" -ParameterFilter { $Name -eq "debugOnly" -and $AsBool } { $false } -Verifiable
        Mock "Get-VstsTaskVariable" -ParameterFilter { $Name -eq "system.defaultWorkingDirectory" -and $Require } { $FakeRoot } -Verifiable
        # Act
        & $sut
        # Assert
        Assert-VerifiableMock
        Assert-MockCalled "Get-ChildItem" -Scope It
    }

    It "lists nothing when debugOnly is true and system.debug is false" {
        # Arrange
        Mock "Get-VstsInput" -ParameterFilter { $Name -eq "debugOnly" -and $AsBool } { $true } -Verifiable
        Mock "Get-VstsTaskVariable" -ParameterFilter { $Name -eq "system.debug" -and $AsBool } { $false } -Verifiable
        # Act
        & $sut
        # Assert
        Assert-VerifiableMock
        Assert-MockCalled "Get-ChildItem" -Times 0 -Scope It
    }

    It "lists files in rootDir when debugOnly is true and system.debug is true" {
        # Arrange
        Mock "Get-VstsInput" -ParameterFilter { $Name -eq "rootDir" } { $FakeRoot } -Verifiable
        Mock "Get-VstsTaskVariable" -ParameterFilter { $Name -eq "system.debug" -and $AsBool } { $true } -Verifiable
        # Act
        & $sut
        # Assert
        Assert-VerifiableMock
        Assert-MockCalled "Get-ChildItem" -Scope It
    }
}
