. "$PSScriptRoot/../../../Tests/Initialize-Tests.ps1" $MyInvocation

InModuleScope "Tools" {
    Describe "New-Property" {
        $FakeStringProperty      = "Property"
        $FakeScriptblockProperty = { "Property" }
        $FakeName                = "Name"
        $FakeFormat              = "Format"
        $FakeWidth               = 1
        $FakeAlignment           = "Left"
        $FakeOtherName           = "Other Name"
        $FakeOtherFormat         = "Other Format"
        $FakeOtherWidth          = 2
        $FakeOtherAlignment      = "Right"

        It "throws an error for an unsupported property" {
            # Act & Assert
            { New-Property 1 } | Should -Throw
        }

        It "throws an error for an unsupported property's expression" {
            # Arrange
            $property = @{ Expression = 1 }
            # Act & Assert
            { New-Property $property } | Should -Throw
        }

        It "supports full-featured property" {
            # Act
            $actualValue = $FakeStringProperty | New-Property -Name $FakeName -Format $FakeFormat -Width $FakeWidth -Alignment $FakeAlignment
            # Assert
            $actualValue              | Should -BeOfType [hashtable]
            $actualValue.Expression   | Should -BeExactly $FakeStringProperty
            $actualValue.Name         | Should -BeExactly $FakeName
            $actualValue.FormatString | Should -BeExactly $FakeFormat
            $actualValue.Width        | Should -BeExactly $FakeWidth
            $actualValue.Alignment    | Should -BeExactly $FakeAlignment
        }

        It "supports scriptblock property" {
            # Act
            $actualValue = $FakeScriptblockProperty | New-Property
            # Assert
            $actualValue            | Should -BeOfType [hashtable]
            $actualValue.Expression | Should -BeExactly $FakeScriptblockProperty
        }

        It "supports existing property" {
            # Arrange
            $property = New-Property $FakeStringProperty
            # Act
            $actualValue = $property | New-Property
            # Assert
            $actualValue | Should -BeOfType [hashtable]
            $actualValue | Should -Not -BeExactly $property
        }

        It "does not override existing attributes" {
            # Arrange
            $property = New-Property $FakeStringProperty -Name $FakeName -Format $FakeFormat -Width $FakeWidth -Alignment $FakeAlignment
            # Act
            $actualValue = $property | New-Property -Name $FakeOtherName -Format $FakeOtherFormat -Width $FakeOtherWidth -Alignment $FakeOtherAlignment
            # Assert
            $actualValue              | Should -BeOfType [hashtable]
            $actualValue.Expression   | Should -BeExactly $FakeStringProperty
            $actualValue.Name         | Should -BeExactly $FakeName
            $actualValue.FormatString | Should -BeExactly $FakeFormat
            $actualValue.Width        | Should -BeExactly $FakeWidth
            $actualValue.Alignment    | Should -BeExactly $FakeAlignment
        }

        It "can force overriding existing attributes" {
            # Arrange
            $property = New-Property $FakeStringProperty -Name $FakeName -Format $FakeFormat -Width $FakeWidth -Alignment $FakeAlignment
            # Act
            $actualValue = $property | New-Property -Name $FakeOtherName -Format $FakeOtherFormat -Width $FakeOtherWidth -Alignment $FakeOtherAlignment -Force
            # Assert
            $actualValue              | Should -BeOfType [hashtable]
            $actualValue.Expression   | Should -BeExactly $FakeStringProperty
            $actualValue.Name         | Should -BeExactly $FakeOtherName
            $actualValue.FormatString | Should -BeExactly $FakeOtherFormat
            $actualValue.Width        | Should -BeExactly $FakeOtherWidth
            $actualValue.Alignment    | Should -BeExactly $FakeOtherAlignment
        }
    }

    Describe "ConvertTo-Unit" {
        $FakeUnit                     = "GB"
        $FakeNameSuffix               = " ($FakeUnit)"
        $FakeStringProperty           = "Property"
        $FakeOtherProperty            = "Other Property"
        $FakeScriptblockProperty      = { $_.$FakeStringProperty + $_.$FakeOtherProperty }
        $FakeFormat                   = "N1"
        $FakeObject                   = @{
            $FakeStringProperty       = ($FakeStringPropertyValue = 1) * 1GB
            $FakeOtherProperty        = ($FakeOtherPropertyValue  = 2) * 1GB
        }
        $FakeScriptblockPropertyValue = $FakeStringPropertyValue + $FakeOtherPropertyValue
        $FakeName                     = "Name"
        $FakeOtherFormat              = "Format"

        It "supports string property" {
            # Act
            $actualValue = $FakeStringProperty | ConvertTo-Unit $FakeUnit
            # Assert
            $actualValue              | Should -BeOfType [hashtable]
            $actualValue.Name         | Should -BeExactly "$FakeStringProperty$FakeNameSuffix"
            $actualValue.FormatString | Should -BeExactly $FakeFormat
            $FakeObject | ForEach-Object $actualValue.Expression | Should -BeExactly $FakeStringPropertyValue
        }

        It "supports scriptblock property" {
            # Act
            $actualValue = $FakeScriptblockProperty | ConvertTo-Unit $FakeUnit
            # Assert
            $actualValue              | Should -BeOfType [hashtable]
            $actualValue.Name         | Should -BeExactly "$FakeScriptblockProperty$FakeNameSuffix"
            $actualValue.FormatString | Should -BeExactly $FakeFormat
            $FakeObject | ForEach-Object $actualValue.Expression | Should -BeExactly $FakeScriptblockPropertyValue
        }

        It "supports named property with format" {
            # Arrange
            $property = New-Property $FakeStringProperty -Name $FakeName -Force $FakeOtherFormat
            # Act
            $actualValue = $property | ConvertTo-Unit $FakeUnit
            # Assert
            $actualValue              | Should -BeOfType [hashtable]
            $actualValue.Name         | Should -BeExactly "$FakeName$FakeNameSuffix"
            $actualValue.FormatString | Should -BeExactly $FakeOtherFormat
        }

        It "supports other units" {
            # Act
            $actualValue = $FakeStringProperty | ConvertTo-Unit $FakeUnit -From KB
            # Assert
            $FakeObject | ForEach-Object $actualValue.Expression | Should -BeExactly ($FakeStringPropertyValue * 1KB)
        }
    }
}
