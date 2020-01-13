# SET VARIABLES
set TERM xterm-256color
set -x EDITOR vim
set -x LC_ALL en_US.utf-8
set -x LANG en_US.utf-8

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
            tmux attach >/dev/null ^&1
            or tmux
            and kill %self
        end
    end
end

# ALIASES
alias ls="ls -h --group-directories-first --color"
alias la="ls -lah --group-directories-first --color"
alias ssh="env TMUX_AUTOSTART=true ssh"
#alias emu="nohup $HOME/Library/Android/sdk/emulator/emulator '@Pixel_3a_rooted_' >/dev/null 2>&1 &; disown"

