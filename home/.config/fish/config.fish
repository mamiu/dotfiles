# THINGS TO DO AT FISH INIT
set TERM xterm-256color
set PATH $PATH ~/bin
set -x EDITOR vim

source $HOME/.config/fish/fish_user_key_bindings.fish
source $HOME/.config/fish/.promptline.fish
source $HOME/.homesick/repos/homeshick/homeshick.fish
source $HOME/.homesick/repos/homeshick/completions/homeshick.fish

set --erase fish_greeting

# SELF DEFINED FUNCTIONS
function sudo -d "run the last command as root with sudo !! or call sudo with fish as shell"
    if test "$argv" = "!!"
        commandline -r 'sudo '$history[1]; and commandline -f execute
    else
        command sudo -s fish -c "$argv"
    end
end

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
