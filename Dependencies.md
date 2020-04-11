# Dependencies

Dependencies are described in `build.json` files anywhere in the repository:

``` json
{
  "resources": [{
    "url": "required",
    "destination": ""
  }],
  "common": [{
    "name": "required",
    "destination": ""
  }],
  "nuget": [{
    "name": "required",
    "version": "",
    "source": "required",
    "destination": ""
  }]
}
```

## Resources

`resources` are basic resources that just need to be downloaded:

* `url`: url of the resource,

## Common

`common` are references to Powershell modules held in the [`Common` directory](Structure.md#Common):

* `name`: name of the module.

## NuGet

`nuget` are references to NuGet packages:

* `name`: name of the package,
* `version`: optional version (the latest available by default) of the package,
* `source`: url of the package's source.

For instance, `VstsTaskSdk` is a convenient module that must be used for any Powershell based task. See its [online documentation](https://github.com/Microsoft/vsts-task-lib/blob/master/powershell/Docs/README.md).

## Destination

`destination` properties are optional paths (relative to the current directory) where to install dependencies. They can be specified on any dependency.

## Example

``` json
{
  "common": [{
    "name": "SomeHelper",
    "destination": "ps_modules"
  }],
  "nuget": [{
    "name": "SomePackage",
    "destination": "packages"
  }, {
    "name": "VstsTaskSdk",
    "version": "0.11.0",
    "source": "https://www.powershellgallery.com/api/v2/",
    "destination": "ps_modules"
  }]
}
```
