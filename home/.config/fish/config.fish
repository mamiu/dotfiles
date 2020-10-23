# SET GLOBAL VARIABLES
set -x LC_ALL en_US.UTF-8
set -x LANG en_US.UTF-8
set -x TERM xterm-256color
set -x EDITOR vim
set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_CACHE_HOME $HOME/.cache
set -x XDG_DATA_HOME $HOME/.local/share

# SET BAT AS PAGER IF IT IS INSTALLED
if type -q bat
    set -x PAGER "bat -p"
    set -x MANPAGER "sh -c 'col -bx | bat -l man --style=plain,numbers'"
    set -x MANROFFOPT "-c"
    set -x SYSTEMD_PAGER "bat -l log -p"
end

# FZF (FUZZY FINDER) CONFIGS
set -gx FZF_GLOBAL_EXCLUDES --exclude '".git"' -E '"GoogleDrive"' -E '"Library/Calendars"' -E '"Library/Application Support"' -E '"Library/Google"' -E '"Library/Group Containers"' -E '"Library/Containers"' -E '"Library/Caches"' -E '".Trash"' -E '"node_modules"' -E '"*.zip"' -E '"*.dmg"' -E '"*.png"' -E '"*.jpg"' -E '"*.jpeg"' -E '"*.so"' -E '"*.db"' -E '"*.plist"' -E '"*.tar"' -E '"*.tar.gz"' -E '"*.7z"' -E '"*.ttf"' -E '"*.otf"' -E '"*.woff"' -E '"*.woff2"' -E '"*.dat"' -E '"*.sqlite"' -E '"*.sqlite3"' -E '"*.sqlite-wal"' -E '"*.sqlite-shm"' -E '"*.db-wal"' -E '"*.db-shm"' -E '"*.ico"' -E '"*.icns"' -E '".DS_Store"' -E '".localize"'
set -gx FZF_DEFAULT_COMMAND "fd --hidden --type file --color always $FZF_GLOBAL_EXCLUDES"
set -gx FZF_DEFAULT_OPTS "--ansi"
set -gx FZF_ALT_C_OPTS "-1 --info inline --bind change:top --prompt='██ ' --color 'prompt:#dddddd,bg:#282828'"
set -gx FZF_CTRL_R_OPTS "--reverse --info inline --bind change:top --prompt='██ ' --color 'prompt:#dddddd,bg:#282828'"

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
set USE_TMUX_BY_DEFAULT true
set ONLY_ATTACH_TO_TMUX_IN_SSH_SESSIONS true

# IMPORT FISH SCRIPTS
source $HOME/.homesick/repos/homeshick/homeshick.fish
source $HOME/.homesick/repos/homeshick/completions/homeshick.fish

# DISABLE FISH GREETING
set --erase fish_greeting

# ALIASES
alias ls="ls -h --group-directories-first --color"
alias la="ls -lah --group-directories-first --color"
alias ssh="env TMUX_AUTOSTART=true ssh"
alias mosh="env TMUX_AUTOSTART=true mosh"

# TMUX FISH INTEGRATION
# only start tmux if current shell is login shell and either the "tmux_autostart"
# environment variable or the "use_tmux_by_default" variable is set to true
if status --is-login
    and test "$TMUX_AUTOSTART" = "true" -o "$USE_TMUX_BY_DEFAULT" = "true"
    # make sure that current shell is not inside tmux
    set -l TMUX_SESSIONS (tmux ls 2>&1 | cut -c-17)
    if test "$TMUX_SESSIONS" = "no server running" -o -z "$TMUX"
        if test -n "$SSH_CLIENT" -o -n "$SSH_CONNECTION" -o -n "$SSH_TTY" -o "$ONLY_ATTACH_TO_TMUX_IN_SSH_SESSIONS" = "false"
            tmux attach >/dev/null 2>&1
            or tmux
            and kill -TERM %self
        else
            tmux
            and kill -TERM %self
        end
    else
        # redraw tmux window if a new shell is created
        tmux refresh-client
    end
end

# CUSTOM USER FUNCTIONS
function vim
    if count $argv >/dev/null
        command vim $argv
    else
        command vim (fzf -m --height 40% --layout reverse --info inline --bind change:top --bind tab:toggle+down+clear-query --preview 'bat --style=numbers --color=always {} | head -500' --prompt='██ ' --color 'prompt:#dddddd,bg:#282828')
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
