-- ~/.config/nvim/lua/config/options.lua
-- Core Neovim settings and options

local opt = vim.opt
local g = vim.g

-- Leader keys (must be set before lazy.nvim)
g.mapleader = ' '
g.maplocalleader = ' '

-- General
opt.hidden = true
opt.showmode = false
opt.clipboard = 'unnamedplus'
opt.updatetime = 250
opt.timeoutlen = 300
opt.swapfile = false

-- UI
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.signcolumn = 'yes'
opt.laststatus = 2
opt.statusline = "%{mode()} %f %y %m %r%="
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
opt.fillchars = { eob = ' ' }
opt.scrollback = 100000

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Wrapping
opt.wrap = true
opt.linebreak = true
opt.breakindent = true
opt.breakindentopt = 'shift:2'
opt.showbreak = '↳ '

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.softtabstop = 2
opt.autoindent = true
opt.smartindent = true

-- Folding
opt.foldmethod = 'indent'
opt.foldlevelstart = 99
opt.foldenable = true

-- Diff
opt.diffopt:append("vertical")

-- Directory
opt.autochdir = true

-- Background and highlights
vim.cmd [[set background=dark]]

local hl = vim.api.nvim_set_hl
hl(0, 'Normal', { bg = '#000000', fg = '#00FF00' })
hl(0, 'NormalFloat', { link = 'Normal' })
hl(0, 'Folded', { bg = 'none' })
hl(0, 'SignColumn', { link = 'Normal' })
hl(0, 'DiffDelete', { fg = '#FF0000', bg = 'NONE' })
hl(0, 'DiffAdd', { fg = '#00ff00', bg = 'NONE' })
hl(0, 'DiffContext', { fg = 'gray', bg = 'NONE' })
hl(0, 'NeogitDiffDelete', { link = 'DiffDelete' })
hl(0, 'NeogitDiffAdd', { link = 'DiffAdd' })
hl(0, 'NeogitDiffContext', { link = 'DiffContext' })
hl(0, 'NeogitDiffDeleteHighlight', { link = 'DiffDelete' })
hl(0, 'NeogitDiffAddHighlight', { link = 'DiffAdd' })
hl(0, 'NeogitDiffContextHighlight', { link = 'DiffContext' })

-- Dispatch options
g.dispatch_no_tmux_make = 1
g.dispatch_no_job_make = 1

-- Neoformat Python configuration
g.neoformat_python_ruff = {
  exe = 'ruff',
  args = { 'format', '-' },
  stdin = 1,
}
g.neoformat_enabled_python = { 'ruff' }

-- Filetype additions
vim.filetype.add({
  extension = {
    http = "http",
  },
})

