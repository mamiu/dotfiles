# Things to do first after Linux Server installation (Debian 8 or Fedora 23)

**Variables in this guide:**

    <SERVER_HOSTNAME>   = servers hostname or IP address
    <SERVER_SHORTNAME>  = an abbreviation/short name for the server
    <SERVER_USERNAME>   = the admins username on the server (not root)
    <FIRST_NAME>        = admins first name
    <LAST_NAME>         = admins last name
    <EMAIL_ADDRESS>     = admins email address

<br><br>
##Things you have to do as root user

####Creating your admins user account and add it to the sudoers group
**Debian:**

    adduser <SERVER_USERNAME> sudo
    passwd <SERVER_USERNAME>
    
**Fedora:**  
You can do it within the graphical installer or by typing the same command as on debian.

<br>
####Install `sudo, git, vim, tmux, curl and fish`.  
**On Debian:**

    apt-get -y install sudo git vim tmux curl
    curl -L https://goo.gl/eHAKB4 | bash

**On Fedora:**

    dnf install git vim tmux fish

<br><br>
## Things you have to do from any other user account (e.g. the admins account)


####To ssh into your machine with the `<SERVER_SHORTNAME>`:

Insert following three lines in `~/.ssh/config` on the host:

    Host <SERVER_SHORTNAME>
        USER <SERVER_USERNAME>
        HostName <SERVER_HOSTNAME>

<br>
####For ssh autologin run (on host):

    cat ~/.ssh/id_rsa.pub | ssh <SERVER_SHORTNAME> "mkdir -p ~/.ssh && cat >> .ssh/authorized_keys"

<br>
####Login with your \<SERVER_USERNAME\> (`ssh <SERVER_SHORTNAME>`)

    git config --global user.name "<FIRST_NAME> <LAST_NAME>"
    git config --global user.email "<EMAIL_ADDRESS>"
    git clone https://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
    ~/.homesick/repos/homeshick/bin/homeshick clone mamiu/dotfiles

<br>
**If you don't want a ssh login message:**  
Clear the file `/etc/motd` (**m**essage **o**f **t**he **d**ay) to remove the login message.  

