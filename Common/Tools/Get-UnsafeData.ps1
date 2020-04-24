function Get-UnsafeData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string] $Name,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [scriptblock[]] $Source,
        [hashtable] $Profiling
    )
    begin {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    }
    process {
        $Source | ForEach-Object {
            try {
                & $_
            } catch {
                Write-Verbose "$Name error: $_"
            }
        }
    }
    end {
        $stopwatch.Stop()
        "$Name elapsed: {0}" -f $stopwatch.Elapsed | Write-Verbose
        if ($Profiling) {
            $Profiling.$Name = $stopwatch.Elapsed
        }
    }
}

Export-ModuleMember -Function @(
    "Get-UnsafeData"
)
