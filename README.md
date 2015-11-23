# dotfiles

## Setup

### Brewfile

* [Brewfile](https://github.com/sugarshin/initial-setting-mac/blob/master/.brewfile/Brewfile)

```shell
xcode-select --install

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

cd

brew bundle
```

### Zsh

* [.zshrc](https://github.com/sugarshin/initial-setting-mac/blob/master/.zshrc)

```shell
vi /etc/shells

/bin/bash
/bin/csh
/bin/ksh
/bin/sh
/bin/tcsh
/bin/zsh
/usr/local/bin/zsh


chsh -s /usr/local/bin/zsh

source ~/.zshrc
```

### Atom

```shell
apm stars --install
```

### Git

* [.gitconfig](https://github.com/sugarshin/initial-setting-mac/blob/master/.gitconfig)

* Add `~/.gitconfig.local`

* [.gitignore_global](https://github.com/sugarshin/initial-setting-mac/blob/master/.gitignore_global)

### Other apps

* [QuickRes](http://www.quickresapp.com/)

### Other setting

Show dotfiles

```shell
defaults write com.apple.finder AppleShowAllFiles YES
```
