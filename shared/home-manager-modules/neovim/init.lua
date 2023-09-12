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
vim.o.spelllang = "en_us,nl"
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.tabstop = 2
vim.o.termguicolors = true
vim.o.wildignorecase = true
vim.o.colorcolumn = "81"
vim.o.clipboard = "unnamedplus"
vim.o.foldenable = false
vim.o.laststatus = 3
vim.g.showbreak = "↪ "
vim.g.mapleader = " "
vim.g.maplocalleader = [[\]]

vim.api.nvim_set_keymap("t", "<C-O>", [[<C-\><C-n><C-O>]], {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>v", "<c-v>", {noremap = true})

vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
    desc = "Assume .pl files contain prolog, not perl",
    pattern = "*.pl",
    callback = function(args)
        vim.api.nvim_buf_set_option(args.buf, "filetype", "prolog")
    end
})
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
    desc = "Enable spell-checking on buffers that contain prose",
    pattern = {"*.md", "COMMIT_EDITMSG", "qutebrowser-editor-*"},
    callback = function() vim.api.nvim_win_set_option(0, "spell", true) end
})
vim.api.nvim_create_autocmd("BufWritePre", {
    desc = "Trim trailing whitespace before saving a file",
    pattern = "*",
    callback = function() vim.api.nvim_command([[%s/\s\+$//e]]) end
})
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Briefly highlight text that was yanked",
    pattern = "*",
    callback = function() vim.highlight.on_yank({timeout = 500}) end
})
vim.api.nvim_create_autocmd("VimSuspend", {
    desc = "Create a session and exit Vim on suspend",
    callback = function()
        vim.api.nvim_command([[mksession!]])
        vim.api.nvim_command([[wqa]])
    end
})

-- COLORSCHEME
vim.o.background = "dark"
vim.cmd("colorscheme nord")
vim.g.lightline = {colorscheme = "nord"}

-- ALE
vim.g.ale_use_global_executables = true
vim.g.ale_linters_explicit = true
vim.g.ale_linters = {
    haskell = {"hlint"},
    elm = {"elm-make"},
    gitcommit = {"vale"},
    go = {"gobuild"},
    nim = {"nimcheck"},
    python = {"flake8"},
    rust = {"cargo"},
    lua = {"luacheck"},
    mail = {"vale"},
    markdown = {"vale"},
    bash = {"shellcheck"},
    sh = {"shellcheck"}
}
vim.g.ale_fixers = {
    ['*'] = {"remove_trailing_lines", "trim_whitespace"},
    ["elm"] = {"elm-format"},
    ["go"] = {"gofmt"},
    ["haskell"] = {"ormolu"},
    ["lua"] = {"lua-format"},
    ["nim"] = {"nimpretty"},
    ["nix"] = {"nixfmt"},
    ["python"] = {"black"},
    ["ruby"] = {"rubocop"},
    ["rust"] = {"rustfmt"},
    ["typescript"] = {"prettier"},
    ["vue"] = {"prettier"}
}

vim.g.ale_fix_on_save = true
vim.g.ale_sign_error = "✗"
vim.g.ale_sign_warning = "!"
vim.g.ale_virtualtext_cursor = "disabled"
vim.g.ale_rust_cargo_use_clippy = vim.fn.executable("cargo-clippy") > 0
vim.g.ale_rust_cargo_check_tests = true
vim.g.ale_rust_ignore_secondary_spans = true

vim.api.nvim_set_keymap("n", "<localleader>e", "<Plug>(ale_detail)",
                        {noremap = true})

-- TREESITTER
require'nvim-treesitter.configs'.setup {
    highlight = {enable = true, additional_vim_regex_highlighting = false}
}

-- FZF
vim.api.nvim_create_user_command("Rg", function(args)
    vim.fn["fzf#run"]({
        source = "rg --column --line-number --no-heading --color=always " ..
            vim.fn.shellescape(args.args),
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
end, {
    desc = "Search for pattern in current working directory",
    nargs = "*",
    bang = true
})

vim.api.nvim_set_keymap("n", "<C-P>", "", {
    desc = "Search for files in current directory",
    noremap = true,
    callback = function()
        vim.fn["fzf#run"]({
            source = vim.env.FZF_DEFAULT_COMMAND .. " | grep -v '^" ..
                vim.fn.expand('%') .. "$' | similar-sort " .. vim.fn.expand('%'),
            sink = "edit",
            window = "enew",
            options = {"--tiebreak=index", "--no-height"}
        })
    end
})

vim.api.nvim_set_keymap("n", "<C-B>", "", {
    desc = "Search for open buffers",
    noremap = true,
    callback = function()
        local buffers = {}
        local current_buffer = vim.fn.bufnr()
        for _, buf in pairs(vim.api.nvim_list_bufs()) do
            local info = vim.fn.getbufinfo(buf)[1]
            if info.listed == 1 and buf ~= current_buffer then
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
                if buf then
                    vim.api.nvim_win_set_buf(0, tonumber(buf))
                else
                    error("Unexpected line: " .. line)
                end
            end
        })
    end
})

vim.api.nvim_set_keymap("n", "<C-L>", "", {
    desc = "Search for lines in current buffer",
    noremap = true,
    callback = function()
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
})

-- DIRVISH
vim.api.nvim_create_autocmd("FileType", {
    desc = "Undo Dirvis' default binding of <C-P>",
    pattern = "dirvish",
    callback = function()
        -- Using nvim_buf_del_keymap fails saying no <C-P> mapping is defined.
        vim.cmd([[silent! unmap <buffer> <C-P>]])
    end
})

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
require('gitsigns').setup({
    current_line_blame = true,

    on_attach = function(bufnr)
        -- Adapted from the gitsings README example:
        -- https://github.com/lewis6991/gitsigns.nvim
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
        end, {expr = true})

        map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
        end, {expr = true})

        -- Actions
        map({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>')
        map({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>')
    end
})
