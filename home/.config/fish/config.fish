# SET ENVIRONMENT VARIABLES
set -x LC_ALL en_US.UTF-8
set -x LANG en_US.UTF-8
set -x TERM xterm-256color
set -x EDITOR vim
set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_CACHE_HOME $HOME/.cache
set -x XDG_DATA_HOME $HOME/.local/share

# CHECK IF BAT IS INSTALLED (CAT ALTERNATIVE)
if type -q bat
    set -g __BAT_CMD (which bat)
else if type -q batcat
    set -g __BAT_CMD (which batcat)
    alias bat=batcat
end

# CHECK IF FD IS INSTALLED (FIND ALTERNATIVE)
if type -q fd
    set -g __FD_CMD (which fd)
else if type -q fdfind
    set -g __FD_CMD (which fdfind)
    alias fd=fdfind
end

# SET BAT AS PAGER (IF IT'S INSTALLED)
if type -q $__BAT_CMD
    set -x PAGER "$__BAT_CMD -p"
    set -x MANPAGER "sh -c 'col -bx | $__BAT_CMD -l man --style=plain,numbers'"
    set -x MANROFFOPT "-c"
    set -x SYSTEMD_PAGER "$__BAT_CMD -l log -p"
end

# BOBTHEFISH THEME CONFIGS
set -g theme_display_git yes
set -g theme_display_git_master_branch yes
set -g theme_display_user ssh
set -g theme_display_hostname ssh
set -g theme_display_date yes
set -g theme_title_use_abbreviated_path yes
set -g theme_title_display_user yes
set -g fish_prompt_pwd_dir_length 0
set -g theme_project_dir_length 0
set -g theme_date_format "+%d.%m.%Y %H:%M:%S"
set -g theme_powerline_fonts yes
set -g theme_show_exit_status yes
set -g theme_display_jobs_verbose yes
set -g theme_color_scheme base16

# FISH SHELL CONFIGS
if not set -q USE_TMUX_BY_DEFAULT
    set USE_TMUX_BY_DEFAULT true
end
set ONLY_ATTACH_TO_TMUX_IN_SSH_SESSIONS true
set -g CTRL_R_ENABLE_COLORS true # this option makes the CTRL-R function slower (just try it)

# IMPORT FISH SCRIPTS
source $HOME/.homesick/repos/homeshick/homeshick.fish
source $HOME/.homesick/repos/homeshick/completions/homeshick.fish
if test -f $HOME/bin/google-cloud-sdk/path.fish.inc
    source $HOME/bin/google-cloud-sdk/path.fish.inc
end

# ALIASES
alias ls="ls -h --group-directories-first --color"
alias la="ls -lah --group-directories-first --color"
alias ssh="env TMUX_AUTOSTART=true ssh"
alias mosh="env TMUX_AUTOSTART=true mosh"

# TMUX FISH INTEGRATION
# Replace currently running shell with tmux if
#  - current shell is a login shell AND
#  - current shell is interactive AND
#  - either the "$TMUX_AUTOSTART" environment variable or the "$USE_TMUX_BY_DEFAULT" variable is set to true
if status is-login
    and status is-interactive
    # the following condition check is a workaround for this bug (and should be removed once it's solved): https://github.com/microsoft/vscode-remote-release/issues/4813#issuecomment-818780854
    and not ps -o command $fish_pid | tail -1 | awk '{print $2}' | string match "*c*" >/dev/null
    and test "$TMUX_AUTOSTART" = "true" -o "$USE_TMUX_BY_DEFAULT" = "true"
    # make sure that current shell is not inside tmux
    set -l TMUX_SESSIONS (tmux ls 2>&1 | cut -c-17)
    if test "$TMUX_SESSIONS" = "no server running" -o -z "$TMUX"
        # not inside of tmux session therefore create new one
        if test -n "$SSH_CLIENT" -o -n "$SSH_CONNECTION" -o -n "$SSH_TTY" -o "$ONLY_ATTACH_TO_TMUX_IN_SSH_SESSIONS" = "false"
            # only try to attach to existing tmux session if in ssh session or if specified with config var
            exec tmux new-session -A -s main
        else
            exec tmux
        end
    else
        # redraw tmux window if a new shell is created
        tmux refresh-client
    end
end

# CUSTOM USER FUNCTIONS

# CUSTOM FZF INTEGRATION
# more infos about fzf can be found here: https://github.com/junegunn/fzf
# this custom fzf integration may be replaced in the future by this fish plugin: https://github.com/PatrickF1/fzf.fish
if type -q fzf
    # FZF (FUZZY FINDER) CONFIGS
    set -gx FZF_ALT_C_OPTS ""
    set -gx FZF_CTRL_R_OPTS ""
    set -gx FZF_DEFAULT_OPTS "--ansi -0 -1 --multi --height 40% --layout reverse --info inline --bind change:top --bind alt-space:toggle --bind tab:toggle+clear-query --bind alt-enter:toggle+down --prompt='██ ' --color 'prompt:#dddddd,bg:#282828'"

    set -l FZF_EXCLUDED_DIRS '.git' 'GoogleDrive' 'Google Drive' 'Library' '.Trash' 'node_modules'
    set -l FZF_EXCLUDED_FILES '*.zip' '*.tar' '*.tar.gz' '*.7z' '*.dmg' '*.png' '*.jpg' '*.jpeg' '*.so' '*.db' '*.plist' '*.ttf' '*.otf' '*.woff' '*.woff2' '*.dat' '*.sqlite' '*.sqlite3' '*.sqlite-wal' '*.sqlite-shm' '*.db-wal' '*.db-shm' '*.ico' '*.icns' '.DS_Store' '.localize'
    set -l FZF_FD_EXCLUDES "-E='"$FZF_EXCLUDED_DIRS"'"
    set -gx FZF_FD_EXCLUDES $FZF_FD_EXCLUDES "-E='"$FZF_EXCLUDED_FILES"'"
    set -l FZF_FIND_EXCLUDES "-not \( -ipath '*"$FZF_EXCLUDED_DIRS"/*' -prune \)"
    set -gx FZF_FIND_EXCLUDES $FZF_FIND_EXCLUDES "-not -iname '"$FZF_EXCLUDED_FILES"'"

    if type -q $__FD_CMD
        set -gx FZF_DEFAULT_COMMAND "$__FD_CMD --hidden --follow --type file $FZF_FD_EXCLUDES"
    else
        set -gx FZF_DEFAULT_COMMAND "bash -c \"find * -type f,l $FZF_FIND_EXCLUDES\""
    end

    # FZF SPECIFIC USER FUNCTIONS
    function vim
        if count $argv >/dev/null
            command vim $argv
        else
            set -l fzf_params "-m"
            set -l fzf_params $fzf_params "--height=40%"
            set -l fzf_params $fzf_params "--layout=reverse"
            set -l fzf_params $fzf_params "--info=inline"
            set -l fzf_params $fzf_params "--bind=change:top"
            set -l fzf_params $fzf_params "--bind=tab:toggle+down+clear-query"
            set -l fzf_params $fzf_params "--prompt=██ "
            set -l fzf_params $fzf_params "--color=prompt:#dddddd,bg:#282828"
            if type -q $__BAT_CMD
                set fzf_params $fzf_params "--preview=$__BAT_CMD --style=numbers --color=always {} | head -500"
            end
            command vim (fzf $fzf_params)
        end
    end

    function cd
        if count $argv >/dev/null
            if [ "$argv[1]" = ".." ]
                set -gx FZF_ALT_C_COMMAND "command pwd | awk '@include \"join\"; { split(\$0, a, \"/\") } END { for (i = 1; i < length(a) - 1; i++) { print join(a, 1, length(a) - i, \"/\") } }'"
                fzf-cd-widget
                set -e FZF_ALT_C_COMMAND
            else
                builtin cd $argv
            end
        else
            fzf-cd-widget
        end
    end

    function history
        if count $argv >/dev/null
            builtin history $argv
        else
            fzf-history-widget
        end
    end
end
