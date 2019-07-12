#!/bin/bash

set -eu
set -o pipefail

IGNORE=${1:-(?!)}
USER_NAME=${2:-"(sugarshin\|(Shingo Sato"}

git ls-files | grep -v "$IGNORE" | xargs -n1 git --no-pager blame -f -w | grep "${USER_NAME}" | wc -l
