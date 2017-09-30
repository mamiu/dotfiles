#!/bin/bash


bold_start=$(tput bold)
bold_end=$(tput sgr0)

echo
echo "Welcome to the ${bold_start}mamiu/dotfiles${bold_end} setup script!"
echo


configure_new_server()
{
    echo
    echo "Configure new server"

    # servers domain or ip address
    read -p "Hostname or ip addresse of the server: " hostname
    echo "servers ip address: $hostname"

    # username with root privileges on the server
    read -p "User name with root privileges [default=${bold_start}root${bold_end}]: " username
    [ -z "$username" ] && username="root"
    echo "servers username: $username"

    # servers port
    read -p "SSH port of the server [default=${bold_start}22${bold_end}]: " port
    [ -z "$port" ] && port="22"
    echo "servers port: $port"

    # autostart tmux at login
    read -p "Start tmux by default on login [${bold_start}Y${bold_end}/n]: " tmux_autostart
    [ -z "$tmux_autostart" ] && tmux_autostart="y"
    case "${tmux_autostart:0:1}" in
        y|Y )
            echo Yes
        ;;
        * )
            echo No
        ;;
    esac

    # login without entering a password in the future (adding id_rsa to known_hosts on server)
    read -p "Login without entering a password in the future [${bold_start}Y${bold_end}/n]: " ssh_copy_id
    [ -z "$ssh_copy_id" ] && ssh_copy_id="y"
    case "${ssh_copy_id:0:1}" in
        y|Y )
            echo Yes
        ;;
        * )
            echo No
        ;;
    esac

    # add this config to ssh config
    read -p "Add this config to ssh config [${bold_start}Y${bold_end}/n]: " add_ssh_config
    [ -z "$add_ssh_config" ] && add_ssh_config="y"
    case "${add_ssh_config:0:1}" in
        y|Y )
            echo Yes

            # nickname for the server
            read -p "Nickname for the server: " nickname
            echo "servers nickname: $nickname"
        ;;
        * )
            echo No
        ;;
    esac
}

choose_host()
{
    select host_option # in "$@" is the default
    do
        if [[ "$REPLY" =~ ^-?[0-9]+$ ]]; then
            if [ "$REPLY" -eq "1" ]; then
                configure_new_server
                break;
            elif [ 1 -lt "$REPLY" ] && [ "$REPLY" -le "$#" ]; then
                hostname=(`ssh -G "$host_option" | grep "^hostname " | sed 's/hostname[ ]*//g'`)
                user=(`ssh -G "$host_option" | grep "^user " | sed 's/user[ ]*//g'`)
                port=(`ssh -G "$host_option" | grep "^port " | sed 's/port[ ]*//g'`)
                sendenv=(`ssh -G "$host_option" | grep "^sendenv " | sed 's/sendenv[ ]*//g'`)

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

############ TO-DO: ASK FOR LOCAL INSTALL OR REMOTE INSTALL

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

