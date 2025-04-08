eval "$(/opt/homebrew/bin/brew shellenv)"

# Added by `rbenv init` on Thu Feb 27 15:24:27 JST 2025
eval "$(rbenv init - --no-rehash zsh)"

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
