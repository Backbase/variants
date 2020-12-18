## Auto detecting the project's platform

All commands (`init`, `setup` and `switch`) are capable of detecting your mobile project's platform (`iOS` or `Android`).
However, you can specify a platform directly, with option `--platform <value>` where value is either `ios` or `android`.

```sh
# Auto detection will happen
$ variants <command>

# Platform is specified, skip auto detection
$ variants <command> --platform ios
$ variants <command> --platform android
```

### Unable to auto detect platform

There are 2 cases when platform auto detection will present a problem.

1. No Android nor Xcode project were found in the working directory

```sh
$ variants switch --variant beta
INFO  [2020-10-21]: ▸ --------------------------------------------------------------------------------------
INFO  [2020-10-21]: ▸ $ variants switch --variant beta
INFO  [2020-10-21]: ▸ --------------------------------------------------------------------------------------
Error: ❌ Could not find an Android or Xcode project in your working directory.
```

2. When both an Android and a Xcode project were found in the working directory, making it unable to decide which platform to use for a command.

```sh
$ variants switch --variant beta
INFO  [2020-10-21]: ▸ --------------------------------------------------------------------------------------
INFO  [2020-10-21]: ▸ $ variants switch --variant beta
INFO  [2020-10-21]: ▸ --------------------------------------------------------------------------------------
Error: ❌ Found an Android and Xcode project in your working directory. Please specify the platform you want using `--platform <value>`
```
