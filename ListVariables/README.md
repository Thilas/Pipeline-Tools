# List Variables Task

This task lists all environment variables defined at the time this task is ran.

## YAML Snippet

``` yaml
- task: ListVariables@1
  displayName: List variables
  # inputs:
  #   debugOnly: false # Optional
```

## Arguments

| Argument | Description |
| -------- | ----------- |
| Execute on Debug Only | If checked, executes only when `system.debug` is set to `true`. |

[Control options](https://docs.microsoft.com/en-us/vsts/pipelines/process/tasks?view=vsts#controloptions)
