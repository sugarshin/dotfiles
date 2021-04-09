:syntax on
set encoding=UTF-8
set fileencoding=UTF-8
set termencoding=UTF-8
set nobackup
set noswapfile
set autoread
set hidden
set showcmd
set cursorline
set number
set cursorcolumn
set smartindent
set visualbell
set showmatch
set laststatus=2
set hlsearch
set title
set ttyfast
set clipboard+=unnamed

call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-rails'
Plug 'kchmck/vim-coffee-script'
Plug 'hail2u/vim-css3-syntax'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'jbgutierrez/vim-babel'
Plug 'mattn/webapi-vim'
Plug 'airblade/vim-gitgutter'
Plug 'scrooloose/nerdtree'
Plug 'rking/ag.vim'
Plug 'digitaltoad/vim-pug'
Plug 'fatih/vim-go'
Plug 'editorconfig/editorconfig-vim'
Plug 'leafgarland/typescript-vim'
Plug 'Quramy/vim-js-pretty-template'
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
call plug#end()
