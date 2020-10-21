<p align="center">
<img src="Assets/Examples/variants_logo.svg" title="variants">
</p>

## Variants

A command line tool to setup deployment variants and full CI/CD pipelines for mobile projects.

## Features

- ✅ Setup your mobile project to have multiple variants of the same application.
    - ➡️ Each variant having it's own:
        - Name
        - Identifier
        - Icon
        - Version
        - Specific tasks and configurations
        - Anything really!
- ✅ Setup CI/CD using fastlane.
    - ➡️ Lanes for specific tasks:
        - Setup CI
        - Create Keychain
        - Perform Unit and UI tests
        - Lint and format
        - Complexity analisys
        - Sonar report
        - Build and sign application
        - Deploy to AppCenter / PlayStore / AppStore
        - Many more!

## Installation

### Homebrew (recommended)

```sh
brew install backbase/m/variants
```

### Make

```sh
git clone https://github.com/backbase/variants.git
cd variants
make install
```

### Swift Package Manager

#### Use as CLI

```sh
git clone https://github.com/backbase/variants.git
cd variants
swift run variants
```

## Usage

```sh
Usage: variants <command> [options]

A command-line tool to setup deployment variants and full CI/CD pipelines

Commands:
  init            Generate specs file - variants.yml
  setup           Setup deployment variants (alongside Fastlane)
  switch          Switch variants
  help            Prints help information
  version         Prints the current version of this app
```

### Initialize

Before running setup to create your deployment variants and pipelines you need a YAML configuration file.
Run `variants init` in the base folder of your project.

```sh
Usage: variants init <platform> [options]

Generate specs file - variants.yml

Options:
  -h, --help       Show help information
  -v, --verbose    Log tech details for nerds
```

Example
```sh
$ variants init ios
```
It will generate a variants.yml file in the base folder of your project

<p align="center">
<img src="Assets/Examples/Project_Example_Step_2.png" title="variants.yml">
</p>

> NOTE: Edit the file variants.yml accordingly.

#### Config settings
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
        app_icon: AppIcon
        source:
          path: Sources
          info: Sources/Info.plist
          # Path to folder that will serve as parent to folder Variants/
          config: Sources
    variants:
        # Default variant is mandatory, do not remove
      - name: default
        version_name: 0.0.1
        version_number: 1
        custom:
            - key: apiBaseUrl
              value: https://sample.com/
      - name: BETA
        id_suffix: beta
        app_icon: AppIcon.beta
        version_name: 0.0.1
        version_number: 13
        custom:
            - key: apiBaseUrl
              value: https://sample-beta.com/
            - key:  OTHER_SWIFT_FLAGS
              value: $(inherited) -DBETA
            
```

### Setup multiple build variants with full fastlane integration.

#### Using default configuration file (variants.yml)

```sh
Usage: variants setup <platform> [options]

Setup deployment variants

Options:
  -h, --help             Show help information
      --skip-fastlane    Skip fastlane setup
  -s, --spec <value>     Use a different yaml configuration spec
  -v, --verbose          Log tech details for nerds
```

Example
```sh
$ variants setup ios
```

This will generate your `Variants/` folder, containing `variants.xcconfig` and `Variants.swift`. You won't have to do anything with these files.
`Variants.swift` is an extension in case you need any of the variant's configuration in your codebase:
```swift
let baseUrl = Variants.configuration["apiBaseURL"]
```

Setup will also configure your Xcode project to use this new configuration and map configs (such as `name`, `bundle_id`, `app_icon`, `version_name` and `version_number`).

<p align="center">
<img src="Assets/Examples/Project_Example_Step_3.png" title="Setup completed">
</p>

#### Using a configuration file other than the default one

You might not always have `variants.yml`  in the base folder of your project or have it with a completely different name, for this reason you can specify its path as an option

```sh
variants setup <platform> [-s,--spec] <yml config path>

variants setup ios -s ~/johndoe/custom/path/variants.yml
```

> NOTE: *variants setup* will automatically assign the `default` variant configuration to the project

### Switch variants

In order to switch between project variants you don't need to modify the Xcode project nor the `variants.xcconfig`, just make use of one command

```sh
Usage: variants switch <platform> [options]

Switch variants

Options:
      --variant <value>  Desired variant (default: default)
  -s, --spec <value>     Use a different yaml configuration spec (default: variants.yml)
  -h, --help             Show help information
  -v, --verbose          Log tech details for nerds
```

Examples
```sh
$ variants switch ios

$ variants switch ios --variant BETA

$ variants switch ios --variant BETA --spec /Path/to/custom/variants.yml
```
