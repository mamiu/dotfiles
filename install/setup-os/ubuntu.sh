
#!/bin/bash

# helper variables to make text bold
bold_start=$(tput bold)
bold_end=$(tput sgr0)

if [ $EUID != 0 ]; then
    echo "Installation script has to be called with root permissions!"
    exit 1
fi

while [ $# -gt 0 ]; do
    case "$1" in
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
        --reboot=*)
            REBOOT_AFTER_INSTALLATION=true
            shift
        ;;
        *)
            if [ "${1// }" ]; then
                echo "unknown option: $1" >&2
                exit 1
            fi
            shift
        ;;
    esac
done

read -p "Change root password? [${bold_start}Y${bold_end}/n]: " change_root_password </dev/tty
[ -z "$change_root_password" ] && change_root_password="y"
case "${change_root_password:0:1}" in
    y|Y )
        passwd </dev/tty
        while [ $? -ne 0 ]
        do
            passwd </dev/tty
        done
    ;;
esac

read -p "Change hostname (current hostname is ${bold_start}$(hostname)${bold_end})? [${bold_start}Y${bold_end}/n]: " change_hostname </dev/tty
[ -z "$change_hostname" ] && change_hostname="y"
case "${change_hostname:0:1}" in
    y|Y )
        read -p "New hostname: " new_hostname </dev/tty
        while [ -z "$new_hostname" ] || [[ ! "$new_hostname" =~ ^[0-9a-zA-Z.-]+$ ]]
        do
            read -p "Hostname must only contain lowercase and uppercase letters, numbers, dashes (-) and dots (.): " new_hostname </dev/tty
        done

        hostnamectl set-hostname "$new_hostname"
    ;;
esac

create_admin_user() {
    all_users=(`awk -F':' '{ print $1}' /etc/passwd`)

    # ADMIN_USER is specified and already exists
    if [ $ADMIN_USER ] && [[ " ${all_users[@]} " =~ " ${ADMIN_USER} " ]]; then
        # no need to ask for the admin user or to create a new user account
        return
    fi

    if [ $ADMIN_USER ]; then
        new_admin_user="$ADMIN_USER"
    else
        read -p "Username for the new admin: " new_admin_user </dev/tty
        while [ -z "$new_admin_user" ] || [[ " ${all_users[@]} " =~ " ${new_admin_user} " ]]
        do
            read -p "Username is blank or does already exist. Please enter another username: " new_admin_user </dev/tty
        done
    fi

    adduser --disabled-password --gecos "" $new_admin_user
    echo "Password for the new admin user"
    passwd $new_admin_user </dev/tty
    while [ $? -ne 0 ]
    do
        passwd $new_admin_user </dev/tty
    done
    adduser $new_admin_user sudo

    ADMIN_USER="$new_admin_user"
}

if [ $ADMIN_USER ]; then
    create_admin_user
else
    read -p "Setup an admin user? [${bold_start}Y${bold_end}/n]: " setup_admin_user </dev/tty
    [ -z "$setup_admin_user" ] && setup_admin_user="y"
    case "${setup_admin_user:0:1}" in
        y|Y )
            # cross-linux method to get all human user accounts
            login_file="/etc/login.defs"
            passwd_file="/etc/passwd"
            user_id_min=$(grep "^UID_MIN" $login_file)
            user_id_max=$(grep "^UID_MAX" $login_file)
            human_users=(`awk -F':' -v "min=${user_id_min##UID_MIN}" -v "max=${user_id_max##UID_MAX}" '{ if ( $3 >= min && $3 <= max  && $7 != "/sbin/nologin" ) print $1 }' "$passwd_file"`)

            if [ ${#human_users[@]} -eq 0 ]; then
                echo "Couldn't find user accounts. Therefore creating a new one."
                create_admin_user
            else
                echo "For which user do you want to install the ${bold_start}mamiu/dotfiles${bold_end}:"

                user_options=('Create new admin user')
                user_options+=("${human_users[@]}")
                user_options_length=(${#user_options[@]})

                select user_option in "${user_options[@]}"
                do
                    if [[ "$REPLY" =~ ^-?[1-9]+$ ]]; then
                        if (( REPLY == 1 )); then
                            create_admin_user
                            break;
                        elif [ $REPLY -le $user_options_length ]; then
                            ADMIN_USER="$user_option"
                            break;
                        else
                            echo "Incorrect Input: Select a number 1-$user_options_length"
                        fi
                    else
                        echo "Incorrect Input: Select a number 1-$user_options_length"
                    fi
                done </dev/tty || user_option="1"
            fi
        ;;
    esac
fi


install_basic_packages() {
    set -x
    apt-get update -y
    apt-get upgrade -y

    # Just to make sure that the very basics are installed
    # net-tools        => netstat (network statistics)
    # at               => run command at given time in the future
    apt-get install -y net-tools at

    # Install most used packages
    apt-get install -y git vim fish tmux mosh ncdu htop fzf bat fd-find ripgrep

    # Install cockpit (https://cockpit-project.org/)
    apt-get install -y cockpit
    systemctl enable --now cockpit.socket
    systemctl start cockpit

    { set +x; } 2>/dev/null
}

setup_dotfiles() {
    cd "$HOME"

    # Download and install dotfiles
    if [ ! -d "$HOME/.homesick/repos/homeshick" ]; then
        set -x
        git clone https://github.com/andsens/homeshick.git "$HOME/.homesick/repos/homeshick"
        { set +x; } 2>/dev/null
    fi

    if [ -d "$HOME/.homesick/repos/dotfiles" ]; then
        echo "There's already a dotfiles repository in the '~/.homesick/repos/' directory."
        echo "Cancel dotfiles installation for this user"
        return 1
    else
        set -x
        "$HOME/.homesick/repos/homeshick/bin/homeshick" clone -b mamiu/dotfiles
        "$HOME/.homesick/repos/homeshick/bin/homeshick" link -f dotfiles
        { set +x; } 2>/dev/null
    fi

    # Install tmux plugin manager and tmux plugins
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        set -x
        git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
        tmux new-session -s "$USER" -d "$HOME/.tmux/plugins/tpm/tpm && $HOME/.tmux/plugins/tpm/scripts/install_plugins.sh"
        { set +x; } 2>/dev/null
    fi

    # Install vim plugins
    if [ ! -d "$HOME/.vim/bundle" ]; then
        set -x
        vim +PluginInstall +qall &>/dev/null
        { set +x; } 2>/dev/null
    fi

    # Install fisher - a package manager for the fish shell
    if [ ! -f "$HOME/.config/fish/functions/fisher.fish" ]; then
        set -x
        curl https://git.io/fisher --create-dirs -sLo "$HOME/.config/fish/functions/fisher.fish"
        fish -c fisher
        { set +x; } 2>/dev/null
    fi

    # Generate ssh key pair
    if [ ! -d "$HOME/.ssh" ]; then
        set -x
        mkdir "$HOME/.ssh"
        { set +x; } 2>/dev/null
    fi
    if [ ! -f "$HOME/.ssh/id_rsa" ]; then
        set -x
        ssh-keygen -b 2048 -t rsa -f "$HOME/.ssh/id_rsa" -q -N ""
        { set +x; } 2>/dev/null
    fi
    set -x
    chmod 700 $HOME/.ssh
    chmod 600 $HOME/.ssh/*
    chmod 644 $HOME/.ssh/*.pub
    { set +x; } 2>/dev/null

    if [ "$PUBLIC_SSH_KEY" ] && { [ -z "$ADMIN_USER" ] || [ "$ADMIN_USER" == "$USER" ]; }; then
        echo "$PUBLIC_SSH_KEY" >> "$HOME/.ssh/authorized_keys"
    fi
}

install_basic_packages

setup_dotfiles

# Make fish the default shell for the root user
chsh -s $(which fish)

if [ "$ADMIN_USER" ]; then
    sudo -u $ADMIN_USER /bin/bash -c "$(declare -f setup_dotfiles); ADMIN_USER='$ADMIN_USER'; PUBLIC_SSH_KEY='$PUBLIC_SSH_KEY'; setup_dotfiles"

    # Make fish the default shell
    set -x
    chsh -s $(which fish) $ADMIN_USER
    { set +x; } 2>/dev/null
fi

# activate tmux autostart (start or attach tmux on login. client has to pass the environment variable TMUX_AUTOSTART=true)
ssh_config_file="/etc/ssh/sshd_config"

if [ "$NEW_SSH_PORT" ]; then
    echo "Changing ssh port to: $NEW_SSH_PORT"
    port_line_number="$(awk '/^Port / {print FNR}' $ssh_config_file)"
    if [ "$port_line_number" ]; then
        sed -i "${port_line_number}s/.*/Port $NEW_SSH_PORT/" $ssh_config_file
    else
        port_line_number="$(awk '/^#Port / {print FNR}' $ssh_config_file)"
        if [ "$port_line_number" ]; then
            sed -i "${port_line_number}s/.*/Port $NEW_SSH_PORT/" $ssh_config_file
        else
            echo "" >> $ssh_config_file
            echo "Port $NEW_SSH_PORT" >> $ssh_config_file
        fi
    fi

    # TODO: if firewall is turned on, open the new port
fi

echo "" >> $ssh_config_file
echo "# Allow user to pass the TMUX_AUTOSTART environment variable." >> $ssh_config_file
echo "AcceptEnv TMUX_AUTOSTART" >> $ssh_config_file

if [ "$REBOOT_AFTER_INSTALLATION" ]; then
    echo "Reboot system in 30 seconds..."
    tmux new-session -d -s reboot 'sleep 30; reboot'
    # echo "sleep 30; reboot" | at now 2>&1 >/dev/null
else
    systemctl restart sshd.service
fi

sleep 1
exit 0
