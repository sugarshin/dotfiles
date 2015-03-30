# dotfiles

## Setup

### Brewfile

* [Brewfile](https://github.com/sugarshin/initial-setting-mac/blob/master/Brewfile)

```shell
xcode-select --install

ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

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

### Sublime Text

```shell
ln -s "/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl" ~/bin/subl
```

Package Control

[https://sublime.wbond.net/installation](https://sublime.wbond.net/installation)

* [Package Control.sublime-settings](https://github.com/sugarshin/initial-setting-mac/blob/master/Package Control.sublime-settings)
* [Preferences.sublime-settings](https://github.com/sugarshin/initial-setting-mac/blob/master/Preferences.sublime-settings)

### Git

* [.gitconfig](https://github.com/sugarshin/initial-setting-mac/blob/master/.gitconfig)

* Add `~/.gitconfig.local`

* [.gitignore_global](https://github.com/sugarshin/initial-setting-mac/blob/master/.gitignore_global)

### App Store

* 1Password
* Keynote
* Numbers
* Pages
* Slicy
* Simplenote
* Page Layers
* ForkLift
* Noizio

// * CopyLess

### Other apps

* [QuickRes](http://www.quickresapp.com/)

### Other setting

Show dotfiles

```shell
defaults write com.apple.finder AppleShowAllFiles YES
```

Generating SSH Keys

[https://help.github.com/articles/generating-ssh-keys](https://help.github.com/articles/generating-ssh-keys)
