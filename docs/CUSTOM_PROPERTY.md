
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

- `environment`:
Ensures the property will/can be exported as environment variable.
This creates a temporary file whose path is printed to stderr when running `setup` or `switch` command.
This is the only thing printed to stderr, so it's easy to be observed/retrieved.
```sh
variants switch --platform  android --variant beta
INFO  [2020-10-20 18:10:12]: ▸ --------------------------------------------------------------------------------------
INFO  [2020-10-20 18:10:12]: ▸ $ variants switch beta
INFO  [2020-10-20 18:10:12]: ▸ --------------------------------------------------------------------------------------
INFO  [2020-10-20 18:10:12]: ▸ Loading configuration
INFO  [2020-10-20 18:10:12]: ▸ Found variant: BETA
EXPORT_ENVIRONMENTAL_VARIABLES_PATH=/var/folders/1r/gf8jjzqx7q153_rm9hwm9fq00000gp/T/tmp.ltGjAbZx
```

The content of this file is in the following format, as example:
```sh
export PROPERTY=value
export ANOTHER_PROPERTY=another-value
```

The above allows you to fetch the file path from stderr and source the file as below, in order to make those environment variables available:
```
source /var/folders/1r/gf8jjzqx7q153_rm9hwm9fq00000gp/T/tmp.ltGjAbZx
```

If and at which stage you do this is automatically is up to you.

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
