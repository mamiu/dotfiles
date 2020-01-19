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

TARGET_USER_HOME=$(su - $TARGET_USER -c 'echo $HOME')

echo Starting installation of the most basic macOS dependencies...

# Install homebrew
sudo -Hu $TARGET_USER /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install brew packages
# highly recommended (basics)
sudo -Hu $TARGET_USER brew install coreutils binutils diffutils findutils bash openssh python
# recommended (cli tools)
sudo -Hu $TARGET_USER brew install git fish tmux ncdu vim kubernetes-cli fzf bat fd ripgrep
# optional
# brew install gnutls grep less gawk gnu-sed gnu-tar gzip rsync wget wdiff gnu-indent unzip gnu-which watch

# Create a folder with symbolic links to all the gnu binaries
mkdir /usr/local/gnubin
chown -R $TARGET_USER:admin /usr/local/gnubin/

for gnuutil in /usr/local/opt/**/libexec/gnubin/*; do
    sudo -Hu $TARGET_USER ln -s "$gnuutil" /usr/local/gnubin/
done

for pybin in /usr/local/opt/python/libexec/bin/*; do
    sudo -Hu $TARGET_USER ln -s "$pybin" /usr/local/gnubin/
done

# Add /usr/local/gnubin as first line to /etc/paths
sed -i '' '1s/^/\/usr\/local\/gnubin\'$'\n/' /etc/paths

# Install dotfiles
sudo -Hu $TARGET_USER git clone https://github.com/andsens/homeshick.git "$TARGET_USER_HOME/.homesick/repos/homeshick"
sudo -Hu $TARGET_USER "$TARGET_USER_HOME/.homesick/repos/homeshick/bin/homeshick" clone -b mamiu/dotfiles
sudo -Hu $TARGET_USER "$TARGET_USER_HOME/.homesick/repos/homeshick/bin/homeshick" link -f dotfiles

# Make fish the default shell
echo $(which fish) >> /etc/shells
chsh -s $(which fish) $TARGET_USER

# Generate ssh key pair
sudo -Hu $TARGET_USER mkdir "$TARGET_USER_HOME/.ssh"
sudo -Hu $TARGET_USER ssh-keygen -b 2048 -t rsa -f "$TARGET_USER_HOME/.ssh/id_rsa" -q -N ""

# Install fisher - a package manager for the fish shell
sudo -Hu $TARGET_USER curl https://git.io/fisher --create-dirs -sLo "$TARGET_USER_HOME/.config/fish/functions/fisher.fish"
sudo -Hu $TARGET_USER fish -c fisher

# Install vim plugins
sudo -Hu $TARGET_USER vim

# Install tmux plugin manager and tmux plugins
sudo -Hu $TARGET_USER git clone https://github.com/tmux-plugins/tpm $TARGET_USER_HOME/.tmux/plugins/tpm
sudo -Hu $TARGET_USER tmux new-session "$TARGET_USER_HOME/.tmux/plugins/tpm/tpm && $TARGET_USER_HOME/.tmux/plugins/tpm/scripts/install_plugins.sh"

# Disable the security assessment policy subsystem
spctl --master-disable

# Download and install FiraCode font
curl -L https://github.com/tonsky/FiraCode/releases/download/2/FiraCode_2.zip -o ./fira_code_2.zip
unzip fira_code_2.zip -d ./fira_code_2
chown root:wheel ./fira_code_2/otf/*
mv fira_code_2/otf/* /Library/Fonts/
rm -rf ./fira_code_2*

# Install iTerm2
sudo -Hu $TARGET_USER brew cask install iterm2

# Done
echo
echo "All dependencies are installed successfully."
echo
echo "Now you can install the mac apps of your choise."
echo "The browser will automatically open at step 14 of this guide:"
echo "https://github.com/mamiu/dotfiles/blob/master/install/setup-os/macos.md"

sudo -Hu $TARGET_USER open "https://github.com/mamiu/dotfiles/blob/master/install/setup-os/macos.md#14-install-mac-apps-only-the-ones-you-really-need"
