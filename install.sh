if [ -d ~/dotfiles ]; then
  cd ~/dotfiles
  git fetch origin --prune
  git reset --hard origin/master
  cd -
else
  git clone git@github.com:sugarshin/dotfiles.git ~/dotfiles
fi
/bin/sh ~/dotfiles/setup.sh
