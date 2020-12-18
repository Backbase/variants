
## Deploying to AppCenter

Running the `variants setup` command generates fastlane files that can deploy your app to [AppCenter or other stores](STORE_DESTINATION.md). Deploying to AppCenter can be achieved solely by making changes to your `variants.yml` spec. It is assumed you have an AppCenter account and a project has already been created.

### Preparation

1. Create an app in your AppCenter project, or open an existing one
1. Record the Owner name, this is in the URL after `orgs/` or `users/`
    1. For example https://<span></span>appcenter.ms/orgs/ **product-owner-org** /apps/variants-project
1. Record the App name, this is int he URL after `apps/`
    1. For example https://<span></span>appcenter.ms/orgs/product-owner-org/apps/ **variants-project**
1. Generate and record an API token
    1. Open up the app's page on AppCenter
    1. Select "Settings" on the left side
    1. Select "App API tokens"
    1. Select "New API token" in the top right
    1. Add a description, give the token full access, and select "Add new API token"

### Setting Up Environment Variables

Now that we have these values, we need to set up our variables. When `variant switch` or `variant setup` is ran, a set of parameter files are generated. Two of these files are `appcenter_params.rb` and `variants_params.rb`. The AppCenter deployment fastlane will need to refer to these files to successfully deploy. 

```
APPCENTER_PARAMS = {
    APPCENTER_OWNER_NAME: ENV["APPCENTER_OWNER_NAME"],
    APPCENTER_API_TOKEN: ENV["APPCENTER_API_TOKEN"],
    APPCENTER_DESTINATION_GROUP: ENV["APPCENTER_DESTINATION_GROUP"]
}.freeze
```
The AppCenter owner name, api token, and destination group are all expected to be set by the evironment variables listed above. Destination group is not a required field, and will default to "Collaborators".

```
custom:
    - name: APPCENTER_APP_NAME
      value: "variants-project"
      destination: fastlane
```
The AppCenter app name must be set as a custom property in `variants.yml` similarly to above. 

Once the environment variables are set and the custom property is added, your fastlane will be all hooked up and ready to run!


### (Optional) Deploying to AppCenter using GitHub Secrets

GitHub secrets is a good way to store sensitive information, in this situation, the API token. We can also store the owner name there since this won't change with different variants.
**NOTE: You must have elevated rights on a GitHub project in order to add secrets**

1. Create a secret for `APPCENTER_OWNER_NAME`, and store the owner as recorded earlier
1. Create a secret for `APPCENTER_API_TOKEN`, and store the token as recorded earlier

Now you must set these secrets to be mapped to environment variables by the same name. [Information on how to implement that can be found here.](https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-commands-for-github-actions#environment-files)
