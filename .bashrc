export HOMEBREW_BREWFILE=~/github.com/sugarshin/dotfiles/.brewfile/Brewfile

# anyenv
#export PATH="$HOME/.anyenv/bin:$PATH"
#eval "$(anyenv init -)"

# colordiff
if [[ -x `which colordiff` ]]; then
  alias diff='colordiff -u'
else
  alias diff='diff -u'
fi

