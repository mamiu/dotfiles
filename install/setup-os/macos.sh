#!/usr/bin/env bash

# helper variables to make text bold
bold_start=$(tput bold)
bold_end=$(tput sgr0)

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
            if [[ -n "${1// }" ]]; then
                echo "unknown option: $1" >&2
            fi
            shift
        ;;
    esac
done

all_users=()
while IFS= read -r line; do
    all_users+=( "$line" )
done < <( dscl . list /Users | grep -v '^_' )

if [ -n "$TARGET_USER" ] && [[ ! " ${all_users[@]} " =~ " ${TARGET_USER} " ]]; then
    echo "Could not find the specified user $TARGET_USER on this system."

    read -p "Do you want to install ${bold_start}mamiu/dotfiles${bold_end} for another user? [${bold_start}Y${bold_end}/n] " install_for_other_user </dev/tty
    [ -z "$install_for_other_user" ] && install_for_other_user="y"
    case "${install_for_other_user:0:1}" in
        y|Y|yes|Yes )
            install_for_other_user=true
        ;;
        * )
            echo Abort installation
            exit 1
        ;;
    esac
fi

if [ -z "$TARGET_USER" ] || [ "$install_for_other_user" == "true" ]; then

    system_users=("daemon" "nobody" "root")

    for target in "${system_users[@]}"; do
        for i in "${!all_users[@]}"; do
            if [[ ${all_users[i]} = $target ]]; then
                unset 'all_users[i]'
            fi
        done
    done

    number_of_users=${#all_users[@]}

    if (( number_of_users == 0 )); then
        echo Couldn\'t find any user on this system
        exit 1
    elif (( number_of_users == 1 )); then
        for element in ${all_users[@]}; do
            user="$element"
        done
        TARGET_USER="$user"
        echo "Only user ${bold_start}${TARGET_USER}${bold_end} was found on this macOS system."
    else
        echo Choose a user account where you want to install the dotfiles:

        select user_option in "${all_users[@]}"
        do
            if [[ "$REPLY" =~ ^[1-9]+$ ]]; then
                if [ "$REPLY" -le "${#all_users[@]}" ]; then
                    TARGET_USER="$user_option"
                    break;
                else
                    echo "Incorrect Input: Select a number 1-${#all_users[@]}"
                fi
            else
                echo "Incorrect Input: Select a number 1-${#all_users[@]}"
            fi
        done </dev/tty || user_option="1"
    fi
fi

# Confirm if dotfiles should be installed in TARGET_USER account
read -p "Do you really want to install ${bold_start}mamiu/dotfiles${bold_end} for the user ${bold_start}${TARGET_USER}${bold_end}? [${bold_start}Y${bold_end}/n] " installation_confirmation </dev/tty
[ -z "$installation_confirmation" ] && installation_confirmation="y"
case "${installation_confirmation:0:1}" in
    y|Y|yes|Yes )
        echo
        echo "Starting installation of the most basic macOS dependencies..."
    ;;
    * )
        echo Abort installation
        exit 1
    ;;
esac

TARGET_USER_HOME=$(su - $TARGET_USER -c 'echo $HOME')

echo Starting installation of the most basic macOS dependencies...

# Install homebrew
sudo -Hu $TARGET_USER /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install brew packages
# highly recommended (basics)
sudo -Hu $TARGET_USER brew install coreutils binutils diffutils findutils bash openssh mosh python
# recommended (cli tools)
sudo -Hu $TARGET_USER brew install git fish tmux ncdu vim kubernetes-cli fzf bat fd ripgrep
# optional
# brew install gnutls grep less gawk gnu-sed gnu-tar gzip rsync wget wdiff gnu-indent unzip gnu-which watch
# macOS GUI apps
brew cask install iterm2

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

# Download dotfiles
sudo -Hu $TARGET_USER git clone https://github.com/andsens/homeshick.git "$TARGET_USER_HOME/.homesick/repos/homeshick"
sudo -Hu $TARGET_USER "$TARGET_USER_HOME/.homesick/repos/homeshick/bin/homeshick" clone -b mamiu/dotfiles

# Backup property list files in case they exist
for file in $TARGET_USER_HOME/.homesick/repos/dotfiles/home/Library/Preferences/*
do
    plist_filename=$(basename "$file")
    plist_path="$TARGET_USER_HOME/Library/Preferences/$plist_filename"
    if [ -f "$plist_path" ]; then
        mv "$plist_path" "${plist_path}_backup"
    fi
done

# Install dotfiles
sudo -Hu $TARGET_USER "$TARGET_USER_HOME/.homesick/repos/homeshick/bin/homeshick" link -f dotfiles

# Make fish the default shell
echo $(which fish) >> /etc/shells
chsh -s $(which fish) $TARGET_USER

# Generate ssh key pair
if [ ! -d "$TARGET_USER_HOME/.ssh" ]; then
    sudo -Hu $TARGET_USER mkdir "$TARGET_USER_HOME/.ssh"
    sudo -Hu $TARGET_USER ssh-keygen -b 2048 -t rsa -f "$TARGET_USER_HOME/.ssh/id_rsa" -q -N ""
fi

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

# Done
echo
echo "All dependencies are installed successfully."
echo
echo "Now you can install the mac apps of your choise."
echo "The browser will automatically open at step 16 of this guide:"
echo "https://github.com/mamiu/dotfiles/blob/master/install/setup-os/macos.md"

sudo -Hu $TARGET_USER open "https://github.com/mamiu/dotfiles/blob/master/install/setup-os/macos.md#16-install-mac-apps-only-the-ones-you-really-need"
