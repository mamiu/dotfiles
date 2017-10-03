#!/bin/bash

if [ $EUID != 0 ]; then
    echo "Installation script has to be called with root permissions!"
    exit 1
fi

echo "start installation"

# ask for root user password change
# ask for admin user password change

# call commands from readme file

#git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# Press `prefix + I` (capital i, as in install) to fetch the plugins

# install docker

#reboot
