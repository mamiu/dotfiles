#!/usr/bin/env bash

# Make sure the script has sudo privileges
sudo echo Starting installation of the most basic macOS dependencies...

# Install homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install brew packages
# highly recommended (basics)
brew install coreutils binutils diffutils findutils bash openssh python
# recommended (cli tools)
brew install git fish tmux ncdu vim kubernetes-cli
# optional
# brew install gnutls grep less gawk gnu-sed gnu-tar gzip rsync wget wdiff gnu-indent unzip gnu-which watch

# Create a folder with symbolic links to all the gnu binaries
sudo mkdir /usr/local/gnubin
sudo chown -R $USER:admin /usr/local/gnubin/

for gnuutil in /usr/local/opt/**/libexec/gnubin/*; do
    ln -s $gnuutil /usr/local/gnubin/
done

for pybin in /usr/local/opt/python/libexec/bin/*; do
    ln -s $pybin /usr/local/gnubin/
done

# Add /usr/local/gnubin as first line to /etc/paths
sudo sed -i '' '1s/^/\/usr\/local\/gnubin\'$'\n/' /etc/paths

# Make fish the default shell
sudo sh -c 'echo $(which fish) >> /etc/shells'
sudo chsh -s $(which fish) $USER

# Generate ssh key pair
mkdir $HOME/.ssh
ssh-keygen -b 2048 -t rsa -f $HOME/.ssh/id_rsa -q -N ""

# Disable the security assessment policy subsystem
sudo spctl --master-disable

# Download and install FiraCode font
open https://github.com/tonsky/FiraCode

# Done
echo
echo 'All dependencies are installed successfully.'
echo
echo 'Now you can install the mac apps of your choise.'
echo '(The browser will automatically open at step 11 of this guide: https://gist.github.com/mamiu/4d71e3eb02ca9136b9a4ec9886b18597)'
open 'https://gist.github.com/mamiu/4d71e3eb02ca9136b9a4ec9886b18597#11-install-mac-apps-only-the-ones-you-really-need'
