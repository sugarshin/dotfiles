#!/bin/bash

# This script clones all repositories from my Bitbucket account
# into the current directory using SSH URLs.
#
## Authentication:
# This script uses the Bitbucket REST API with HTTP Basic Authentication.
# You will be prompted to enter your password.
# If you have two-factor authentication (2FA) enabled, you MUST use an **App Password** instead.
#
##  How to create an App Password:
# 1. Go to: https://bitbucket.org/account/settings/app-passwords/
# 2. Click "Create app password"
# 3. Set a label like "clone-all-script"
# 4. Enable the following permission:
#    - Repository: Read
# 5. Click "Create" and copy the generated App Password

USERNAME="sugarshin"

TARGET_DIR=$(pwd)

curl -s -u "$USERNAME" "https://api.bitbucket.org/2.0/repositories/$USERNAME?pagelen=100" |
  jq -r '.values[] | .links.clone[] | select(.name == "ssh") | .href' |
  while read repo; do
    echo "Cloning $repo into $TARGET_DIR/$(basename "$repo" .git) ..."
    git clone "$repo" "$(basename "$repo" .git)"
  done
