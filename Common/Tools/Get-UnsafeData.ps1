function Get-UnsafeData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string] $Name,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [scriptblock[]] $Source
    )
    process {
        $Source | ForEach-Object {
            try {
                & $_
            } catch {
                Write-Verbose "$Name error: $_"
            }
        }
    }
}

Export-ModuleMember -Function @(
    "Get-UnsafeData"
)
