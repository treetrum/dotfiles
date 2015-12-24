" ============
" SETUP VUNDLE
" ============

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" PLACE PLUGINS HERE
Plugin 'https://github.com/ctrlpvim/ctrlp.vim.git'
Plugin 'https://github.com/scrooloose/nerdtree.git'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required


" ==============================================
" MY PERSONAL CUSTOMISATIONS / OUTSIDE OF VUNDLE
" ==============================================

set ruler laststatus=2 number title hlsearch
syntax on
colorscheme spacegray
map <C-n> :NERDTreeToggle<CR>
