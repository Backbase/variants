# WIP

See branch **new-proposal**

<p align="center">
<img src="Assets/logo.svg" title="MobileSetup">
</p>

<p align="center">MobileSetup is a command line tool written in Swift that setup deployment variants and full CI/CD pipelines for mobile projects.</p>

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

## Installation

### Homebrew (recommended)

```sh
brew tap arthurpalves/formulae
brew install mobile-setup
```

### [Mint](https://github.com/yonaskolb/Mint)

```sh
mint install arthurpalves/mobile-setup
```

### Make

```sh
git clone https://github.com/arthurpalves/mobile-setup.git
cd mobile-setup
make install
```

### Swift Package Manager

#### Use as CLI

```sh
git clone https://github.com/arthurpalves/mobile-setup.git
cd mobile-setup
swift run mobile-setup
```

#### Use as dependency

Add the following to your Package.swift file's dependencies:

```swift
.package(url: "https://github.com/arthurpalves/mobile-setup.git", from: "0.0.1"),
```

And then import wherever needed: import MobileSetup

## Usage

### Initialize

Before running setup to create your deployment variants and pipelines you need a YAML configuration file.
Run `mobile-setup init` in the base folder of your project.

```sh
mobile-setup init <platform>

# Example:
## Initialize with a configuration file specific for an iOS project
mobile-setup init ios
```

> NOTE: Edit the generated .yml file accordingly.

### Generate multiple build variants per environment.

#### Using default configuration file (mobile-setup.yml)

```sh
mobile-setup <platform>

# Example:
## Create multiple variants for your iOS app, each using its own config.json,
## name, bundle-id, version, assets, backend environment, etc.
mobile-setup ios
```

#### Using a configuration file other than the default one

```sh
mobile-setup <platform> [-c,--config] <yml config path>

# Example:
## Create multiple variants for your iOS app, each using its own config.json,
## name, bundle-id, version, assets, backend environment, etc.
mobile-setup ios -c ./MyProjectConfig.yml
```

### Generate fastlane setup

```sh
mobile-setup <platform> --include-fastlane

# Example:
## Besides creating multiple variants, include a fully working
## fastlane setup, with lanes specific for: `master`, `develop`,
## `release` and `branch`.
mobile-setup ios --include-fastlane
```


### Flags

|          |                             |                            |
|:---------|:----------------------------|:---------------------------|
| **`-v`** | **`--verbose`**             | Log tech details for nerds |
| **`-h`** | **`--help`**                | Show help information      |
|          | **`--include-fastlane`**    | Include fastlane setup     |

