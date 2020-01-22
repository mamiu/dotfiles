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
        *)
            if [[ -n "${1// }" ]]; then
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

    adduser $new_admin_user
    passwd $new_admin_user </dev/tty
    while [ $? -ne 0 ]
    do
        passwd $new_admin_user </dev/tty
    done
    gpasswd -a $new_admin_user wheel

    echo "$new_admin_user"
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
                ADMIN_USER=$(create_admin_user)
            else
                echo "For which user do you want to install the ${bold_start}mamiu/dotfiles${bold_end}:"

                user_options=('Create new admin user')
                user_options+=("${human_users[@]}")
                user_options_length=(${#user_options[@]})

                select user_option in "${user_options[@]}"
                do
                    if [[ "$REPLY" =~ ^-?[1-9]+$ ]]; then
                        if (( REPLY == 1 )); then
                            ADMIN_USER=$(create_admin_user)
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

    dnf -y update
    dnf -y install git vim tmux fish mosh ncdu fzf bat fd-find ripgrep

    set +x
    cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
    set -x
    dnf install -y kubectl

    set +x
}

setup_dotfiles() {
    # Download and install dotfiles
    if [ ! -d "$HOME/.homesick/repos/homeshick" ]; then
        set -x
        git clone https://github.com/andsens/homeshick.git "$HOME/.homesick/repos/homeshick"
        set +x
    fi

    if [ -d "$HOME/.homesick/repos/dotfiles" ]; then
        echo "Theres already a dotfiles repository in the '~/.homesick/repos/' directory."
        echo "Cancel dotfiles installation for this user"
        return 1
    else
        set -x
        "$HOME/.homesick/repos/homeshick/bin/homeshick" clone -b mamiu/dotfiles
        "$HOME/.homesick/repos/homeshick/bin/homeshick" link -f dotfiles
        set +x
    fi

    # Install tmux plugin manager and tmux plugins
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        set -x
        git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
        tmux new-session -s "$USER" -d "$HOME/.tmux/plugins/tpm/tpm && $HOME/.tmux/plugins/tpm/scripts/install_plugins.sh"
        set +x
    fi

    # Install vim plugins
    if [ ! -d "$HOME/.vim/bundle" ]; then
        set -x
        vim
        set +x
    fi

    # Install fisher - a package manager for the fish shell
    if [ ! -f "$HOME/.config/fish/functions/fisher.fish" ]; then
        set -x
        curl https://git.io/fisher --create-dirs -sLo "$HOME/.config/fish/functions/fisher.fish"
        fish -c fisher
        set +x
    fi

    # Generate ssh key pair
    if [ ! -d "$HOME/.ssh" ]; then
        set -x
        mkdir "$HOME/.ssh"
        ssh-keygen -b 2048 -t rsa -f "$HOME/.ssh/id_rsa" -q -N ""
        set +x
    fi
}

install_basic_packages

setup_dotfiles

# Make fish the default shell for the root user
chsh -s $(which fish)

if [ $ADMIN_USER ]; then
    export -f setup_dotfiles
    su $ADMIN_USER -c "bash -c setup_dotfiles"

    # Make fish the default shell
    chsh -s $(which fish) $ADMIN_USER
fi

# activate tmux autostart (start or attach tmux on login. client has to pass the environment variable TMUX_AUTOSTART=true)
ssh_config_file="/etc/ssh/sshd_config"

echo "" >> $ssh_config_file
echo "# Allow user to pass the TMUX_AUTOSTART environment variable." >> $ssh_config_file
echo "AcceptEnv TMUX_AUTOSTART" >> $ssh_config_file

systemctl restart sshd.service
