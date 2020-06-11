fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
### slackit
```
fastlane slackit
```

### deploy
```
fastlane deploy
```
Run deploy
### match_signing_config
```
fastlane match_signing_config
```
Match signing confifguration
### master
```
fastlane master
```

### develop
```
fastlane develop
```

### release
```
fastlane release
```

### cohesion
```
fastlane cohesion
```
Measure and report cohesion
### local_run
```
fastlane local_run
```
Run all fastlane commands that can run outside of a jenkins environment
### prepare
```
fastlane prepare
```
Prepares the environment for build / test
### pods_update
```
fastlane pods_update
```
Update cocoapods and repo-art automatically if pod install fails
### pod_repo_art_update
```
fastlane pod_repo_art_update
```
Update all repo-art repositories
### sonar_report
```
fastlane sonar_report
```
Run a sonar scan using the configuration in sonar-project.properties
### lint
```
fastlane lint
```
Run swiftlint on the entire codebase
### coverage
```
fastlane coverage
```

### lizard_report
```
fastlane lizard_report
```
Run a lizard scan on the project
### tests
```
fastlane tests
```
Run all tests
### update_tag
```
fastlane update_tag
```

### commit_build_and_tag
```
fastlane commit_build_and_tag
```

### ui_test
```
fastlane ui_test
```
Run UI Tests

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
