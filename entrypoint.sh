#!/bin/sh -l

set -e

: ${WPE_ENVIRONMENT_NAME?Required environment name variable not set.}
: ${WPE_SSH_KEY_PRIVATE?Required secret not set.}
: ${WPE_SSH_KEY_PUBLIC?Required secret not set.}

SSH_PATH="$HOME/.ssh"
WPE_HOST="git.wpengine.com"
KNOWN_HOSTS_PATH="$SSH_PATH/known_hosts"
WPE_SSH_KEY_PRIVATE_PATH="$SSH_PATH/WPE_key"
WPE_SSH_KEY_PUBLIC_PATH="$SSH_PATH/WPE_key.pub"
WPE_ENVIRONMENT_DEFAULT="production"
WPE_ENV=${WPE_ENVIRONMENT:-$WPE_ENVIRONMENT_DEFAULT}
WPE_LOCAL_BRANCH_DEFAULT="master"
BRANCH=${WPE_LOCAL_BRANCH:-$WPE_LOCAL_BRANCH_DEFAULT}
GIT_INCLUDE=${WPE_GIT_INCLUDE}
GIT_EXCLUDE=${WPE_GIT_EXCLUDE}

if [ $GIT_INCLUDE -n ]
then
  echo "Adding files to GIT"
  include_files=()
  mapfile -t include_files < "$GIT_INCLUDE"
  for include_file in "${include_files[@]}"
  do
    git add "$include_file" -f
  done
fi

if [ $GIT_EXCLUDE -n ]
then
  echo "Removing files from GIT"
  exclude_files=()
  mapfile -t exclude_files < "$GIT_INCLUDE"
  for exclude_file in "${exclude_files[@]}"
  do
    git rm -r --ignore-unmatch "$exclude_file"
  done
fi

echo "Committing build changes"
git commit -m "Github Actions Deploy"

echo "Setting up SSH keys"
mkdir "$SSH_PATH"
ssh-keyscan -t rsa "$WPE_HOST" >> "$KNOWN_HOSTS_PATH"

echo "$WPE_SSH_KEY_PRIVATE" > "$WPE_SSH_KEY_PRIVATE_PATH"
echo "$WPE_SSH_KEY_PUBLIC" > "$WPE_SSH_KEY_PUBLIC_PATH"

chmod 700 "$SSH_PATH"
chmod 644 "$KNOWN_HOSTS_PATH"
chmod 600 "$WPE_SSH_KEY_PRIVATE_PATH"
chmod 644 "$WPE_SSH_KEY_PUBLIC_PATH"

echo "Adding SSH key to GIT"
git config core.sshCommand "ssh -i $WPE_SSH_KEY_PRIVATE_PATH -o UserKnownHostsFile=$KNOWN_HOSTS_PATH"

echo "Pushing to WP Engine"
git remote add $WPE_ENV git@$WPE_HOST:$WPE_ENV/$WPE_ENVIRONMENT_NAME.git
git push -fu $WPE_ENV $BRANCH:master
