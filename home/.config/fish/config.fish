# THINGS TO DO AT FISH INIT
set TERM xterm-256color
set PATH $PATH ~/bin
set -x EDITOR vim

source $HOME/.config/fish/fish_user_key_bindings.fish
source $HOME/.config/fish/.promptline.fish
source $HOME/.homesick/repos/homeshick/homeshick.fish

set --erase fish_greeting

# SELF DEFINED FUNCTIONS
function dd
    if test (echo $argv | cut -c 1-2) = "if"; and test (echo $argv | cut -d \  -f 2 | cut -c 1-2) = "of"
        set input_file (echo $argv | cut -d \  -f 1 | cut -c 4-)
        set target (echo $argv | cut -d \  -f 2 | cut -c 4-)
        set file_size (ls -lh $input_file | cut -d \  -f 5)
        set dd_arguments (echo $argv | cut -d \  -f 3-)
        sudo -v
        sudo bash -c "\dd if=$input_file $dd_arguments 2>/dev/null | pv -tpreb -s $file_size | \dd of=$target $dd_arguments 2>/dev/null"
    end
end

function sudo
    if test "$argv" = ""
        commandline -r 'sudo '$history[1]
        commandline -f execute
    else
        command sudo $argv
    end
end

function cd
    if begin; test -n "$argv"; and test (count "$argv") -eq 1; and test -L "$argv"; end
        builtin cd (dirname (readlink "$argv"))
    else
        builtin cd $argv
    end
end

# ALIASES
alias ack="command ack --pager='less -R'"
alias bash="bash --norc"

# COMPLETIONS
