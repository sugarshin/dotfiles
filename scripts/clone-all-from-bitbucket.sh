#!/bin/bash

USERNAME="sugarshin"

TARGET_DIR=$(pwd)

curl -s -u "$USERNAME" "https://api.bitbucket.org/2.0/repositories/$USERNAME?pagelen=100" |
  jq -r '.values[] | .links.clone[] | select(.name == "ssh") | .href' |
  while read repo; do
    echo "Cloning $repo into $TARGET_DIR/$(basename "$repo" .git) ..."
    git clone "$repo" "$(basename "$repo" .git)"
  done
