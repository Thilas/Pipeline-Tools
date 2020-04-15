# Comment Task

This task lets you save a few comments about the pipeline - e.g. why it's setup the way it is, things you should know before running the pipeline, etc.

## YAML Snippet

``` yaml
- task: Comment@1
  displayName: $(comments)
  # inputs:
  #   comments: '' # Optional
  #   includeCommentsInLog: false # Optional
```

## Arguments

| Argument | Description |
| -------- | ----------- |
| Comments | Provide a few comments about the pipeline - e.g. why it's setup the way it is, things you should know before running the pipeline, etc. |
| Include Comments in Log | If checked, the comments will be included in the log file. |

[Control options](https://docs.microsoft.com/en-us/vsts/pipelines/process/tasks?view=vsts#controloptions)
