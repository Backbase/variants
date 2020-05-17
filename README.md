<p align="center">
<img src="Assets/Examples/variants_logo.svg" title="variants">
</p>

<p align="center">Variants is a command line tool written in Swift that setup deployment variants and full CI/CD pipelines for mobile projects.</p>

## Features

- ✅ Setup your mobile project to have multiple variants of the same application.
  - ➡️ Each variant having it's own:
	  - Name
	  - Bundle Identifier
	  - Icon
	  - Connecting to specific backend environment
- ✅ Setup CI/CD using fastlane.
  - ➡️ Lanes for specific tasks:
  	- Setup CI
	- Create Keychain
	- Perform Unit and UI tests
	- Lint and format
	- Complexity analisys
	- Sonar report
	- Build and sign application
	- Deploy to AppCenter
  - ➡️ Lanes for specific branches (to be triggered by CI - Jenkins, Github Actions, Azure DevOps, etc)
	- master
		- Deploys production application
	- develop
		- Deploys test application
	- release
		- Deploys beta application
	- branch
		- Performs specific tasks and flags build as successful or failure.

## Usage

### Initialize

Before running setup to create your deployment variants and pipelines you need a YAML configuration file.
Run `variants init` in the base folder of your project.

```sh
variants init <platform>

# Example:
## Initialize with a configuration file specific for an iOS project

variants init ios
```
It will generate a variants.yml file in the base folder of your project

<p align="center">
<img src="Assets/Examples/Project_Example_Step_2.png" title="variants.yml">
</p>

> NOTE: Edit the file variants.yml accordingly.

#### Config settings
Your `variants.yml` will contain all the necessary fields. It comes with one variant named `default`, which will be used whenever a variant isn't specified. You can then include custom variants, for which the following settings are required:
* `bundle_id_suffix`

```yaml
ios:
  xcodeproj: PeachTree.xcodeproj
  targets:
    PeachTree:
      name: PeachyApp
      bundle_id: com.peachtree.peachy
      icon: AppIcon
      source:
        path: Sources
        info: Sources/Info.plist
  variants:
    - name: default
      version_name: 1.0.0
      version_number: 1
    - name: dev
      bundle_id_suffix: dev
      icon: DevelopmentIcon
      version_name: 0.0.1
      version_number: 1
    - name: test
      bundle_id_suffix: test
      icon: TestIcon
      version_name: 0.1.0
      version_number: 1
```

### Setup multiple build variants with full fastlane integration.

#### Using default configuration file (variants.yml)

```sh
variants setup <platform>

# Example:
## Create multiple variants for your iOS app, each using its own
## name, bundle-id, version, assets, backend environment, etc.

variants setup ios
```

It will generate a fully working fastlane setup for your platform (ios or android), edit your project in order to read default configs from variants (such as `app_name`, `bundle_id`, `icon`, `version_name` and `version_number`) and add code extensions so you can easily access your custom settings in code (i.e.: `server_base_url`, `a_service_api_key` etc )

<p align="center">
<img src="Assets/Examples/Project_Example_Step_3.png" title="Setup completed">
</p>

#### Using a configuration file other than the default one

```sh
variants setup <platform> [-s,--spec] <yml config path>

# Example:
## Create multiple variants for your iOS app, each using its own
## name, bundle-id, version, assets, backend environment, etc.

variants setup ios -s ./custom/path/variants.yml
```

> NOTE: *variants setup* will automatically assign the first variant configuration to the project

### Switch variants

```sh
variants switch <platform> <variant>

# Example:
## Switches configuration to one of the available variants in your `variants.yml`.

variants switch ios dev
```

### As part of fastlane deployment

```sh

# Example:
# You can switch variants before deploying your application.
#
# fastlane deploy variant:'test'
# fastlane deploy variant:'dev'
# fastlane deploy variant:'uat'
# fastlane deploy variant:'region_abc'
# fastlane deploy

lane :deploy do |options|
    switch_variant(options)

    run_tests
    run_linter
    run_cohesion
    run_lizard
    run_archive
    run_deploy
end

private_lane :switch_variant do |options|
    variant = options[:variant] || 'default'
    begin
        sh 'variants switch ios #{variant}'
    rescue
        UI.user_error!("variant #{variant} not found in your configuration")
    end
end

```

