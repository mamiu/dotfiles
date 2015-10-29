# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

# Start tmux at login if there's a running session
if [[ -z "$TMUX" ]]; then
    tmux has-session &> /dev/null
    if [ $? -eq 1 ]; then
        exec tmux
        exit
    else
        exec tmux attach
        exit
    fi
else
    # use fish as login shell
    fish -l
    exit
fi
