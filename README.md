# dotfiles

* [Brewfile](https://github.com/sugarshin/initial-setting-mac/blob/master/.brewfile/Brewfile)
* [Atomfile](https://github.com/sugarshin/initial-setting-mac/blob/master/Atomfile)

```sh
xcode-select --install
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
cd
brew bundle
apm install --packages-file Atomfile
touch ~/.gitconfig.local
```
