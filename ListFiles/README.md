# List Files Task

This task recursively lists all files and directories beneath the specified directory.

## YAML Snippet

``` yaml
- task: ListFiles@1
  displayName: List files in $(rootDir)
  # inputs:
  #   rootDir: $(system.defaultWorkingDirectory) # Optional
  #   debugOnly: false # Optional
```

## Arguments

| Argument | Description |
| -------- | ----------- |
| Root Directory | The root directory to list files and directories under when this task is ran. |
| Execute on Debug Only | If checked, executes only when `system.debug` is set to `true`. |

[Control options](https://docs.microsoft.com/en-us/vsts/pipelines/process/tasks?view=vsts#controloptions)
