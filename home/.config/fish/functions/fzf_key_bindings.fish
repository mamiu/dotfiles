
# Key bindings
# ------------
function fzf_key_bindings

    function fzf-history-widget -d "Show command history"
        set -q FZF_TMUX_HEIGHT
        or set FZF_TMUX_HEIGHT 40%
        begin
            set -lx FZF_DEFAULT_OPTS "--height $FZF_TMUX_HEIGHT $FZF_DEFAULT_OPTS --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS +m"

            set -l FISH_MAJOR (echo $version | cut -f1 -d.)
            set -l FISH_MINOR (echo $version | cut -f2 -d.)

            # history's -z flag is needed for multi-line support.
            # history's -z flag was added in fish 2.4.0, so don't use it for versions
            # before 2.4.0.
            if [ "$FISH_MAJOR" -gt 2 -o \( "$FISH_MAJOR" -eq 2 -a "$FISH_MINOR" -ge 4 \) ]
                if type -q $__BAT_CMD
                    and test $CTRL_R_ENABLE_COLORS = "true"
                    builtin history -z |
                    awk -v ORS='⏎ ' '1' |
                    string replace -r '⏎ $' '' |
                    string split0 |
                    command $__BAT_CMD --paging=never -p --color=always --italic-text=always -l bash |
                    cut -c-400 |
                    eval (__fzfcmd) --print0 -q '(commandline)' |
                    string replace -ar '⏎ ' '\n' |
                    read -gz result
                    and commandline -- $result
                else
                    builtin history -z | eval (__fzfcmd) --read0 --print0 -q '(commandline)' | read -gz result
                    and commandline -- $result
                end
            else
                builtin history | eval (__fzfcmd) -q '(commandline)' | read -l result
                and commandline -- $result
            end
        end
        commandline -f repaint
    end

    function fzf-cd-widget -d "Change directory"
        set -l commandline (__fzf_parse_commandline)
        set -l dir $commandline[1]
        set -l fzf_query $commandline[2]

        set -q FZF_ALT_C_COMMAND
        or set -l FZF_ALT_C_COMMAND "command $__FD_CMD -H -t d $FZF_GLOBAL_EXCLUDES 2>/dev/null | awk -v home="$HOME" 'BEGIN{ print home } { print $0 }'"
        set -q FZF_TMUX_HEIGHT
        or set FZF_TMUX_HEIGHT 40%
        begin
            set -lx FZF_DEFAULT_OPTS "--height $FZF_TMUX_HEIGHT --reverse $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS"
            eval "$FZF_ALT_C_COMMAND | "(__fzfcmd)' +m --query "'$fzf_query'"' | read -l result

            if [ -n "$result" ]
                builtin cd $result

                # Remove last token from commandline.
                commandline -t ""
            end
        end

        commandline -f repaint
    end

    function __fzfcmd
        set -q FZF_TMUX
        or set FZF_TMUX 0
        set -q FZF_TMUX_HEIGHT
        or set FZF_TMUX_HEIGHT 40%
        if [ $FZF_TMUX -eq 1 ]
            echo "fzf-tmux -d$FZF_TMUX_HEIGHT"
        else
            echo "fzf"
        end
    end

    bind \ct fzf-file-widget
    bind \cr fzf-history-widget
    bind \ec fzf-cd-widget

    if bind -M insert >/dev/null 2>&1
        bind -M insert \ct fzf-file-widget
        bind -M insert \cr fzf-history-widget
        bind -M insert \ec fzf-cd-widget
    end

    function __fzf_parse_commandline -d 'Parse the current command line token and return split of existing filepath and rest of token'
        # eval is used to do shell expansion on paths
        set -l commandline (eval "printf '%s' "(commandline -t))

        if [ -z $commandline ]
            # Default to current directory with no --query
            set dir '.'
            set fzf_query ''
        else
            set dir (__fzf_get_dir $commandline)

            if [ "$dir" = "." -a (string sub -l 1 $commandline) != '.' ]
                # if $dir is "." but commandline is not a relative path, this means no file path found
                set fzf_query $commandline
            else
                # Also remove trailing slash after dir, to "split" input properly
                set fzf_query (string replace -r "^$dir/?" '' "$commandline")
            end
        end

        echo $dir
        echo $fzf_query
    end

    function __fzf_get_dir -d 'Find the longest existing filepath from input string'
        set dir $argv

        # Strip all trailing slashes. Ignore if $dir is root dir (/)
        if [ (string length $dir) -gt 1 ]
            set dir (string replace -r '/*$' '' $dir)
        end

        # Iteratively check if dir exists and strip tail end of path
        while [ ! -d "$dir" ]
            # If path is absolute, this can keep going until ends up at /
            # If path is relative, this can keep going until entire input is consumed, dirname returns "."
            set dir (dirname "$dir")
        end

        echo $dir
    end

end
