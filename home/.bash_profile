# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/.local/bin:$HOME/bin

export PATH

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
