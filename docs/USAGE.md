## Usage

```sh
Usage: variants <command> [options]

A command-line tool to setup deployment variants and working CI/CD setup

Commands:
  init            Generate specs file - variants.yml
  setup           Setup deployment variants (alongside Fastlane)
  switch          Switch variants
  help            Prints help information
  version         Prints the current version of this app
```

### List of commands

* [1. Initialize](#initialize)
    * [Variants Spec](#variants-spec)
    * [Custom configuration](#custom-configuration)
    * [Signing configuration (iOS only)](#signing-configuration)
* [2. Setup](#setup-multiple-build-variants-with-full-fastlane-integration)
* [3. Switch](#switch-variants)

### Initialize

Before running setup to create your deployment variants and Fastlane setup you need a YAML configuration file.
Run `variants init` in the base folder of your project.

```sh
OVERVIEW: Generate spec file - variants.yml

USAGE: variants init [--platform <platform>] [--timestamps] [--verbose]

OPTIONS:
  -p, --platform <platform>
                          'ios' or 'android'
  -t, --timestamps        Show timestamps.
  -v, --verbose           Log tech details for nerds
  --version               Show the version.
  -h, --help              Show help information.
```

Examples
```sh
# Automatically detect platform
$ variants init

# Specify platform (in case there are projects for different platforms in the working directory, this will be mandatory)
$ variants init --platform ios
```
It will generate a variants.yml file in the base folder of your project

<p align="center">
<img src="../Assets/Examples/Project_Example_Step_2.png" title="variants.yml">
</p>

> NOTE: Edit the file variants.yml accordingly.

#### Variants Spec
Your `variants.yml` spec will contain all the necessary fields. The information within `xcodeproj` and `targets` sections are populated automatically if a `.xcodeproj` is found in your working directory - otherwise, you'll be asked to update the placeholders in this file. It comes with one variant named `default`, which will be used whenever a variant isn't specified. You can then include custom variants, for which the following settings are required:
* `name`
* `version_name`
* `version_number`

```yaml
ios:
    xcodeproj: SampleProject.xcodeproj
    targets:
      SampleProject:
        name: SampleApp
        bundle_id: com.sample.app
        test_target: SampleProjectTests
        app_icon: AppIcon
        source:
          path: Sources
          info: Sources/Info.plist
          # Path to folder that will serve as parent to folder Variants/
          config: Sources
    variants:
      # Default variant is mandatory, do not remove
      default:
        version_name: 0.0.1
        version_number: 1
        store_destination: AppStore
        custom:
            - name: apiBaseUrl
              value: https://sample.com/
              destination: project
      BETA:
        id_suffix: beta
        app_icon: AppIcon.beta
        version_name: 0.0.1
        version_number: 13
        store_destination: TestFlight
        custom:
            - name: apiBaseUrl
              value: https://sample-beta.com/
              destination: project
            - key:  OTHER_SWIFT_FLAGS
              value: $(inherited) -DBETA
              destination: project
```

#### Custom configuration

Configuration through custom properties can bring a lot of value to your variants, such as defining different API base URLs, or credentials using environment variables. This allows us to also define its destination. Certain properties should not be available to the project but to fastlane and vice-versa.

See our [Custom Property documentation](CUSTOM_PROPERTY.md) for a better understanding and examples.

#### Signing configuration

Code signing for iOS apps can also be handled through `variants.yml` as long as Fastlane Match is used.
For more information see [Working with Fastlane Match](ios/WORKING_WITH_FASTLANE_MATCH.md).

### Setup multiple build variants with full fastlane integration

#### Using default spec file (variants.yml)

```sh
OVERVIEW: Setup deployment variants (alongside Fastlane)

USAGE: variants setup [--platform <platform>] [--spec <spec>] [--skip-fastlane] [--timestamps] [--verbose]

OPTIONS:
  -p, --platform <platform>
                          'ios' or 'android'
  -s, --spec <spec>       Use a different yaml configuration spec (default: variants.yml)
  --skip-fastlane
  -t, --timestamps        Show timestamps.
  -v, --verbose           Log tech details for nerds
  --version               Show the version.
  -h, --help              Show help information.
```

Examples
```sh
# Automatically detect platform
$ variants setup

# Specify platform (in case there are projects for different platforms in the working directory, this will be mandatory)
$ variants setup --platform ios
```

This will generate your `Variants/` folder, containing `variants.xcconfig` and `Variants.swift`. You won't have to do anything with these files.
`Variants.swift` is an extension in case you need any of the variant's configuration in your codebase:
```swift
let baseUrl = Variants.configuration["apiBaseURL"]
```

Setup will also configure your Xcode project to use this new configuration and map configs (such as `name`, `bundle_id`, `app_icon`, `version_name` and `version_number`).

<p align="center">
<img src="../Assets/Examples/Project_Example_Step_3.png" title="Setup completed">
</p>

#### Using a spec file other than the default one

You might not always have `variants.yml`  in the base folder of your project or have it with a completely different name, for this reason you can specify its path as an option

```sh
variants setup -s (or --spec) <yml spec path>

variants setup -s ~/johndoe/custom/path/variants.yml
```

> NOTE: *variants setup* will automatically assign the `default` variant configuration to the project

### Switch variants

In order to switch between project variants you don't need to modify the Xcode project nor the `variants.xcconfig`, just make use of one command

```sh
OVERVIEW: Switch variants

USAGE: variants switch [--variant <variant>] [--platform <platform>] [--spec <spec>] [--timestamps] [--verbose]

OPTIONS:
  --variant <variant>     Desired variant (default: default)
  -p, --platform <platform>
                          'ios' or 'android'
  -s, --spec <spec>       Use a different yaml configuration spec (default: variants.yml)
  -t, --timestamps        Show timestamps.
  -v, --verbose           Log tech details for nerds
  --version               Show the version.
  -h, --help              Show help information.
```

Examples
```sh
# Automatically detect platform
$ variants switch --variant beta

# Specify platform (in case there are projects for different platforms in the working directory, this will be mandatory)
$ variants switch --variant beta --platform ios
```
