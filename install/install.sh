#!/bin/bash


bold_start=$(tput bold)
bold_end=$(tput sgr0)

echo
echo "Welcome to the ${bold_start}fedora server setup${bold_end} script!"
echo


configure_new_server()
{
    echo "Configure new server"
    # servers domain or ip address

    # username with root privileges on the server

    # servers port

    # autostart tmux at login

    # nickname for the server

    # login without entering a password in the future (adding id_rsa to known_hosts on server)

    # add this config to ssh config
}

choose_host()
{
  select option; do # in "$@" is the default
    if [[ "$REPLY" =~ ^-?[0-9]+$ ]]
    then
        if [ "$REPLY" -eq "1" ];
        then
            configure_new_server
            break;
        elif [ 1 -lt "$REPLY" ] && [ "$REPLY" -le "$#" ];
        then
            hostname=(`ssh -G "$option" | grep "^hostname " | sed 's/hostname[ ]*//g'`)
            user=(`ssh -G "$option" | grep "^user " | sed 's/user[ ]*//g'`)
            port=(`ssh -G "$option" | grep "^port " | sed 's/port[ ]*//g'`)

            echo "ssh -p $port $user@$hostname"

            break;
        else
            echo "Incorrect Input: Select a number 1-$#"
        fi
    else
        echo "Incorrect Input: Select a number 1-$#"
    fi
  done
}

setup_server()
{
    echo "Setup server"
    # log into server
    #ssh server.miu.io -t "curl -sL https://raw.githubusercontent.com/mamiu/dotfiles/master/install/setup_server.sh | bash"

    # download and call setup script on server
    # reboot server
}

# get the hosts from ~/.ssh/config
hosts=(`grep -w -i "Host" ~/.ssh/config | sed 's/[ ]*[Hh][Oo][Ss][Tt][ ]*//g'`)

# add option 'New Server' to array
host_options=('New Server')
host_options+=("${hosts[@]}")

echo Choose the server you want to setup:
choose_host "${host_options[@]}"
echo

setup_server

echo
# output login info





#read -p "Is this a good question (y/n)? " answer
#case ${answer:-yes} in
    #yes|Yes )
        #echo Yes
    #;;
    #* )
        #echo No
    #;;
#esac
