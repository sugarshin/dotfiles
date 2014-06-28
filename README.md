# Initialize setting of Mac

* OSX 10.9.3
* MacBook Pro Retina 15 inch

## How to

### Brewfile

```
xcode-select --install

ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

cd

brew bundle

ln -s "/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl" ~/bin/subl

subl /etc/shells

/bin/bash
/bin/csh
/bin/ksh
/bin/sh
/bin/tcsh
/bin/zsh
/usr/local/bin/zsh


chsh -s /usr/local/bin/zsh

```

### .zshrc

* [.zshrc](https://github.com/sugarshin/initial-setting-mac/blob/master/.zshrc)

```
source ~/.zshrc
```

### node

```
nodebrew ls-remote  
nodebrew install-binary <version>
nodebrew use <version>
node -v
```

### ruby, sass

```
rbenv install --list
rbenv install -v <version>
rbenv global <version>
rbenv rehash
ruby -v

gem install sass
sass -v
```

### Sublime Text

* [Package Control.sublime-settings](https://github.com/sugarshin/initial-setting-mac/blob/master/Package Control.sublime-settings)
* [Preferences.sublime-settings](https://github.com/sugarshin/initial-setting-mac/blob/master/Preferences.sublime-settings)


### Terminal color scheme

[SMYCK](http://color.smyck.org/)

* [hukl-Smyck-Color-Scheme-fc16622.zip](https://github.com/sugarshin/initial-setting-mac/blob/master/hukl-Smyck-Color-Scheme-fc16622.zip)


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
* Eggy
