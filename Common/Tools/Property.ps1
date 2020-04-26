function New-Property {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [object] $Property,
        [string] $Name,
        [string] $Format,
        [int]    $Width,
        [ValidateSet("Left", "Center", "Right")]
        [string] $Alignment,
        [switch] $Force
    )
    process {
        $result = if ($Property -is [string] -or $Property -is [scriptblock]) {
            @{ Expression = $Property -as $Property.GetType() }
        } elseif ($Property -is [hashtable]) {
            if ($Property.Expression -is [string] -or $Property.Expression -is [scriptblock]) {
                $Property.Clone()
            } else {
                throw [ArgumentException]::new("The expression of the argument `"Property`" is neither a string nor a scriptblock. Provide a valid value for the argument, and then try running the command again.")
            }
        } else {
            throw [ArgumentException]::new("The argument `"Property`" is neither a string, a scriptblock nor a hashtable. Provide a valid value for the argument, and then try running the command again.")
        }
        if ($Name -and (!$result.Name -or $Force)) {
            $result.Name = $Name
        }
        if ($Format -and (!$result.FormatString -or $Force)) {
            $result.FormatString = $Format
        }
        if ($Width -and (!$result.Width -or $Force)) {
            $result.Width = $Width
        }
        if ($Alignment -and (!$result.Alignment -or $Force)) {
            $result.Alignment = $Alignment
        }
        $result
    }
}

function ConvertTo-Enum {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [type] $Type,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [object] $Property
    )
    process {
        $result = $Property | New-Property
        # Creating a new scope as a workaround for a PowerShell bug related to GetNewClosure().
        # See https://stackoverflow.com/a/24766059
        $result.Expression = & {
            $type = $Type
            if ($result.Expression -is [scriptblock]) {
                $expression = $result.Expression
                { [enum]::ToObject($type, ($_ | ForEach-Object $expression)) }.GetNewClosure()
            } else {
                $property = $result.Expression
                { [enum]::ToObject($type, $_.$property) }.GetNewClosure()
            }
        }
        $result
    }
}

function ConvertTo-Unit {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("KB", "MB", "GB")]
        [string] $Unit,
        [ValidateSet("KB", "MB", "GB")]
        [string] $From,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [object] $Property
    )
    process {
        $result = $Property | New-Property -Format "N1"
        $name = if ($result.Name) { $result.Name } else { $result.Expression }
        # Creating a new scope as a workaround for a PowerShell bug related to GetNewClosure().
        # See https://stackoverflow.com/a/24766059
        $result.Expression = & {
            $divisor = Invoke-Expression "1$Unit / 1$From"
            if ($result.Expression -is [scriptblock]) {
                $expression = $result.Expression
                { ($_ | ForEach-Object $expression) / $divisor }.GetNewClosure()
            } else {
                $property = $result.Expression
                { $_.$property / $divisor }.GetNewClosure()
            }
        }
        $result | New-Property -Name "$name ($Unit)" -Force
    }
}

Export-ModuleMember -Function @(
    "New-Property"
    "ConvertTo-Enum"
    "ConvertTo-Unit"
)
