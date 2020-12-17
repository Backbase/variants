
## Android Project configuration

If `variants init` has been run successfully, you will see a `variants.yml` file in your project directory. This is where we configure the variants for our project.

## Working with `variants.yml`

### Where do values go?
First, it is important to note that the values from the configuration will be placed in multiple locations. For example, values for fastlane are stored in `./fastlane/parameters`, while gradle values are stored in `./gradleScripts/variants.gradle`. For custom properties, these locations are explicity [set with the destination value](https://github.com/Backbase/variants/blob/main/docs/CUSTOM_PROPERTY.md#destination). For others, they are placed in a location by default, since Variants already know where those values should be used.

### Configuring project
- `path`: Path to the base directory of the Android project. Typically this would be `.` if you generated the variants template in the base directory.
- `app_name`: The name of the application, ex: `Frank Bank`
- `app_identifier`: This is the package for the project, ex: `com.backbase.frank`
- `variants`: Here we will add our different variants. This is where we can differentiate which builds/flavors we want, and also the destination of these builds (currently configurable for AppCenter and PlayStore). **Note: There is a required "default" variant. This should be considered the production configuration.**

### Configuring variants
- `name`: The name to reference the variant. This is namely used to select which variant to use via the switch command. Ex: `variant switch -—variant test`.
- `version_name`:  Same value as `versionName` for Android. Ex: `1.0.0`.
- `version_code`: Same value as `versionCode` for Android. Ex: `1`.
- `task_build`: The build task for your specific build/flavor. Ex: `assembleDevelop`.
- `task_unittest`: The unit test task for your specific build/flavor. Ex: `testDevDebugUnitTestv`.
- `task_uitest`: The ui test task for your specific build/flavor. Ex: `connectedDevDebugAndroidTest`.
- `store_destination`: The destination for your build. Currently there are only two options, `PlayStore` and `AppCenter`. [More information can be found in the `STORE_DESTINATION` documentation.](https://github.com/Backbase/variants/blob/main/docs/STORE_DESTINATION.md)

### Configuring custom values
Each variant can also have custom values if your needs were not met by the standard values. [More information on these can be found in the `CUSTOM_PROPERTY` documentation.](https://github.com/Backbase/variants/blob/main/docs/CUSTOM_PROPERTY.md) A common example of this is the app name variable used in AppCenter.

### Generating files
Once your `variants.yml` spec has been configured, you can setup the project with `variants setup`. You will only need to run this once. After this, you can generate new files by simply calling the switch command, such as  `variants switch --variant test`. [More information on commands can be found in the project README.](https://github.com/Backbase/variants/blob/develop/README.md)

### Updating module `build.gradle`
Lastly, after your project has generated all the necessary files using variants, you must update your `build.gradle` to access these variables. This is simple, just add the reference to your gradle variants inside `build.gradle`, ex: `apply from: '../gradleScripts/variants.gradle'`, and then refer to those variables.
```defaultConfig {
        applicationId rootProject.ext.appIdentifier
        minSdkVersion 21
        targetSdkVersion 29
        versionCode rootProject.ext.versionCode
        versionName rootProject.ext.versionName
    }
