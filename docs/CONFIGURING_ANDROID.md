
## Android Project configuration

If `variants init` has been run successfully, you will see a `variants.yml` file in your project directory. This is where we configure the variants for our project.

### Configuring project
- `path`: Path to the base directory of the Android project. Typically this would be `.` if you generated the variants template in the base directory.
- `app_name`: The name of the application, ex: `Frank Bank`
- `app_identifier`: This is the package for the project, ex: `com.backbase.frank`
- `variants`: Here we will add our different variants. This is where we can differentiate which builds/flavors we want, and also the destination of these builds (currently configurable for AppCenter and PlayStore).

### Configuring variants
- `name`: The name to reference the variant. This is namely used to select which variant to use via the switch command. Ex: `variant switch —platform android —variant test`.
- `version_name`:  Same value as `versionName` for Android. Ex: `1.0.0`.
- `version_code`: Same value as `versionCode` for Android. Ex: `1`.
- `task_build`: The build task for your specific build/flavor. Ex: `assembleDevelop`.
- `task_unittest`: The unit test task for your specific build/flavor. Ex: `testDevDebugUnitTestv`.
- `task_uitest`: The ui test task for your specific build/flavor. Ex: `connectedDevDebugAndroidTest`.
- `store_destination`: The destination for your build. Currently there are only two options, `PlayStore` and `AppCenter`. More information can be found in the `STORE_DESTINATION` documentation.

### Configuring custom values
Each variant can also have custom values if your needs were not met by the standard values. More information on these can be found in the `CUSTOM_PROPERTY` documentation. A common example of this is the app name variable used in AppCenter.

### Generating files
Once your project has been configured, you can setup the project with `variants setup`. Note that this generates files for your default variant. If you wish to setup a project for a non-default variant, first run the setup command `variants setup` and then switch to your chosen variant, `variants switch --platform android --variant test`. More information on commands can be found in the project README.
