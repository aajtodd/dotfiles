"NeoBundle Scripts-----------------------------
if has('vim_starting')
  if &compatible
    set nocompatible               " Be iMproved
  endif
endif

set encoding=utf-8

function! BuildYCM(info)
    " info is a dictionary with 3 fields
    " - name:   name of the plugin
    " - status: 'installed', 'updated', or 'unchanged'
    " - force:  set on PlugInstall! or PlugUpdate!
    if a:info.status == 'installed' || a:info.force
        !./install.py --clang-completer --go-completer --rust-completer --ts-completer
     endif
endfunction

" Required:
call plug#begin('~/.config/nvim/plugged')

" Add or remove your Bundles here:

" General
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-abolish'
Plug 'flazz/vim-colorschemes'
Plug 'vim-scripts/hexHighlight.vim'
Plug 'tomtom/tcomment_vim'
Plug 'Valloric/ListToggle'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree'
Plug 'godlygeek/tabular'
Plug 'sjl/gundo.vim'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'itchyny/lightline.vim'
Plug 'machakann/vim-highlightedyank'
Plug 'andymass/vim-matchup'
" Plug 'jiangmiao/auto-pairs'

"Plug 'bling/vim-airline'
"Plug 'vim-airline/vim-airline-themes'
" Plug 'autozimu/LanguageClient-neovim', {
"     \ 'branch': 'next',
"     \ 'do': 'bash install.sh',
"     \ }

" Fuzzy finder
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

" Completion/Linting
"Plug 'scrooloose/syntastic'
Plug 'w0rp/ale'
Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }

" Rust Support
Plug 'rust-lang/rust.vim'
"Plug 'racer-rust/vim-racer'

" Go Support
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
Plug 'jstemmer/gotags'

" TOML
Plug 'cespare/vim-toml'

" Support for clang-tidy outformat (:FormatCode)
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'

" auto-regen tag files
Plug 'craigemery/vim-autotag'

" Required:
call plug#end()

call glaive#Install()


" Required:
" Initialize plugin system
filetype plugin indent on

"End Plug Scripts


" Set the mapleader for all commands using it
let mapleader=","

"""""""""""""""""""""""""""""""""""""""""""""""
" Syntastic options
"""""""""""""""""""""""""""""""""""""""""""""""
" GLOBALS
"let g:syntastic_enable_signs=1

let g:syntastic_check_on_open = 1
let g:syntastic_aggregate_errors = 1

" C++
let g:syntastic_cpp_checkers = ['gcc']
let g:syntastic_cpp_compiler = 'g++'
let g:syntastic_cpp_check_header = 1
let g:syntastic_cpp_compiler_options = '-Wall -Wextra'

" JavaScript
let g:Syntastic_javascript_checkers = ['jshint']


" Conflict between YCM and Syntastic for C/C++. Map convenient shortcuts
noremap <leader>sc :SyntasticCheck gcc<CR>
noremap <leader>se :Errors<CR>


"""""""""""""""""""""""""""""""""""""""""""""""
" ALE
"""""""""""""""""""""""""""""""""""""""""""""""
" only lint on save
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_save = 1
let g:ale_lint_on_enter = 0
let g:ale_virtualtext_cursor = 1
let g:ale_virtualtext_delay = 100
let g:ale_rust_rls_config = {
	\ 'rust': {
		\ 'all_targets': 1,
		\ 'build_on_save': 1,
		\ 'clippy_preference': 'on'
	\ }
	\ }
let g:ale_rust_rls_toolchain = ''
let g:ale_linters = {'rust': ['rls'] }
highlight link ALEWarningSign Todo
highlight link ALEErrorSign WarningMsg
highlight link ALEVirtualTextWarning Todo
highlight link ALEVirtualTextInfo Todo
highlight link ALEVirtualTextError WarningMsg
highlight ALEError guibg=None 
highlight ALEWarning guibg=None
let g:ale_sign_error = "✖"
let g:ale_sign_warning = "⚠"
let g:ale_sign_info = "i"
let g:ale_sign_hint = "➤"

nnoremap <silent> K :ALEHover<CR>
nnoremap <silent> gd :ALEGoToDefinition<CR>

"""""""""""""""""""""""""""""""""""""""""""""""
" YouCompleteMe 
"""""""""""""""""""""""""""""""""""""""""""""""
" Remove preview window
" set completeopt -=preview
let g:ycm_autoclose_preview_window_after_insertion = 0


" Let syntastic handle the diagnostics
"NOTE: These don't work...ycm removes syntastic checker on load of conf.py
"file. See docs
"let g:ycm_show_diagnostics_ui = 0
" let g:ycm_register_as_syntastic_checker = 0

" Shortcut to compile and immediately show diagnostics
" noremap <F5> :YcmForceCompileAndDiagnostics<CR>
noremap <F5> :YcmDiags<CR>


"Always put the full diagnostic message in the location list
"  - This can overwrite other locationlist info which is why it was off by
"    default
" let g:ycm_always_populate_location_list = 1

" note <leader>d (\d) when on highlighted line shows full diagnostic

" Whitelist/Blacklist conf files (!before an entry blacklists). Earlier
" entries take precedence over later
let g:ycm_extra_conf_globlist =  ['~/*']
let g:ycm_confirm_extra_conf = 0

" Quick goto sub commands
nnoremap <leader>jd :YcmCompleter GoTo<CR>

" Rust Doc source
let g:ycm_rust_src_path=$RUST_SRC_PATH


"""""""""""""""""""""""""""""""""""""""""""""""
" ListToggle
"""""""""""""""""""""""""""""""""""""""""""""""
let g:lt_location_list_toggle_map = '<leader>l'
let g:lt_quickfix_list_toggle_map = '<leader>q'

"""""""""""""""""""""""""""""""""""""""""""""""
" Tagbar
"""""""""""""""""""""""""""""""""""""""""""""""
" nmap <F8> :TagbarToggle<CR>
map <silent><leader>t :TagbarToggle<CR>

"""""""""""""""""""""""""""""""""""""""""""""""
" NERDTree
"""""""""""""""""""""""""""""""""""""""""""""""
"Open nerdtree if no files specified
autocmd vimenter * if !argc() | NERDTree | endif

"Open nerdtree with ctrl+n
map <C-n> :NERDTreeToggle<CR>

"Close vim if only window left is nerdtree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

"""""""""""""""""""""""""""""""""""""""""""""""
" Racer (rust)
"""""""""""""""""""""""""""""""""""""""""""""""
let g:racer_cmd = "~/.cargo/bin/racer"
"let $RUST_SRC_PATH="/home/ajt/opt/rustc-1.9.0/src"

au FileType rust nmap <C-]> <Plug>(rust-def)
au FileType rust nmap gs <Plug>(rust-def-split)
au FileType rust nmap gx <Plug>(rust-def-vertical)
au FileType rust nmap <leader>gd <Plug>(rust-doc)

let g:rustfmt_command = "rustfmt +nightly"
let g:rustfmt_autosave = 1
let g:rustfmt_emit_files = 1
let g:rustfmt_fail_silently = 0
let g:rust_clip_command = 'xclip -selection clipboard'

" Convenient PyCharm/Intellij like toggle comment
" map <C-/> :TComment<CR>
"
"""""""""""""""""""""""""""""""""""""""""""""""
" LanguageClient-neovim
"""""""""""""""""""""""""""""""""""""""""""""""
" let g:LanguageClient_serverCommands = {
"     \ 'rust': ['rustup', 'run', 'stable', 'rls'],
"     \ }


"""""""""""""""""""""""""""""""""""""""""""""""
" FZF
"""""""""""""""""""""""""""""""""""""""""""""""
" ctrl-p to invoke FZF (to regain ctrlp like functionality)
nnoremap <C-p> :Files<cr>
map <C-p> :Files<CR>



" from http://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
if executable('ag')
	set grepprg=ag\ --nogroup\ --nocolor
endif

if executable('rg')
	set grepprg=rg\ --no-heading\ --vimgrep
	set grepformat=%f:%l:%c:%m

    command! -bang -nargs=* F call fzf#vim#grep(g:rg_command .shellescape(<q-args>), 1, <bang>0)

    " Full text search
    let g:rg_command = '
     \ rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --color "always"
     \ -g "*.{js,json,php,md,styl,jade,html,config,py,cpp,c,go,hs,rb,conf,rs}"
     \ -g "!{.git,node_modules,vendor}/*" '
endif


"""""""""""""""""""""""""""""""""""""""""""""""
" vim-go
"""""""""""""""""""""""""""""""""""""""""""""""
let g:go_fmt_command = "goimports"
let g:go_fmt_autosave = 1


"""""""""""""""""""""""""""""""""""""""""""""""
" vim-airline
"""""""""""""""""""""""""""""""""""""""""""""""
" let g:airline_theme='papercolor'
"let g:airline_theme='angr'
"let g:airline_powerline_fonts = 1
" NOTE: change terminal font to Ubuntu Monospace Derivative Powrline after installing the powerline fonts


"""""""""""""""""""""""""""""""""""""""""""""""
" General Options 
"""""""""""""""""""""""""""""""""""""""""""""""
" Enable linenumbers
set number

" Use spaces instead of tabs
set expandtab

" Be smart when using tabs
set smarttab

" 1 tab == 4 spaces
set tabstop=4
set shiftwidth=4
set softtabstop=4

set noswapfile

nmap <leader>i :set list!<CR>
set listchars=tab:▸\ ,eol:¬

set ai " Auto indent
set si " Smart indent

" Fix backspace
set bs=2

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Make search act like search in modern browsers
set incsearch

" Show command in last line of screen as its being typed
set showcmd

" Turn OmniComplete on
set omnifunc=syntaxcomplete#Complete

" Allow visual block mode to select outside bound of text (i.e. into
" whitespace)
set virtualedit=block

" (neovim) see substitutions real-time
set inccommand=split


"""""""""""""""""""""""
"=> Colors and Fonts
"""""""""""""""""""""""
" Turn on syntax highlighting
syntax on

" Enable 256 color support
set t_Co=256


"NOTE: To convert a colorscheme written for gvim, uncomment bundle
"colorschem.vim, put colorscheme desired below, and re-open vim. The
"colorschem.vim script will convert for color terminals. 
"Run ColorSchemeSave <name> to save it to a different name. Then re-comment
"out the bundle and put the new colorscheme name below. Not having the bundle
"load and convert everytime makes vim load faster

" colorscheme github
" colorscheme github-cterm
" colorscheme PaperColor
" colorscheme molokai
" colorscheme desert

"set background=dark
let g:solarized_termcolors=256
"colorscheme solarized
colorscheme darcula

"""""""""""""""""""""""
"=> Moving around, tabs, windows and buffers 
"""""""""""""""""""""""
" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove

" Toggle error panel with Ctrl-e
"nnoremap <silent> <C-e> :<C-u>call ToggleErrors()<CR>

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif
" Remember info about open buffers on close
set viminfo^=%

" Qargs helper command sets the arglist to contain each of the files
" referenced by the quickfix list. :Qargs
command! -nargs=0 -bar Qargs execute 'args' QuickfixFilenames()
function! QuickfixFilenames()
  " Building a hash ensures we get each buffer only once
  let buffer_numbers = {}
  for quickfix_item in getqflist()
    let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
  endfor
  return join(map(values(buffer_numbers), 'fnameescape(v:val)'))
endfunction

"""""""""""""""""""""""
"=> Status line
"""""""""""""""""""""""
" Always show the status line
set laststatus=2

" Add Git, Syntastic info
" from https://github.com/spf13/spf13-vim/blob/master/.vimrc
" if has('statusline')
"   set laststatus=2
"   " Broken down into easily includeable segments
"   set statusline=%<%f\                     " Filename
"   set statusline+=%w%h%m%r                 " Options
"   set statusline+=%{fugitive#statusline()} " Git Hotness
"   set statusline+=\ [%{&ff}/%Y]            " filetype
"   " set statusline+=\ [%{getcwd()}]          " current dir
"   set statusline+=%#warningmsg#
"   set statusline+=%{SyntasticStatuslineFlag()}
"   set statusline+=%*
"   let g:syntastic_enable_signs=1
"   set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
" endif

" vim-airline settings
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_symbols.space = "\ua0"

let g:airline_powerline_fonts = 1
"let g:airline#extensions#tabline#enabled = 1
" let g:airline_theme = 'dark'
let g:airline_theme = 'solarized'


" Show buffers as tabs
"let g:airline#extensions#tabline#enabled = 1
"
"" Show full path in statusline
"let g:airline_section_c = '%F'
"
"" In X, we can use fancy colors and Unicode symbols
"if &term =~ "xterm" || has ("gui_running")
"
"    " Define dict before settings symbols in it
"    if !exists('g:airline_symbols')
"        let g:airline_symbols = {}
"    endif
"
"    let g:airline_left_sep                        = '▶'
"    let g:airline_right_sep                       = '◀'
"    let g:airline_symbols.linenr                  = '␤ '
"    let g:airline#extensions#tabline#left_sep     = '▶'
"    let g:airline#extensions#tabline#left_alt_sep = '▶'
"    " Show buffers as tabs
"    let g:airline#extensions#tabline#enabled      = 1
"
"" In VT, we can only use simple ASCII and 8 color themes
"else
"
"    let g:airline_theme                           = 'hybrid'
"    let g:airline_left_sep                        = ' '
"    let g:airline_right_sep                       = ' '
"    let g:airline#extensions#tabline#left_sep     = ' '
"    let g:airline#extensions#tabline#left_alt_sep = ' '
"
"endif

"""""""""""""""""""""""
"=> Helper functions 
"""""""""""""""""""""""
" Toggle location list error window for syntastic
" " From stackoverflow/questions/17512794/toggle-error-location-panel-in-syntastic
" function! ToggleErrors()
"    if empty(filter(tabpagebuflist(), 'getbufvar(v:val, "&buftype") is# "quickfix"'))
        " No location/quickfix list shown, open syntastic error location panel
"        Errors
"    else
"        lclose
"    endif
"endfunction 


" function! Formatonsave()
"     :FormatCode
" endfunction
"autocmd BufWritePre *.h,*.cc,*.cpp call Formatonsave()
