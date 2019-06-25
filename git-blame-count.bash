#!/bin/bash

set -eu

readonly ignore=${1:-(?!)}
readonly user=${2:-"(sugarshin\|(Shingo Sato"}

git ls-files | grep -v "$ignore" | xargs -n1 git --no-pager blame -f -w | grep "${user}" | wc -l
