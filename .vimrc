" Some settings are OS dependant
let s:uname = system("echo -n \"$(uname)\"")
let dot = '~/repos/dot/'
" VUNDLE
set nocompatible
filetype off
set rtp+=~/repos/dot/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-rhubarb'
Plugin 'tpope/vim-unimpaired'
Plugin 'airblade/vim-gitgutter'
" Plugin 'mhinz/vim-signify' " alternative to gitgutter
Plugin 'tpope/vim-surround' " cs'<p>
"Plugin 'python-mode/python-mode'
Plugin 'rafi/awesome-vim-colorschemes'
"Plugin 'MaxMEllon/vim-jsx-pretty'
"Plugin 'cespare/vim-toml'
"Plugin 'vim-airline/vim-airline'
"Plugin 'vim-airline/vim-airline-themes'
Plugin 'dense-analysis/ale'
Plugin 'joshdick/onedark.vim'
Plugin 'itchyny/lightline.vim'
Plugin 'sheerun/vim-polyglot' " language support
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
"automatic vim sessions
Plugin 'tpope/vim-obsession'
Plugin 'dhruvasagar/vim-prosession'
Plugin 'rhysd/vim-clang-format'
Plugin 'psf/black'
Plugin 'prettier/vim-prettier'
"Plugin 'samoshkin/vim-mergetool'
"Plugin 'vim-ctrlspace/vim-ctrlspace'

call vundle#end()

filetype plugin indent on
syntax on

set textwidth=80
let &wrapmargin= &textwidth
set colorcolumn=+1,+21,+41
highlight ColorColumn ctermbg=lightgrey guibg=lightgrey
set formatoptions=croql

set linebreak
set wrap

set hidden
set history=1000
set number
" highlight search results
set hlsearch
" incremental search while typing
set incsearch
set autoindent
set smartindent
" case insensitive search
set ignorecase
" If search pattern contains an upper case character, search case sensitive
set smartcase
" tab autocompletion
set wildmenu
set wildmode=list:longest
" Ignore compiled files
set wildignore=*.o,*~,*.pyc
if has("win16") || has("win32")
    set wildignore+=.git\*,.hg\*,.svn\*
else
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
endif

" keep 5 lines of context when scrolling
set scrolloff=5
" autoreload files when focus returns
set autoread
au FocusGained * :checktime
" Expand tabs to spaces
set expandtab
set smarttab
set tabstop=2
set shiftwidth=2
"set sts=-1
"set undofile
" Backspace through indentation and such
set backspace=indent,eol,start
set whichwrap+=<,>,h,l

" only single space after sentences
set nojoinspaces

set synmaxcol=1024
set ttyfast
set ttyscroll=3
" do not redraw while executing macros
set lazyredraw
set relativenumber
set ruler
" magic for regular expressions
set magic

" highlight matching brackets
set showmatch
set mat=2

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

" split to the bottom right by default when using :vsplit
" Alternative: use :bo[tright] vs filename
set splitbelow
set splitright

" Make split divisions look nicer.
"set fillchars+=vert:\


" Spellchecking
set spell
set spelllang=en_us,de_de

" show partial command at bottom of screen
set showcmd

" When completing, do not automatically select the first choice,
" but instead just insert the longest common text.
set completeopt=menu

" Unify vim's default register and the system clipboard
set clipboard=unnamed
if s:uname == "Linux"
  set clipboard=unnamedplus
endif


let mapleader = ","


" :W sudo saves the file
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!


" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>


" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Map <Space> to / (search) and Ctrl-<Space> to ? (backwards search)
map <space> /
map <C-space> ?

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Move a line of text using ALT+[jk] or Command+[jk] on mac
nmap <M-j> mz:m+<cr>`z
nmap <M-k> mz:m-2<cr>`z
vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

if has("mac") || has("macunix")
  nmap <D-j> <M-j>
  nmap <D-k> <M-k>
  vmap <D-j> <M-j>
  vmap <D-k> <M-k>
endif



" Toggle paste mode on and off
map <leader>pp :setlocal paste!<cr>

" Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<cr>


" AUTOCOMMANDS
au BufRead,BufNewFile *.ipynb,Pipfile.lock,.eslintrc setfiletype json
au BufRead,BufNewFile Pipfile setfiletype config
au BufRead,BufNewFile Dockerfile* setfiletype Dockerfile
au BufRead,BufNewFile *.pl setfiletype prolog
au BufRead,BufNewFile *.beamer,*.cls setfiletype tex
au BufRead,BufNewFile *.launch setfiletype xml
au BufRead,BufNewFile *.cpp,*.hpp,*.h set tabstop=2
au BufRead,BufNewFile *.cpp,*.hpp,*.h set shiftwidth=2
au BufRead,BufNewFile *.cpp,*.hpp,*.h set expandtab
au BufEnter,BufRead,BufNewFile,BufFilePost *.md set spell

" KEYMAP
" move around on soft wrapped lines as if they were hard wrapped
nnoremap j gj
nnoremap k gk
" jump between splits without the C-W first
nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>
nnoremap <C-l> <C-w><C-l>
nnoremap <C-h> <C-w><C-h>
" nmap <silent> <C-k> <Plug>(ale_previous_wrap)
" nmap <silent> <C-j> <Plug>(ale_next_wrap)
" Next buffer using tab, previous buffer using shift+tab.
nnoremap <silent>   <tab> :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bnext<CR>
nnoremap <silent> <s-tab> :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bprevious<CR>
inoremap <S-Tab> <C-d> " fix shift+tab for unindent


" PLUGIN: netrw
" Thanks @George Ornbo https://shapeshed.com/vim-netrw/
let g:netrw_liststyle = 3
let g:netrw_banner = 0
let g:netrw_browse_split = 2
let g:netrw_winsize = 10


" PLUGIN: YCM
let g:ycm_confirm_extra_conf = 0
let g:ycm_python_interpreter_path = ''
let g:ycm_python_sys_path = []
let g:ycm_extra_conf_vim_data = ['g:ycm_python_interpreter_path', 'g:ycm_python_sys_path']
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
" required on macos
let g:ycm_clangd_binary_path = trim(system('brew --prefix llvm')).'/bin/clangd'


" PLUGIN: ale
let g:ale_sign_column_always = 1
let g:ale_sign_error = '!!'
let g:ale_sign_warning = '¡¡'
let g:ale_fix_on_save = 1
"let g:ale_fixers = {
"  \   '*': ['remove_trailing_lines', 'trim_whitespace'],
"  \   'javascript': ['prettier', 'eslint'],
"  \   'typescript': ['prettier', 'eslint'],
"  \}

" PLUGIN: GitGutter
let g:gitgutter_override_sign_column_highlight = 0
let g:gitgutter_sign_removed = '-'
highlight GitGutterAdd ctermfg=34
highlight GitGutterChange ctermfg=184
highlight GitGutterChangeDelete ctermfg=184
highlight GitGutterDelete ctermfg=124


" PLUGIN: fzf
nnoremap <C-p> :Files<Cr>
nnoremap <Alt-p> :Buffers<Cr>
nnoremap π :Buffers<Cr>

"<C-t> to open in new tab
"<C-v> to open in vertical split
"<C-x> to open in horizontal split
" Enable calls like << :RG -t yaml PATTERN >>
function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case '
  let initial_command = command_fmt.(a:query)
  let reload_command = printf(command_fmt.('%s'), '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:eval '.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction
command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

" PLUGIN: fugitive
" auto-clean fugitive buffers when they become hidden
autocmd BufReadPost fugitive://* set bufhidden=delete

" PLUGIN: unimpaired
" map <> to []
nmap < [
nmap > ]
omap < [
omap > ]
xmap < [
xmap > ]

" PLUGIN: clang-format
"autocmd FileType *.c,*.cpp,*.h,*.hpp ClangFormatAutoEnable
autocmd FileType c ClangFormatAutoEnable
autocmd FileType cpp ClangFormatAutoEnable


" PLUGIN lightline
set laststatus=2
set noshowmode " lightline shows status
let g:lightline = {
        "\ 'colorscheme': 'Tomorrow',
        "\ 'colorscheme': 'ayu_light',
        \ 'colorscheme': '16color',
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ],
        \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ],
        \   'right': [ [ 'lineinfo' ],
        \              [ 'percent' ],
        \              [ 'obsession', 'fileformat', 'fileencoding', 'filetype' ] ]
        \ },
        \ 'component_function': {
        \     'fileformat': 'LightlineFileformat',
        \     'filetype': 'LightlineFiletype',
        \     'gitbranch': 'FugitiveHead',
        \     'obsession': 'ObsessionStatus',
        \   },
        \ }
function! LightlineFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction
function! LightlineFiletype()
  return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : '') : ''
endfunction

" PLUGIN prettier
let g:prettier#autoformat = 0
let g:prettier#autoformat_require_pragma = 0

" PLUGIN (ctrl)(p(r))obsession
let g:prosession_default_session = 0
"let g:prosession_last_session_dir = "~"
"let g:prosession_ignore_dirs = [ "build" ]

" PLUGIN mergetool
let g:mergetool_layout = 'mr'
let g:mergetool_prefer_revision = 'local'

" Change where we store swap/undo files.
if !isdirectory($HOME . "/.vim/tmp")
  " Ensure the temp dirs exist
  call system("mkdir -p ~/.vim/tmp/swap")
  call system("mkdir -p ~/.vim/tmp/undo")
endif
set dir=~/.vim/tmp/swap/
set undodir=~/.vim/tmp/undo/

" Disable vim's own backups.
set nobackup
set nowritebackup
set noswapfile

" I do not use tabs.
set sessionoptions-=tabpages
" Don't remember help pages in sessions
set sessionoptions-=help
" Do not save hidden buffers, as they are hidden
"set sessionoptions-=buffers

" Show @@@ in the last line if it is truncated.
set display=truncate

" autoread when a file is changed from the outside
set autoread
au FocusGained,BufEnter * checktime

" Allow mouse use
if has('mouse')
  if &term =~ 'xterm'
    set mouse=a
  else
    set mouse=nvi
  endif
endif


" Viminfo saves/restores editing metadata in ~/.viminfo.
" '100   Save marks for the last 100 edited files
" f1     Store global marks
" <500   Save max of 500 lines of each register
" :100   Save 100 lines of command-line history
" /100   Save 100 searches
" h      Disable hlsearch when starting
set viminfo='1000,f1,<500,:100,/100,h


" --------------------------- Colorscheme Settings -------------------------
call plug#begin('~/.vim/plugged')
"Plug 'sonph/onehalf', { 'rtp': 'vim' }
syntax on
set t_Co=256
set cursorline
"colorscheme onehalfdark
"colorscheme molokai
"colorscheme deus
"let g:airline_theme='onehalfdark'
" lightline
" let g:lightline = { 'colorscheme': 'onehalfdark' }
" colorscheme molokai

if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
  if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    " Turns on true terminal colors
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

    " Turns on 24-bit RGB color support
    set termguicolors

    " Defines how many colors should be used. (maximum: 256, minimum: 0)
    set t_Co=256
  endif
endif

let g:onedark_termcolors=256
set background=dark
let g:onedark_color_overrides = {
  \ "background": {"gui": "#000000", "cterm": "255", "cterm16": "0" },
  \}
colorscheme onedark

" Show extra whitespace
hi ExtraWhitespace guibg=#CCCCCC
hi ExtraWhitespace ctermbg=7
match ExtraWhitespace /\s\+$/
augroup highlight_whitespace
  au!
  au BufWinEnter * match ExtraWhitespace /\s\+$/
  au InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
  au InsertLeave * match ExtraWhitespace /\s\+$/
  au BufWinLeave * call clearmatches()
augroup END

" ---------------------- Custom Commands and Functions ---------------------

" A function to delete all trailing whitespace from a file. (From
" http://vimcasts.org/episodes/tidying-whitespace/)
function! Preserve(command)
  " Preparation: save last search, and cursor position.
  let _s=@/
  let l = line(".")
  let c = col(".")
  " Do the business:
  execute a:command
  " Clean up: restore previous search history, and cursor position
  let @/=_s
  call cursor(l, c)
endfunction
nmap _$ :call Preserve("%s/\\s\\+$//e")<CR>
nmap _= :call Preserve("normal gg=G")<CR>
autocmd BufWritePre * :call Preserve("%s/\\s\\+$//e") " remove trailing spaces
"autocmd BufWritePre *.py,*.cpp,*.hpp,*.h,*.c,*.proto :call Preserve("normal gg=G")<CR>

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif
