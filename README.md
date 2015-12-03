#Things to do first after Linux Server installation (Debian 8 or Fedora 23)

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
You can do it within the graphical installer or by issuing following commands:

    adduser <SERVER_USERNAME>
    passwd <SERVER_USERNAME>
    gpasswd wheel -a <SERVER_USERNAME>

<br>
####Install `sudo, git, vim, tmux, curl and fish`
**On Debian:**

    apt-get -y install sudo git vim tmux curl
    curl -L https://goo.gl/eHAKB4 | bash  # BE CAREFULL!!! Please check the script behind this link before!

**On Fedora:**

    dnf install git vim tmux fish

<br><br>
##Things you have to do from your host

####To ssh into your server with the `<SERVER_SHORTNAME>`:

Insert following three lines in `~/.ssh/config` on the host:

    Host <SERVER_SHORTNAME>
        USER <SERVER_USERNAME>
        HostName <SERVER_HOSTNAME>

<br>
####To ssh into your server without passphrase:

    cat ~/.ssh/id_rsa.pub | ssh <SERVER_SHORTNAME> "mkdir -p ~/.ssh && cat >> .ssh/authorized_keys"

<br><br>
##Things you have to do admin

####Login with your \<SERVER_USERNAME\> (`ssh <SERVER_SHORTNAME>`)

    git config --global user.name "<FIRST_NAME> <LAST_NAME>"
    git config --global user.email "<EMAIL_ADDRESS>"
    git clone https://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
    ~/.homesick/repos/homeshick/bin/homeshick clone mamiu/dotfiles

<br><br>
##Extras

####To symlink the same dotfiles for root, call the `symlink_as_another_user.sh` as root user:

    /home/<SERVER_USERNAME>/.homesick/repos/dotfiles/symlink_as_another_user.sh

####If you don't want a ssh login message:
Clear the file `/etc/motd` (**m**essage **o**f **t**he **d**ay) to remove the login message.  

