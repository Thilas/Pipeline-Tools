# Structure

## Tasks

Tasks are declared in `vss-extension.json` file and held in dedicated directories. They have the following structure:

* `task.json` describes the task,
* `build.json` declares the task's [dependencies](Dependencies.md),
* `Tests` holds the task's unit tests,
* `README.md` documents the task.

Existing tasks or [Microsoft tasks](https://github.com/Microsoft/vsts-tasks) can be used as examples.

Microsoft provides a convenient [SDK](https://github.com/Microsoft/vsts-task-lib) that must be used as much as possible.

## Common

Powershell modules are held in dedicated subdirectories of this directory and can easily be used from any tasks thanks to [`common` dependencies](Dependencies.md#Common). They have the following structure:

* `Tests` holds the module's unit tests,
* `README.md` documents the module.

## Tests

This directory provides:

* `Initialize-Tests.ps1` is a bootstrapper for all tests,
* `Integration-Tests.ps1` contains integration tests of all tasks.

All Powershell tests relies on [Pester](https://github.com/pester/Pester). Read the [documentation](https://github.com/pester/Pester/wiki) to learn about it.

### Example

``` powershell
. "$PSScriptRoot/../../Tests/Initialize-Tests.ps1" $MyInvocation

Describe "System Under Test" {
    It "succeeds when doing something" {
        # Arrange
        Mock "Some-Function" -ParameterFilter { $Arg -eq $SomeValue } { $ExpectedValue } -Verifiable
        # Act
        $actualValue = Function-UnderTest $SomeValue
        # Assert
        $actualValue | Shoud Be $ExpectedValue
        Assert-VerifiableMock
    }
}
```
