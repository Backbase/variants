## iOS Signing

Variants allows you to highly customize the signing for each variant and each type of signing (debug vs release). Internally, every variant will always have a debug signing and a release signing that are selected using the following priority order:

`release_signing` (from variant configuration) > `signing` (from variant configuration) > `signing` (from global configuration)

The same priority applies to the debug signing

`debug_signing` (from variant configuration) > `signing` (from variant configuration) > `signing` (from global configuration)

`auto_detect_signing_identity` boolean flag will determine if Variants should attempt to fetch the matching signing certificate from the Keychain Access automatically. If this fails, it will fall back to manual signing gracefully. Auto detect is enabled by default.

If no signing configuration is found, an error is thrown to the user so the `variants.yml` must be updated.

### Configuration example

Given the following `variants.yml`:

```yaml
ios:
    xcodeproj: SampleProject.xcodeproj
    target:
        ...
    extensions:
        - name: TestWidgetExtension
          bundle_suffix: TestWidgetExtension
          signed: true
    variants:
        default:
            ... # does not include a signing, debug_signing, or release_signing
        beta:
            signing:
                match_url: "git@github.com:sample/match.git"
                team_name: "Beta Backbase B.V."
                team_id: "DEF7654321D"
                export_method: "appstore"
                auto_detect_signing_identity: true
        staging:
            signing:
                match_url: "git@github.com:sample/match.git"
                team_name: "Staging Backbase B.V."
                team_id: "ABD1234567D"
                export_method: "appstore"
            debug_signing:
                style: automatic
        prod:
            release_signing:
                match_url: "git@github.com:sample/match.git"
                team_name: "Prod Backbase B.V."
                team_id: "GHI8765432D"
                export_method: "appstore"
            debug_signing:
                style: automatic
    signing:
        match_url: "git@github.com:sample/match.git"
        team_name: "Backbase B.V."
        team_id: "ABC1234567D"
        export_method: "appstore"
        auto_detect_signing_identity: true
```

This is the output in Xcode and Matchfile:

- For the `default` variant, both the release signing and debug signing will come from the global signing configuration.
- For the `beta` variant, both the release signing and debug signing are overwritten by the local variant configuration.
- For the `staging` variant, both the release signing and debug signing are overwritten, but in this case, the debug signing is overwritten by the `debug_signing` configuration and the release signing is overwritten by the `signing` configuration
- For the `prod` variant, both the release signing and debug signing are overwritten, but in this case, the debug signing is overwritten by the `debug_signing` configuration and the release signing is overwritten by the `release_signing` configuration

### Target extension signing

The signing will also affect the sign of the target extensions listed in the `extensions` configuration that are marked with `signed` as `true`. They will follow the same rules as the main app as mentioned above.

Extensions will inherit the signing configuration from the respective (debug / release) signing configuration of the current selected variant.
