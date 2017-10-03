#!/bin/bash


bold_start=$(tput bold)
bold_end=$(tput sgr0)

echo
echo "Welcome to the ${bold_start}mamiu/dotfiles${bold_end} setup script!"
echo


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

    setup_remote_host $hostname $port $username
}

choose_remote_host()
{
    # get the hosts from ~/.ssh/config
    hosts=(`grep -w -i "Host" ~/.ssh/config | sed 's/[ ]*[Hh][Oo][Ss][Tt][ ]*//g'`)

    # add option 'New Server' to array
    host_options=('New Server')
    host_options+=("${hosts[@]}")

    echo "Choose the server you want to setup:"

    select host_option in "${host_options[@]}"
    do
        [[ -n $host_option ]] || { echo "What's that? Please try again." >&2; continue; }
        if [[ "$REPLY" =~ ^-?[0-9]+$ ]]; then
            if [ "$REPLY" -eq "1" ]; then
                configure_new_server
                break;
            elif [ 1 -lt "$REPLY" ] && [ "$REPLY" -le  "${#host_options[@]}" ]; then
                hostname=(`ssh -G "$host_option" | grep "^hostname " | sed 's/hostname[ ]*//g'`)
                port=(`ssh -G "$host_option" | grep "^port " | sed 's/port[ ]*//g'`)
                username=(`ssh -G "$host_option" | grep "^user " | sed 's/user[ ]*//g'`)

                setup_remote_host $hostname $port $username

                break;
            else
                echo "Incorrect Input: Select a number 1-${#host_options[@]}"
            fi
        else
            echo "Incorrect Input: Select a number 1-${#host_options[@]}"
        fi
    done
}

exit_program()
{
    echo
    exit $1
}

check_os()
{
    echo "########## SETUP $HOSTNAME ##########"

    case "$OSTYPE" in
        linux*)
            os_release_file=/etc/os-release

            if [ -e $os_release_file ] ; then
                source $os_release_file

                #if [ "$ID" == "fedora" ] && [ "$VERSION_ID" == "26" ]; then
                if [ "$ID" == "fedora" ]; then
                    echo "setup mamiu/dotfiles on fedora server"
                elif [ "$ID" == "ubuntu" ]; then
                    echo "Ubuntu will be supported soon."
                    exit_programm 1
                else
                    echo "This linux distro isn't supported."
                    exit_programm 1
                fi
            else
                echo "Couldn't specify the linux distro."
                exit_program 1
            fi
        ;;
        darwin*)
            echo "macOS will be supported soon."
            exit_program 1
        ;;
        msys*)
            echo "Windows is currently not supported."
            exit_program 1
        ;;
        *)
            echo "Unknown operating system. This OS is not supported."
            exit_program 1
        ;;
    esac
}

setup_remote_host()
{
    echo "########## SETUP REMOTE HOST ##########"
    echo

    hostname=$1
    port=$2
    username=$3

    echo "hostname: $hostname"
    echo "port: $port"
    echo "username: $username"

    check_os
    #ssh -o StrictHostKeyChecking=no -p $port $username@$hostname "echo \$0"

    # log into server
    #ssh server.miu.io -t "curl -sL https://raw.githubusercontent.com/mamiu/dotfiles/master/install/setup_server.sh | bash"

    # download and call setup script on server
    # reboot server
}

choose_install_target()
{
    # install remote or locally
    while :
    do
        read -p "Do you want to setup the (l)ocal or a (r)emote host [l/${bold_start}R${bold_end}]: " install_target
        [ -z "$install_target" ] && install_target="r"
        case "${install_target:0:1}" in
            r|R )
                choose_remote_host
                break
            ;;
            l|L )
                check_os
                break
            ;;
            * )
                echo "Invalid choice. Please select ${bold_start}l${bold_end} for local or ${bold_start}r${bold_end} for remote!"
            ;;
        esac
    done
}


while [ "$#" -gt 0 ]; do
  case "$1" in
    -r|--remote)
        choose_remote_host
        exit_program
    ;;
    -l|--local)
        check_os
        exit_program
    ;;
    *)
        echo "unknown option: $1" >&2
        exit_program 1
    ;;
  esac
done

choose_install_target
