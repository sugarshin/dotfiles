[ -f ~/.commonrc ] && source ~/.commonrc
[ -f ~/.bashrc.local ] && source ~/.bashrc.local

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path bash)"
