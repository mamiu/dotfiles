#!/bin/bash
# MAMIU/DOTFILES SETUP SCRIPT

# Log file path of the setup scripts
INSTALLATION_LOG_FILE="/mamiu_dotfiles_setup.log"

# helper variables to make text bold
bold_start=$(tput bold)
bold_end=$(tput sgr0)

get_public_ssh_key()
{
    key_file="$HOME/.ssh/id_rsa"
    public_key_file="${key_file}.pub"

    if [ ! -f "$public_key_file" ] ; then
        ssh-keygen -t rsa -N "" -f $key_file
    fi

    public_key="$(cat $public_key_file)"

    echo "$public_key"
}

configure_new_server()
{
    echo
    echo "########## CONFIGURE NEW SERVER ##########"

    # servers domain or IP address
    read -p "Hostname or IP address of the server: " hostname </dev/tty
    while ! ping -c1 -W1 "$hostname" >/dev/null 2>&1
    do
        read -p "Host is not reachable. Please enter a valid hostname or IP address: " hostname </dev/tty
    done

    # servers port
    read -p "SSH port of the server [default=${bold_start}22${bold_end}]: " port </dev/tty
    [ -z "$port" ] && port="22"
    while ! nc -z $hostname $port >/dev/null 2>&1
    do
        read -p "Port is not open. Please enter a valid port: " port </dev/tty
    done

    # username with root privileges on the server
    read -p "User name with root privileges [default=${bold_start}root${bold_end}]: " username </dev/tty
    [ -z "$username" ] && username="root"

    if [ "$username" != "root" ]; then
        # username is a user that already exists
        read -p "Does the user ${bold_start}${username}${bold_end} already exist? [y/${bold_start}N${bold_end}] " user_exists </dev/tty
        [ -z "$user_exists" ] && user_exists="n"
        case "${user_exists:0:1}" in
            n|N )
                user_exists=false
            ;;
            * )
                user_exists=true
            ;;
        esac
    fi

    # add this config to ssh config
    read -p "Add this config to SSH config file? [${bold_start}Y${bold_end}/n] " add_ssh_config </dev/tty
    [ -z "$add_ssh_config" ] && add_ssh_config="y"
    case "${add_ssh_config:0:1}" in
        y|Y )
            add_ssh_config=true

            # nickname for the server
            read -p "Nickname for this SSH login: [default=${bold_start}${hostname}${bold_end}] " nickname </dev/tty
            [ -z "$nickname" ] && nickname="$hostname"
            while [[ " ${hosts[@]} " =~ " ${nickname} " ]]
            do
                read -p "Nickname does already exist. Please enter another nickname: [default=${bold_start}${hostname}${bold_end}] " nickname </dev/tty
                [ -z "$nickname" ] && nickname="$hostname"
            done

            # autostart tmux at login
            read -p "Start tmux by default on SSH login? [${bold_start}Y${bold_end}/n] " tmux_autostart </dev/tty
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
    read -p "Login without entering a password in the future? [${bold_start}Y${bold_end}/n] " ssh_copy_id </dev/tty
    [ -z "$ssh_copy_id" ] && ssh_copy_id="y"
    case "${ssh_copy_id:0:1}" in
        y|Y )
            ssh_copy_id=true
        ;;
        * )
            ssh_copy_id=false
        ;;
    esac

    if [ "$add_ssh_config" == true ]; then
        # add ssh configuration to ssh config file

        ssh_config_file="$HOME/.ssh/config"

        if [ ! -f "$ssh_config_file" ] ; then
            touch $ssh_config_file
        fi

        if [ -w "$ssh_config_file" ] ; then
            echo "" >> $ssh_config_file
            echo "Host $nickname" >> $ssh_config_file
            echo "    User $username" >> $ssh_config_file
            echo "    HostName $hostname" >> $ssh_config_file
            echo "    Port $port" >> $ssh_config_file
            if [ "$tmux_autostart" == true ]; then
                echo "    SendEnv TMUX_AUTOSTART" >> $ssh_config_file
            fi
        else
            echo "SSH configuration cannot be safed, because the SSH config file ($ssh_config_file) is not writable"
        fi
    fi

    # reboot server
    read -p "Do you want to reboot the server after a successful setup? [${bold_start}Y${bold_end}/n] " reboot_server </dev/tty
    [ -z "$reboot_server" ] && reboot_server="y"
    case "${reboot_server:0:1}" in
        y|Y )
            reboot_after_installation=true
        ;;
        * )
            reboot_after_installation=false
        ;;
    esac

    setup_remote_host $hostname $port $username $user_exists $ssh_copy_id $reboot_after_installation
}

choose_remote_host()
{
    # get the hosts from ~/.ssh/config
    hosts=(`grep -w -i "Host" ~/.ssh/config | sed 's/[ ]*[Hh][Oo][Ss][Tt][ ]*//g'`)

    # add option 'New Server' to array
    host_options=('New Server')
    host_options+=("${hosts[@]}")

    echo
    echo "Choose the server you want to setup:"

    select host_option in "${host_options[@]}"
    do
        if [[ "$REPLY" =~ ^[1-9]+$ ]]; then
            if [ $REPLY -eq 1 ]; then
                configure_new_server
                break;
            elif [ 1 -lt $REPLY ] && [ $REPLY -le ${#host_options[@]} ]; then
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
    done </dev/tty || host_option="1"
}

exit_program()
{
    echo
    exit $1
}

# `readlink -f` functionality for macOS
get_path_of_current_file() {
    TARGET_FILE=$1

    cd `dirname $TARGET_FILE`
    TARGET_FILE=`basename $TARGET_FILE`

    # Iterate down a (possible) chain of symlinks
    while [ -L "$TARGET_FILE" ]
    do
        TARGET_FILE=`readlink $TARGET_FILE`
        cd `dirname $TARGET_FILE`
        TARGET_FILE=`basename $TARGET_FILE`
    done

    # Finding the physical path for the directory we are in
    echo `pwd -P`
}

call_installation_script()
{
    current_script_path=$(get_path_of_current_file "$0")
    target_os=$1
    install_script="${current_script_path}/setup-os/${target_os}.sh"

    params=()
    if [ "$ADMIN_USER" ]; then
        params+=("--admin-user=$ADMIN_USER")
    fi
    if [ "$PUBLIC_SSH_KEY" ]; then
        params+=("--add-ssh-key=$PUBLIC_SSH_KEY")
    fi

    (( EUID != 0 )) && run_as_root="sudo"
    if [ -f "$install_script" ]; then
        $run_as_root "$install_script" "${params[@]}" |& $run_as_root tee $INSTALLATION_LOG_FILE
        return_value="$?"
    else
        curl -sL "https://raw.githubusercontent.com/mamiu/dotfiles/master/install/setup-os/${target_os}.sh" -o "./${target_os}.sh"
        chmod +x "./${target_os}.sh"
        $run_as_root "./$target_os.sh" "${params[@]}" |& $run_as_root tee $INSTALLATION_LOG_FILE
        return_value="$?"
        rm -f "./${target_os}.sh"
    fi

    echo

    if (( return_value == 0 )); then
        echo "########## ${bold_start}MAMIU/DOTFILES${bold_end} WAS INSTALLED SUCCESSFULLY ##########"

        if [ "$REBOOT_AFTER_INSTALLATION" ]; then
            echo "Reboot system..."
            $run_as_root reboot
        fi
    else
        echo "########## !!! ${bold_start}MAMIU/DOTFILES${bold_end} WAS NOT INSTALLED !!! ##########"
    fi

    exit_program
}

check_os()
{
    echo
    uppercase_hostname=`echo "$HOSTNAME" | tr '[:lower:]' '[:upper:]'`
    echo "########## SETUP $uppercase_hostname ##########"

    case "$OSTYPE" in
        linux*)
            os_release_file=/etc/os-release

            if [ -f "$os_release_file" ] ; then
                source $os_release_file

                if [ "$ID" == "fedora" ] && (( "$VERSION_ID" >= "29" )); then
                    call_installation_script "fedora"
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
            call_installation_script "macos"
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
    echo
    echo "########## SETUP REMOTE HOST ##########"

    hostname=$1
    port=$2
    username=$3
    user_exists=$4
    ssh_copy_id=$5
    reboot_after_installation=$6

    if [ "$user_exists" == "false" ]; then
        user="root"
    else
        user=$username
    fi

    echo "username: $username"
    echo "hostname: $hostname"


    params="curl -sL https://raw.githubusercontent.com/mamiu/dotfiles/master/install/install.sh | bash -s -- -l --no-greeting"
    if [ "$username" != "root" ] && [ "$user_exists" == "false" ]; then
        params+=" --admin-user=$username"
    fi
    if [ "$reboot_after_installation" == "true" ]; then
        params+=" --reboot"
    fi
    if [ "$ssh_copy_id" == "true" ]; then
        params+=" --add-ssh-key='$(get_public_ssh_key)'"
    fi

    ssh-keygen -R "$hostname" >/dev/null 2>&1
    if (( port != 22 )); then
        echo port other than 22
        ssh-keygen -R "$hostname:$port" >/dev/null 2>&1
    fi

    known_hosts_backup="$HOME/.ssh/known_hosts.old"
    if [ -f "$known_hosts_backup" ] ; then
        rm "$known_hosts_backup"
    fi

    echo "Adding host verification keys to ~/.ssh/known_hosts ..."
    ssh-keyscan -H -p "$port" -t rsa,ecdsa $hostname >> "$HOME/.ssh/known_hosts" 2>/dev/null
    for ip in $(dig @8.8.8.8 $hostname +short)
    do
        ssh-keyscan -H -p "$port" -t rsa,ecdsa $hostname,$ip >> "$HOME/.ssh/known_hosts" 2>/dev/null
        ssh-keyscan -H -p "$port" -t rsa,ecdsa $ip >> "$HOME/.ssh/known_hosts" 2>/dev/null
    done

    ssh -o StrictHostKeyChecking=no -p $port $user@$hostname -t "$params"

    exit_program
}

choose_install_target()
{
    echo
    # install remote or locally
    while :
    do
        read -p "Do you want to setup the (l)ocal or a (r)emote host? [l/${bold_start}R${bold_end}] " install_target </dev/tty || install_target="l"
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


while [ $# -gt 0 ]; do
  case "$1" in
    -r|--remote)
        INSTALLATION_TARGET="remote"
        shift
    ;;
    -l|--local)
        INSTALLATION_TARGET="local"
        shift
    ;;
    -n|--no-greeting)
        NO_GREETING=true
        shift
    ;;
    -r|--reboot)
        REBOOT_AFTER_INSTALLATION=true
        shift
    ;;
    -u)
        ADMIN_USER="$2"
        shift 2
    ;;
    --admin-user=*)
        ADMIN_USER="${1#*=}"
        shift
    ;;
    -k)
        PUBLIC_SSH_KEY="$2"
        shift 2
    ;;
    --add-ssh-key=*)
        PUBLIC_SSH_KEY="${1#*=}"
        shift
    ;;
    *)
        echo "unknown option: $1" >&2
        exit_program 1
    ;;
  esac
done

if [ -z "$NO_GREETING" ]; then
    echo
    echo "Welcome to the ${bold_start}mamiu/dotfiles${bold_end} setup script!"
fi

if [ -z "$INSTALLATION_TARGET" ]; then
    choose_install_target
elif [ "$INSTALLATION_TARGET" == "remote" ]; then
    choose_remote_host
elif [ "$INSTALLATION_TARGET" == "local" ]; then
    check_os
fi

exit_program
