# .bash_profile

export PATH=$HOME/bin:/usr/local/bin:$PATH

# Source global definitions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi


# Use fish as login shell
case "$-" in
    *i*) fish -il; exit ;;
    *)  ;;
esac

export PATH="$HOME/.cargo/bin:$PATH"
