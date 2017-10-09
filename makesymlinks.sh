#!/bin/bash
###########################################
# .makesymlinks.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
##########################################

######### Variables

dir=$(pwd)			# dotfiles directory
backupdir="$dir/backup"		# old dotfiles backup directory
colorsdir="$dir/vimcolors"
dotfilesdir="$dir/dotfiles"

files="eslintrc.yml sass-lint.yml vimrc"			# list of files/folders to symlink in homeidr
colors="itg_flat.vim spacegray.vim"

########

# Create create backup dir
mkdir -p $backupdir

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks
echo ""
echo "============================================="
echo "Creating dotfiles symlinks"
echo "============================================="
echo ""
echo "---------------------------------------------"
for file in $files; do

    # Move existing files
    if [ -h ~/.$file ]; then
        echo "Moving ~/.$file to $backupdir/$file"
        cp -L ~/.$file $backupdir/$file
        rm ~/.$file
    fi

    # Create symlinks
    echo "Creating symlink to $file in home directory."
    ln -s $dotfilesdir/$file ~/.$file

    echo "---------------------------------------------"

done

# Create symlinks for any color schemes as well
echo ""
echo "============================================="
echo "Creating color symlinks"
echo "============================================="
echo ""
echo "---------------------------------------------"
for color in  $colors; do
	mkdir -p ~/.vim/colors
	echo "Creating symlink from $color to ~/.vim/colors/$color"
	ln -s $colorsdir/$color ~/.vim/colors/$color
    echo "---------------------------------------------"
done
