if [ -d ~/dotfiles ]; then
  cd ~/dotfiles
  git pull origin master
  cd -
else
  git clone git@github.com:sugarshin/dotfiles.git ~/dotfiles
fi
  /bin/sh ~/dotfiles/setup.sh
 
