## Working with Fastlane Match

### Before you start

The Fastlane template you get, when running `variants setup`, already works with [Match](https://docs.fastlane.tools/actions/match/) in order to help sign your iOS applications. It doesn't, however, create a Match repository for you.

If you desire to use Match, follow the instructions provided in the [Fastlane documentation](https://docs.fastlane.tools/actions/match/#setup) in order to create your repository, which will contain your certificates and profiles, as well as set the appropriate environment variables such as `MATCH_PASSWORD` (the password used to encrypt the repository).


### Working with your Variants spec

Now that your Match repo(s) exist, you can work in your `variants.yml` spec, where you can provide a `signing` section with a few properties, either globally or for each variant. It takes `match_url`, `team_name`, `team_id` and `export_method`:

| Property | Explanation |
| ------- | ------------- |
| `match_url` | The URL to a Match git repository. |
| `team_name` | The name of your Developer Portal team. i.e.: `"iPhone Developer: BACKBASE EUROPE B.V."` |
| `team_id` | The ID of your Developer Portal team. |
| `export_method` | One of: _development_, _adhoc_, _appstore_ or _enterprise_ (For more information, see [Match documentation](https://docs.fastlane.tools/actions/match/). |

**Example:**

* You'll notice that `signing` can be specified globally. In such a case all variants will be signed used this configuration.

```yaml
ios:
    ...
    variants:
        ...
    signing:
        match_url: "git@github.com:sample/match.git"
        team_name: "iPhone Developer: Sample Organization"
        team_id: "ABC1234567D"
        export_method: "appstore"
```

* Another option is to specify it for each variant. In this case, the variant's configuration override the global one.

```yaml
ios:
    ...
    variants:
        # Variant 'default' doesn't implement it's signing, thus it will use the global one.
        - name: default
          ...
          
        # Variant 'beta' only overrides the 'export_method', thus all the rest will be used
        # from the global configuration.
        - name: beta
          ...
          signing:
              export_method: "adhoc"
              
        # Variant 'internal_enterprisse_release' overrides everything, in this example
        # using a completely different match repository and signing identity.
        - name: internal_enterprisse_release
          ...
          signing:
              match_url: "git@github.com:sample-enterprise/match.git"
              team_name: "iPhone Developer: Enterprise Organization"
              team_id: "JKI1234567F"
              export_method: "enterprise"
          
    signing:
        match_url: "git@github.com:sample/match.git"
        team_name: "iPhone Developer: Sample Organization"
        team_id: "ABC1234567D"
        export_method: "appstore"
```


Based on the above, whenever you run `setup` and/or `switch` commands, the file `fastlane/Matchfile` will be modified to reflect this information. Take, for instance, if you switch to _"BETA"_ variant:

```ruby
git_url("git@github.com:sample/match.git")
storage_mode("git")

type("adhoc")

# Assume the identifier (not visible in the spec above) would be "com.sample.mobile"
app_identifier([
    "com.sample.mobile.beta"
])
```


### Match parameters file

The file `fastlane/parameters/match_params.rb` is used to configure the parameters necessary to:
* Create a temporary keychain to store the certificates and profiles
* Clone the private match repository
* Decrypt the contents of the repository

It looks like this:

```ruby
MATCH_PARAMS = {
  MATCH_KEYCHAIN_NAME: ENV['MATCH_KEYCHAIN_NAME']
  MATCH_KEYCHAIN_PASSWORD: ENV['MATCH_KEYCHAIN_PASSWORD']
  
  # This is needed if your Match repository is private
  MATCH_GIT_BASIC_AUTHORIZATION: ENV['MATCH_GIT_BASIC_AUTHORIZATION'],
  
  # Match repository password, used to decrypt files
  MATCH_PASSWORD: ENV['MATCH_PASSWORD']
  
  # Signing properties coming from Variants YAML spec.
  # Do not change manually!
  TEAMNAME: "iPhone Distribution: Enterprise Sample",
  TEAMID: "7A1234567D",
  EXPORTMETHOD: "enterprise"
}.freeze
```

| Key(s) | Explanation |
| ------- | ------------- |
| _MATCH_KEYCHAIN_NAME_, _MATCH_KEYCHAIN_PASSWORD_  | A temporary keychain is created only when running on CI, therfore the values for the environment variables `MATCH_KEYCHAIN_*` could be anything you desire on that CI machine, as the keychain will be deleted after every run. However, since a keychain won't be created when running this locally, you have to set local environment variables `MATCH_KEYCHAIN_NAME` and `MATCH_KEYCHAIN_PASSWORD` to an existing keychain name and password in your machine. |
| _MATCH_GIT_BASIC_AUTHORIZATION_ | If your machine is currently using SSH to authenticate with GitHub, you'll want to use a git URL, otherwise, you may see an authentication error when you attempt to use match. Alternatively, you can set a basic authorization for match. See [Match documentation](https://docs.fastlane.tools/actions/match/#git-storage-on-github). |
| _MATCH_PASSWORD_ | Git repo encryption password, the password used to encrypt the Match git repository when it was created in the first place. |
| Other properties | All other properties are populated automatically on `variants setup` | `variants switch`. |


### Validate it works

If everything has been set successfully (the Match repository for the current variant exists, it contains profiles for the current variant and the environment variables from section above are set), you should be able to run the following fastlane command with success, adding the certificates and profiles to your keychain.

```bash
bundle exec fastlane run_match_signing
```


### Ensure Match is being used during deployment

Match isn't used by default before archiving your application. Make sure to uncomment one line of code in the file `fastlane/Deploy`.
You'll see the following in this file. Simply remove `#` from the second line.

```ruby
    # If Match is enabled, uncomment line below
    # run_match_signing
```
