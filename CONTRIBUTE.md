# Pipeline Tools Extension

Any contributions are welcome. You can do so by submitting a pull request.

## Structure

This repository follows some guidelines regarding its [structure](Structure.md).

## Build

Build mainly consists in getting [dependencies](Dependencies.md). You can build all tasks with the following command:

``` powershell
build.ps1
```

Available options:

* `-Build` or `-Rebuild` builds (by default) or rebuilds all tasks,
* `-UnitTests` runs unit tests,
* `-IntegrationTests` runs integration tests,
* `-CodeCoverage` generates code coverage reports for each test suite (unit/integration tests),
* `-Clear` prepares the repository for publication.

## Test

Tests for each task are located in a [`Tests` directory](Structure.md#Tests). You can run them with the following command:

``` powershell
test.ps1
```

If you run the command from the directory of a specific task, only its tests will be run:

``` powershell
cd "InstallEnablonInstance"
../test.ps1
```

Available options:

* `-Integration` runs integration tests instead of default unit tests,
* `-TestName`  filters `Describe` blocks that match the provided name (wildcards are supported),
* `-Tag` filters `Describe` blocks based on their `Tag` parameters (wildcards are not supported),
* `-CodeCoverage` generates a code coverage report,
* `-EnableExit` exits with an exit code equal to the number of failed tests once all tests have been run.
