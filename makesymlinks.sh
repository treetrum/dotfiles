#!/bin/bash
###########################################
# .makesymlinks.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
##########################################

######### Variables

dir=~/.dotfiles			# dotfiles directory
backupdir="$dir/backup"		# old dotfiles backup directory
colorsdir="$dir/vimcolors"
dotfilesdir="$dir/dotfiles"

files="eslintrc.yml sass-lint.yml"			# list of files/folders to symlink in homeidr

########

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