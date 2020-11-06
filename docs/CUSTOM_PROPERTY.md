
## Custom Property

Your `variants.yml` spec is composed of different objects per platform, which are likely mandatory, but it also introduces an optional property called `"custom"`, which is either a platform property and/or a variant property.

A custom property consists of 3 values:

- `name`:  Name of the property
- `value`: Value of the property
- `destination`: Destination of the property

### Destination

Destination is an Enum, with three supported destinations:

- `project`: 
Ensures the property is available to be used by your project, either in `variants.gradle` or `variants.xcconfig`, depending on the platform.

To use such properties in an iOS codebase, you can do so as:
```swift
let property = Variants.configuration["NAME_OF_PROPERTY"]
```

In Android, you'll have to include `variants.gradle` in your `app/build.gradle` and access the properties that way.

- `fastlane`: 
Ensures the property is available to your fastlane setup, in file `fastlane/parameters/variants_params.rb`.

To use such a property in a fastlane file, you can do so as:
```ruby
property = VARIANTS_PARAMS[:NAME_OF_PROPERTY]
```

## Examples

**iOS Example**
```yaml
ios:
    xcodeproj: ...
    targets:
      ...
    variants:
      - name: default
        version_name: 0.0.1
        version_number: 1
        ...
        custom:
            {{ INSERT ARRAY OF CUSTOM PROPERTY ONLY AVAILABLE TO VARIANT 'default' }}
    custom:
        {{ INSERT ARRAY OF CUSTOM PROPERTY ALWAYS AVAILABLE FOR iOS }}
```

**Android Example**
```yaml
android:
    path: ...
    ...
    variants:
      - name: default
        version_name: 0.0.1
        version_number: 1
        ...
        custom:
            {{ INSERT ARRAY OF CUSTOM PROPERTY ONLY AVAILABLE TO VARIANT 'default' }}
    custom:
        {{ INSERT ARRAY OF CUSTOM PROPERTY ALWAYS AVAILABLE FOR ANDROID }}
```

As seen above, custom properties that are specific to a variant will only be available for that variant, while custom properties tied to the platform is available at all times regardless of the variant used. A real use case of this could be as below:

```yaml
android:
    ...
    variants:
      - name: default
        version_name: 1.0.0
        version_number: 10
        ...
        custom:
            - name: BASE_URL
              value: https://api.service.com/
              destination: project
      - name: BETA
        version_name: 1.1.8
        version_number: 23
        ...
        custom:
            - name: BASE_URL
              value: https://api.beta-service.com/
              destination: project
    custom:
        - name: MAVEN_USERNAME
          value: sample-username
          destination: project
        - name: MAVEN_PASSWORD
          value: sample-encrypted-password
          destination: project
```
Above, both `default` and `BETA` contain a `"BASE_URL"` property, which can be used in your project's network services as base URL, whose value will change depending on the variant you choose. Meanwhile, regardless of the variant chosen, `MAVEN_USERNAME` and `MAVEN_PASSWORD` will be available, allowing you to potentially fetch artefacts from a private repository.

## Working with Environment Variables

We often find ourselves in need to use an API token - or any other secret - in our codebase or CD setup that shouldn't, by any means, be hardcoded nor committed in the repository. It's common in these situations to use _environment variables_.

Custom properties support environment variable values, that will provide the destination (`fastlane` or `project`) access to those values in the appropriate manner. The syntax is simple:

```yaml
custom:
    - name: NAME_OF_PROPERTY
      value: "{{ envVars.NAME_OF_ENV_VAR }}"
      destination project
    - name: DEPLOYMENT_API_TOKEN
      value: "{{ envVars.APPCENTER_API_TOKEN }}"
      destination fastlane
```

#### Destination `project`

- Android
Such a property will be written to `variants.gradle`
```gradle
// ==== Custom values ====
rootProject.ext.NAME_OF_PROPERTY = System.getenv('NAME_OF_ENV_VAR')
```
- iOS
Currently, destination `project` with an environment variable value is not supported. It will not write anything to `variants.xcconfig`.
iOS implementation depends on [Issue #87](https://github.com/Backbase/variants/issues/87)

#### Destination `fastlane`

These properties will continue to be written to `fastlane/parameters/variants_params.rb` and used the same way as a normal property.
The only difference is where the value comes from:

```ruby
VARIANTS_PARAMS = {
    DEPLOYMENT_API_TOKEN: ENV["APPCENTER_API_TOKEN"],
}.freeze
```
