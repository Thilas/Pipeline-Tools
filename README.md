# Pipeline Tools Extension

This extension provides several pipeline tasks that can help you diagnose your Windows-based pipelines as well as control the retention of completed runs. The tasks are also useful for keeping a running history of environment variables, files and installed apps on your Azure Pipelines agents.

This extension is a fork of [VSTS-Tools Build Extensions](https://marketplace.visualstudio.com/items?itemName=moonspace-labs-llc.vsts-tools-build-extensions) and started fixing warnings in the original tasks.

[![Build Status](https://dev.azure.com/totodem/Pipeline-Tools/_apis/build/status/Pipeline-Tools?branchName=master&label=build)](https://dev.azure.com/totodem/Pipeline-Tools/_build/latest?definitionId=10&branchName=master) [![Test Status](https://dev.azure.com/totodem/Pipeline-Tools/_apis/build/status/Pipeline%20Tools%20Test?branchName=master&label=test)](https://dev.azure.com/totodem/Pipeline-Tools/_build/latest?definitionId=11&branchName=master)

## List Apps Task

This task provides you with a list of all applications installed on the Azure Pipelines agent at the time the pipeline is executed. This task is especially useful on self-hosted agents where you do not have direct access to the file system.

There is one parameter that can be set with this task:

* Execute on Debug Only - if checked, the task will execute only if **system.debug** is set to **true**.

![List Apps task](https://github.com/Thilas/Pipeline-Tools/blob/master/Resources/ListApps.png?raw=true)

## List Files Task

This task will list out (in the log) all files beneath the directory specified as the *Root Directory*. This task can be especially useful on self-hosted agents where you do not have direct access to the file system.

There are two parameters that can be set with this task:

* Root Directory - all files and directories beneath the root directory will be listed (recursively).
* Execute on Debug Only - if checked, the task will execute only if **system.debug** is set to **true**.

![List Files task](https://github.com/Thilas/Pipeline-Tools/blob/master/Resources/ListFiles.png?raw=true)

## List System Info Task

This task will list out (in the log) various system-related information and settings. This task can be especially useful on self-hosted agents where you do not have direct access to the server.

There is one parameter that can be set with this task:

* Execute on Debug Only - if checked, the task will execute only if **system.debug** is set to **true**.

![List System Info task](https://github.com/Thilas/Pipeline-Tools/blob/master/Resources/ListSystemInfo.png?raw=true)

## List Variables Task

This task will list out (in the log) all variables that are defined at the time it is executed. This task can be especially useful on self-hosted agents where you do not have direct access to the file system.

There is one parameter that can be set with this task:

* Execute on Debug Only - if checked, the task will execute only if **system.debug** is set to **true**.

![List Variables task](https://github.com/Thilas/Pipeline-Tools/blob/master/Resources/ListVariables.png?raw=true)

## Retain Run Task

This task allows you to retain a run. This is especially handy if you are making use of a 3rd party release tool (e.g. Octopus Deploy) or a custom release process and you want to set the retention after completing the deployment-related pipeline tasks.

There are two parameters that can be set with this task:

* Execute on Debug Only - if checked, the task will execute only if **system.debug** is set to **true**.

> **IMPORTANT:** If you are not using a YAML pipeline, before you can make use of the *Retain Run* task, you must first configure your pipeline to allow the use of the OAuth token. To do this, go to the **Options** tab of the pipeline definition and select **Allow Scripts to Access OAuth Token**.

![OAuth token](https://github.com/Thilas/Pipeline-Tools/blob/master/Resources/OAuth.png?raw=true)

## Release Notes

| Release | Description                                   |
| -------:| --------------------------------------------- |
| 1.x     | VSTS-Tools Build Extensions original releases |
| 2.2     | Pipeline Tools first release                  |
| 2.3     | Minor improvements                            |

## Feedback, Support and Contribution

If you like this set of tasks, please leave a review and rating. If you have any suggestions and/or problems, please [file an issue so I can get it resolved](https://github.com/Thilas/Pipeline-Tools/issues). Any contribution is most welcome.
