# default fish key bindings:
# https://github.com/fish-shell/fish-shell/blob/master/share/functions/fish_default_key_bindings.fish

# user defined key binding functions
function __comment_and_execute_commandline
    commandline -r "# "(commandline)
    commandline -f execute
end

function __watch_last_command
    commandline -b "watch -n 1 $history[1]"
    commandline -f execute
end

function __sudo_prefix_last_command
    commandline -b "sudo $history[1]"
    commandline -f execute
end

function __append_fzf_and_execute
    if type -q fzf
        if test -n ( commandline )
            commandline -r ( commandline | string trim )" | fzf"
        else
            commandline -b "$history[1] | fzf"
        end
        commandline -f execute
    end
end

function __change_directory
    if type -q fzf
        fzf-cd
    end
end

function __browse_history
    if type -q fzf
        fzf-history
    else
        builtin history | less

        echo -e "\n💡 Hint: You can reverse search the history by typing a few characters of"
        echo "the command you want to execute again and then press the UP arrow key ⬆️"
        commandline -f repaint
    end
end

# user defined key bindings
function fish_user_key_bindings
    fzf_commands
    bind \e\r accept-autosuggestion execute
    bind \el 'commandline -a la; commandline -f execute'
    bind \cf __append_fzf_and_execute
    bind \ck history-search-backward
    bind \eu upcase-word backward-word upcase-word
    bind \cc 'commandline -r ""'
    bind \ec __comment_and_execute_commandline
    bind \cj __change_directory
    bind \cr __browse_history
    bind \ew __watch_last_command
    bind \es __sudo_prefix_last_command
end
