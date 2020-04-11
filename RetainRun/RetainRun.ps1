[CmdletBinding(PositionalBinding=$false)]
[OutputType([void])]
param()

Trace-VstsEnteringInvocation $MyInvocation
try {
    $debugOnly = Get-VstsInput -Name "debugOnly" -AsBool

    $debug = Get-VstsTaskVariable -Name "System.Debug" -AsBool
    if (!$debugOnly -or ($debugOnly -and $debug)) {
        $collectionUri = Get-VstsTaskVariable -Name "System.TeamFoundationCollectionUri" -Require
        $project       = Get-VstsTaskVariable -Name "System.TeamProject" -Require
        $accessToken   = Get-VstsTaskVariable -Name "System.AccessToken" -Require
        $definitionId  = Get-VstsTaskVariable -Name "System.DefinitionId" -Require
        $buildId       = Get-VstsTaskVariable -Name "Build.BuildId" -Require

        $uri = "$collectionUri$project/_apis/build/retention/leases?api-version=6.0-preview.1"
        Write-Verbose "Azure DevOps uri: $uri"
        $headers = @{ Authorization = "Basic {0}" -f [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("RetainRun:$accessToken")) }
        # $headers = @{ Authorization = "Bearer $accessToken" }
        $parameters = @{
            definitionId = $definitionId
            runId        = $buildId
            ownerId      = "Retain Run Task"
        }

        Write-Output "Checking retention leases on run #$buildId of pipeline #$definitionId..."
        $leases = Invoke-RestMethod -Uri $uri -Method Get -UseBasicParsing -Headers $headers -Body $parameters -ContentType "application/json"
        "Leases: {0}" -f $leases.count | Write-Verbose
        $leases.value | ForEach-Object { "  $_" } | Write-Verbose

        if ($leases.count) {
            Write-Warning "Pipeline run already retained."
        } else {
            Write-Output "Retaining run..."
            $body = $parameters + @{ daysValid = 365000 } | ConvertTo-Json -Compress
            Invoke-RestMethod -Uri $uri -Method Post -UseBasicParsing -Headers $headers -Body "[$body]" -ContentType "application/json" | Out-Null
        }
    }
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}