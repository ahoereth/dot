" Some settings are OS dependant
let s:uname = system("echo -n \"$(uname)\"")
let dot = '~/repos/dot/'


" PLUG
" filetype off

let s:plugin_manager=expand('~/.vim/autoload/plug.vim')
let s:plugin_url='https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
if empty(glob(s:plugin_manager))
  echom 'vim-plug not found. Installing...'
  if executable('curl')
    silent exec '!curl -fLo ' . s:plugin_manager . ' --create-dirs ' .
          \ s:plugin_url
  elseif executable('wget')
    call mkdir(fnamemodify(s:plugin_manager, ':h'), 'p')
    silent exec '!wget --force-directories --no-check-certificate -O ' .
          \ expand(s:plugin_manager) . ' ' . s:plugin_url
  else
    echom 'Could not download plugin manager. No plugins were installed.'
    finish
  endif
  augroup vimplug
    autocmd!
    autocmd VimEnter * PlugInstall
  augroup END
endif
" Create a horizontal split at the bottom when installing plugins
let g:plug_window = 'botright new'
let g:plug_dir = expand('~/.vim/plugged')
call plug#begin(g:plug_dir)
Plug 'liuchengxu/vim-clap', { 'do': ':Clap install-binary!' }
Plug 'itchyny/lightline.vim' " statusline
Plug 'preservim/tagbar' " show current tag in statusline
Plug 'ludovicchabant/vim-gutentags' " automatic tag management
Plug 'Yggdroot/indentLine' " vertical lines on indents
Plug 'andymass/vim-matchup' " highlight matching words and such
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround' " cs'<p>
Plug 'tpope/vim-repeat' " better . for repeating commands
Plug 'tpope/vim-commentary' " gcc for commenting lines
Plug 'wellle/context.vim'
Plug 'rust-lang/rust.vim'
call plug#end()
let g:loaded_matchit = 1

" VUNDLE
set rtp+=~/repos/dot/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
" Plugin 'Valloric/YouCompleteMe'
Plugin 'airblade/vim-gitgutter'
" Plugin 'mhinz/vim-signify' " alternative to gitgutter
"Plugin 'python-mode/python-mode'
Plugin 'rafi/awesome-vim-colorschemes'
"Plugin 'MaxMEllon/vim-jsx-pretty'
"Plugin 'cespare/vim-toml'
" Plugin 'dense-analysis/ale'
Plugin 'joshdick/onedark.vim'
Plugin 'sheerun/vim-polyglot' " language support
"Plugin 'junegunn/fzf'
"Plugin 'junegunn/fzf.vim'
"automatic vim sessions
Plugin 'tpope/vim-obsession'
Plugin 'dhruvasagar/vim-prosession'

Plugin 'rhysd/vim-clang-format'
Plugin 'psf/black'
Plugin 'prettier/vim-prettier'
"
"Plugin 'samoshkin/vim-mergetool'
"Plugin 'vim-ctrlspace/vim-ctrlspace'

Plugin 'DoxygenToolkit.vim' " vim-scripts/DoxygenToolkit.vim " :Dox
"Plugin 'ctrlpvim/ctrlp.vim'
" Plugin 'bfrg/vim-cpp-modern'
Plugin 'machakann/vim-highlightedyank'
Plugin 'itchyny/vim-cursorword'
" Plugin 'muellan/vim-brace-for-umlauts' " make qwertz more useful
" Plugin 'bounceme/poppy.vim' " highlight matching braces
" Plugin 'kien/rainbow_parentheses.vim'
" Plugin 'luochen1990/rainbow' " highlight braces
" Plugin 'krischik/vim-rainbow'
"Plugin 'mg979/vim-visual-multi' " multi cursor support
Plugin 'rhysd/clever-f.vim' " f{char} and t{char} jumps
"Plugin 'preservim/vim-pencil' " better prose editing
" Plugin 'tommcdo/vim-exchange' " exchange text using cx{motion}
Plugin 'kana/vim-niceblock' " I and A in block-wise mode
" Plugin 'umaumax/vim-format'
"Plugin 'neoclide/coc.nvim' " snippet completion

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
set list " show whitespace
set softtabstop=0
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

" Escape special characters in a string for exact matching.
" This is useful to copying strings from the file to the search tool
" Based on this - http://peterodding.com/code/vim/profile/autoload/xolox/escape.vim
function! EscapeString (string)
  let string=a:string
  " Escape regex characters
  let string = escape(string, '^$.*\/~[]')
  " Escape the line endings
  let string = substitute(string, '\n', '\\n', 'g')
  return string
endfunction

" Get the current visual block for search and replaces
" This function passed the visual block through a string escape function
" Based on this - https://stackoverflow.com/questions/676600/vim-replace-selected-text/677918#677918
function! GetVisual() range
  " Save the current register and clipboard
  let reg_save = getreg('"')
  let regtype_save = getregtype('"')
  let cb_save = &clipboard
  set clipboard&

  " Put the current visual selection in the " register
  normal! ""gvy
  let selection = getreg('"')

  " Put the saved registers and clipboards back
  call setreg('"', reg_save, regtype_save)
  let &clipboard = cb_save

  "Escape any special characters in the selection
  let escaped_selection = EscapeString(selection)

  return escaped_selection
endfunction

vmap <C-r> <Esc>:%s/<c-r>=GetVisual()<cr>//gc<left><left>

" Search/replace after visual selection using ctrl+r
"vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>



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
au BufEnter,BufRead,BufNewFile,BufFilePost *.md set spell

" cpp development
au FileType cpp,c,hpp,h set tabstop=2
au FileType cpp,c,hpp,h set shiftwidth=2
au FileType cpp,c,hpp,h set expandtab
au FileType cpp,c,hpp,h set syntax=cpp.doxygen
command Switch :e %:p:s,.hpp$,.X123X,:s,.cpp$,.hpp,:s,.X123X$,.cpp,
command Sw :e %:p:s,.hpp$,.X123X,:s,.cpp$,.hpp,:s,.X123X$,.cpp,

" python
au FileType python set tabstop=4
au FileType python set shiftwidth=4
au FileType python set expandtab

" stamp text -- replace word with last yank
nnoremap S "_diwP

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

" PLUGIN: rust
let g:rustfmt_autosave = 1

" PLUGIN: context
let g:context_enabled = 1
let g:context_max_height = 3
let g:context_highlight_tag = '<hide>'

" PLUGIN: commentary
au FileType cpp,c,hpp,h setlocal commentstring=//\ %s
au FileType proto setlocal commentstring=//\ %s

" PLUGIN: black
" augroup black_on_save
"   autocmd!
"   autocmd BufWritePre *.py Black
" augroup end


" PLUGIN: poppy / rainbow parentheses
"au! cursormoved * call PoppyInit()
" au FileType cpp,c,hpp,h RainbowParenthesesActivate
" au FileType cpp,c,hpp,h RainbowParenthesesLoadRound
" au FileType cpp,c,hpp,h RainbowParenthesesLoadSquare
" au FileType cpp,c,hpp,h RainbowParenthesesLoadBraces
" if exists("g:btm_rainbow_color") && g:btom_rainbow_color
let g:rainbow_parenthesis_color = 'slve'
" call rainbow_paranthesis#LoadSquare()
" autocmd FileType cpp call rainbow_parenthesis#LoadBraces()
" autocmd FileType cpp call rainbow_parenthesis#Activate()
" endif



" PLUGIN: vim-format
let g:vim_format_fmt_on_save = 1


" PLUGIN: clap
" left right split
" let g:clap_preview_direction = 'LR'
" let g:clap_layout = {'relative': 'editor', 'width': '50%', 'col': '0%', 'height': '99%', 'row': '2%'}
" top bottom split
let g:clap_preview_direction = 'UD'
let g:clap_layout = {'relative': 'editor', 'width': '100%', 'col': '0%', 'height': '70%', 'row': '5%'}
"let g:clap_theme = { 'search_text': {'guifg': 'red', 'ctermfg': 'red'} }
" let g:clap_theme = {'display': {'guibg': 'black'}, 'preview': {'guibg': 'black'}}
" let g:clap_theme['search_text'] = {'guibg': 'black', 'ctermbg': 'black'}
" let g:clap_theme['input'] = {'guibg': 'black', 'ctermbg': 'black'}
" let g:clap_theme['indicator'] = {'guibg': 'black', 'ctermbg': 'black'}
" let g:clap_theme['spinner'] = {'guibg': 'black', 'ctermbg': 'black'}
" let g:clap_disable_run_rooter = 'v:true'
let g:clap_popup_input_delay = '40ms'
let g:clap_provider_grep_delay = '10ms'
" nnoremap <C-p> :Clap files<CR>
" lowercase option p
nnoremap π :Clap files<CR>
" uppercase option p
nnoremap ∏ :Clap buffers<CR>
map <leader>p :Clap git_files<CR>
map <leader>g :Clap grep<CR>
map <leader>r :Clap recent_files<CR>
map <leader>P :b#<CR> # previous buffer

" PLUGIN: YCM
" let g:ycm_confirm_extra_conf = 0
" let g:ycm_python_interpreter_path = ''
" let g:ycm_python_sys_path = []
" let g:ycm_extra_conf_vim_data = ['g:ycm_python_interpreter_path', 'g:ycm_python_sys_path']
" let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
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

" PLUGIN: gutentags
" let g:gutentags_trace = 1
let g:gutentags_ctags_exclude = ['--*']
let g:gutentags_file_list_command = 'rg --files'

" PLUGIN: fzf
"nnoremap <Alt-p> :Files<Cr>
"nnoremap <Alt-o> :Buffers<Cr>
" lowercase option p
"nnoremap π :Files<Cr>
" uppercase option p
"nnoremap ∏ :Buffers<CR>

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
let $FZF_DEFAULT_OPTS = '--bind ctrl-a:select-all'

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

" jump to tags
" nnoremap t <C-]>
nnoremap ü <C-]>
nnoremap Ü <C-O>

" PLUGIN: clang-format
"autocmd FileType *.c,*.cpp,*.h,*.hpp ClangFormatAutoEnable
autocmd FileType c ClangFormatAutoEnable
autocmd FileType cpp ClangFormatAutoEnable
autocmd FileType proto ClangFormatAutoEnable


" PLUGIN: matchup
" let g:matchup_matchparen_offscreen = {'method': 'status_manual'}
let g:matchup_matchparen_offscreen = {'method': 'popup', 'highlight': 'OffscreenPopup', 'fullwidth': 1, 'syntax_hl': 1}
let g:matchup_delim_stopline      = 1500 " generally
let g:matchup_matchparen_stopline = 1500  " for match highlighting only

" PLUGIN: lightline
set laststatus=2
set noshowmode " lightline shows status
let g:lightline = {
        "\   'colorscheme': 'Tomorrow',
        "\   'colorscheme': 'ayu_light',
        "\   'enable': { 'statusline': 0 },
        \   'colorscheme': '16color',
        \   'active': {
        \     'left': [ [ 'mode', 'paste' ],
        \               [ 'filename' ] ],
        \     'right': [ [ 'percent', 'lineinfo' ],
        \                [ 'gitbranch', 'readonly'],
        \                [ 'fileformat', 'fileencoding', 'filetype' ] ]
        \   },
        \   'component': {
        \       'tagbar': '%{tagbar#currenttag("%s", "")}',
        \   },
        \   'component_function': {
        \     'fileformat': 'LightlineFileformat',
        \     'filetype': 'LightlineFiletype',
        \     'filename': 'LightlineFilename',
        \     'gitbranch': 'FugitiveHead',
        \     'obsession': 'ObsessionStatus',
        \   },
        \ }
        " \   'mode_map': {
        " \     'n' : 'N',
        " \     'i' : 'I',
        " \     'R' : 'R',
        " \     'v' : 'V',
        " \     'V' : 'VL',
        " \     "\<C-v>": 'VB',
        " \     'c' : 'C',
        " \     's' : 'S',
        " \     'S' : 'SL',
        " \     "\<C-s>": 'SB',
        " \     't': 'T',
        " \   },
function! LightlineFilename()
  let filename = expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
  let tagname = tagbar#currenttag("%s", "", "", "scoped-stl")
  let tagname = len(tagname) > 0 ? "::" . tagname : ""
  let modified = &modified ? '+' : ''
  return filename . tagname . modified
endfunction
function! LightlineFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction
function! LightlineFiletype()
  return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : '') : ''
endfunction

" PLUGIN: prettier
let g:prettier#autoformat = 0
let g:prettier#autoformat_require_pragma = 0

" PLUGIN: (ctrl)(p(r))obsession
let g:prosession_default_session = 0
"let g:prosession_last_session_dir = "~"
"let g:prosession_ignore_dirs = [ "build" ]

" PLUGIN: mergetool
let g:mergetool_layout = 'mr'
let g:mergetool_prefer_revision = 'local'

" PLUGIN: doxygen toolkit
let g:DoxygenToolkit_authorName="Alexander Höreth <alexander@psiori.com>"

" PLUGIN: vim-cpp-modern
let g:cpp_function_highlight = 1
let g:cpp_attributes_highlight = 1
let g:cpp_member_highlight = 1
let g:cpp_simple_highlight = 0

" PLUGIN: indentLine
au FileType markdown let g:indentLine_setConceal = 0
au FileType json let g:indentLine_setConceal = 0
let g:vim_markdown_conceal = 0
let g:vim_markdown_conceal_code_blocks = 0

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
" if has('mouse')
"   if &term =~ 'xterm'
"     set mouse=a
"   else
"     set mouse=nvi
"   endif
" endif


" Viminfo saves/restores editing metadata in ~/.viminfo.
" '100   Save marks for the last 100 edited files
" f1     Store global marks
" <500   Save max of 500 lines of each register
" :100   Save 100 lines of command-line history
" /100   Save 100 searches
" h      Disable hlsearch when starting
set viminfo='1000,f1,<500,:100,/100,h


" --------------------------- Colorscheme Settings -------------------------
let g:is_bash = 1
syntax on
set t_Co=256
set cursorline
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

" let g:onedark_termcolors=256
" let g:onedark_color_overrides = {
"   \ "background": {"gui": "#000000", "cterm": "255", "cterm16": "0" },
" \}
" colorscheme onedark
" colorscheme one
" set background=light
" let ayucolor="light"
let ayucolor="dark"
colorscheme ayu
" colorscheme pink-moon

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

function! Corne()
  :set langmap=dh,hj,tk,nl
endfunction
