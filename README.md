# dotfiles

* [Brewfile](https://github.com/sugarshin/initial-setting-mac/blob/master/.brewfile/Brewfile)
* [Atomfile](https://github.com/sugarshin/initial-setting-mac/blob/master/Atomfile)

```sh
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install rcmdnk/file/brew-file
brew update
echo 'if [ -f $(brew --prefix)/etc/brew-wrap ];then
  source $(brew --prefix)/etc/brew-wrap
fi' >> ~/.bashrc
git clone git@github.com:sugarshin/dotfiles.git --depth=1
export HOMEBREW_BREWFILE=~/Dropbox/Brewfile
brew file install
apm install --packages-file Atomfile
touch ~/.gitconfig.local
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false         # For VS Code
defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false # For VS Code Insider
defaults delete -g ApplePressAndHoldEnabled
```
