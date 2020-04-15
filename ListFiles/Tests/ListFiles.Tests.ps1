$sut = . "$PSScriptRoot/../../Tests/Initialize-Tests.ps1" $MyInvocation -PassThru

Describe "List Files" {
    # Arrange
    $FakeRoot = "$PSScriptRoot/.."
    Mock "Get-ChildItem" { @([pscustomobject] @{ FullName = 1; PsIsContainer = $true }) }

    It "lists files in System.DefaultWorkingDirectory when rootDir is null and debugOnly is false" {
        Mock "Get-VstsTaskVariable" -ParameterFilter { $Name -eq "System.DefaultWorkingDirectory" -and $Require } { $FakeRoot } -Verifiable
        # Act
        & $sut
        # Assert
        Assert-VerifiableMock
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

    It "lists files in rootDir when debugOnly is true and System.Debug is true" {
        # Arrange
        Mock "Get-VstsInput" -ParameterFilter { $Name -eq "rootDir" } { $FakeRoot } -Verifiable
        Mock "Get-VstsTaskVariable" -ParameterFilter { $Name -eq "System.Debug" -and $AsBool } { $true } -Verifiable
        # Act
        & $sut
        # Assert
        Assert-VerifiableMock
        Assert-MockCalled "Get-ChildItem" -Scope It
    }
}
