
# Source global definitions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# Use fish as login shell
case "$-" in
    *i*) exec fish -il ;;
    *)  ;;
esac
