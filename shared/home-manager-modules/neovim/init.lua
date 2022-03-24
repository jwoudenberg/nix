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
local open_bin = vim.fn.executable("xdg-open") > 0 and "xdg-open" or "open"
local open_cmd = [[:silent execute "!]] .. open_bin ..
                     [[ " . shellescape("<cWORD>")<CR>]]
vim.api.nvim_set_keymap("n", "gx", open_cmd, {silent = true})

vim.cmd([[
  augroup custom_commands
    autocmd BufNewFile,BufRead *.pl :set ft=prolog
    autocmd BufWritePre * :%s/\s\+$//e
    au TextYankPost * silent! lua vim.highlight.on_yank({ timeout = 500 })
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
vim.g.ale_rust_cargo_use_clippy = vim.fn.executable("cargo-clippy") > 0
vim.g.ale_rust_cargo_check_tests = true
vim.g.ale_rust_ignore_secondary_spans = true

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
vim.g.neoformat_enabled_markdown = {}

-- FZF
vim.cmd([[
  augroup fzf_commands
    " don't show fzf statusline
    autocmd  FileType fzf set laststatus=0 noshowmode noruler
      \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
  augroup END
]])

-- FZF :Rg
function _G.fzf_rg(needle)
    vim.fn["fzf#run"]({
        source = "rg --column --line-number --no-heading --color=always " ..
            vim.fn.shellescape(needle),
        window = "enew",
        options = {
            "--no-height", "--ansi", "--multi", "--delimiter=:",
            "--bind=ctrl-a:select-all,ctrl-d:deselect-all", "--with-nth=1,4.."
        },
        sinklist = function(lines)
            local qflist = {}
            for _, line in pairs(lines) do
                local filename, lnum, col, text = string.match(line,
                                                               "^([^:]*):([^:]*):([^:]*):(.*)$")
                table.insert(qflist, {
                    filename = filename,
                    lnum = tonumber(lnum),
                    col = tonumber(col),
                    text = text
                })
            end

            if #qflist >= 1 then
                local first = qflist[1]
                vim.cmd("edit " .. first.filename);
                vim.api.nvim_win_set_cursor(0, {first.lnum, first.col - 1})
            end

            if #qflist > 1 then
                vim.fn.setqflist(qflist)
                vim.cmd("copen")
            end
        end
    })
end

vim.cmd([[command! -bang -nargs=* Rg call v:lua.fzf_rg(<q-args>)]])

-- FZF :Files
function _G.fzf_files()
    vim.fn["fzf#run"]({
        source = vim.env.FZF_DEFAULT_COMMAND .. " | grep -v '^" ..
            vim.fn.expand('%') .. "$' | similar-sort " .. vim.fn.expand('%'),
        sink = "edit",
        window = "enew",
        options = {"--tiebreak=index", "--no-height"}
    })
end

vim.cmd([[command! -bang -nargs=? Files call v:lua.fzf_files()]])
vim.api.nvim_set_keymap("n", "<C-P>", ":Files<CR>", {noremap = true})

-- FZF :Buffers
function _G.fzf_buffers()
    local buffers = {}
    local current_buffer = vim.fn.bufnr()
    for _, buf in pairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and buf ~= current_buffer then
            local info = vim.fn.getbufinfo(buf)[1]
            local name = info.name == "" and "[no name]" or
                             vim.fn.fnamemodify(info.name, ":.")
            local lastused = info.lastused or 0
            table.insert(buffers, lastused .. "\t" .. buf .. "\t" .. name)
        end
    end

    -- Sort last-opened first
    table.sort(buffers, function(x, y) return x > y end)

    vim.fn["fzf#run"]({
        source = buffers,
        window = "enew",
        options = {
            "--tiebreak=index", "--delimiter=\t", "--with-nth=3..",
            "--no-height"
        },
        sink = function(line)
            local buf = string.match(line, "^%d*\t(%d+)\t")
            if buf then vim.api.nvim_win_set_buf(0, buf) end
        end
    })
end

vim.cmd([[command! -bang -nargs=? Buffers call v:lua.fzf_buffers()]])
vim.api.nvim_set_keymap("n", "<C-B>", ":Buffers<CR>", {noremap = true})

-- FZF :Lines
function _G.fzf_lines()
    local lines = {}
    for index, line in pairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
        table.insert(lines, index .. "\t" .. line)
    end

    local bufnr = vim.fn.bufnr()

    vim.fn["fzf#run"]({
        source = lines,
        window = "enew",
        options = {
            "--no-height", "--multi", "--delimiter=\t",
            "--bind=ctrl-a:select-all,ctrl-d:deselect-all", "--with-nth=2.."
        },
        sinklist = function(selected_lines)
            local loclist = {}
            for _, line in pairs(selected_lines) do
                local line_parts = vim.fn.split(line, "\t");
                table.insert(loclist, {
                    bufnr = bufnr,
                    lnum = tonumber(line_parts[1]),
                    col = 1,
                    text = line_parts[2]
                })
            end

            if #loclist >= 1 then
                local first = loclist[1]
                vim.api.nvim_win_set_cursor(0, {first.lnum, 1})
            end

            if #loclist > 1 then
                vim.fn.setloclist(0, loclist)
                vim.cmd("lopen")
            end
        end
    })
end

vim.cmd([[command! -bang -nargs=? Lines call v:lua.fzf_lines()]])
vim.api.nvim_set_keymap("n", "<C-L>", ":Lines<CR>", {noremap = true})

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

-- GIT
require('gitsigns').setup({current_line_blame = true})
require('plenary') -- Needs to be loaded before neogit: https://github.com/TimUntersberger/neogit/issues/206
require('neogit').setup({})

-- SUBSTITUTIONS
vim.api.nvim_set_keymap("n", "s", [[<plug>(SubversiveSubstitute)]], {})
vim.api.nvim_set_keymap("n", "ss", [[<plug>(SubversiveSubstituteLine)]], {})
vim.api.nvim_set_keymap("n", "S", [[<plug>(SubversiveSubstituteToEndOfLine)]],
                        {})
-- PAREN PAIRS
vim.api.nvim_set_keymap("i", "<C-s>(", "()<Left>", {})
vim.api.nvim_set_keymap("i", "<C-s>)", "()<Left>", {})
vim.api.nvim_set_keymap("i", "<C-s>[", "[]<Left>", {})
vim.api.nvim_set_keymap("i", "<C-s>]", "[]<Left>", {})
vim.api.nvim_set_keymap("i", "<C-s>{", "{}<Left>", {})
vim.api.nvim_set_keymap("i", "<C-s>}", "{}<Left>", {})
vim.api.nvim_set_keymap("i", "<C-s><", "<><Left>", {})
vim.api.nvim_set_keymap("i", "<C-s>>", "<><Left>", {})
vim.api.nvim_set_keymap("i", "<C-s>(", "()<Left>", {})
vim.api.nvim_set_keymap("i", "<C-s>)", "()<Left>", {})
vim.api.nvim_set_keymap("i", "<C-s>|", "||<Left>", {})
