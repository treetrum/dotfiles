#!/bin/bash
###########################################
# .makesymlinks.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
##########################################

######### Variables

# Base dotfiles directory
dir=~/.dotfiles 

# Location of actual dotfiles
dotfilesdir="$dir/dotfiles" 

# list of files/folders to symlink in homeidr
files="eslintrc.yml sass-lint.yml"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks
echo ""
echo "============================================="
echo "Creating dotfiles symlinks"
echo "============================================="
echo ""
for file in $files; do

    echo "---------------------------------------------"

    # Remove existing files
    if [ -h ~/.$file ]; then
        rm ~/.$file
    fi

    # Create symlinks
    echo "Creating symlink to $file in home directory."
    ln -s $dotfilesdir/$file ~/.$file

    echo "---------------------------------------------"

done