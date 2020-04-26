. "$PSScriptRoot/Initialize-Tests.ps1"

Describe "Integration Tests" {
    BeforeEach {
        Write-Verbose "Backing up current environment variables..."
        $Script:environmentVariables = Backup-EnvironmentVariables
    }

    AfterEach {
        Write-Verbose "Restoring initial environment variables..."
        Restore-EnvironmentVariables $Script:environmentVariables
    }

    # Throw an error if a task fails
    Mock "Write-Host" -ParameterFilter { $Object -eq "##vso[task.complete result=Failed]" } { throw "Task has failed." }

    Context "List Apps Task" {
        It "lists apps when debugOnly is true and system.debug is true" {
            # Assert
            $Env:INPUT_DEBUGONLY = "true"
            $Env:SYSTEM_DEBUG    = "true"
            # Act
            Invoke-VstsTaskScript { . "$PSScriptRoot/../ListApps/ListApps.ps1" }
        }
    }

    Context "List Files Task" {
        # Arrange
        New-Item "$TestDrive/File.ext" -ItemType File | Out-Null
        New-Item "$TestDrive/Directory" -ItemType Directory | Out-Null

        It "lists files in system.defaultWorkingDirectory when rootDir is null, debugOnly is true and system.debug is true" {
            # Arrange
            $Env:INPUT_ROOTDIR                  = " " # It is not possible to create an empty environment variable
            $Env:INPUT_DEBUGONLY                = "true"
            $Env:SYSTEM_DEFAULTWORKINGDIRECTORY = $TestDrive
            $Env:SYSTEM_DEBUG                   = "true"
            # Act
            Invoke-VstsTaskScript { . "$PSScriptRoot/../ListFiles/ListFiles.ps1" }
        }

        It "lists files in rootDir when rootDir is not null and debugOnly is false" {
            # Arrange
            $Env:INPUT_ROOTDIR   = $TestDrive
            $Env:INPUT_DEBUGONLY = "false"
            # Act
            Invoke-VstsTaskScript { . "$PSScriptRoot/../ListFiles/ListFiles.ps1" }
        }
    }

    Context "List System Info Task" {
        It "lists system info when debugOnly is true and system.debug is true" {
            # Assert
            $Env:INPUT_DEBUGONLY = "true"
            $Env:SYSTEM_DEBUG    = "true"
            # Act
            Invoke-VstsTaskScript { . "$PSScriptRoot/../ListSystemInfo/ListSystemInfo.ps1" }
        }
    }

    Context "List Variables Task" {
        It "lists variables when debugOnly is true and system.debug is true" {
            # Assert
            $Env:INPUT_DEBUGONLY = "true"
            $Env:SYSTEM_DEBUG    = "true"
            # Act
            Invoke-VstsTaskScript { . "$PSScriptRoot/../ListVariables/ListVariables.ps1" }
        }
    }

    Context "Retain Run Task" {
        It "retains the run when debugOnly is true and system.debug is true" {
            # Assert
            $Env:INPUT_DEBUGONLY                    = "true"
            $Env:SYSTEM_DEBUG                       = "true"
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
            Invoke-VstsTaskScript { . "$PSScriptRoot/../RetainRun/RetainRun.ps1" }
            # Assert
            Assert-MockCalled "Invoke-RestMethod" -Times 2 -Scope It -Exactly
        }

        It "warns when the run is already retained" {
            # Arrange
            $Env:INPUT_DEBUGONLY                    = "false"
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
            Invoke-VstsTaskScript { . "$PSScriptRoot/../RetainRun/RetainRun.ps1" }
            # Assert
            Assert-VerifiableMock
        }
    }
}
