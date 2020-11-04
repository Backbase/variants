
## Store Destination

This tool not only creates multiple deployment variants of your application but it allows you to use a generated `fastlane` setup, which among other things, allow us to deploy our applications to multiple stores, they being:

- AppStore
- TestFlight
- AppCenter
- PlayStore

A real life use case for an application is that the production variant might be deployed to a public store, while a beta variant or similar might be deployed to `AppCenter` or `TestFlight`, for example.

In order to support this without major modifications in the generated `fastlane` setup, we can specify the store destination for each variant directly in `variants.yml`.

## iOS Stores

Specifying the store destination for a variant isn't mandatory.
Note that by not specifying or specifying an unsupported store will fallback to `AppStore`.

### AppStore / TestFlight

>
> 
> Deploying to TestFlight or AppStore require
> authentication to AppStoreConnect.
>
> In order to have this handled automatically in
> your CI machine, you'll need an Application Specific Password
> 
> Find more about it and how to generate yours in:
> https://docs.fastlane.tools/best-practices/continuous-integration/#application-specific-passwords
>
>

### AppCenter

>
> 
> Deploying to AppCenter requires an API token,
> the application's name, owner's name and destination group.
>
> For more information, see
> `Templates/ios/_fastlane/fastlane/parameters/appcenter_params.rb`
> 
> You should also specify `APPCENTER_APP_NAME` as a custom property of your variants
> which destination `fastlane`.
>
>

#### Example

Assume we have an iOS project, which production variant (default) should deploy to *Apple's AppStore*. A beta variant should be deployed to *Apple's TestFlight*. And an internal enterprise variant of this application (using an enterprise developer account) should be deployed to *AppCenter*. This could be achieved with the following:

```yaml
ios:
    xcodeproj: ...
    targets:
      ...
    variants:
      - name: default
        version_name: 0.0.1
        version_number: 1
        store_destination: AppStore
        ...
      - name: beta
        version_name: 0.0.1
        version_number: 1
        store_destination: TestFlight
        ...
      - name: enterprise_release
        version_name: 0.0.1
        version_number: 1
        store_destination: AppCenter
        ...
```

Now, all we have to do is to switch to the correct variant and instruct *fastlane* to deploy as usual:

```sh
variants switch --platform ios --variant <value>

fastlane deploy
```


