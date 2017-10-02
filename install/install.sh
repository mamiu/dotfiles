#!/bin/bash


bold_start=$(tput bold)
bold_end=$(tput sgr0)

echo
echo "Welcome to the ${bold_start}mamiu/dotfiles${bold_end} setup script!"
echo

# GLOBAL VARIABLES
HOSTNAME=""
PORT=""
USERNAME=""


configure_new_server()
{
    echo
    echo "########## CONFIGURE NEW SERVER ##########"

    # servers domain or ip address
    read -p "Hostname or ip address of the server: " hostname
    while ! ping -c1 -W1 "$hostname" >/dev/null 2>&1
    do
        read -p "Host is not reachable. Please enter a valid hostname or ip address: " hostname
    done

    # servers port
    read -p "SSH port of the server [default=${bold_start}22${bold_end}]: " port
    [ -z "$port" ] && port="22"
    while ! nc -z $hostname $port >/dev/null 2>&1
    do
        read -p "Port is not open. Please enter a valid port: " port
    done

    # username with root privileges on the server
    read -p "User name with root privileges [default=${bold_start}root${bold_end}]: " username
    [ -z "$username" ] && username="root"

    # add this config to ssh config
    read -p "Add this config to ssh config [${bold_start}Y${bold_end}/n]: " add_ssh_config
    [ -z "$add_ssh_config" ] && add_ssh_config="y"
    case "${add_ssh_config:0:1}" in
        y|Y )
            add_ssh_config=true

            # nickname for the server
            read -p "Nickname for the server: " nickname
            while [ -z "$nickname" ] || [[ " ${hosts[@]} " =~ " ${nickname} " ]]
            do
                read -p "Nickname is blank or exists already. Please enter another nickname: " nickname
            done

            # autostart tmux at login
            read -p "Start tmux by default on login [${bold_start}Y${bold_end}/n]: " tmux_autostart
            [ -z "$tmux_autostart" ] && tmux_autostart="y"
            case "${tmux_autostart:0:1}" in
                y|Y )
                    tmux_autostart=true
                ;;
                * )
                    tmux_autostart=false
                ;;
            esac
        ;;
        * )
            add_ssh_config=false
        ;;
    esac

    # login without entering a password in the future (adding id_rsa to known_hosts on server)
    read -p "Login without entering a password in the future [${bold_start}Y${bold_end}/n]: " ssh_copy_id
    [ -z "$ssh_copy_id" ] && ssh_copy_id="y"
    case "${ssh_copy_id:0:1}" in
        y|Y )
            ssh_copy_id=true
        ;;
        * )
            ssh_copy_id=false
        ;;
    esac

    if $add_ssh_config; then
        # add ssh configuration to ssh config file

        ssh_config_file=~/.ssh/config

        if [ ! -e $ssh_config_file ] ; then
            touch $ssh_config_file
        fi

        if [ -w $ssh_config_file ] ; then
            echo "" >> $ssh_config_file
            echo "Host $nickname" >> $ssh_config_file
            echo "    User $username" >> $ssh_config_file
            echo "    HostName $hostname" >> $ssh_config_file
            echo "    Port $port" >> $ssh_config_file
            if $tmux_autostart; then
                echo "    SendEnv TMUX_AUTOSTART" >> $ssh_config_file
            fi
        else
            echo cannot write to $ssh_config_file
        fi
    fi

    if $ssh_copy_id; then
        # copy public id to the remote server

        key_file=~/.ssh/id_rsa
        public_key_file="${key_file}.pub"

        if [ ! -e $public_key_file ] ; then
            ssh-keygen -t rsa -N "" -f $key_file
        fi

        cat $public_key_file | ssh -o StrictHostKeyChecking=no -p $port $username@$hostname "mkdir -p ~/.ssh && cat >> .ssh/authorized_keys"
    fi

    # save the ssh credentials into the global variables
    HOSTNAME=$hostname
    PORT=$port
    USERNAME=$username
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

    echo "hostname: $HOSTNAME"
    echo "port: $PORT"
    echo "username: $USERNAME"

    ssh -o StrictHostKeyChecking=no -p $PORT $USERNAME@$HOSTNAME "echo \$0"
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

