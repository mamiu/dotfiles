# SET VARIABLES
set TERM xterm-256color
set PATH ~/bin $PATH
set -x EDITOR vim
set -x LC_ALL en_US.utf-8
set -x LANG en_US.utf-8

# IMPORT FISH SCRIPTS
source $HOME/.config/fish/fish_user_key_bindings.fish
source $HOME/.config/fish/.promptline.fish
source $HOME/.homesick/repos/homeshick/homeshick.fish
source $HOME/.homesick/repos/homeshick/completions/homeshick.fish

# DISABLE FISH GREETING
set --erase fish_greeting

# START TMUX IF TMUX_AUTOSTART ENVIRONMENT VARIABLE IS SET,
# CURRENT SHELL IS LOGIN SHELL AND SHELL IS NOT INSIDE TMUX
if test "$TMUX_AUTOSTART" = "true"
    if status --is-login
        if test -z "$TMUX"
            tmux attach >/dev/null 2>&1; or tmux; and kill %self
        end
    end
end

# ALIASES
alias ack="command ack --pager='less -R'"
alias ls="ls -h --group-directories-first --color"
alias la="ls -lah --group-directories-first --color"
