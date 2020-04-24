$sut = . "$PSScriptRoot/../../Tests/Initialize-Tests.ps1" $MyInvocation -PassThru

Describe "Retain Run Task" {
    # Arrange
    Mock "Invoke-RestMethod" -ParameterFilter { $Method -eq "Get" } { @{ count = 1 } }

    It "retains the run when debugOnly is false" {
        # Arrange
        Mock "Get-VstsInput" -ParameterFilter { $Name -eq "debugOnly" -and $AsBool } { $false } -Verifiable
        Mock "Get-VstsTaskVariable" -ParameterFilter { $Name -eq "system.teamFoundationCollectionUri" -and $Require } -Verifiable
        Mock "Get-VstsTaskVariable" -ParameterFilter { $Name -eq "system.teamProject" -and $Require } -Verifiable
        Mock "Get-VstsTaskVariable" -ParameterFilter { $Name -eq "system.accessToken" -and $Require } -Verifiable
        Mock "Get-VstsTaskVariable" -ParameterFilter { $Name -eq "system.definitionId" -and $Require } -Verifiable
        Mock "Get-VstsTaskVariable" -ParameterFilter { $Name -eq "build.buildId" -and $Require } -Verifiable
        Mock "Write-Warning" -Verifiable
        # Act
        & $sut
        # Assert
        Assert-VerifiableMock
        Assert-MockCalled "Invoke-RestMethod" -Scope It
    }

    It "does nothing when debugOnly is true and system.debug is false" {
        # Arrange
        Mock "Get-VstsInput" -ParameterFilter { $Name -eq "debugOnly" -and $AsBool } { $true } -Verifiable
        Mock "Get-VstsTaskVariable" -ParameterFilter { $Name -eq "system.debug" -and $AsBool } { $false } -Verifiable
        # Act
        & $sut
        # Assert
        Assert-VerifiableMock
        Assert-MockCalled "Invoke-RestMethod" -Times 0 -Scope It
    }

    It "retains the run when debugOnly is true and system.debug is true" {
        # Arrange
        Mock "Get-VstsTaskVariable" -ParameterFilter { $Name -eq "system.debug" -and $AsBool } { $true } -Verifiable
        Mock "Invoke-RestMethod" -ParameterFilter { $Method -eq "Get" } { @{ count = 0 } } -Verifiable
        Mock "Invoke-RestMethod" -ParameterFilter { $Method -eq "Post" } -Verifiable
        # Act
        & $sut
        # Assert
        Assert-VerifiableMock
    }
}
