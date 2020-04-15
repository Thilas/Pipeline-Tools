function ConvertTo-Hashtable {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [string] $KeyProperty,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [object[]] $InputObject
    )
    begin {
        $result = @{ }
    }
    process {
        $InputObject | ForEach-Object {
            $key = $_.$KeyProperty
            $result.$key = $_
        }
    }
    end {
        $result
    }
}

Export-ModuleMember -Function @(
    "ConvertTo-Hashtable"
)
