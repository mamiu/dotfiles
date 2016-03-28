# THINGS TO DO AT FISH INIT
set TERM xterm-256color
set PATH ~/bin $PATH
set -x EDITOR vim

source $HOME/.config/fish/fish_user_key_bindings.fish
source $HOME/.config/fish/.promptline.fish
source $HOME/.homesick/repos/homeshick/homeshick.fish
source $HOME/.homesick/repos/homeshick/completions/homeshick.fish

set --erase fish_greeting

if test "$TMUX_AUTOSTART" = "true"
    if status --is-login
        tmux attach; and kill %self
    end
end

# SELF DEFINED FUNCTIONS
function cd -d "follow symlinks with cd (e.g. cd symlink --> goto directory, where the symlinks target is stored)"
    if begin; test -n "$argv"; and test (count "$argv") -eq 1; and test -L "$argv"; end
        builtin cd (dirname (readlink "$argv"))
    else
        builtin cd $argv
    end
end

# ALIASES
alias bash="bash --norc"
alias ack="command ack --pager='less -R'"
alias ls="ls -lh --group-directories-first --color"
alias la="ls -lah --group-directories-first --color"
# alias vim="gvim -v" # fix for fedora
