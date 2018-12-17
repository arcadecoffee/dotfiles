" Load defaults
source $VIMRUNTIME/defaults.vim

" Visual aids
set laststatus=2
set cc=80
highlight ColorColumn ctermbg=black

" Spaces not tabs, default width 4
set tabstop=4
set shiftwidth=4
set expandtab

" Overriding tabsize for ruby to 2
autocmd FileType ruby setlocal expandtab shiftwidth=2 tabstop=2
