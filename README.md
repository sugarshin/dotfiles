# dotfiles

* [Brewfile](https://github.com/sugarshin/initial-setting-mac/blob/master/.brewfile/Brewfile)
* [Atomfile](https://github.com/sugarshin/initial-setting-mac/blob/master/Atomfile)

```sh
# TODO
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install rcmdnk/file/brew-file
brew update
echo 'if [ -f $(brew --prefix)/etc/brew-wrap ];then
  source $(brew --prefix)/etc/brew-wrap
fi' >> ~/.bashrc
git clone git@github.com:sugarshin/dotfiles.git --depth=1
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/.gitignore.global ~/.gitignore.global
ln -s ~/dotfiles/.zpreztorc ~/.zpreztorc
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.bashrc ~/.bashrc
ln -s ~/dotfiles/.bash_profile ~/.bash_profile
export HOMEBREW_BREWFILE=~/dotfiles/.brewfile/Brewfile
brew file install
mkdir -p "$(nodenv root)"/plugins
git clone https://github.com/nodenv/nodenv-update.git "$(nodenv root)"/plugins/nodenv-update
apm install --packages-file Atomfile
touch ~/.gitconfig.local
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false         # For VS Code
defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false # For VS Code Insider
defaults delete -g ApplePressAndHoldEnabled
defaults write com.apple.finder AppleShowAllFiles TRUE
```

## Signing Git commits on GitHub using Keybase PGP Key

```sh
keybase -v
keybase version 2.5.2-20180906142014+a801e75b82

gpg --version
gpg (GnuPG) 2.2.10
libgcrypt 1.8.3

keybase pgp export | gpg --import
keybase pgp export --secret | gpg --allow-secret-key --import
```

if you have an error, try to bellow:

```
export GPG_TTY=$(tty)
```

Set .gitconfig

```
gpg --list-secret-keys

sec   rsa4096 2016-09-20 [SC]
      <id>
uid           [ unknown] Shingo Sato <shinsugar@gmail.com>
ssb   rsa2048 2016-09-20 [E] [expires: 2024-09-18]
ssb   rsa2048 2016-09-20 [SA] [expires: 2024-09-18]

git config --global user.signingkey <id>
git config --global commit.gpgsign true
```

