-- luacheck: globals vim
-- VIM SETTINGS
vim.o.completeopt = "menu,noselect"
vim.o.expandtab = true
vim.o.hidden = true
vim.o.lbr = true;
vim.o.mouse = "a"
vim.o.modeline = false
vim.o.swapfile = false
vim.o.number = true
vim.o.path = "**"
vim.o.shiftround = true
vim.o.shiftwidth = 2
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.tabstop = 2
vim.o.termguicolors = true
vim.o.wildignorecase = true
vim.o.colorcolumn = "81"
vim.o.clipboard = "unnamedplus"
vim.o.foldenable = false

vim.g.showbreak = "↪ "
vim.g.mapleader = " "
vim.g.maplocalleader = [[\]]

vim.api.nvim_set_keymap("t", "<C-O>", [[<C-\><C-n><C-O>]], {noremap = true})
vim.api.nvim_set_keymap("n", "gx",
                        [[:silent execute "!open " . shellescape("<cWORD>")<CR>]],
                        {})

vim.cmd([[
  augroup custom_commands
    autocmd BufNewFile,BufRead *.pl :set ft=prolog
    autocmd BufWritePre * :%s/\s\+$//e
  augroup END
]])

-- COLORSCHEME
vim.o.background = "dark"
vim.cmd("colorscheme nord")
vim.g.lightline = {colorscheme = "nord"}

-- ALE
vim.g.ale_use_global_executables = true
vim.g.ale_linters_explicit = true
vim.g.ale_linters = {
    haskell = {"hlint"},
    elm = {"make"},
    nim = {"nimcheck"},
    rust = {"cargo"},
    lua = {"luacheck"}
}

vim.g.ale_sign_error = "✗"
vim.g.ale_sign_warning = "!"
vim.g.ale_rust_cargo_use_clippy = vim.fn.executable("cargo-clippy")
vim.g.ale_rust_cargo_check_tests = true

vim.cmd([[
  augroup ale_commands
    autocmd!
    nmap <silent> <localleader>e <Plug>(ale_detail)
    autocmd BufWritePre * Neoformat
  augroup END
]])

-- POLYGLOT
vim.g.polyglot_disabled = {"haskell", "markdown"}

-- NEOFORMAT
vim.g.neoformat_basic_format_retab = true
vim.g.neoformat_enabled_nix = {"nixfmt"}
vim.g.neoformat_enabled_rust = {"rustfmt"}
vim.g.neoformat_enabled_lua = {"luaformat"}
vim.g.neoformat_enabled_haskell = {"ormolu"}
vim.g.neoformat_enabled_ruby = {}
vim.g.neoformat_enabled_sql = {}
vim.g.neoformat_enabled_yaml = {}
vim.g.neoformat_enabled_json = {}
vim.g.neoformat_enabled_html = {}

-- FZF
vim.g.fzf_layout = {window = "enew"}
vim.cmd([[let $FZF_DEFAULT_OPTS .= ' --no-height']]) -- fixes fzf in nvim terminals
vim.cmd([[
  augroup fzf_commands
    " don't show fzf statusline
    autocmd  FileType fzf set laststatus=0 noshowmode noruler
      \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
  augroup END
]])

-- SEARCHING FILES
vim.api.nvim_set_keymap("n", "<C-P>", ":Files<CR>", {noremap = true})
vim.api.nvim_set_keymap("n", "<C-B>", ":Buffers<CR>", {noremap = true})
vim.cmd([[
  command! -bang -nargs=? -complete=dir Files
    \ call fzf#run(fzf#wrap({"source": $FZF_DEFAULT_COMMAND . " \| similar-sort " . (@% == '' ? 'a' : @%),
                          \ "sink": "edit",
                          \ "options": "--tiebreak index"
                          \ }))
]])

-- DIRVISH
vim.cmd([[
  augroup dirvish_commands
    autocmd!

    " Undo Dirvish' default binding of <C-P>
    autocmd FileType dirvish silent! unmap <buffer> <C-P>
  augroup END
]])

-- FILE SEARCH

-- <leader>g takes a motion, then searches for the text covered by the motion.
vim.api.nvim_set_keymap("n", "<leader>g", [[:set opfunc=SearchMotion<CR>g@]],
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap("v", "<leader>g",
                        [[:<C-U>call SearchMotion(visualmode(), 1)<CR>]],
                        {noremap = true, silent = true})

vim.cmd([[
  function! SearchMotion(type, ...)
    let sel_save = &selection
    let &selection = "inclusive"
    let reg_save = @@

    if a:0  " Invoked from Visual mode, use '< and '> marks.
      silent exe "normal! `<" . a:type . "`>y"
    elseif a:type == 'line'
      silent exe "normal! '[V']y"
    elseif a:type == 'block'
      silent exe "normal! `[\<C-V>`]y"
    else
      silent exe "normal! `[v`]y"
    endif

    let @/ = @@
    exe "normal /\<cr>"

    let &selection = sel_save
    let @@ = reg_save
  endfunction
]])

-- CROSS-PROJECT GREP
vim.cmd([[
  command! -bang -nargs=* Rg
    \ call fzf#vim#grep(
    \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>).'| tr -d "\017"', 1,
    \   { 'options': '--bind ctrl-a:select-all,ctrl-d:deselect-all' },
    \   <bang>0)
]])

-- <leader>G takes a motion, then searches for the text covered by the motion using :Rg.
vim.api.nvim_set_keymap("n", "<leader>G",
                        [[:set opfunc=ProjectGrepMotion<CR>g@]],
                        {noremap = true, silent = true})
vim.api.nvim_set_keymap("v", "<leader>G",
                        [[:<C-U>call ProjectGrepMotion(visualmode(), 1)<CR>]],
                        {noremap = true, silent = true})

vim.cmd([[
  function! ProjectGrepMotion(type, ...)
    let sel_save = &selection
    let &selection = "inclusive"
    let reg_save = @@

    if a:0  " Invoked from Visual mode, use '< and '> marks.
      silent exe "normal! `<" . a:type . "`>y"
    elseif a:type == 'line'
      silent exe "normal! '[V']y"
    elseif a:type == 'block'
      silent exe "normal! `[\<C-V>`]y"
    else
      silent exe "normal! `[v`]y"
    endif

    exe 'Rg '.@@

    let &selection = sel_save
    let @@ = reg_save
  endfunction
]])

-- COMPLETION
local cmp = require('cmp')
cmp.setup({
    sources = {{name = 'cmp_tabnine'}},
    mapping = {
        ['<C-f>'] = cmp.mapping.confirm({
            select = true,
            behavior = cmp.SelectBehavior.Insert
        })
    },
    experimental = {ghost_text = true},
    snippet = {
        expand = function(args) require('luasnip').lsp_expand(args.body) end
    }
})

require('cmp_tabnine.config'):setup({max_num_results = 1})

-- GITSIGNS

require('gitsigns').setup({current_line_blame = false})
