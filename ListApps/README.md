# List Apps Task

This task lists all applications installed on the Azure Pipelines agent.

## YAML Snippet

``` yaml
- task: ListApps@1
  displayName: List installed applications
  # inputs:
  #   debugOnly: false # Optional
```

## Arguments

| Argument | Description |
| -------- | ----------- |
| Execute on Debug Only | If checked, executes only when `System.Debug` is set to `true`. |

[Control options](https://docs.microsoft.com/en-us/vsts/pipelines/process/tasks?view=vsts#controloptions)
