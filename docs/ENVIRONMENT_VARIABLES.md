## Working with Environment Variables

> This documentation relates to [Custom Property](CUSTOM_PROPERTY.md).

We often find ourselves in need to use an API token - or any other secret - in our codebase or CD setup that shouldn't, by any means, be hardcoded nor committed in the repository. It's common in these situations to use _environment variables_.

Custom properties support environment variable values, that will provide the destination (`fastlane` or `project`) access to those values in the appropriate manner. This is done through the `env` key.

### Examples

Let's assume you have the following line in the file `~/.bash_profile`, exporting the environment variable `FOO`:

```bash
export FOO="Once upon a time there was a king..."
```

#### Destination `fastlane`

Now, let's create 3 custom properties in `variants.yml` and see how they will be used, depending on the `env` key.

```yaml
custom:
    - name: A_PROPERTY
      value: FOO
      destination: fastlane
      
    - name: B_PROPERTY
      value: FOO
      env: false
      destination: fastlane
      
    - name: C_PROPERTY
      value: FOO
      env: true
      destination: fastlane
```

In the example above, all custom properties are set to destination `fastlane`, which means all 3 will be exposed to `fastlane/parameters/variants_params.rb` as follows:

```ruby
VARIANTS_PARAMS = {
        A_PROPERTY: "FOO",
        B_PROPERTY: "FOO",
        C_PROPERTY: ENV["FOO"]
}.freeze
```

#### Destination `project`

- When destination is set to `project` and platform is Android, such properties will be written to `variants.gradle`.

```gradle
// ==== Custom values ====
rootProject.ext.A_PROPERTY = "FOO"
rootProject.ext.B_PROPERTY = "FOO"
rootProject.ext.C_PROPERTY = System.getenv('FOO')
```

- When platform is iOS, these properties behave in a slightly different way.

Properties whose destination is `project`, for iOS, that are **not** reading from environment variables, will be available in `variants.xcconfig`. But their names are exposed to the codebase directly in `Variants/Variants.swift`, as keys within a `ConfigurationValueKey` enum

```swift
// This entire file is automatically generated.

public struct Variants {
    static let configuration: [String: Any] = {
        guard let infoDictionary = Bundle.main.infoDictionary else {
            fatalError("Info.plist file not found")
        }
        return infoDictionary
    }()

    // MARK: - ConfigurationValueKey
    /// Custom configuration values coming from variants.yml as enum cases
    
    public enum ConfigurationValueKey: String { 
        case A_PROPERTY 
    }
    
    static func configurationValue(for key: ConfigurationValueKey) -> Any? {
        return Self.configuration[key.rawValue]
    }
        
        ...
    }
```

It can be used in your codebase as:
```swift
Variants.configurationValue(for: .A_PROPERTY)
/// or
Variants.configuration["A_PROPERTY"]
```

However, properties whose values are read from environment variables are exposed to the codebase directly in `Variants/Variants.swift`, as static variables within a `Secrets` type.
In Swift, properties can't read directly from environment variables, therefore Variants encrypts these values with a xor cipher using a salt that's generated randomly each time.

```swift
// This entire file is automatically generated.

public struct Variants {
    static let configuration: [String: Any] = {
        guard let infoDictionary = Bundle.main.infoDictionary else {
            fatalError("Info.plist file not found")
        }
        return infoDictionary
    }()

    // Encrypted secrets coming from variants.yml as environment variables
    public struct Secrets {
        private static let salt: [UInt8] = [
            // Randomly generated salt
            ...
        ]
        
        static var C_PROPERTY: String {
            let encoded: [UInt8] = [
                // Encrypted value of environment variable 'FOO'
                ...
                
                return decode(encoded, cipher: salt)
            ]
        }
        
        ...
    }
```

This guarantees a minimal level of security by not exposing the value of environment variable 'FOO' directly into the source code.
The property can now be used anywhere in the codebase as in the example below:

```swift
> print(Variants.Secrets.C_PROPERTY)
"Once upon a time there was a king..."
```
