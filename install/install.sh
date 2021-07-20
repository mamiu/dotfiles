#!/usr/bin/env bash
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

    # Servers domain or IP address
    read -p "Hostname or IP address of the server: " hostname </dev/tty
    while ! ping -c1 -W1 "$hostname" &>/dev/null
    do
        read -p "Host is not reachable. Please enter a valid hostname or IP address: " hostname </dev/tty
    done

    # SSH port
    read -p "SSH port of the server [default=${bold_start}22${bold_end}]: " port </dev/tty
    [ -z "$port" ] && port="22"
    while ! nc -z $hostname $port &>/dev/null
    do
        read -p "Port is not open. Please enter a valid port: " port </dev/tty
    done

    # Change SSH port
    if (( port == 22 )); then
        read -p "Change SSH port to something else than 22? [${bold_start}Y${bold_end}/n] " change_ssh_port </dev/tty
        [ -z "$change_ssh_port" ] && change_ssh_port="y"
        case "${change_ssh_port:0:1}" in
            y|Y )
                change_ssh_port=true

                # New SSH port
                read -p "New SSH port: [default=${bold_start}22222${bold_end}] " new_ssh_port </dev/tty
                [ -z "$new_ssh_port" ] && new_ssh_port=22222
                while [[ ! "$new_ssh_port" =~ ^[1-9]+$ ]]
                do
                    read -p "Only numbers are allowed as an SSH port: [default=${bold_start}22222${bold_end}] " new_ssh_port </dev/tty
                    [ -z "$new_ssh_port" ] && new_ssh_port=22222
                done
            ;;
            * )
                change_ssh_port=false
            ;;
        esac
    else
        change_ssh_port=false
    fi

    # installation user
    read -p "Which user do you want to use for the installation (must exist and have root privileges) [default=${bold_start}root${bold_end}]: " install_user </dev/tty
    [ -z "$install_user" ] && install_user="root"

    # setup admin user
    read -p "Do you want to setup a new admin user? [${bold_start}Y${bold_end}/n] " setup_admin_user </dev/tty
    [ -z "$setup_admin_user" ] && setup_admin_user="y"
    case "${setup_admin_user:0:1}" in
        y|Y )
            setup_admin_user=true
        ;;
        * )
            setup_admin_user=false
        ;;
    esac

    if [ "$setup_admin_user" = "true" ]; then
        read -p "Admin user name [default=${bold_start}${USER}${bold_end}]: " admin_user </dev/tty
        [ -z "$admin_user" ] && admin_user="$USER"
    else
        admin_user=""
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

    if [ "$add_ssh_config" == "true" ]; then
        # add ssh configuration to ssh config file

        ssh_config_file="$HOME/.ssh/config"

        if [ ! -f "$ssh_config_file" ] ; then
            touch $ssh_config_file
        fi

        if [ -w "$ssh_config_file" ] ; then
            echo "" >> $ssh_config_file
            echo "Host $nickname" >> $ssh_config_file
            echo "    User $admin_user" >> $ssh_config_file
            echo "    HostName $hostname" >> $ssh_config_file
            if [ "$change_ssh_port" == "true" ]; then
                echo "    Port $new_ssh_port" >> $ssh_config_file
            else
                echo "    Port $port" >> $ssh_config_file
            fi
            if [ "$tmux_autostart" == "true" ]; then
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

    setup_remote_host $hostname $port $install_user $setup_admin_user $admin_user $ssh_copy_id $reboot_after_installation $change_ssh_port $new_ssh_port
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
    if [ "$NEW_SSH_PORT" ]; then
        params+=("--new-ssh-port=$NEW_SSH_PORT")
    fi


    (( EUID != 0 )) && run_as_root="sudo -s"
    if [ -f "$install_script" ]; then
        # To get a colored output unbuffer the following command like so: https://superuser.com/a/751809/325412
        $run_as_root "$install_script" "${params[@]}" 2>&1 | $run_as_root tee $INSTALLATION_LOG_FILE
        return_value="$?"
    else
        curl -sL "https://raw.githubusercontent.com/mamiu/dotfiles/master/install/setup-os/${target_os}.sh" -o "./${target_os}.sh"
        chmod +x "./${target_os}.sh"
        # To get a colored output unbuffer the following command like so: https://superuser.com/a/751809/325412
        $run_as_root "./$target_os.sh" "${params[@]}" 2>&1 | $run_as_root tee $INSTALLATION_LOG_FILE
        return_value="$?"
        rm -f "./${target_os}.sh"
    fi

    if (( return_value == 0 )); then
        if [ "$REBOOT_AFTER_INSTALLATION" ]; then
            if sudo -n true &>/dev/null; then
                echo "Reboot system in 30 seconds..."
                nohup sudo bash -c 'sleep 30 && reboot' >/dev/null &
            else
                echo "Cannot reboot system, because install script has no root privileges (anymore)."
                echo "Please reboot the system manually."
            fi
        fi

        echo
        echo "########## ${bold_start}MAMIU/DOTFILES${bold_end} WAS INSTALLED SUCCESSFULLY ##########"
    else
        echo
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
                    call_installation_script "ubuntu"
                else
                    echo "This linux distro isn't supported."
                    exit_program 1
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
    install_user=$3
    setup_admin_user=$4
    admin_user=$5
    ssh_copy_id=$6
    reboot_after_installation=$7
    change_ssh_port=$8
    new_ssh_port=$9

    echo "username: $install_user"
    echo "hostname: $hostname"

    params=("curl -sL https://raw.githubusercontent.com/mamiu/dotfiles/master/install/install.sh | bash -s -- -l --no-greeting")
    if [ "$setup_admin_user" == "true" ]; then
        params+=("--admin-user=$admin_user")
    fi
    if [ "$reboot_after_installation" == "true" ]; then
        params+=("--reboot")
    fi
    if [ "$ssh_copy_id" == "true" ]; then
        params+=("--add-ssh-key='$(get_public_ssh_key)'")
    fi
    if [ "$change_ssh_port" == "true" ]; then
        params+=("--new-ssh-port=$new_ssh_port")
    fi

    ssh-keygen -R "$hostname" &>/dev/null
    if (( port != 22 )); then
        ssh-keygen -R "[${hostname}]:$port" &>/dev/null
    fi

    echo "Adding host verification keys to ~/.ssh/known_hosts ..."
    ssh-keyscan -H -p "$port" -t rsa,ecdsa $hostname >> "$HOME/.ssh/known_hosts" 2>/dev/null
    for ip in $(dig @8.8.8.8 $hostname +short)
    do
        ssh-keygen -R "$ip" &>/dev/null
        if (( port != 22 )); then
            ssh-keygen -R "[${ip}]:$port" &>/dev/null
        fi
        ssh-keyscan -H -p "$port" -t rsa,ecdsa $hostname,$ip >> "$HOME/.ssh/known_hosts" 2>/dev/null
        ssh-keyscan -H -p "$port" -t rsa,ecdsa $ip >> "$HOME/.ssh/known_hosts" 2>/dev/null
    done

    ssh -o StrictHostKeyChecking=no -p $port $install_user@$hostname -t "${params[@]}"

    if [ "$change_ssh_port" == "true" ]; then
        echo "Removing old host verification keys from ~/.ssh/known_hosts and adding new ones ..."

        ssh-keygen -R "$hostname" &>/dev/null
        if (( port != 22 )); then
            ssh-keygen -R "[${hostname}]:$port" &>/dev/null
        fi
        ssh-keygen -R "[${hostname}]:$new_ssh_port" &>/dev/null

        ssh-keyscan -H -p "$new_ssh_port" -t rsa,ecdsa $hostname >> "$HOME/.ssh/known_hosts" 2>/dev/null

        for ip in $(dig @8.8.8.8 $hostname +short)
        do
            ssh-keygen -R "$ip" &>/dev/null
            if (( port != 22 )); then
                ssh-keygen -R "[${ip}]:$port" &>/dev/null
            fi
            ssh-keygen -R "[${ip}]:$new_ssh_port" &>/dev/null

            ssh-keyscan -H -p "$new_ssh_port" -t rsa,ecdsa $hostname,$ip >> "$HOME/.ssh/known_hosts" 2>/dev/null
            ssh-keyscan -H -p "$new_ssh_port" -t rsa,ecdsa $ip >> "$HOME/.ssh/known_hosts" 2>/dev/null
        done
    fi

    known_hosts_backup="$HOME/.ssh/known_hosts.old"
    if [ -f "$known_hosts_backup" ] ; then
        rm "$known_hosts_backup"
    fi

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
    -b|--reboot)
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
    -p)
        NEW_SSH_PORT="$2"
        shift 2
    ;;
    --new-ssh-port=*)
        NEW_SSH_PORT="${1#*=}"
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
