<!-- omit in toc -->
# Pipeline Tools Extension

This extension provides several pipeline tasks that can help you diagnose your Windows-based pipelines as well as control the retention of completed runs. The tasks are also useful for keeping a running history of environment variables, files and installed apps on your Azure Pipelines agents.

This extension is a fork of [VSTS-Tools Build Extensions](https://marketplace.visualstudio.com/items?itemName=moonspace-labs-llc.vsts-tools-build-extensions) and started fixing warnings in the original tasks.

[![Build Status](https://dev.azure.com/totodem/Pipeline-Tools/_apis/build/status/Pipeline-Tools?branchName=master&label=build)](https://dev.azure.com/totodem/Pipeline-Tools/_build/latest?definitionId=10&branchName=master)
[![Test Status](https://dev.azure.com/totodem/Pipeline-Tools/_apis/build/status/Pipeline%20Tools%20Test?branchName=master&label=test)](https://dev.azure.com/totodem/Pipeline-Tools/_build/latest?definitionId=11&branchName=master)

Available tasks:

- [List Apps Task](#list-apps-task)
- [List Files Task](#list-files-task)
- [List System Info Task](#list-system-info-task)
- [List Variables Task](#list-variables-task)
- [Retain Run Task](#retain-run-task)

## List Apps Task

This task provides you with a list of all applications installed on the Azure Pipelines agent at the time the pipeline is executed. This task is especially useful on self-hosted agents where you do not have direct access to the file system.

There is one parameter that can be set with this task:

- Execute on Debug Only - if checked, the task will execute only if **system.debug** is set to **true**.

**Sample**

``` ini
Application                                              Version         Size (MB)
-----------                                              -------         ---------
7-Zip 19.00 (x64)                                        19.00                 5.0
Active Directory Authentication Library for SQL Server   15.0.1300.359         3.2
Application Verifier x64 External Package                10.1.18362.1          7.1
AWS Command Line Interface v2                            2.0.7.0              78.1
Azure Cosmos DB Emulator                                 2.9.2               792.9
CMake                                                    3.17.1               94.3
Git version 2.26.1                                       2.26.1              250.3
Google Chrome                                            81.0.4044.113         0.0
# ...
```

## List Files Task

This task will list out (in the log) all files beneath the directory specified as the *Root Directory*. This task can be especially useful on self-hosted agents where you do not have direct access to the file system.

There are two parameters that can be set with this task:

- Root Directory - all files and directories beneath the root directory will be listed (recursively).
- Execute on Debug Only - if checked, the task will execute only if **system.debug** is set to **true**.

**Sample**

``` ini
Path                                                Size (KB)
----                                                ---------
C:\Sources\Pipeline-Tools\.editorconfig                   0.6
C:\Sources\Pipeline-Tools\.gitattributes                  0.5
C:\Sources\Pipeline-Tools\.gitignore                      0.1
C:\Sources\Pipeline-Tools\.vscode\
C:\Sources\Pipeline-Tools\.vscode\launch.json             1.3
C:\Sources\Pipeline-Tools\.vscode\settings.json           1.0
C:\Sources\Pipeline-Tools\_build\
C:\Sources\Pipeline-Tools\_build\nuget.exe            6,359.4
C:\Sources\Pipeline-Tools\_build\packages\
# ...
```

## List System Info Task

This task will list out (in the log) various system-related information and settings. This task can be especially useful on self-hosted agents where you do not have direct access to the server.

There is one parameter that can be set with this task:

- Execute on Debug Only - if checked, the task will execute only if **system.debug** is set to **true**.

**Sample**

``` ini
Computer     : Virtual Machine
Manufacturer : Microsoft Corporation
# ...
Processor                                       Cores   Threads   Virtualization
---------                                       -----   -------   --------------
Intel(R) Xeon(R) Platinum 8171M CPU @ 2.60GHz       2         4            False
# ...
Disk         RPM   Bus   Size (GB)   Allocated (GB)    Status
----         ---   ---   ---------   --------------    ------
Virtual HD     0   ATA       270.0            270.0   Healthy
# ...
Video Controller          RAM (GB)   Resolution   Color Depth
----------------          --------   ----------   -----------
Microsoft Hyper-V Video        0.0   1024 x 768            32
# ...
Operating System           : Microsoft Windows Server 2019 Datacenter
Culture                    : en-US
Total Physical Memory (GB) : 7.0
Free Physical Memory (GB)  : 5.4
# ...
Name Volume  File System Compressed Size (GB) Free (GB)
---- ------  ----------- ---------- --------- ---------
C:   Windows NTFS        False          255.5     120.0
```

## List Variables Task

This task will list out (in the log) all variables that are defined at the time it is executed. This task can be especially useful on self-hosted agents where you do not have direct access to the file system.

There is one parameter that can be set with this task:

- Execute on Debug Only - if checked, the task will execute only if **system.debug** is set to **true**.

**Sample**

``` ini
Variable                         Value
--------                         -----
AGENT_BUILDDIRECTORY             D:\a\1
AGENT_ID                         78
AGENT_JOBSTATUS                  Succeeded
AGENT_MACHINENAME                WIN-KJA10851F8D
AGENT_NAME                       Hosted Agent
AGENT_OS                         Windows_NT
AGENT_OSARCHITECTURE             X64
AGENT_ROOTDIRECTORY              D:\a
AGENT_TEMPDIRECTORY              D:\a\_temp
AGENT_VERSION                    2.166.4
AGENT_WORKFOLDER                 D:\a
BUILD_ARTIFACTSTAGINGDIRECTORY   D:\a\1\a
BUILD_BINARIESDIRECTORY          D:\a\1\b
BUILD_BUILDID                    655
BUILD_BUILDNUMBER                2.6.0
# ...
```

## Retain Run Task

This task allows you to retain a run. This is especially handy if you are making use of a 3rd party release tool (e.g. Octopus Deploy) or a custom release process and you want to set the retention after completing the deployment-related pipeline tasks.

There are two parameters that can be set with this task:

- Execute on Debug Only - if checked, the task will execute only if **system.debug** is set to **true**.

> **IMPORTANT:** If you are not using a YAML pipeline, before you can make use of the *Retain Run* task, you must first configure your pipeline to allow the use of the OAuth token. To do this, go to the **Additional options** section of the job definition and select **Allow scripts to access the OAuth token**.

<!-- omit in toc -->
## Release Notes

| Release | Description                                   |
|:-------:| --------------------------------------------- |
| 1.x     | VSTS-Tools Build Extensions original releases |
| 2.x     | Pipeline Tools release                        |

See [detailed release notes](https://github.com/Thilas/Pipeline-Tools/releases).

<!-- omit in toc -->
## Feedback, Support and Contribution

If you like this set of tasks, please leave a review and rating. If you have any suggestions and/or problems, please [file an issue so I can get it resolved](https://github.com/Thilas/Pipeline-Tools/issues). Any contribution is most welcome.

Icons made by [phatplus](https://www.flaticon.com/authors/phatplus) and [Freepik](https://www.flaticon.com/authors/freepik) from [www.flaticon.com](https://www.flaticon.com/)
