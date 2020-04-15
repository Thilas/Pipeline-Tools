. "$PSScriptRoot/../../../Tests/Initialize-Tests.ps1" $MyInvocation

InModuleScope "Tools" {
    Describe "Set-HostBufferSize" {
        It "sets a new width" {
            # Arrange
            $FakeWidth = 1
            $FakeHost = @{ UI = @{ RawUI = @{ BufferSize = @{} } } }
            Mock "Get-Host" { $FakeHost } -Verifiable
            # Act
            Set-HostBufferSize -Width $FakeWidth
            # Assert
            Assert-VerifiableMock
            $FakeHost.UI.RawUI.BufferSize.Width | Should -BeExactly $FakeWidth
        }

        It "sets a new height" {
            # Arrange
            $FakeHeight = 1
            $FakeHost = @{ UI = @{ RawUI = @{ BufferSize = @{} } } }
            Mock "Get-Host" { $FakeHost } -Verifiable
            # Act
            Set-HostBufferSize -Height $FakeHeight
            # Assert
            Assert-VerifiableMock
            $FakeHost.UI.RawUI.BufferSize.Height | Should -BeExactly $FakeHeight
        }

        It "doesn't set a width too small" {
            # Arrange
            $FakeWidth = 1
            $FakeHost = @{ UI = @{ RawUI = @{ BufferSize = @{}; WindowSize = @{ Width = $FakeWidth + 1 } } } }
            Mock "Get-Host" { $FakeHost } -Verifiable
            # Act
            Set-HostBufferSize -Width $FakeWidth
            # Assert
            Assert-VerifiableMock
            $FakeHost.UI.RawUI.BufferSize.Width | Should -BeNullOrEmpty
        }

        It "doesn't set a height too small" {
            # Arrange
            $FakeHeight = 1
            $FakeHost = @{ UI = @{ RawUI = @{ BufferSize = @{}; WindowSize = @{ Height = $FakeHeight + 1 } } } }
            Mock "Get-Host" { $FakeHost } -Verifiable
            # Act
            Set-HostBufferSize -Height $FakeHeight
            # Assert
            Assert-VerifiableMock
            $FakeHost.UI.RawUI.BufferSize.Height | Should -BeNullOrEmpty
        }

        It "warns if unable to set host buffer size" {
            # Arrange
            $FakeMessage = "Message"
            Mock "Get-Host" { throw $FakeMessage } -Verifiable
            Mock "Write-Warning" -ParameterFilter { $Message -like "Unable to set host buffer size: $FakeMessage" } -Verifiable
            # Act
            Set-HostBufferSize
            # Assert
            Assert-VerifiableMock
        }
    }
}
