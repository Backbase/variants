
## Custom Property

Your `variants.yml` spec is composed of different objects per platform, which are likely mandatory, but it also introduces an optional property called `"custom"`, which is either a platform property and/or a variant property.

A custom property consists of 4 values:

| Value | Explanation | Default | Required |
| ------- | ------------- | ----------- | --------- |
| `name` | Name of the property.  | N/A | Yes | 
| `value` | Value of the property. If `env` is set to `true` it refers to the name of an environment variable | N/A | Yes |
| `env` | Boolean to specify if value is the name of an environment variable. | false | No |
| `destination` | Destination of the property. It is either `fastlane` or `project`. | N/A | Yes |

### Destination

Destination is an Enum, with two supported destinations:

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
      default:
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
      default:
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
      default:
        version_name: 1.0.0
        version_number: 10
        ...
        custom:
            - name: BASE_URL
              value: https://api.service.com/
              destination: project
      BETA:
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

Custom Properties support the use of environment variables, whenever there is the need to expose information to an Android/iOS project or to Fastlane without hardcoding and/or committing its value. This is often used for secrets/tokens. See [Working with Environment Variables](ENVIRONMENT_VARIABLES.md) for examples.
