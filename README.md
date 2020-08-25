# GitHub Action for WP Engine Git Deployments

An action to deploy your repository to a **[WP Engine](https://wpengine.com)** site via git. [Read more](https://wpengine.com/git/) about WP Engine's git deployment support.

## Example GitHub Action workflow

```
name: WP Engine Git Deploy
on:
  push:
    branches: staging
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - run: |
          git fetch --prune --unshallow
      - name: GitHub Action for WP Engine Git Deployment
        uses: epogeedesign/github-action-wpengine-git-deploy@master
        env:
          WPE_ENVIRONMENT_NAME: ${{ secrets.WPE_SSH_KEY_PRIVATE }}
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

### Example with Options

```
name: WP Engine Git Deploy
on:
  push:
    branches: staging
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - run: |
          git fetch --prune --unshallow
      - name: GitHub Action for WP Engine Git Deployment
        uses: epogeedesign/github-action-wpengine-git-deploy@master
        env:
          WPE_ENVIRONMENT_NAME: ${{ secrets.WPE_SSH_KEY_PRIVATE }}
          WPE_SSH_KEY_PRIVATE: ${{ secrets.WPE_SSH_KEY_PRIVATE }}
          WPE_SSH_KEY_PUBLIC: ${{ secrets.WPE_SSH_KEY_PUBLIC }}
		  WPE_ENVIRONMENT: 'production'
		  WPE_LOCAL_BRANCH: 'master'
		  WPE_GIT_INCLUDE: '.github/wpe-deploy-include.txt'
		  WPE_GIT_EXCLUDE: '.github/wpe-deploy-exclude.txt'
```

### Example WPE_GIT_INCLUDE file
```
wp-content/themes/*/dist/*
```

### Example WPE_GIT_EXCLUDE file
```
package.json
wp-config.php
```

### Further reading

* [Defining environment variables in GitHub Actions](https://developer.github.com/actions/creating-github-actions/accessing-the-runtime-environment/#environment-variables)
* [Storing secrets in GitHub repositories](https://developer.github.com/actions/managing-workflows/storing-secrets/)

## Setting up your SSH keys

1. [Generate a new SSH key pair](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/) as a special deploy key. The simplest method is to generate a key pair with a blank passphrase, which creates an unencrypted private key.
2. Store your public and private keys in your GitHub repository as new 'Secrets' (under your repository settings), using the names `WPE_SSH_KEY_PRIVATE` and `WPE_SSH_KEY_PUBLIC` respectively. In theory, this replaces the need for encryption on the key itself, since GitHub repository secrets are encrypted by default.
3. Add the public key to your target WP Engine environment.
4. Per the [WP Engine documentation](https://wpengine.com/git/), it takes about 30-45 minutes for the new SSH key to become active.
