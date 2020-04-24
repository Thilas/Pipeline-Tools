# List System Info Task

This task lists various system information for the Azure Pipelines agent running the pipeline.

## YAML Snippet

``` yaml
- task: ListSystemInfo@1
  displayName: List system information
  # inputs:
  #   debugOnly: false # Optional
```

## Arguments

| Argument | Description |
| -------- | ----------- |
| Execute on Debug Only | If checked, executes only when `system.debug` is set to `true`. |

[Control options](https://docs.microsoft.com/en-us/vsts/pipelines/process/tasks?view=vsts#controloptions)
