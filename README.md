# Initialize setting of Mac

* OSX 10.9.3
* MacBook Pro Retina

## Step

### Brewfile

* [Brewfile](https://github.com/sugarshin/initial-setting-mac/blob/master/Brewfile)

```
xcode-select --install

ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

cd

brew bundle
```

### Zsh

* [.zshrc](https://github.com/sugarshin/initial-setting-mac/blob/master/.zshrc)

```
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

### Node.js

```
nodebrew ls-remote
nodebrew install-binary <version>
nodebrew use <version>
node -v
```

### Ruby

```
rbenv install --list
rbenv install -v <version>
rbenv global <version>
rbenv rehash
ruby -v
```

### RubyGems

```
gem install sass
gem install tw
```

### Sublime Text

```
ln -s "/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl" ~/bin/subl
```

Package Control

[https://sublime.wbond.net/installation](https://sublime.wbond.net/installation)

* [Package Control.sublime-settings](https://github.com/sugarshin/initial-setting-mac/blob/master/Package Control.sublime-settings)
* [Preferences.sublime-settings](https://github.com/sugarshin/initial-setting-mac/blob/master/Preferences.sublime-settings)

### Atom

```
ln -s /Applications/Atom.app/Contents/MacOS/Atom /usr/local/bin/atom
```

### Terminal color scheme

[SMYCK](http://color.smyck.org/)

* [hukl-Smyck-Color-Scheme-fc16622.zip](https://github.com/sugarshin/initial-setting-mac/blob/master/hukl-Smyck-Color-Scheme-fc16622.zip)

### Git

* .gitconfig

```
git config --global user.name "name"
git config --global user.email "email"

git config --global alias.st status
git config --global alias.cm commit
git config --global alias.sts stash
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ad add
git config --global alias.ps push
git config --global alias.pl pull

git config --global core.excludesfile ~/.gitignore_global
git config --global push.default simple
```

* [.gitignore_global](https://github.com/sugarshin/initial-setting-mac/blob/master/.gitignore_global)


### Font

* [SourceCodePro_FontsOnly-1.013.zip](https://github.com/sugarshin/initial-setting-mac/blob/master/SourceCodePro_FontsOnly-1.013.zip)


### App Store

* 1Password
* Keynote
* Numbers
* Pages
* Slicy
* Simplenote
* Page Layers
* Caffeine
* WinArchiver Lite
* ForkLift
* CopyLess

### Other apps

* [QuickRes](http://www.quickresapp.com/)

### Other Setting

Show dotfile

```shell
defaults write com.apple.finder AppleShowAllFiles YES
```

Generating SSH Keys

[https://help.github.com/articles/generating-ssh-keys](https://help.github.com/articles/generating-ssh-keys)
