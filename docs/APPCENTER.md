## Deploying with AppCenter

Fastlane can be configured to make deployments to AppCenter with a single command. There are only a few requirements for this.

### Getting Started

1. Create an app on AppCenter, or open an existing one
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


### Deploying to AppCenter using GitHub Secrets

GitHub secrets is a good way to store sensitive information, in this situation the API token. We can also store the Owner name there since this won't change with different variants.
**NOTE: You must have elevated rights on a GitHub project in order to add secrets**

1. Create a secret for `APPCENTER_OWNER_NAME`, and store the owner as recorded earlier
1. Create a secret for `APPCENTER_API_TOKEN`, and store the token as recorded earlier
1. Add a custom value to the specific variant you're making the deployment for, inside your `variants.yml`
    * This is done at the variant level, so that if you have multiple AppCenter app flavors (prod, dev, test, etc), then you can use the `switch` command to easily switch before running the lane for AppCenter deployment.
    
    
    ```
    custom:
        - name: APPCENTER_APP_NAME
          value: "variants-project"
          destination: fastlane
         
**Note**: By default, when Variants generates your files, it stores the AppCenter owner and AppCenter API token as a resource retrieved from the Environment. This allows it to read those values we set in GitHub Secrets without any extra work!
### Deploying to AppCenter without Secrets

If you aren't using GitHub or prefer not to use secrets, you can add the `APPCENTER_OWNER_NAME` and `APPCENTER_API_TOKEN` values as custom properties, similarly to how you add the `APPCENTER_APP_NAME` value in the final step above. You may want to add your `variants.yml` file and the generated `variants_params.rb` file to your .gitignore, in order to keep your API token private.
