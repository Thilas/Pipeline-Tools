. "$PSScriptRoot/../../../Tests/Initialize-Tests.ps1" $MyInvocation

InModuleScope "Tools" {
    Describe "ConvertTo-Hashtable" {
        $FakeKey        = "Key"
        $FakeKey1       = "Key 1"
        $FakeKey2       = "Key 2"
        $FakeItem1      = @{ $FakeKey = $FakeKey1 }
        $FakeItem2      = @{ $FakeKey = $FakeKey2 }
        $FakeCollection = $FakeItem1, $FakeItem2

        It "returns hashtable" {
            # Act
            $actualValue = $FakeCollection | ConvertTo-Hashtable $FakeKey
            # Assert
            $actualValue           | Should -BeOfType [hashtable]
            $actualValue.Keys      | Should -HaveCount $FakeCollection.Length
            $actualValue.Keys      | Should -Contain $FakeKey1
            $actualValue.Keys      | Should -Contain $FakeKey2
            $actualValue.$FakeKey1 | Should -BeExactly $FakeItem1
            $actualValue.$FakeKey2 | Should -BeExactly $FakeItem2
        }
    }
}
