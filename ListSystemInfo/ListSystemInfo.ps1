[CmdletBinding(PositionalBinding=$false)]
[OutputType([void])]
param()

Trace-VstsEnteringInvocation $MyInvocation
try {
    $debugOnly = Get-VstsInput -Name "debugOnly" -AsBool

    if ($debugOnly) {
        $debug = Get-VstsTaskVariable -Name "system.debug" -AsBool
    }

    if (!$debugOnly -or ($debugOnly -and $debug)) {
        Import-Module "$PSScriptRoot/ps_modules/Tools" -NoClobber

        Set-HostBufferSize -Width 300

        $profiling = @{ }
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

        $session = New-CimSession

        & "$PSScriptRoot/SystemInfo.ps1" `
        | ForEach-Object {
            # Gather all required properties
            $properties = @()
            if ($_.Properties) {
                $properties += $_.Properties `
                | ForEach-Object {
                    if ($_ -is [string]) {
                        $_
                    } elseif ($_.Expression -is [string]) {
                        $_.Expression
                    } elseif ($_.Expression -is [scriptblock] -and $_.Expression.Module) {
                        & $_.Expression.Module Get-Variable "property" -ValueOnly -Scope Local -ErrorAction SilentlyContinue
                    }
                } | Where-Object { $_ }
            }
            if ($_.Key)   { $properties += $_.Key }
            if ($_.Sort)  { $properties += $_.Sort }
            if ($_.Extra) { $properties += $_.Extra }

            # Build Get-CimInstance parameters
            $parameters = @{
                ClassName = $_.ClassName
                Property  = $properties | Select-Object -Unique
            }
            if ($_.Namespace) { $parameters.Namespace = $_.Namespace }
            if ($_.Filter) { $parameters.Filter = $_.Filter }

            # Call Get-CimInstance
            $data = { Get-CimInstance @parameters -CimSession $session -OperationTimeoutSec 5 } `
            | Get-UnsafeData $_.Name -Profiling $profiling

            # Sort data
            if ($_.Sort) {
                $parameters = @{ Property = $_.Sort }
                if ($_.Descending) { $parameters.Descending = $true }
                $data = $data | Sort-Object @parameters
            }

            # Format data
            if ($_.Format -eq "List") {
                $data | Format-List $_.Properties
            } elseif ($_.Format -eq "Table") {
                $data | Format-Table $_.Properties -AutoSize -Wrap
            }

            # Convert data to hashtable
            if ($_.Hashtable -and $_.Key) {
                $data `
                | ConvertTo-Hashtable $_.Key `
                | Set-Variable -Name $_.Hashtable
            }
        }

        $stopwatch.Stop()
        "Total elapsed: {0}" -f $stopwatch.Elapsed | Write-Verbose
        $profiling.GetEnumerator() `
        | Sort-Object "Value" -Descending `
        | Format-Table @(
            "Key"   | New-Property -Name "Profiling"
            New-Property { $_.Value / $stopwatch.Elapsed } -Name "%" -Format "P0"
            "Value" | New-Property -Name "Elapsed"
        ) -AutoSize -Wrap `
        | Out-String -Stream `
        | Write-Verbose
    }
} finally {
    if ($session) { Remove-CimSession $session }
    Trace-VstsLeavingInvocation $MyInvocation
}
