-- ~/.config/nvim/init.lua
-- Minimal bootstrap file that loads modular configuration

-- Load core settings first (includes leader key setup)
require('config.options')

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require('lazy').setup(require('plugins'))

-- Load the rest of the configuration
require('config.autocmds')
require('config.keymaps')

-- Initialize gitlab.nvim (needs to be after lazy setup)
pcall(function() require("gitlab").setup() end)

print('speed is life')
