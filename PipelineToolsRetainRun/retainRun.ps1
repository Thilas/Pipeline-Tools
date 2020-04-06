[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

[string] $debugOnly = $Env:INPUT_DEBUGONLY

if ($Env:SYSTEM_DEBUG -eq "true") {
    Write-Output "##vso[task.debug]Entering: retainRun.ps1"
    Write-Output "##vso[task.debug]  debugOnly: $debugOnly"
}

if ($debugOnly -ne "true" -or ($debugOnly -eq "true" -and $Env:SYSTEM_DEBUG -eq "true")) {
    $uri = "$Env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI$Env:SYSTEM_TEAMPROJECT/_apis/build/retention/leases?api-version=6.0-preview.1"
    if ($Env:SYSTEM_DEBUG -eq "true") {
        Write-Output "##vso[task.debug]Azure DevOps uri: $uri"
    }
    $headers = @{ Authorization = "Basic {0}" -f [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("None:$Env:SYSTEM_ACCESSTOKEN")) }
    # $headers = @{ Authorization = "Bearer $Env:SYSTEM_ACCESSTOKEN" }
    $parameters = @{
        definitionId = $Env:SYSTEM_DEFINITIONID
        runId = $Env:BUILD_BUILDID
        ownerId = "Pipeline-Tools Retain Run Task"
    }

    Write-Output "Checking retention leases on run #$Env:BUILD_BUILDID of pipeline #$Env:SYSTEM_DEFINITIONID..."
    $leases = Invoke-RestMethod -Uri $uri -Method Get -UseBasicParsing -Headers $headers -Body $parameters -ContentType "application/json"
    if ($Env:SYSTEM_DEBUG -eq "true") {
        "##vso[task.debug]Leases: {0}" -f $leases.count | Write-Output
        $leases.value | ForEach-Object {
            "##vso[task.debug]  {0}" -f ($_ -replace ";", "%3B" -replace "`r", "%0D" -replace "`n", "%0A" -replace "]", "%5D") | Write-Output
        }
    }

    if ($leases.count) {
        Write-Output "##vso[task.logissue type=warning]Run already retained"
    } else {
        Write-Output "Retaining run..."
        $body = $parameters + @{ daysValid = 365000 } | ConvertTo-Json -Compress
        Invoke-RestMethod -Uri $uri -Method Post -UseBasicParsing -Headers $headers -Body "[$body]" -ContentType "application/json" | Out-Null
    }
}
