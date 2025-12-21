-- ~/.config/nvim/lua/plugins/ui.lua
-- UI enhancements and visual plugins

return {
  -- Core dependencies
  { 'nvim-lua/plenary.nvim', lazy = true },
  { 'nvim-tree/nvim-web-devicons', lazy = true },

  -- Indent guides
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    event = 'BufReadPost',
    config = function()
      require('ibl').setup()
    end
  },

  -- Which-key
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      require('which-key').setup()
    end
  },

  -- Aerial (code outline)
  {
    'stevearc/aerial.nvim',
    commit = '8c63f41c13d250faeb3c848b61b06adedac737e5',
    event = 'BufReadPost',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('aerial').setup {
        backends = { 'treesitter', 'lsp', 'markdown', 'asciidoc', 'man' },
        layout = { max_width = { 0.9 }, min_width = 0.6, default_direction = 'float' },
        filter_kind = { 'Class', 'Constructor', 'Enum', 'Function', 'Interface', 'Module', 'Method', 'Struct' },
        lazy_load = true,
      }
    end
  },

  -- No-neck-pain (centering)
  {
    'shortcuts/no-neck-pain.nvim',
    version = '*',
    config = function()
      require("no-neck-pain").setup({
        buffers = {
          scratchPad = {
            enabled = false,
            location = "~/Documents/",
          },
          bo = {
            filetype = "md",
          },
        },
      })
    end
  },

  -- Focus modes
  { 'folke/twilight.nvim', cmd = 'Twilight', config = true },
  { 'pocco81/true-zen.nvim', cmd = { 'TZFocus', 'TZMinimalist', 'TZAtaraxis', 'TZNarrow' }, config = true },

  -- Taboo (tab renaming)
  { 'jdearmas/taboo', event = 'BufWinEnter', config = true },

  -- Window picker
  { 'yorickpeterse/nvim-window', keys = { { 'n', '<leader>w' } }, config = true },

  -- Snacks (picker & input)
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      picker = { enabled = true },
      input = { enabled = true },
    },
  },

  -- Command line
  {
    'VonHeikemen/fine-cmdline.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    config = function()
      require('fine-cmdline').setup {
        cmdline = { enable_keymaps = true, smart_history = true, prompt = ': ' },
        popup = {
          position = { row = '50%', col = '50%' },
          size = { width = '60%' },
          border = { style = 'rounded' },
          win_options = { winhighlight = 'Normal:Normal,FloatBorder:FloatBorder' }
        },
      }
    end
  },

  -- Quickfix enhancement
  { 'kevinhwang91/nvim-bqf' },
}

