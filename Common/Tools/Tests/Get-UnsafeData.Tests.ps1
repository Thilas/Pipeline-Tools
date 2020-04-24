. "$PSScriptRoot/../../../Tests/Initialize-Tests.ps1" $MyInvocation

InModuleScope "Tools" {
    Describe "Get-UnsafeData" {
        $FakeName  = "Name"
        $FakeItem1 = @{ }
        $FakeItem2 = @{ }
        $FakeItem3 = @{ }

        It "returns source with single item if no errors" {
            # Act
            $actualValue = { $FakeItem1 } | Get-UnsafeData $FakeName
            # Assert
            $actualValue | Should -BeExactly $FakeItem1
        }

        It "returns source with multiple items if no errors" {
            # Act
            $actualValue = { $FakeItem1, $FakeItem2 } | Get-UnsafeData $FakeName
            # Assert
            $actualValue | Should -HaveCount 2
            $actualValue | Should -BeExactly $FakeItem1, $FakeItem2
        }

        It "returns multiple sources if no errors" {
            # Act
            $actualValue = { $FakeItem1 }, { $FakeItem2, $FakeItem3 } | Get-UnsafeData $FakeName
            # Assert
            $actualValue | Should -HaveCount 3
            $actualValue | Should -BeExactly $FakeItem1, $FakeItem2, $FakeItem3
        }

        It "returns sources even if some errors" {
            # Arrange
            $FakeMessage = "Message"
            Mock "Write-Verbose" -ParameterFilter { $Message -like "$FakeName*$FakeMessage" } -Verifiable
            # Act
            $actualValue = { $FakeItem1 }, { throw $FakeMessage }, { $FakeItem2 } | Get-UnsafeData $FakeName
            # Assert
            Assert-VerifiableMock
            $actualValue | Should -HaveCount 2
            $actualValue | Should -BeExactly $FakeItem1, $FakeItem2
        }

        It "adds profiling data" {
            # Act
            $FakeProfiling = @{ }
            Get-UnsafeData $FakeName -Profiling $FakeProfiling { $FakeItem1 }
            # Assert
            $FakeProfiling.Keys | Should -Contain $FakeName
            $FakeProfiling.$FakeName | Should -BeOfType [timespan]
        }
    }
}
