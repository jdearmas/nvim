-- ~/.config/nvim/lua/config/autocmds.lua
-- Autocommands

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local fn = require('config.functions')

local user_augroup = augroup('UserAuCmds', { clear = true })

-- Delete swap files automatically
autocmd("SwapExists", {
  group = user_augroup,
  pattern = "*",
  callback = function()
    vim.v.swapchoice = "d"
  end,
})

-- Terminal-specific keymaps
autocmd('TermOpen', {
  group = user_augroup,
  pattern = '*',
  callback = function()
    local opts = { buffer = 0, noremap = true, silent = true }
    vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
    vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
    vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
    vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
    vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
    vim.cmd('set noinsertmode')
    vim.cmd('stopinsert')
  end,
  desc = 'Set terminal-specific keymaps',
})

-- Resize splits equally on Vim resize
autocmd('VimResized', {
  group = user_augroup,
  pattern = '*',
  command = 'wincmd =',
  desc = 'Resize splits equally on Vim resize',
})

-- Ensure directory exists before writing buffer (handles both new and existing files)
autocmd('BufWritePre', {
  group = user_augroup,
  pattern = '*',
  callback = function(ev)
    fn.ensure_directory(ev.match)
  end,
  desc = 'Ensure directory exists before writing buffer',
})

-- Consolidated FileType autocommands for better performance
autocmd('FileType', {
  group = user_augroup,
  pattern = { 'python', 'qf', 'go', 'rust' },
  callback = function(ev)
    local ft = ev.match

    if ft == 'python' then
      -- Configure Neoformat for Python with virtualenv
      local venv = os.getenv('VIRTUAL_ENV')
      if venv then
        local venv_ruff = venv .. '/bin/ruff'
        if vim.fn.executable(venv_ruff) == 1 then
          vim.g.neoformat_python_ruff.exe = venv_ruff
        end
      end

    elseif ft == 'qf' then
      -- Quickfix window height
      local height = math.floor(vim.o.lines / 2)
      vim.cmd(height .. "wincmd _")

    elseif ft == 'go' then
      -- Go-specific settings
      vim.bo.makeprg = 'go run .'
      vim.bo.errorformat = '%f:%l:%c:%m,%f:%l:%m'
      vim.keymap.set('n', '<leader>ie', function()
        local lnum = vim.api.nvim_win_get_cursor(0)[1]
        local indent_level = vim.fn.indent(lnum)
        local indent_str = string.rep(' ', indent_level)
        local lines_to_insert = {
          indent_str .. 'if err != nil {',
          indent_str .. '\treturn ',
          indent_str .. '}',
        }
        vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, lines_to_insert)
        vim.api.nvim_win_set_cursor(0, { lnum + 1, #lines_to_insert[2] + 1 })
        vim.cmd('startinsert')
      end, { buffer = true, silent = true, desc = 'Insert Go error block' })

    elseif ft == 'rust' then
      -- Rust makeprg
      vim.bo.makeprg = 'cargo run'
    end
  end,
  desc = 'Filetype-specific settings (python, qf, go, rust)',
})

-- Org file auto-indent on save
autocmd("BufWritePre", {
  group = user_augroup,
  pattern = "*.org",
  callback = function()
    local pos = vim.fn.getpos(".")
    vim.cmd("normal! gg=G")
    vim.fn.setpos(".", pos)
  end,
})

