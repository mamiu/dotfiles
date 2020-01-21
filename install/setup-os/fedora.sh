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
    ;;
esac

if [ -z $ADMIN_USER ]; then
    read -p "Setup an admin user? [${bold_start}Y${bold_end}/n]: " setup_admin_user </dev/tty
    [ -z "$setup_admin_user" ] && setup_admin_user="y"
else
    setup_admin_user="y"
fi
case "${setup_admin_user:0:1}" in
    y|y )
        setup_admin_user=true

        users=(`awk -F':' '{ print $1}' /etc/passwd`)

        if [ -z $ADMIN_USER ]; then
            read -p "Create a new user for the admin? [${bold_start}Y${bold_end}/n]: " new_admin_user </dev/tty
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
                gpasswd -a $admin_name wheel
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
    ;;
esac


dnf -y update
dnf -y install git vim tmux fish mosh ncdu fzf bat fd-find ripgrep

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
dnf install -y kubectl

# Download and install dotfiles
git clone https://github.com/andsens/homeshick.git "$HOME/.homesick/repos/homeshick"
"$HOME/.homesick/repos/homeshick/bin/homeshick" clone -b mamiu/dotfiles
"$HOME/.homesick/repos/homeshick/bin/homeshick" link -f dotfiles

# Make fish the default shell
echo $(which fish) >> /etc/shells
chsh -s $(which fish)

# Generate ssh key pair
if [ ! -d "$HOME/.ssh" ]; then
    mkdir "$HOME/.ssh"
    ssh-keygen -b 2048 -t rsa -f "$HOME/.ssh/id_rsa" -q -N ""
fi

# Install fisher - a package manager for the fish shell
curl https://git.io/fisher --create-dirs -sLo "$HOME/.config/fish/functions/fisher.fish"
fish -c fisher

# Install vim plugins
vim

# Install tmux plugin manager and tmux plugins
git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
tmux new-session "$HOME/.tmux/plugins/tpm/tpm && $HOME/.tmux/plugins/tpm/scripts/install_plugins.sh"

# activate tmux autostart (start or attach tmux on login. client has to pass the environment variable TMUX_AUTOSTART=true)
ssh_config_file="/etc/ssh/sshd_config"

echo "" >> $ssh_config_file
echo "# Allow user to pass the TMUX_AUTOSTART environment variable." >> $ssh_config_file
echo "AcceptEnv TMUX_AUTOSTART" >> $ssh_config_file

systemctl restart sshd.service
