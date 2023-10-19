## Switching Variants on CI

After setting things up with `variants setup`, you'll likely let your CI perform `variants switch` before deploying, to ensure the correct variant is deployed to the desired store. Doing this only requires Variants to be installed in your CI machine.

### Using Github Actions

> **_Important:_**  When using this action, it's important to run your Github Action workflow on 'macos-12'. This will ensure variants-switch will be done within seconds instead of minutes.

If Github Actions is your CI and you use the [Github-hosted macOS runner](https://docs.github.com/en/free-pro-team@latest/actions/reference/specifications-for-github-hosted-runners), the best approach is to use Variants directly from Github Actions Marketplace, placing the following in your `workflow` file:

```yaml
- uses: backbase/variants@main
  with:
    version: 1.2.0
    spec: variants.yml
    platform: ios
    variant: beta
    verbose: true
```

**Note**: This Github Action simply switches between variants. It doesn't support `init` nor `setup` commands. These commands should still be done manually on a local environment.

#### Supported properties

| Property | Explanation | Default | Required |
| ------- | ------------- | ----------- | --------- |
| `version` | A version of `variants` that this action will use to perform the switch. | latest | No. If not specified, default is used. | 
| `spec` | Path to a `variants.yml` spec.  | variants.yml | No. If not specified, default is used. | 
| `platform` | Platform is either `ios` or `android` | - | No. If not specified, Variants will automatically detect your platform. [See here](PLATFORM_AUTO_DETECTION.md) for more information. |
| `variant` | Desired variant you want to switch to. | default | Yes |
| `verbose` | Log tech details for nerds. | false | Yes |
