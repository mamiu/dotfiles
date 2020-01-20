# SET VARIABLES
set -x LC_ALL en_US.UTF-8
set -x LANG en_US.UTF-8
set -x TERM xterm-256color
set -x EDITOR vim
set -x FZF_DEFAULT_COMMAND 'fd -H -t f -E .git -E GoogleDrive'

set -x FZF_DEFAULT_COMMAND 'fd --hidden --type file --color always -E ".git" -E "GoogleDrive" -E "Library/Calendars" -E "Library/Application Support" -E "Library/Google" -E "Library/Group Containers" -E "Library/Containers" -E "Library/Caches" -E ".Trash" -E "node_modules" -E "*.zip" -E "*.dmg" -E "*.png" -E "*.jpg" -E "*.jpeg" -E "*.so" -E "*.db" -E "*.plist" -E "*.tar" -E "*.tar.gz" -E "*.7z" -E "*.ttf" -E "*.otf" -E "*.woff" -E "*.woff2" -E "*.dat" -E "*.sqlite" -E "*.sqlite3" -E "*.sqlite-wal" -E "*.sqlite-shm" -E "*.db-wal" -E "*.db-shm" -E "*.ico" -E "*.icns" -E ".DS_Store" -E ".localize"'
set -x FZF_DEFAULT_OPTS '--ansi'

# SET KUBERNETES EXECUTABLE PATHS
#set -x PATH $PATH /Users/manuel.miunske/.vs-kubernetes/tools/helm/darwin-amd64
#set -x PATH $PATH /Users/manuel.miunske/.vs-kubernetes/tools/draft/darwin-amd64
#set -x PATH $PATH /Users/manuel.miunske/.vs-kubernetes/tools/kubectl
#set -x PATH $PATH /Users/manuel.miunske/.vs-kubernetes/tools/minikube/darwin-amd64
#set -x PATH $PATH $HOME/.cargo/bin

#set -x ANDROID_SDK $HOME/Library/Android/sdk
#set -x PATH $ANDROID_SDK/emulator $ANDROID_SDK/tools $PATH

# IMPORT FISH SCRIPTS
source $HOME/.config/fish/fish_user_key_bindings.fish
source $HOME/.homesick/repos/homeshick/homeshick.fish
source $HOME/.homesick/repos/homeshick/completions/homeshick.fish

# DISABLE FISH GREETING
set --erase fish_greeting

# START TMUX IF TMUX_AUTOSTART ENVIRONMENT VARIABLE IS SET,
# CURRENT SHELL IS LOGIN SHELL AND SHELL IS NOT INSIDE TMUX
if test "$TMUX_AUTOSTART" = "true"
    if status --is-login
        if test -z "$TMUX"
            tmux attach >/dev/null ^&1
            or tmux
            and kill %self
        end
    end
end

# CUSTOM USER FUNCTIONS
function ls
    command ls -h --group-directories-first --color $argv

end

function la
    ls -lah --group-directories-first --color $argv

end

function vim
    if count $argv >/dev/null
        command vim $argv
    else
        vim (fzf --preview 'bat --style=numbers --color=always {} | head -500')
    end
end

# ALIASES
alias ls="ls -h --group-directories-first --color"
alias la="ls -lah --group-directories-first --color"
alias ssh="env TMUX_AUTOSTART=true mosh"
#alias emu="nohup $HOME/Library/Android/sdk/emulator/emulator '@Pixel_3a_rooted_' >/dev/null 2>&1 &; disown"

# BOBTHEFISH THEME CONFIGURATION
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
#set -g theme_display_k8s_context yes

