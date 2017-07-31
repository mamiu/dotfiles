# .bash_profile

# Source global definitions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi


# Use fish as login shell
case "$-" in
    *i*) fish -il; exit ;;
    *)  ;;
esac
