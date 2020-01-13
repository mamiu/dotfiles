# mamius' dotfiles

This is the repository of the config files, I need on every system.
I manage my config files with [homeshick](https://github.com/andsens/homeshick), an awesome git dotfiles synchronizer written in bash.

## Installation

To install this config files on your system, you just have to ensure that you have git installed.
Then execute following lines:

```bash
# Download homeshick and clone this dotfiles repository
git clone https://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
$HOME/.homesick/repos/homeshick/bin/homeshick clone mamiu/dotfiles -b

# ONLY EXECUTE THE FOLLOWING LINE ON A MAC OS SYSTEM
git -C $HOME/.homesick/repos/dotfiles checkout macbook

# That line again on both, linux and mac os
$HOME/.homesick/repos/homeshick/bin/homeshick link dotfiles

# Install and setup system
$HOME/.homesick/repos/dotfiles/install/install.sh --local
```

That's it! Have fun :tada:
