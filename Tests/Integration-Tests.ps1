. "$PSScriptRoot\Initialize-Tests.ps1"

Describe "Integration-Tests" {
    BeforeEach {
        Write-Verbose "Backing up current environment variables..."
        $Script:environmentVariables = Backup-EnvironmentVariables

        # Set test environment variables
        $Env:SYSTEM_DEBUG                   = "true"
        $Env:SYSTEM_DEFAULTWORKINGDIRECTORY = $TestDrive
    }

    AfterEach {
        Write-Verbose "Restoring initial environment variables..."
        Restore-EnvironmentVariables $Script:environmentVariables
    }

    # Throw an error if a task fails
    Mock "Write-Host" -ParameterFilter { $Object -eq "##vso[task.complete result=Failed]" } { throw "Task has failed." }

    It "writes comments when includeCommentsInLog is true" {
        # Arrange
        $Env:INPUT_COMMENTS             = "Some multiline`ncomments..."
        $Env:INPUT_INCLUDECOMMENTSINLOG = "true"
        # Act
        Invoke-VstsTaskScript -ScriptBlock { . "$PSScriptRoot\..\Comment\Comment.ps1" }
    }

    It "lists apps when debugOnly is false" {
        # Act
        Invoke-VstsTaskScript -ScriptBlock { . "$PSScriptRoot\..\ListApps\ListApps.ps1" }
    }

    It "lists files in System.DefaultWorkingDirectory when rootDir is null and debugOnly is false" {
        # Arrange
        New-Item "$TestDrive/File.ext" -ItemType File | Out-Null
        New-Item "$TestDrive/Directory" -ItemType Directory | Out-Null
        # Act
        Invoke-VstsTaskScript -ScriptBlock { . "$PSScriptRoot\..\ListFiles\ListFiles.ps1" }
    }

    It "lists system info when debugOnly is false" {
        # Act
        Invoke-VstsTaskScript -ScriptBlock { . "$PSScriptRoot\..\ListSystemInfo\ListSystemInfo.ps1" }
    }

    It "lists variables when debugOnly is false" {
        # Act
        Invoke-VstsTaskScript -ScriptBlock { . "$PSScriptRoot\..\ListVariables\ListVariables.ps1" }
    }

    It "retains the run when debugOnly is false" {
        # Arrange
        $Env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI = "https://dev.azure.com/organization/"
        $Env:SYSTEM_TEAMPROJECT                 = "Project"
        $Env:SYSTEM_ACCESSTOKEN                 = "Token"
        $Env:SYSTEM_DEFINITIONID                = "1"
        $Env:BUILD_BUILDID                      = "2"
        Mock "Invoke-RestMethod" -ParameterFilter {
            $Uri -like "$Env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI*" -and $Method -in "Get", "Post" -and `
            $UseBasicParsing -and $Headers -and $Body -and $ContentType -eq "application/json"
        }
        # Act
        Invoke-VstsTaskScript -ScriptBlock { . "$PSScriptRoot\..\RetainRun\RetainRun.ps1" }
        # Assert
        Assert-MockCalled "Invoke-RestMethod" -Times 2 -Scope It -Exactly
    }

    It "warns when the run is already retained" {
        # Arrange
        $Env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI = "https://dev.azure.com/organization/"
        $Env:SYSTEM_TEAMPROJECT                 = "Project"
        $Env:SYSTEM_ACCESSTOKEN                 = "Token"
        $Env:SYSTEM_DEFINITIONID                = "1"
        $Env:BUILD_BUILDID                      = "2"
        Mock "Invoke-RestMethod" -ParameterFilter {
            $Uri -like "$Env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI*" -and $Method -in "Get", "Post" -and `
            $UseBasicParsing -and $Headers -and $Body -and $ContentType -eq "application/json"
        } { @{ count = 1 }} -Verifiable
        Mock "Write-Warning" -Verifiable
        # Act
        Invoke-VstsTaskScript -ScriptBlock { . "$PSScriptRoot\..\RetainRun\RetainRun.ps1" }
        # Assert
        Assert-VerifiableMock
    }
}
