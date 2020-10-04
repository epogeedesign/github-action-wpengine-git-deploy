# GitHub Action for WP Engine Git Deployments

An action to deploy your repository to a **[WP Engine](https://wpengine.com)** site via git. [Read more](https://wpengine.com/git/) about WP Engine's git deployment support.

## Example GitHub Action workflow

```
name: WP Engine Git Deploy
on:
  push:
    branches:
      - master
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Git checkout
        uses: actions/checkout@v2
      - name: Git fetch
        run: |
          git fetch --prune --unshallow
      - name: Push to WP Engine
        uses: epogeedesign/github-action-wpengine-git-deploy@master
        env:
          WPE_ENVIRONMENT_NAME: 'my-wpe-environment'
          WPE_SSH_KEY_PRIVATE: ${{ secrets.WPE_SSH_KEY_PRIVATE }}
          WPE_SSH_KEY_PUBLIC: ${{ secrets.WPE_SSH_KEY_PUBLIC }}
```

## Environment Variables & Secrets

### Required

| Name | Type | Usage |
|-|-|-|
| `WPE_ENVIRONMENT_NAME` | Environment Variable | The name of the WP Engine environment you want to deploy to. |
| `WPE_SSH_KEY_PRIVATE` | Secret | Private SSH key of your WP Engine git deploy user. See below for SSH key usage. |
| `WPE_SSH_KEY_PUBLIC` | Secret | Public SSH key of your WP Engine git deploy user. See below for SSH key usage. |

### Optional

| Name | Type  | Usage |
|-|-|-|
| `WPE_ENVIRONMENT` | Environment Variable  | Defaults to `production`. You shouldn't need to change this, but if you're using WP Engine's legacy staging, you can override the default and set to `staging` if needed. |
| `WPE_LOCAL_BRANCH` | Environment Variable  | Set which branch in your repository you'd like to push to WP Engine. Defaults to `master`. |
| `WPE_GIT_INCLUDE` | Environment Variable | Path of include file containing list of files to include from GIT after checkout and before deploy. |
| `WPE_GIT_EXCLUDE` | Environment Variable | Path of include file containing list of files to exclude from GIT after checkout and before deploy. |

## Additional Examples

### Example with All Options

```
name: WP Engine Git Deploy
on:
  push:
    branches: master
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - run: |
          git fetch --prune --unshallow
      - name: Push to WP Engine
        uses: epogeedesign/github-action-wpengine-git-deploy@master
        env:
          WPE_ENVIRONMENT_NAME: ${{ secrets.WPE_SSH_KEY_PRIVATE }}
          WPE_SSH_KEY_PRIVATE: ${{ secrets.WPE_SSH_KEY_PRIVATE }}
          WPE_SSH_KEY_PUBLIC: ${{ secrets.WPE_SSH_KEY_PUBLIC }}
          WPE_ENVIRONMENT: 'production'
          WPE_LOCAL_BRANCH: 'master'
          WPE_GIT_INCLUDE: '.github/wpe-git-include.txt'
          WPE_GIT_EXCLUDE: '.github/wpe-git-exclude.txt'
```

### Example Workflow with Multiple Branches

It is possible to utilize the multiple environments provided by WP Engine in combination with specific branches in Github. The below example assumes the `master` branch deploys to `my-wpe-production` and the `staging` branch deploys to `my-wpe-staging`. Add or replace these as necessary to match the branches and WP Engine environment names for the given project.

```
name: WP Engine Git Deploy
on:
  push:
    branches:
      - master
      - staging
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Git checkout
        uses: actions/checkout@v2
      - name: Git fetch
        run: |
          git fetch --prune --unshallow
      - name: Set environment to production
        if: endsWith(github.ref, '/master')
        run: |
          echo "::set-env name=WPE_ENVIRONMENT_NAME::my-wpe-production"
      - name: Set environment to staging
        if: endsWith(github.ref, '/staging')
        run: |
          echo "::set-env name=WPE_ENVIRONMENT_NAME::my-wpe-staging"
      - name: Push to WP Engine
        uses: epogeedesign/github-action-wpengine-git-deploy@master
        env:
          WPE_SSH_KEY_PRIVATE: ${{ secrets.WPE_SSH_KEY_PRIVATE }}
          WPE_SSH_KEY_PUBLIC: ${{ secrets.WPE_SSH_KEY_PUBLIC }}
```

### Example WPE_GIT_INCLUDE file

If the workflow additionally runs build scripts such as NPM and/or produces artifacts these files will not automatically be deployed to WP Engine. The `WPE_GIT_INCLUDE` file may be a list of exact paths and filenames or an *nix file pattern. These files will be added and committed to the temporary Git checkout that is deployed to WP Engine. These files will not be added to Github.

```
wp-content/themes/*/dist/*
```

### Example WPE_GIT_EXCLUDE file

WP Engine disallows several files and paths such as wp-config.php and wp-content/uploads/. If these files are committed to Github they will be rejected by WP Engine and cause the build to fail. The `WPE_GIT_EXCLUDE` file may be a list of paths and filenames or an *nix file pattern. These files will be removed and committed to the temporary Git checkout that is deployed to WP Engine. These files will not be removed from Github.

```
package.json
wp-config.php
```

## Setting up your SSH keys

1. [Generate a new SSH key pair](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/) as a special deploy key. The simplest method is to generate a key pair with a blank passphrase, which creates an unencrypted private key.
2. Store your public and private keys in your GitHub repository as new 'Secrets' (under your repository settings), using the names `WPE_SSH_KEY_PRIVATE` and `WPE_SSH_KEY_PUBLIC` respectively. In theory, this replaces the need for encryption on the key itself, since GitHub repository secrets are encrypted by default.
3. Add the public key to your target WP Engine environment(s).
4. Per the [WP Engine documentation](https://wpengine.com/git/), it takes about 30-45 minutes for the new SSH key to become active.

### Further reading

* [Defining environment variables in GitHub Actions](https://developer.github.com/actions/creating-github-actions/accessing-the-runtime-environment/#environment-variables)
* [Storing secrets in GitHub repositories](https://developer.github.com/actions/managing-workflows/storing-secrets/)

## Common Problems

* key_load_public: invalid format
  * The secrets for `WPE_SSH_KEY_PUBLIC` or `WPE_SSH_KEY_PRIVATE` are missing, not using the right names, or the key was improperly copied.
* fatal: Could not read from remote repository
  * The provided `WPE_SSH_KEY_PUBLIC` is not added to WP Engine or `WPE_SSH_KEY_PRIVATE` does not match the public key.
  * The `WPE_ENVIRONMENT_NAME` setting is incorrect or does not match a WP Engine environment with the specified `WPE_SSH_KEY_PUBLIC` key added.
* system/large file types detected
  * WP Engine will reject the deploy if particular files are not removed. Check the `WPE_GIT_EXCLUDE` example for removing these files before being deployed.
