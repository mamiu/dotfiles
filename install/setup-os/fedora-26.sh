#!/bin/bash

if [ $EUID != 0 ]; then
    echo "Installation script has to be called with root permissions!"
    exit 1
fi

while [ "$#" -gt 0 ]; do
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
            echo "unknown option: $1" >&2
            exit 1
        ;;
    esac
done

read -p "Change root password [${bold_start}Y${bold_end}/n]: " change_root_password </dev/tty
[ -z "$change_root_password" ] && change_root_password="y"
case "${change_root_password:0:1}" in
    y|Y )
        passwd </dev/tty
    ;;
esac

if [ -z $ADMIN_USER ]; then
    read -p "setup an admin user [${bold_start}Y${bold_end}/n]: " setup_admin_user </dev/tty
    [ -z "$setup_admin_user" ] && setup_admin_user="y"
else
    setup_admin_user="y"
fi
case "${setup_admin_user:0:1}" in
    y|y )
        setup_admin_user=true

        users=(`awk -F':' '{ print $1}' /etc/passwd`)

        if [ -z $ADMIN_USER ]; then
            read -p "Create a new user [${bold_start}Y${bold_end}/n]: " new_admin_user </dev/tty
            [ -z "$new_admin_user" ] && new_admin_user="y"
        else
            admin_name=$ADMIN_USER

            if [[ " ${users[@]} " =~ " ${ADMIN_USER} " ]]; then
                new_admin_user="-"
            else
                new_admin_user="y"
            fi
        fi
        case "${new_admin_user:0:1}" in
            y|y )

                if [ -z $ADMIN_USER ]; then
                    read -p "Username for the new admin: " admin_name </dev/tty
                    while [ -z "$admin_name" ] || [[ " ${users[@]} " =~ " ${admin_name} " ]]
                    do
                        read -p "Username is blank or does already exist. Please enter another username: " admin_name </dev/tty
                    done
                fi

                adduser $admin_name
                passwd $admin_name </dev/tty
                gpasswd wheel -a $admin_name
            ;;
            n|N )

                login_file="/etc/login.defs"
                passwd_file="/etc/passwd"

                # get mini UID limit
                user_id_min=$(grep "^UID_MIN" $login_file)
                # get max UID limit
                user_id_max=$(grep "^UID_MAX" $login_file)

                # use awk to print if UID >= $MIN and UID <= $MAX and shell is not /sbin/nologin
                users=(`awk -F':' -v "min=${user_id_min##UID_MIN}" -v "max=${user_id_max##UID_MAX}" '{ if ( $3 >= min && $3 <= max  && $7 != "/sbin/nologin" ) print $1 }' "$passwd_file"`)

                for user in "${users[@]}"; do
                    echo "user: $user"
                done

                ##### TO-DO: select a user

            ;;
        esac

        read -p "Setup git for admin user [${bold_start}Y${bold_end}/n]: " setup_git </dev/tty
        [ -z "$setup_git" ] && setup_git="y"
        case "${setup_git:0:1}" in
            y|y )
                setup_git=true

                # full name of admin user
                read -p "Full name of the admin user: " admin_full_name </dev/tty
                while [ -z "$admin_full_name" ]
                do
                    read -p "Full name of admin user cannot be blank. Please enter a valid name: " admin_full_name </dev/tty
                done

                # email address of admin user
                read -p "Email address of admin user: " admin_email_address </dev/tty
                while [ -z "$admin_email_address" ]
                do
                    read -p "Email address of admin user cannot be blank. Please enter a valid email address: " admin_email_address </dev/tty
                done
            ;;
        esac
    ;;
esac

#dnf update vim-minimal
dnf -y update
dnf -y install git vim tmux fish

git clone https://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
git clone https://github.com/mamiu/dotfiles.git $HOME/.homesick/repos/dotfiles
~/.homesick/repos/homeshick/bin/homeshick link -f dotfiles
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# Press prefix + I (capital i, as in install) to fetch the plugins

if [ "$setup_admin_user" == true ]; then

    runuser -l "$admin_name" -c "
    git clone https://github.com/andsens/homeshick.git ~/.homesick/repos/homeshick
    git clone https://github.com/mamiu/dotfiles.git ~/.homesick/repos/dotfiles
    ~/.homesick/repos/homeshick/bin/homeshick link -f dotfiles
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    # Press prefix + I (capital i, as in install) to fetch the plugins

    if [ \"$setup_git\" == true ]; then
        git config --global user.name \"$admin_full_name\"
        git config --global user.email \"$admin_email_address\"
    fi
    "
fi

# install docker
dnf -y install container-selinux libcgroup
mkdir -p ~/tmp && cd ~/tmp
wget "https://download.docker.com/linux/fedora/26/x86_64/stable/Packages/docker-ce-17.09.0.ce-1.fc26.x86_64.rpm"
rpm -i docker-ce-17.09.0.ce-1.fc26.x86_64.rpm
cd ~ && rm -rf ~/tmp
dnf -y install docker-compose
systemctl enable docker.service
systemctl start docker

# activate tmux autostart (start or attach tmux on login. client has to pass the environment variable TMUX_AUTOSTART=true)
ssh_config_file="/etc/ssh/sshd_config"

echo "" >> $ssh_config_file
echo "# Allow user to pass the TMUX_AUTOSTART environment variable." >> $ssh_config_file
echo "AcceptEnv TMUX_AUTOSTART" >> $ssh_config_file

systemctl restart sshd.service

