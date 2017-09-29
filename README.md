# mamius' dotfiles

This is the repository of the config files, I need on every system.
I manage my config files with [homeshick](https://github.com/andsens/homeshick), an awesome git dotfiles synchronizer written in bash.

To install this config files on your system, you just have to ensure that you have git, vim, tmux and fish installed and then execute following two lines:

    git clone https://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
    ~/.homesick/repos/homeshick/bin/homeshick clone mamiu/dotfiles

That's it! Have fun :tada:

<br>

## This guide is an example how to setup a fedora server after a clean installation

Tested with Fedora 22 and above.  
A description of the Variables used in this guide can be found at the bottom.

### On the server

#### STEP 1: Login as root user

#### STEP 2: Creating your admins user account and add it to the sudoers group

If you already created an user account for the admin, skip this step.
Otherwise create your admins user account:

    adduser <SERVER_USERNAME>
    passwd <SERVER_USERNAME>
    gpasswd wheel -a <SERVER_USERNAME>

#### STEP 3: Install the most important tools

    dnf update vim-minimal
    dnf install git vim tmux fish

#### STEP 4: Clone the dotfiles from these reporitory

    git clone https://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
    ~/.homesick/repos/homeshick/bin/homeshick clone mamiu/dotfiles

#### STEP 5: Login to your admins user account

    su - <SERVER_USERNAME>

#### STEP 6: Configure git

    git config --global user.name "<FIRST_NAME> <LAST_NAME>"
    git config --global user.email "<EMAIL_ADDRESS>"

#### STEP 7: Clone the dotfiles from these reporitory

    git clone https://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
    ~/.homesick/repos/homeshick/bin/homeshick clone mamiu/dotfiles
    

### On the client:

#### STEP 1: Setup ssh config to login easily with `ssh <SERVER_NICKNAME>`

Insert following four lines in `~/.ssh/config` on the host:

    Host <SERVER_NICKNAME>
        User <SERVER_USERNAME>
        HostName <SERVER_HOSTNAME>
        Port <SERVER_PORT>
        SendEnv TMUX_AUTOSTART

#### STEP 2: Add clients public key to your servers athorized keys

This step will enable you to ssh into your server without passphrase.

If you have the `ssh-copy-id` command on your client it's only:

    ssh-copy-id <SERVER_NICKNAME>

Otherwise you have to call:

    cat ~/.ssh/id_rsa.pub | ssh <SERVER_NICKNAME> "mkdir -p ~/.ssh; and cat >> .ssh/authorized_keys"

If you use *bash* or *zsh* on the client, replace the `; and ` with ` && `.

### Extras

#### To start tmux automatically after login add following line to `/etc/ssh/sshd_config`:

    AcceptEnv TMUX_AUTOSTART

After that you have to restart the ssh server with:

    systemctl restart sshd.service


### Variables in this guide

    <SERVER_HOSTNAME>   = servers hostname or IP address
    <SERVER_PORT>       = port on server where the ssh service is listening
    <SERVER_NICKNAME>   = an abbreviation/short name for the server
    <SERVER_USERNAME>   = the admins username on the server (not root)
    <FIRST_NAME>        = admins first name
    <LAST_NAME>         = admins last name
    <EMAIL_ADDRESS>     = admins email address

<br>
----------

Made by a :nerd_face: with :heartpulse: in :de:
