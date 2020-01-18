#!/usr/bin/env bash

if [ $EUID != 0 ]; then
    echo "Installation script has to be called with root permissions!"
    exit 1
fi

while [ "$#" -gt 0 ]; do
    case "$1" in
        -u)
            if [ -z "$2" ]; then
                shift
            fi
            TARGET_USER="$2"
            shift 2
        ;;
        # call this parameter admin user to make it compatible with the other installation scripts
        --admin-user=*)
            TARGET_USER="${1#*=}"
            shift
        ;;
        *)
            echo "unknown option: $1" >&2
            shift
        ;;
    esac
done

if [ -z "$TARGET_USER" ]; then
    echo "Target user must be specified via '-u <USERNAME>' or '--admin-user=<USERNAME>' script parameter"
    exit 1
fi

# run command as target user
# example:
#   whoami               ==> root
#   run_as_user whoami   ==> <TARGET_USER>
run_as_user() {
    COMMAND="$@"
    echo `sudo -Hu "$TARGET_USER" /bin/bash -c "$COMMAND"`
}

echo Starting installation of the most basic macOS dependencies...

# Install homebrew
run_as_user /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install brew packages
# highly recommended (basics)
run_as_user brew install coreutils binutils diffutils findutils bash openssh python
# recommended (cli tools)
run_as_user brew install git fish tmux ncdu vim kubernetes-cli fzf bat fd ripgrep
# optional
# brew install gnutls grep less gawk gnu-sed gnu-tar gzip rsync wget wdiff gnu-indent unzip gnu-which watch

# Create a folder with symbolic links to all the gnu binaries
mkdir /usr/local/gnubin
chown -R $USER:admin /usr/local/gnubin/

for gnuutil in /usr/local/opt/**/libexec/gnubin/*; do
    run_as_user ln -s $gnuutil /usr/local/gnubin/
done

for pybin in /usr/local/opt/python/libexec/bin/*; do
    run_as_user ln -s $pybin /usr/local/gnubin/
done

# Add /usr/local/gnubin as first line to /etc/paths
sed -i '' '1s/^/\/usr\/local\/gnubin\'$'\n/' /etc/paths

# Install dotfiles
run_as_user git clone https://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
run_as_user $HOME/.homesick/repos/homeshick/bin/homeshick clone -b mamiu/dotfiles
run_as_user $HOME/.homesick/repos/homeshick/bin/homeshick link -f dotfiles

# Make fish the default shell
sh -c 'echo $(which fish) >> /etc/shells'
chsh -s $(which fish) $USER

# Generate ssh key pair
run_as_user mkdir $HOME/.ssh
run_as_user ssh-keygen -b 2048 -t rsa -f $HOME/.ssh/id_rsa -q -N ""

# Install fisher - a package manager for the fish shell
run_as_user curl https://git.io/fisher --create-dirs -sLo $HOME/.config/fish/functions/fisher.fish
run_as_user fish -c fisher

# Install tmux plugin manager and tmux plugins
run_as_user git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
run_as_user tmux new-session "$HOME/.tmux/plugins/tpm/tpm && $HOME/.tmux/plugins/tpm/scripts/install_plugins.sh"

# Disable the security assessment policy subsystem
spctl --master-disable

# Download and install FiraCode font
curl -L https://github.com/tonsky/FiraCode/releases/download/2/FiraCode_2.zip -o ./fira_code_2.zip
unzip fira_code_2.zip -d ./fira_code_2
chown root:wheel ./fira_code_2/otf/*
mv fira_code_2/otf/* /Library/Fonts/
rm -rf ./fira_code_2*

# Install iTerm2
run_as_user brew cask install iterm2

# Done
echo
echo 'All dependencies are installed successfully.'
echo
echo 'Now you can install the mac apps of your choise.'
echo 'The browser will automatically open at step 14 of this guide:'
echo 'https://github.com/mamiu/dotfiles/blob/master/install/setup-os/macos.md'

run_as_user open 'https://github.com/mamiu/dotfiles/blob/master/install/setup-os/macos.md#14-install-mac-apps-only-the-ones-you-really-need'
