# Retain Run Task

This task retains the current run.

This task applies to pipelines only.

## YAML Snippet

``` yaml
- task: RetainRun@1
  displayName: Retain run
  # inputs:
  #   debugOnly: false # Optional
```

## Arguments

| Argument | Description |
| -------- | ----------- |
| Execute on Debug Only | If checked, executes only when `system.debug` is set to `true`. |

[Control options](https://docs.microsoft.com/en-us/vsts/pipelines/process/tasks?view=vsts#controloptions)
