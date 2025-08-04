-- ~/.config/nvim/init.lua
--
-- Set <space> as the leader key
-- Must be set before lazy.nvim setup
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable', -- latest stable release
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath) -- Add lazy.nvim to the runtime path

-- [[ Basic Neovim settings ]]
vim.o.hidden = true
vim.o.laststatus = 2  -- 2 = always show, 3 = global statusline
vim.opt.termguicolors = true -- Enable true color support
vim.opt.number = true -- Show absolute line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.clipboard = 'unnamedplus' -- Use system clipboard
vim.opt.wrap = true -- Enable line wrapping
vim.opt.linebreak = true -- Wrap lines at convenient points
vim.opt.breakindent = true -- Maintain indentation for wrapped lines
vim.opt.breakindentopt = 'shift:2' -- Indentation amount for wrapped lines
vim.opt.showbreak = '↳ ' -- Character to show before wrapped lines
vim.opt.ignorecase = true -- Ignore case in search patterns
vim.opt.smartcase = true -- Override ignorecase if pattern contains uppercase letters
vim.opt.tabstop = 2 -- Number of spaces that a <Tab> in the file counts for
vim.opt.shiftwidth = 2 -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.softtabstop = 2 -- Number of spaces that a <Tab> counts for while performing editing operations
vim.opt.autoindent = true -- Copy indent from current line when starting a new line
vim.opt.autochdir = true -- Automatically change directory to the file's directory (Consider potential side effects)
vim.opt.foldmethod = 'indent' -- Fold based on indentation
vim.opt.foldlevelstart = 99 -- Start with most folds open
vim.opt.foldenable = true -- Enable folding
vim.o.splitright = true -- Vertical splits open to the right
vim.o.splitbelow = true -- Horizontal splits open below
vim.opt.signcolumn = 'yes' -- Always show the signcolumn
vim.opt.updatetime = 250 -- Faster completion diagnostics update time
vim.opt.timeoutlen = 300 -- Lower timeout for key sequences
vim.opt.list = true -- Show invisible characters
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.fillchars = { eob = ' ' } -- Don't show '~' on empty lines
vim.opt.showmode = false -- Don't show mode in command line (status line usually does)
vim.opt.scrollback = 100000 -- Increase terminal scrollback buffer size
vim.opt.diffopt:append("vertical")
vim.opt.smartindent = true

-- Set background color (important for some themes/highlighting)
vim.cmd [[set background=dark]]
-- Custom highlight groups (set early for consistency)
vim.api.nvim_set_hl(0, 'Normal', { bg = '#000000', fg = '#00FF00' }) -- Example basic theme
vim.api.nvim_set_hl(0, 'NormalFloat', { link = 'Normal' })
vim.api.nvim_set_hl(0, 'Folded', { bg = 'none' })
vim.api.nvim_set_hl(0, 'SignColumn', { link = 'Normal' }) -- Avoid distracting sign column background


-- fix
-- vim.api.nvim_set_hl(0, 'CustomVertSplit', { guibg = 'green' }) -- Example custom highlight
--
--
vim.api.nvim_set_hl(0, 'DiffDelete', { fg = '#FF0000', bg = 'NONE' })
vim.api.nvim_set_hl(0, 'DiffAdd', { fg = '#00ff00', bg = 'NONE' })
vim.api.nvim_set_hl(0, 'DiffContext', { fg = 'gray', bg = 'NONE' })
vim.api.nvim_set_hl(0, 'NeogitDiffDelete', { link = 'DiffDelete' })
vim.api.nvim_set_hl(0, 'NeogitDiffAdd', { link = 'DiffAdd' })
vim.api.nvim_set_hl(0, 'NeogitDiffContext', { link = 'DiffContext' })
vim.api.nvim_set_hl(0, 'NeogitDiffDeleteHighlight', { link = 'DiffDelete' })
vim.api.nvim_set_hl(0, 'NeogitDiffAddHighlight', { link = 'DiffAdd' })
vim.api.nvim_set_hl(0, 'NeogitDiffContextHighlight', { link = 'DiffContext' })

-- Dispatch options (set before potential usage)
vim.g.dispatch_no_tmux_make = 1
vim.g.dispatch_no_job_make = 1

-- Define LSP attach function *before* lazy setup if used within plugin configs
local lsp_attach_callback = function(client, bufnr)
  local map = function(mode, lhs, rhs, opts)
    opts = vim.tbl_extend('force', { buffer = bufnr, noremap = true, silent = true }, opts or {})
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  print('LSP attached to buffer ' .. bufnr .. ': ' .. client.name)

  -- Standard LSP keymaps
  map('n', 'gd', vim.lsp.buf.definition, { desc = 'LSP Go to Definition' })
  map('n', 'gD', vim.lsp.buf.declaration, { desc = 'LSP Go to Declaration' })
  map('n', 'gr', vim.lsp.buf.references, { desc = 'LSP Go to References' })
  map('n', 'gi', vim.lsp.buf.implementation, { desc = 'LSP Go to Implementation' })
  map('n', 'H', vim.lsp.buf.hover, { desc = 'LSP Hover' }) -- Standard hover key
  map('n', '<C-k>', vim.lsp.buf.signature_help, { desc = 'LSP Signature Help' }) -- Standard signature help key
  map('i', '<C-k>', vim.lsp.buf.signature_help, { desc = 'LSP Signature Help' })
  map('n', '<F2>', vim.lsp.buf.rename, { desc = 'LSP Rename' })
  map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { desc = 'LSP Code Action' })
  map('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, { desc = 'LSP Format Buffer' })

  -- Workspace management
  map('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, { desc = 'LSP Add Workspace Folder' })
  map('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, { desc = 'LSP Remove Workspace Folder' })
  map('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, { desc = 'LSP List Workspace Folders' })

  -- Optional: Enable completion triggered by <c-x><c-o>
  -- vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

  -- Conditionally load plugins that depend on LSP
  -- Example: Trigger treesitter context loading if not already loaded
  -- require('lazy').load { plugins = { "nvim-treesitter-context" } }
end

-- [[ Set up plugins with lazy.nvim ]]
require('lazy').setup({
  -- Core dependencies (often loaded early or implicitly by others)
  { 'nvim-lua/plenary.nvim', lazy = true }, -- Most plugins load it on demand
  { 'nvim-tree/nvim-web-devicons', lazy = true }, -- Load when icons are needed

  -- LLM Stuff
  {
  "yetone/avante.nvim",
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  -- ⚠️ must add this setting! ! !
  build = vim.fn.has("win32") ~= 0
      and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    -- add any opts here
    -- for example
    provider = "claude",
    providers = {
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-sonnet-4-20250514",
        timeout = 30000, -- Timeout in milliseconds
          extra_request_body = {
            temperature = 0.75,
            max_tokens = 20480,
          },
      },
      moonshot = {
        endpoint = "https://api.moonshot.ai/v1",
        model = "kimi-k2-0711-preview",
        timeout = 30000, -- Timeout in milliseconds
        extra_request_body = {
          temperature = 0.75,
          max_tokens = 32768,
        },
      },
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "echasnovski/mini.pick", -- for file_selector provider mini.pick
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "ibhagwan/fzf-lua", -- for file_selector provider fzf
    "stevearc/dressing.nvim", -- for input provider dressing
    "folke/snacks.nvim", -- for input provider snacks
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
},

  -- LSP & Completion Engine
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v4.x',
    dependencies = {
      -- LSP Support
      { 'neovim/nvim-lspconfig' }, -- Required
      { 'williamboman/mason.nvim' }, -- Optional: Automatically install LSPs
      { 'williamboman/mason-lspconfig.nvim' }, -- Optional: Bridge mason and lspconfig

      -- Autocompletion
      { 'hrsh7th/nvim-cmp' }, -- Required
      { 'hrsh7th/cmp-nvim-lsp' }, -- Required
      { 'hrsh7th/cmp-buffer' }, -- Optional: Source for buffer words
      { 'hrsh7th/cmp-path' }, -- Optional: Source for filesystem paths
      { 'L3MON4D3/LuaSnip' }, -- Required for snippet support in cmp
      -- { 'saadparwaiz1/cmp_luasnip' }, -- Connects LuaSnip to cmp
    },
    config = function()
      local lsp_zero = require('lsp-zero')
      lsp_zero.extend_lspconfig()

      lsp_zero.on_attach(lsp_attach_callback) -- Use the callback defined above

      -- Configure LSP servers using mason-lspconfig
      require('mason').setup {}
      require('mason-lspconfig').setup {
        ensure_installed = {
          'clangd',
          'lua_ls', -- Formerly sumneko_lua
          'pylsp',
          'terraformls',
          'bashls',
          'jsonls',
          'yamlls',
          'dockerls',
          'eslint',
          'html',
          'cssls',
          'rust_analyzer',
          'gopls',
          'marksman', -- Markdown LSP
          -- Add other LSPs you use
        },
        handlers = {
          lsp_zero.default_setup, -- Use lsp-zero's default handler
          lua_ls = function() -- Example custom setup for lua_ls
            local lua_opts = lsp_zero.nvim_lua_ls()
            require('lspconfig').lua_ls.setup(lua_opts)
          end,
        },
      }

      -- Setup nvim-cmp
      local cmp = require('cmp')
      local cmp_action = lsp_zero.cmp_action() -- Use lsp-zero's enhanced actions

      cmp.setup {
        -- sources = cmp.config.sources({ -- Simplified source setup
        --   { name = 'nvim_lsp' },
        --   { name = 'luasnip' },
        --   { name = 'buffer' },
        --   { name = 'path' },
        -- }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip', keyword_length = 2 }, -- Only trigger snippets if typing 2+ chars
          { name = 'buffer', keyword_length = 3 }, -- Only trigger buffer completion if typing 3+ chars
          { name = 'path' },
        },
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<CR>'] = cmp.mapping.confirm { select = false },
          ['<C-Space>'] = cmp.mapping.complete(), -- Manually trigger completion
          ['<C-f>'] = cmp_action.luasnip_jump_forward(),
          ['<C-b>'] = cmp_action.luasnip_jump_backward(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif require('luasnip').expand_or_jumpable() then
              vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), '')
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif require('luasnip').jumpable(-1) then
              vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-prev', true, true, true), '')
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        -- Experiment with completion triggers
        completion = {
          -- completeopt = 'menu,menuone,noinsert,noselect', -- Standard completion options
          -- Trigger completion on typing, but maybe slightly delayed
          -- autocomplete = { require('cmp.types').cmp.TriggerEvent.InsertEnter, require('cmp.types').cmp.TriggerEvent.TextChanged }
        },
        -- Window appearance (optional)
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = lsp_zero.cmp_format(), -- Use lsp-zero's formatting
      }

      -- LSP Signatures (optional, alternative to built-in)
      lsp_zero.format_on_save {
        format_opts = {
          async = false,
          timeout_ms = 10000,
        },
        servers = nil, -- Format for all configured servers
      }
    end,
    event = { 'BufReadPre', 'BufNewFile' }, -- Load LSP stuff early but not immediately on startup
  },

  -- Snippets Engine
  {
    'L3MON4D3/LuaSnip',
    version = 'v2.*',
    -- build = "make install_jsregexp", -- Optional build step
    dependencies = { 'rafamadriz/friendly-snippets' }, -- Optional: useful snippets
    event = 'InsertEnter', -- Load when entering insert mode
    config = function()
      -- Optional: Load snippets from friendly-snippets
      -- require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPre', 'BufNewFile' }, -- Load treesitter early for highlighting/parsing
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects', -- Optional: for text objects
    },
    config = function()
      require('nvim-treesitter.configs').setup {
        -- Ensure parsers are installed
        ensure_installed = {
          'bash',
          'c',
          'cpp',
          'css',
          'diff',
          'git_config',
          'git_rebase',
          'gitattributes',
          'gitcommit',
          'gitignore',
          'go',
          'gomod',
          'gosum',
          'html',
          'http',
          'javascript',
          'json',
          'lua',
          'make',
          'markdown',
          'markdown_inline',
          -- 'norg', -- If you use norg
          'python',
          'query',
          'regex',
          'rust',
          'sql',
          'toml',
          'typescript',
          'vim',
          'vimdoc',
          'xml',
          'yaml',
        },
        sync_install = false, -- Install parsers asynchronously
        auto_install = true, -- Automatically install missing parsers
        highlight = { enable = true },
        indent = { enable = true }, -- Optional: enable indentation based on treesitter
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<c-space>',
            node_incremental = '<c-space>',
            scope_incremental = '<c-s>',
            node_decremental = '<bs>',
          },
        },
        textobjects = { -- Optional configuration for text objects
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              [']m'] = '@function.outer',
              [']]'] = '@class.outer',
            },
            goto_next_end = {
              [']M'] = '@function.outer',
              [']['] = '@class.outer',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[['] = '@class.outer',
            },
            goto_previous_end = {
              ['[M'] = '@function.outer',
              ['[]'] = '@class.outer',
            },
          },
        },
      }
    end,
  },
  { 'nvim-treesitter/nvim-treesitter-context', dependencies = 'nvim-treesitter/nvim-treesitter', event = 'BufWinEnter', config = true }, -- Load when a window is entered

  -- File Explorer / Fuzzy Finder
  {
    "MattesGroeger/vim-bookmarks",
    config = function()
      vim.g.bookmark_sign = "⚑"
      vim.g.bookmark_highlight_lines = 1
    end,
	},
  {"tom-anders/telescope-vim-bookmarks.nvim"},
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope', -- Load when :Telescope is called
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Optional: FZF sorter for improved performance
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      'nvim-telescope/telescope-media-files.nvim',
      'MattesGroeger/vim-bookmarks', -- Integrated bookmark support
    },
    keys = {
      {
        "<leader>ft",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find({
            prompt_title  = "🔍 Buffer Search",
            initial_mode  = "insert",
            -- this is your hardcoded prefix:
            default_text  = "* ",
          })
        end,
        desc = "Fuzzy search in current buffer with hardcoded PREFIX",
      },
    },
    config = function()
      local telescope = require 'telescope'
      telescope.setup {
        buffers = {
          show_all_buffers = true,
          sort_mru = true,
          ignore_current_buffer = true,
        },
        defaults = {
          layout_strategy = 'horizontal',
          layout_config = {
            horizontal = {
              prompt_position = 'top',
              preview_width = 0.55,
            },
            vertical = { mirror = false },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          sorting_strategy = 'ascending',
          file_ignore_patterns = { 'node_modules', '.git' },
          path_display = { 'truncate' },
          mappings = {
            i = {
              ['<C-n>'] = require('telescope.actions').move_selection_next,
              ['<C-p>'] = require('telescope.actions').move_selection_previous,
              ['<C-q>'] = require('telescope.actions').send_selected_to_qflist + require('telescope.actions').open_qflist,
              ['<Down>'] = require('telescope.actions').move_selection_next,
              ['<Up>'] = require('telescope.actions').move_selection_previous,
              ['<esc>'] = require('telescope.actions').close,
            },
          },
        },
        pickers = {
          -- Configure pickers
        },
        extensions = {
          fzf = {
            fuzzy = true, -- Enable fuzzy finding
            override_generic_sorter = true, -- Use fzf sorter for generic pickers
            override_file_sorter = true, -- Use fzf sorter for file pickers
            case_mode = 'smart_case', -- "smart_case" | "ignore_case" | "respect_case"
          },
          media_files = {
            -- filetypes = {"png", "webp", "jpg", "jpeg"}, -- Specify filetypes for media preview
            -- find_cmd = "rg" -- Can change the command used for finding files
          },
        },
      }
      -- Load extensions
      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'media_files')
      pcall(telescope.load_extension, 'vim_bookmarks')
    end,
  },
  { 'junegunn/fzf', build = './install --bin', lazy = true }, -- Dependency for fzf.vim and telescope-fzf-native
  { 'junegunn/fzf.vim', cmd = { 'FZF', 'Files', 'Buffers', 'Lines', 'BLines', 'Tags', 'BTags', 'Commits', 'BCommits', 'History', 'Snippets', 'Commands' }, dependencies = { 'junegunn/fzf' } }, -- Load on fzf commands

  -- Git Integration
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim', -- Recommended for diff viewing
      'nvim-telescope/telescope.nvim', -- Optional integration
      -- 'ibhagwan/fzf-lua', -- Optional alternative finder
    },
    cmd = 'Neogit', -- Load when :Neogit is called
    config = true, -- Use default config
  },
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles' }, -- Load on Diffview commands
    config = function()
      require('diffview').setup { enhanced_diff_hl = true }
    end,
  },

  -- UI Enhancements & Helpers
  { 'lukas-reineke/indent-blankline.nvim', main = 'ibl', event = 'BufReadPost', config = function() require('ibl').setup() end }, -- Load after buffer read
  { 'folke/which-key.nvim', event = 'VeryLazy', config = function() require('which-key').setup() end }, -- Load very late
    {
    "nvim-orgmode/telescope-orgmode.nvim",
    -- event = "VeryLazy",
    dependencies = {
      "nvim-orgmode/orgmode",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("telescope").load_extension("orgmode")

      vim.keymap.set("n", "<leader>r", require("telescope").extensions.orgmode.refile_heading)
      vim.keymap.set("n", "<leader>fh", require("telescope").extensions.orgmode.search_headings)
      vim.keymap.set("n", "<leader>li", require("telescope").extensions.orgmode.insert_link)
    end,
  },
  { 'stevearc/aerial.nvim', commit='8c63f41c13d250faeb3c848b61b06adedac737e5', event = 'BufReadPost', dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, config = function() require('aerial').setup { -- Your existing aerial config goes here (abbreviated)
    backends = { 'treesitter', 'lsp', 'markdown', 'asciidoc', 'man' },
    layout = { max_width = { 0.9 }, min_width = 0.6, default_direction = 'float' },
    filter_kind = { 'Class', 'Constructor', 'Enum', 'Function', 'Interface', 'Module', 'Method', 'Struct' },
    -- Add the rest of your aerial config options...
    lazy_load = true,
  } end },
  { 'shortcuts/no-neck-pain.nvim', version = '*' },
  { 'folke/twilight.nvim', cmd = 'Twilight', config = true }, -- Load on command
  { 'pocco81/true-zen.nvim', cmd = { 'TZFocus', 'TZMinimalist', 'TZAtaraxis', 'TZNarrow' }, config = true }, -- Load on command
  { 'jdearmas/taboo', event = 'BufWinEnter', config = true }, -- Load when entering a window
  { 'yorickpeterse/nvim-window', keys = { { 'n', '<leader>a' } }, config = true }, -- Load on keypress
  -- { 'chrisbra/Colorizer', event = 'BufReadPost', config = true }, -- Load after buffer read

  -- Command Line / Terminal
  { 'VonHeikemen/fine-cmdline.nvim', dependencies = { 'MunifTanjim/nui.nvim' },  config = function() require('fine-cmdline').setup { -- Your existing fine-cmdline config
    cmdline = { enable_keymaps = true, smart_history = true, prompt = ': ' },
    popup = { position = { row = '50%', col = '50%' }, size = { width = '60%' }, border = { style = 'rounded' }, win_options = { winhighlight = 'Normal:Normal,FloatBorder:FloatBorder' } },
  } end },
  { 'chomosuke/term-edit.nvim', version = '1.*', event = 'TermOpen', -- Load when a terminal opens
    config = function() require('term-edit').setup { prompt_end = { '%$ ', '> ' } } end },
  { 'voldikss/vim-floaterm', cmd = 'FloatermNew', config = function()
    vim.g.floaterm_width = 0.95
    vim.g.floaterm_height = 0.95
  end },
  { 'mtikekar/nvim-send-to-term'},
  {'mrcjkb/rustaceanvim'},
  {
	  'windwp/nvim-autopairs',
	  event = "InsertEnter",
	  config = true
	  -- use opts = {} for passing setup options
	  -- this is equivalent to setup({}) function
  },
  -- {
  --   "ahmedkhalf/project.nvim",
  --   config = function()
  --     require("project_nvim").setup {
  --       -- your configuration comes here
  --       -- or leave it empty to use the default settings
  --       -- refer to the configuration section below
  --       patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
  --     }
  --   end
  -- },
  -- {"rcarriga/nvim-notify"},
  {
    "ray-x/go.nvim",
    dependencies = {  -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      -- lsp_keymaps = false,
      -- other options
    },
    config = function(lp, opts)
      require("go").setup(opts)
      local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          require('go.format').goimports()
        end,
        group = format_sync_grp,
      })
    end,
    event = {"CmdlineEnter"},
    ft = {"go", 'gomod'},
    build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
  },
  { 'tpope/vim-dispatch' }, -- Load on command
  {'kevinhwang91/nvim-bqf'},
  { 'jdearmas/vim-dispatch-neovim', dependencies = { 'tpope/vim-dispatch' } }, -- Load when dispatch is loaded

  -- Filetype Specific
  { 'mattn/emmet-vim', ft = { 'html', 'css', 'javascript', 'typescript', 'jsx', 'tsx' } }, -- Load for specific filetypes
  -- { 'ray-x/go.nvim', dependencies = { 'ray-x/guihua.lua', 'neovim/nvim-lspconfig', 'nvim-treesitter/nvim-treesitter' }, ft = { 'go', 'gomod' }, build = ':lua require("go.install").update_all_sync()', -- build step
  --   config = function() require('go').setup() end },


    -- Utilities
  { 'tpope/vim-commentary', event = 'VeryLazy' }, -- Basic commenting, load late
  { 'mbbill/undotree', cmd = 'UndotreeToggle' }, -- Load on command
  { 'sbdchd/neoformat', cmd = 'Neoformat', event = 'BufWritePre' }, -- Load on command or before writing
  -- { 'github/copilot.vim', cmd = 'Copilot' }, -- Load on command
  { 'ptzz/lf.vim', cmd = 'Lf', dependencies = { 'voldikss/vim-floaterm' } }, -- Load on command
  { 'maralla/completor.vim', lazy = true }, -- Load when needed by completion? (May conflict with nvim-cmp)

  -- Task Runner Integration
  { 'stevearc/overseer.nvim', cmd = { 'OverseerRun', 'OverseerToggle' }, config = true },
  { 'pianocomposer321/officer.nvim', dependencies = 'stevearc/overseer.nvim', cmd = 'Officer', config = function() require('officer').setup() end },
  {
    'nvim-orgmode/orgmode',
    lazy = true,
    ft = 'org',
    opts = {
      org_agenda_files       = { '~/org/*', '~/orgs/**/*' },
      org_default_notes_file = '~/org/todo.org',
    },
    config = function(_, opts)
      local api = vim.api
      local uv  = vim.loop

      -- stopwatch state in a persistent buffer
      local state = {
        buf                = nil,
        timer              = nil,
        org_clock_start_hr = nil,
        org_clock_header   = nil,
        header_line        = nil,
        win                = nil,
        pos                = 'top',  -- 'top' or 'bottom'
      }

      -- ensure or create a named scratch buffer
      local function get_buffer()
        if state.buf and api.nvim_buf_is_valid(state.buf) then
          return state.buf
        end
        state.buf = api.nvim_create_buf(true, true)
        api.nvim_buf_set_name(state.buf, 'OrgStopwatch')
        return state.buf
      end

      -- create floating window anchored to top or bottom center
      local function create_win()
        if state.win and api.nvim_win_is_valid(state.win) then return end
        local buf = get_buffer()
        local width, height = 60, 1
        local ui = api.nvim_list_uis()[1]
        local row = (state.pos == 'bottom')
        and (ui.height - height - 1)
        or 1
        local col = math.floor((ui.width - width) / 2)
        state.win = api.nvim_open_win(buf, false, {
          relative   = 'editor',
          width      = width,
          height     = height,
          row        = row,
          col        = col,
          style      = 'minimal',
          border     = 'rounded',
          focusable  = false,
          zindex     = 50,
        })
      end

      -- close floating window
      local function close_win()
        if state.win and api.nvim_win_is_valid(state.win) then
          api.nvim_win_close(state.win, true)
        end
        state.win = nil
      end

      -- format nanoseconds → H:MM:SS.mmm or MM:SS.mmm
      local function format_elapsed_ns(ns)
        local total_ms = ns / 1e6
        local ms       = math.floor(total_ms % 1000)
        local total_s  = math.floor(total_ms / 1000)
        local s        = total_s % 60
        local m        = math.floor((total_s % 3600) / 60)
        local h        = math.floor(total_s / 3600)
        if h > 0 then
          return string.format('%d:%02d:%02d.%03d', h, m, s, ms)
        else
          return string.format('%02d:%02d.%03d', m, s, ms)
        end
      end

      -- restart float if layout changes
      local function ensure_float()
        if state.timer and (not state.win or not api.nvim_win_is_valid(state.win)) then
          create_win()
        end
      end

      -- toggle position and recreate window
      local function toggle_position()
        state.pos = (state.pos == 'top') and 'bottom' or 'top'
        if state.timer then
          -- close and reopen at new position
          close_win()
          create_win()
        end
      end

      -- wrapper: clock in + start stopwatch + toggle bookmark
      --
      local function removeTODO(s)
        return s:gsub("^%s*TODO%s*", "")
      end
      local function clock_in_and_start()
        require('orgmode').action('clock.org_clock_in')
        vim.schedule(function()
          local lines = api.nvim_buf_get_lines(0, 0, -1, false)
          state.header_line = nil
          for idx, ln in ipairs(lines) do
            local y, mo, d, HH, MM = ln:match(
              'CLOCK:%s*%[(%d+)%-(%d+)%-(%d+) [^ ]+ (%d+):(%d+)%]'
            )
            if y and not ln:find('%-%-') then
              local ts = os.time{
                year  = tonumber(y), month = tonumber(mo), day = tonumber(d),
                hour  = tonumber(HH),    min   = tonumber(MM),  sec = 0,
              }
              local now_hr    = uv.hrtime()
              -- local elapsed_s = os.time() - ts
              local now = os.date("*t")
              now.sec = 0
              local elapsed_s = os.time(now) - ts
              state.org_clock_start_hr = now_hr - elapsed_s * 1e9
              for j = idx, 1, -1 do
                local title = lines[j]:match('^%*+%s+(.*)')
                if title then
                  state.org_clock_header = removeTODO(title)
                  state.header_line = j
                  break
                end
              end
              break
            end
          end
          if state.header_line then
            local win = api.nvim_get_current_win()
            api.nvim_win_set_cursor(win, { state.header_line, 0 })
            vim.cmd('BookmarkToggle')
          end
          if state.timer then
            state.timer:stop(); state.timer:close()
          end
          create_win()
          state.timer = uv.new_timer()
          state.timer:start(0, 100, vim.schedule_wrap(function()
            if not state.org_clock_start_hr then return end
            local elapsed_ns = uv.hrtime() - state.org_clock_start_hr
            local txt = string.format('%s | %s',  format_elapsed_ns(elapsed_ns), state.org_clock_header or '')
            local buf = get_buffer()
            if api.nvim_buf_is_valid(buf) then
              api.nvim_buf_set_lines(buf, 0, -1, false, { txt })
            end
          end))
        end)
      end

      -- wrapper: clock out + stop + toggle bookmark
      local function clock_out_and_stop()
        require('orgmode').action('clock.org_clock_out')
        if state.header_line then
          vim.schedule(function()
            local win = api.nvim_get_current_win()
            api.nvim_win_set_cursor(win, { state.header_line, 0 })
            vim.cmd('BookmarkToggle')
          end)
        end
        if state.timer then
          state.timer:stop(); state.timer:close()
          state.timer = nil
          vim.defer_fn(function()
            close_win()
            state.org_clock_start_hr = nil
            state.org_clock_header   = nil
            state.header_line        = nil
          end, 2000)
        end
      end

      -- init Orgmode
      require('orgmode').setup(opts)

      -- mappings in Org buffers
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'org',
        callback = function()
          vim.keymap.set('n', '<Space>oxi', clock_in_and_start, { buffer = true })
          vim.keymap.set('n', '<Space>oxo', clock_out_and_stop,  { buffer = true })
          vim.keymap.set('n', '<Space>oxt', toggle_position,      { buffer = true, desc = 'Toggle stopwatch position' })
        end,
      })

      -- ensure float on layout changes
      vim.api.nvim_create_autocmd({ 'WinEnter', 'TabEnter', 'VimResized', 'WinClosed' }, {
        callback = vim.schedule_wrap(ensure_float),
      })
    end,
  }




})

-- [[ Autocommands ]]
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local user_augroup = augroup('UserAuCmds', { clear = true })

-- Auto format on save (ensure Neoformat is loaded)
-- autocmd('BufWritePre', {
--   group = user_augroup,
--   pattern = '*',
--   callback = function()
--     -- Use pcall in case neoformat isn't loaded or fails
--     local success, _ = pcall(vim.cmd, 'silent! Neoformat')
--     if not success then
--       -- print("Neoformat not available or failed.")
--     end
--   end,
--   desc = 'Auto format buffer on save using Neoformat',
-- })

-- Define keymaps for terminal buffers when they open
autocmd('TermOpen', {
  group = user_augroup,
  pattern = 'term://*',
  callback = function()
    local opts = { buffer = 0, noremap = true, silent = true }
    vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', 'hs', [[<C-\><C-n>]], opts) -- Custom mapping?
    vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
    vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
    vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
    vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
    vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts) -- Standard terminal window command prefix
    -- vim.keymap.set('n', 'f', ':f ', { buffer = 0 }) -- Consider if this should be global or terminal-specific
    -- vim.cmd 'startinsert' -- Optional: go directly into insert mode in new terminals
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

-- Auto create directories when saving/creating files
local function ensure_directory(filepath)
  local dir = vim.fn.fnamemodify(filepath, ':h')
  if dir ~= '' and dir ~= '.' and vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, 'p')
  end
end

autocmd('BufWritePre', {
  group = user_augroup,
  pattern = '*',
  callback = function(ev)
    ensure_directory(ev.match)
  end,
  desc = 'Ensure directory exists before writing buffer',
})

autocmd('BufNewFile', {
  group = user_augroup,
  pattern = '*',
  callback = function(ev)
    ensure_directory(ev.match)
    -- Optional: Create the file immediately if it doesn't exist
    -- if vim.fn.filereadable(ev.match) == 0 then
    --   vim.fn.writefile({}, ev.match)
    -- end
  end,
  desc = 'Ensure directory exists for new files',
})


-- [[ Functions ]]

-- Function to pipe :messages to a new buffer
function _G.pipe_messages_to_buffer()
  local messages_output = vim.api.nvim_exec('messages', true)
  vim.cmd 'enew'
  vim.bo.buftype = 'nofile'
  vim.bo.swapfile = false
  vim.bo.bufhidden = 'wipe'
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(messages_output, '\n'))
end

-- Function to toggle the quickfix window
function _G.ToggleQuickFix()
  local is_open = false
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      is_open = true
      break
    end
  end
  if is_open then
    vim.cmd 'cclose'
  else
    -- vim.cmd 'copen 50'
    local height = math.floor(vim.o.lines * 0.5)
    vim.cmd('copen ' .. height)
  end
end

-- Function to copy full file path:line to clipboard
function _G.copy_full_path_to_clipboard()
  local full_path = vim.fn.expand '%:p'
  if full_path == '' then
    print 'No file path associated with buffer.'
    return
  end
  local line_num = vim.fn.line '.'
  local full_path_with_line = full_path .. ':' .. line_num
  vim.fn.setreg('+', full_path_with_line)
  vim.notify('Copied to clipboard: ' .. full_path_with_line, vim.log.levels.INFO)
end

-- Function for gf to create file/dir if it doesn't exist
function _G.goto_or_create()
  local filename = vim.fn.expand '<cfile>'
  if filename == '' then
    print 'No filename under cursor.'
    return
  end
  ensure_directory(filename) -- Ensure directory exists first
  if vim.fn.filereadable(filename) == 1 or vim.fn.isdirectory(filename) == 1 then
    vim.cmd('edit ' .. vim.fn.fnameescape(filename))
  else
    -- Ask user if they want to create it? Or just create. Let's just create.
    vim.cmd('edit ' .. vim.fn.fnameescape(filename))
    -- vim.cmd('write') -- Optionally save immediately
    print('Created and opened new file: ' .. filename)
  end
end

-- Function to delete buffers matching a pattern
function _G.DeleteBuffersMatchingPattern()
  local pattern = vim.fn.input 'Enter regex pattern to delete buffers: '
  if pattern == '' then
    print 'No pattern entered.'
    return
  end
  local buffers_deleted = 0
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then -- Only consider loaded buffers
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      if bufname ~= '' and string.match(bufname, pattern) then
        -- Check if buffer is displayed or modified before deleting
        local bufinfo = vim.fn.getbufinfo(bufnr)[1]
        if bufinfo and not bufinfo.hidden and not bufinfo.listed then -- Skip special buffers
          goto continue
        end
        if bufinfo and bufinfo.windows and #bufinfo.windows > 0 then
          print('Skipping deletion, buffer displayed in a window: ' .. bufname)
        elseif bufinfo and bufinfo.changed == 1 then
          local choice = vim.fn.input('Buffer is modified. Force delete? (y/N): ' .. bufname .. ' ')
          if string.lower(choice) == 'y' then
            vim.api.nvim_buf_delete(bufnr, { force = true })
            buffers_deleted = buffers_deleted + 1
          else
            print('Skipping deletion of modified buffer: ' .. bufname)
          end
        else
          vim.api.nvim_buf_delete(bufnr, { force = false }) -- Try non-force first
          buffers_deleted = buffers_deleted + 1
        end
      end
    end
    ::continue::
  end
  vim.notify(string.format('Deleted %d buffers matching pattern "%s"', buffers_deleted, pattern), vim.log.levels.INFO)
end

-- Function to set makeprg from visual selection
function _G.SetMakePrgFromVisualSelection()
  local old_reg = vim.fn.getreg '"'
  local old_reg_type = vim.fn.getregtype '"'
  vim.cmd 'normal! `<v`>y' -- Yank selection
  local selected_text = vim.fn.getreg '"'
  vim.fn.setreg('"', old_reg, old_reg_type) -- Restore register

  if selected_text == '' then
    print 'No text selected.'
    return
  end

  -- Basic escaping, might need improvement depending on content
  local escaped_text = selected_text --vim.fn.shellescape(selected_text) -- shellescape might be too much here
  vim.opt_local.makeprg = escaped_text -- Use setlocal for buffer-specific makeprg
  vim.notify('Set local makeprg to: ' .. escaped_text, vim.log.levels.INFO)
end


function _G.surround_visual_with_example_org_block()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line_num = start_pos[2]
  local end_line_num = end_pos[2]

  local block_type = "example"

  -- Extract indentation from first line
  local line = vim.api.nvim_buf_get_lines(0, start_line_num - 1, start_line_num, false)[1]
  local indent_str = line:match("^%s*") or ""

  -- Construct start and end block lines with indentation
  local start_block_lines = {
    indent_str .. "#+RESULTS:",
    indent_str .. "#+begin_" .. block_type
  }

  local block_type_token = block_type:match("%S+")
  local end_block_line = indent_str .. "#+end_" .. block_type_token

  -- Insert end block *after* selection
  vim.api.nvim_buf_set_lines(0, end_line_num, end_line_num, false, { end_block_line })

  -- Insert start block lines *before* selection
  vim.api.nvim_buf_set_lines(0, start_line_num - 1, start_line_num - 1, false, start_block_lines)

  -- Adjust selection markers to include the new block
  vim.fn.setpos("'<", { 0, start_line_num + 2, 1, 0 })
  vim.fn.setpos("'>", { 0, end_line_num + 2, 1, 0 })
end

-- Function to surround visual selection with org block
function _G.surround_visual_with_org_block()
  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"
  local start_line_num = start_pos[2]
  local end_line_num = end_pos[2]

  local block_type = vim.fn.input 'Enter org block type (e.g., src, quote): '
  if block_type == '' then
    print 'Invalid block type entered.'
    return
  end

  local lang = ''
  if block_type == 'src' then
    lang = vim.fn.input 'Enter source language (e.g., lua, python): '
    if lang ~= '' then
      block_type = block_type .. ' ' .. lang
    end
  end

  local start_block = '#+begin_' .. block_type

  local block_type_tokens = block_type:match("%S+")
  local end_block = '#+end_' .. block_type_tokens

  local indent_str = vim.fn.matchstr(vim.api.nvim_buf_get_lines(0, start_line_num - 1, start_line_num, false)[1], '^%s*')

  -- Insert end block first to avoid messing up line numbers for start block insertion
  vim.api.nvim_buf_set_lines(0, end_line_num, end_line_num, false, { indent_str .. end_block })
  vim.api.nvim_buf_set_lines(0, start_line_num - 1, start_line_num - 1, false, { indent_str .. start_block })

  -- Adjust selection markers if needed (optional)
  vim.fn.setpos("'<", { start_pos[1], start_line_num + 1, start_pos[3], start_pos[4] })
  vim.fn.setpos("'>", { end_pos[1], end_line_num + 1, end_pos[3], end_pos[4] })
end

-- Function to save quickfix list to a file
local function sanitize_command(cmd)
  local sanitized = cmd:gsub('^:%s*', ''):gsub('^Dispatch%s+', ''):gsub('%s*%([^)]*%)', ''):gsub('%s+', '_'):gsub('[/\\]', '_')
  return sanitized == '' and 'quickfix' or sanitized
end

_G.save_quickfix_to_file = function()
  local qf_info = vim.fn.getqflist { title = 1, items = 1 } -- Get title and items
  if not qf_info or not qf_info.items or #qf_info.items == 0 then
    print 'Quickfix list is empty.'
    return
  end

  local title = qf_info.title or 'quickfix_list'
  local command = sanitize_command(title)
  local timestamp = os.time()
  local filename = string.format('%s_%s.txt', timestamp, command)
  -- local home_dir = vim.fn.expand '~/' -- Ensure trailing slash
  local current_dir = vim.fn.expand './' -- Ensure trailing slash
  local output_file = current_dir .. filename

  local lines = {}
  for _, item in ipairs(qf_info.items) do
    table.insert(lines, item.text or '')
  end

  local success = pcall(vim.fn.writefile, lines, output_file)
  if success then
    vim.notify('Quickfix list saved to ' .. output_file, vim.log.levels.INFO)
  else
    vim.notify('Error saving quickfix list to ' .. output_file, vim.log.levels.ERROR)
  end
end

-- Function for C template creation
function create_c_template()
  local dir = vim.fn.input 'Enter directory name for C project: '
  if dir == '' then
    print 'No directory entered.'
    return
  end
  local home = vim.fn.expand '~'
  local target_dir = home .. '/test/c/' .. dir -- Define base path
  vim.fn.mkdir(target_dir, 'p')

  local c_filepath = target_dir .. '/main.c'
  local c_template = [[
/* Compile and run: clang -Wall -Wextra -pedantic -std=c11 -o main main.c && ./main */
#include <stdio.h>
#include <stdlib.h> // Include stdlib for EXIT_SUCCESS/FAILURE

int main(void) {
    printf("Hello, World!\n");
    return EXIT_SUCCESS; // Use standard exit codes
}
]]
  local c_file = io.open(c_filepath, 'w')
  if c_file then
    c_file:write(c_template)
    c_file:close()
  else
    print('Error creating file: ' .. c_filepath)
    return
  end

  local make_filepath = target_dir .. '/Makefile'
  -- Improved Makefile
  local make_template = [[
CC = clang
CFLAGS = -Wall -Wextra -pedantic -std=c11 -g # Add -g for debugging symbols
TARGET = main
SRC = main.c

.PHONY: all run clean

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC)

run: all
	./$(TARGET)

clean:
	rm -f $(TARGET)
]]
  local make_file = io.open(make_filepath, 'w')
  if make_file then
    make_file:write(make_template)
    make_file:close()
  else
    print('Error creating file: ' .. make_filepath)
  end

  vim.cmd('edit ' .. vim.fn.fnameescape(c_filepath))
  vim.notify('C project template created in ' .. target_dir, vim.log.levels.INFO)
end

-- Function to set makeprg from current line comment
function _G.ProcessAndSetMakeprg()
  local line = vim.api.nvim_get_current_line()
  -- Extract command after comment marker (more robust)
  local processed_line = line:match('^%s*[%-%/*#$]+%s*(.*)') -- Match common comment chars

  if not processed_line then
    processed_line = line:match('^%s*(.*)') -- Fallback: use whole line if no comment marker found
  end
  processed_line = processed_line:gsub('^%s*', ''):gsub('%s*$', '') -- Trim whitespace

  if processed_line == '' then
    print 'Could not extract command from line.'
    return
  end

  vim.opt_local.makeprg = processed_line
  vim.notify('Set local makeprg to: ' .. processed_line, vim.log.levels.INFO)

  -- Highlight the line briefly
  local ns = vim.api.nvim_create_namespace 'makeprg_highlight'
  vim.api.nvim_buf_add_highlight(0, ns, 'Visual', vim.fn.line('.') - 1, 0, -1)
  vim.defer_fn(function() vim.api.nvim_buf_clear_namespace(0, ns, 0, -1) end, 750)
end

-- Function to create diff patch
function _G.create_diff_patch()
  local filepath = vim.fn.expand '%:p'
  if vim.fn.empty(filepath) == 1 or vim.fn.filereadable(filepath) == 0 then
    print 'Cannot diff: File not saved or does not exist.'
    return
  end
  local patchfile = filepath .. '.patch'
  local cmd = string.format('write !diff -u %s - > %s', vim.fn.shellescape(filepath), vim.fn.shellescape(patchfile))
  local success, result = pcall(vim.cmd, cmd)
  if success then
    vim.notify('Patch created: ' .. patchfile, vim.log.levels.INFO)
  else
    vim.notify('Error creating patch: ' .. tostring(result), vim.log.levels.ERROR)
  end
end

-- Function to toggle diagnostics display
local diagnostics_active = true -- Assume enabled by default
function _G.ToggleDiagnostics()
  diagnostics_active = not diagnostics_active
  if diagnostics_active then
    vim.diagnostic.enable()
    vim.notify 'Diagnostics Enabled'
  else
    vim.diagnostic.disable()
    vim.notify 'Diagnostics Disabled'
  end
  -- Optional: Also toggle virtual text, signs, etc.
  -- local config = vim.diagnostic.config
  -- config({ virtual_text = diagnostics_active, signs = diagnostics_active, underline = diagnostics_active })
end

-- [[ Keymaps ]]
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- General Navigation & Editing
map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true }) -- Allow leader key timeout
map('n', 'j', 'gj', { noremap = true, silent = true, desc = 'Move down visual line' })
map('n', 'k', 'gk', { noremap = true, silent = true, desc = 'Move up visual line' })
map('n', 'J', '<PageDown>', { desc = 'Page Down' }) -- Remap J/K for PgUp/PgDn if desired
map('n', 'K', '<PageUp>', { desc = 'Page Up' }) -- Conflicts with default K (hover) if LSP not mapped differently
map('n', '<BS>', ':bp<CR>', opts) -- Go to previous buffer
map('n', '<leader>w', ':set wrap!<CR>', opts) -- Toggle wrap
map('n', '<leader>m', ':NoNeckPain<CR>', opts) -- Toggle NoNeckPain
map('n', '<leader>r', ':only<CR>', opts) -- Close all other windows
map('n', '<leader><leader>', ':w!<CR>', opts) -- Quick save
map('n', '<leader>D', ':bd!<CR>', opts) -- Force delete buffer
map('n', '<leader>c', ':close<CR>', opts) -- Close current window

vim.keymap.set("n", "<leader>Q", function()
	-- Gather buffers displayed in any window
	local displayed_buffers = {}
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		displayed_buffers[vim.api.nvim_win_get_buf(win)] = true
	end

	-- Iterate over all buffers
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if not displayed_buffers[buf] then
			local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
			local modifiable = vim.api.nvim_buf_get_option(buf, "modifiable")
			local modified = vim.api.nvim_buf_get_option(buf, "modified")
			local name = vim.api.nvim_buf_get_name(buf)

			-- If it's a modifiable text buffer with a filename and unsaved changes, save it
			if modifiable and modified and buftype == "" and name ~= "" then
				vim.api.nvim_buf_call(buf, function()
					vim.cmd("silent! write")
				end)
			end

			-- Delete the buffer (including terminal or unnamed buffers)
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
		end
	end
end, { desc = "Save & close all undisplayed buffers" })

map('n', '<leader>=', ':%!jq .<CR>', { noremap = true, desc = 'Format JSON with jq' }) -- Requires jq
map('n', '7', '<C-w>=', { desc = 'Equalize window sizes' })

-- Window Management
map('n', '<leader>s', ':split<CR>', opts) -- Horizontal split
map('n', '<leader>v', ':vsplit<CR>', opts) -- Vertical split (Added)
map('n', '<leader>j', '<C-w>j', opts) -- Move to window below
map('n', '<leader>k', '<C-w>k', opts) -- Move to window above
map('n', '<leader>h', '<C-w>h', opts) -- Move to window left (Added)
map('n', '<leader>l', '<C-w>l', opts) -- Move to window right (Added)
map('n', '<leader>a', ':lua require("nvim-window").pick()<CR>', opts) -- Pick window visually

-- Tab Management
map('n', '<leader>tn', ':tabnew<CR>', { noremap = true, desc = 'New Tab' })
map('n', '<leader>tc', ':tabclose<CR>', { noremap = true, desc = 'Close Tab' }) -- Added
map('n', '<leader>to', ':tabonly<CR>', { noremap = true, desc = 'Tab Only' }) -- Added
map('n', '<leader>tr', ':TabooRename<Space>', { noremap = true, desc = 'Rename Tab (Taboo)' })
map('n', ']t', ':tabnext<CR>', { noremap = true, silent = true, desc = 'Next Tab' }) -- Added
map('n', '[t', ':tabprevious<CR>', { noremap = true, silent = true, desc = 'Previous Tab' }) -- Added

-- Terminal
map('n', '<leader>i', ':new | terminal<CR>', opts) -- Open terminal in new horizontal split
map('n', 's',        '<Plug>SendLine')

-- Clipboard / Yanking
map({ 'n', 'v' }, '<leader>y', '"+y', { desc = 'Yank to system clipboard' })
map('n', '<leader>Y', '"+Y', { desc = 'Yank line to system clipboard' })
map('x', '<leader>p', '"_dP', { desc = 'Paste without yanking deleted text' })
map('n', '<leader>cp', ':lua copy_full_path_to_clipboard()<CR>', opts) -- Copy file path:line

-- File Navigation / Fuzzy Finding (Telescope)
map('n', '<leader>ff', ':Telescope find_files<CR>', opts) -- Find files
map('n', '<leader>fg', ':Telescope live_grep<CR>', opts) -- Live grep
map('n', '<leader>fb', ':Telescope buffers<CR>', opts) -- Find buffers
map('n', "<leader>b",  ':Telescope buffers<CR>', { noremap = true, silent = true })
map('n', '<leader>fh', ':Telescope help_tags<CR>', opts) -- Find help tags (Added)
map('n', '<leader>fo', ':Telescope oldfiles<CR>', opts) -- Find oldfiles
map('n', '<leader>fz', ':FZF<CR>', opts) -- FZF (alternative)
map('n', '<leader>fc', ':Rg<CR>', opts) -- Ripgrep (fzf.vim)
map('n', '<leader>fl', ':Telescope lsp_document_symbols<CR>', opts) -- LSP Document Symbols
map('n', '<leader>fL', ':Telescope lsp_workspace_symbols<CR>', opts) -- LSP Workspace Symbols (Added)
map('n', '<leader>gb', ':Telescope current_buffer_fuzzy_find<CR>', opts) -- Fuzzy find in current buffer
map('n', '<leader>gj', ':Telescope jumplist<CR>', opts) -- Telescope jumplist
map('n', '<leader>go', ':Telescope vim_bookmarks all<CR>', opts) -- Telescope bookmarks

-- Git (Neogit / Diffview)
map('n', '<leader>gs', ':Neogit<CR>', opts) -- Open Neogit
map('n', '<leader>gd', ':DiffviewOpen<CR>', opts) -- Open Diffview (Added)
map('n', '<leader>gD', ':DiffviewClose<CR>', opts) -- Close Diffview (Added)
map('n', '<leader>gh', ':Telescope git_status<CR>', opts) -- Git status (Telescope) (Added)
map('n', '<leader>gc', ':Telescope git_commits<CR>', opts) -- Git commits (Telescope) (Added)
map('n', '<leader>gb', ':Telescope git_branches<CR>', opts) -- Git branches (Telescope) (Added)

-- LSP / Diagnostics
map('n', '<leader>d', ':TroubleToggle<CR>', opts) -- Toggle diagnostics list (Requires folke/trouble.nvim) (Added)
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic' })
map('n', '<leader>dl', vim.diagnostic.open_float, { desc = 'Open diagnostic float' })
map('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Set diagnostics list' })
map('n', '<leader>tt', ':lua ToggleDiagnostics()<CR>', opts) -- Toggle diagnostics on/off

-- Running Code / Dispatch / Overseer
map('n', 'x',         ':Dispatch<CR>', opts) -- Run with Dispatch
map('n', '<leader>t', ':SendHere<CR>', opts) -- Send line to terminal (nvim-send-to-term)
-- map('n', '<leader>T', ':OverseerRun<CR>', opts) -- Run with Overseer (Added)
-- map('n', '<leader>O', ':OverseerToggle<CR>', opts) -- Toggle Overseer window (Added)
map('n', "<leader>O", ":lua pipe_messages_to_buffer()<CR>", { noremap = true, silent = true })

map('n', ';', ':lua ToggleQuickFix()<CR>', opts) -- Toggle quickfix list
map('v', '<leader>m', [[:lua SetMakePrgFromVisualSelection()<CR>]], opts) -- Set makeprg from selection
map('n', 'f', [[:lua ProcessAndSetMakeprg()<CR>]], opts) -- Set makeprg from line comment

-- Plugin Specific
map('n', '<leader>u', ':Lf<CR>', opts) -- Lf file manager
map('n', '<leader>U', ':UndotreeToggle<CR>', opts) -- Toggle Undotree (Added)
map('n', '<leader>e', ':edit $MYVIMRC<CR>', opts) -- Edit init.lua
map('n', '<leader>lr', ':luafile %<CR>', opts) -- Reload init.lua
map('n', '<leader>ou', ':AerialNavToggle<CR>', opts) -- Toggle Aerial (Symbol outline)
map('n', '<leader>oM', ':messages<CR>', opts) -- Show messages (Built-in)
map('n', '<leader>om', ':lua pipe_messages_to_buffer()<CR>', opts) -- Pipe messages to buffer

-- TrueZen mappings
map('n', '<leader>zn', ':TZNarrow<CR>', {})
map('v', '<leader>zn', ":'<,'>TZNarrow<CR>", {})
map('n', '<leader>zf', ':TZFocus<CR>', {})
map('n', '<leader>zm', ':TZMinimalist<CR>', {})
map('n', '<leader>za', ':TZAtaraxis<CR>', {})

-- Orgmode specific mappings
map('n', '<leader>oa', ':lua require("orgmode").action("org_agenda")<CR>', opts) -- Example Org agenda mapping
map('n', '<leader>oc', ':lua require("orgmode").action("org_capture")<CR>', opts) -- Example Org capture mapping
map('n', '<leader>G', '', { noremap = true, silent = true, callback = function() -- Insert TODO heading
  pcall(require, 'orgmode') -- Ensure orgmode is loaded before using its actions
  if _G.orgmode then
    _G.orgmode.action('org_mappings.insert_todo_heading_respect_content')()
    _G.orgmode.action('org_mappings.do_demote')()
  else
    print 'Orgmode not loaded'
  end
end, desc = 'Org Insert TODO Heading' })
map('v', '<leader>o', [[:<C-u>lua surround_visual_with_org_block()<CR>]], opts) -- Surround with org block
map('v', '<leader>O', [[:<C-u>lua surround_visual_with_example_org_block()<CR>]], opts) -- Surround with org block

-- Misc / Utility
map('n', '<leader>S', '<cmd>lua save_quickfix_to_file()<CR>', opts) -- Save quickfix list
map('n', '<leader>d', ':lua create_diff_patch()<CR>', opts) -- Create diff patch
map('n', '<leader>ot', ':lua create_c_template()<CR>', opts) -- Create C template project
map('n', '<leader>db', ':lua DeleteBuffersMatchingPattern()<CR>', opts) -- Delete buffers by pattern
map('n', 'gf', ':lua goto_or_create()<CR>', opts) -- Go to file under cursor (create if needed)

-- Override '<Enter>' for fine-cmdline
map('n', '<CR>', '<cmd>FineCmdline<CR>', { noremap = true })

-- Fix potential conflicts/typos
map('i', 'hs', '<esc>', opts) -- Escape from insert mode
map('i', 'hu', '<esc>', opts) -- Escape from insert mode (duplicate?)


-- Remove or fix potentially conflicting/unused maps
-- map('v', 'n', '<C-y,', {}) -- What was this intended for? Removing for now.
vim.api.nvim_set_keymap("v", "n", "<C-y>,", {})


-- Unset the keybinding
vim.api.nvim_del_keymap('n', 'n')
-- vim.api.nvim_del_keymap('n', 'N')

-- Add this to your Neovim configuration file (e.g., init.lua)

-- Save the original 's' mapping
local original_s = vim.fn.maparg('s', 'n', false, true)

-- Set up an autocommand to ensure 's' is always available as an operator
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Check if 's' is mapped to something else
    if vim.fn.maparg('s', 'n') ~= '' then
      -- Restore the original 's' mapping
      if original_s.buffer then
        vim.keymap.set('n', 's', original_s.rhs, { buffer = true, silent = true })
      else
        vim.keymap.set('n', 's', original_s.rhs, { silent = true })
      end
    end
    
    -- Ensure 's' is available as an operator
    vim.keymap.set('n', 's', 's', { noremap = true, silent = true })
  end,
})


require("no-neck-pain").setup({
	buffers = {
		scratchPad = {
			-- set to `false` to
			-- disable auto-saving
			enabled = false,
			-- set to `nil` to default
			-- to current working directory
			location = "~/Documents/",
		},
		bo = {
			filetype = "md",
		},
	},
})

-- Configure 'makeprg' for Rust
vim.cmd([[
autocmd FileType rust setlocal makeprg=cargo\ run
]])

vim.filetype.add({
  extension = {
    http = "http",
  },
})

vim.api.nvim_set_keymap("n", "<leader>G", "", {
	noremap = true,
	silent = true,
	callback = function()
		require("orgmode").action("org_mappings.insert_todo_heading_respect_content")
		require("orgmode").action("org_mappings.do_demote")
	end,
})


vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    local height = math.floor(vim.o.lines / 2)
    vim.cmd(height .. "wincmd _") -- resize to half the screen
  end,
})

vim.keymap.set("n", "<leader>fh", require("telescope").extensions.orgmode.search_headings)

-- Search headlines in current file only
vim.keymap.set(
  "n",
  "<Leader>ofc",
  function()
    require('telescope').extensions.orgmode.search_headings({ only_current_file = true })
  end,
  { desc = "Find headlines in current file"}
)

vim.keymap.set("n","F",":f ")

-- Fold everything except the current visual selection
local function fold_except_selection()
  local api = vim.api

  -- Get buffer and window
  local bufnr = api.nvim_get_current_buf()
  local winnr = api.nvim_get_current_win()

  -- Get visual marks '< and '>
  local start_pos = api.nvim_buf_get_mark(bufnr, "<")
  local end_pos   = api.nvim_buf_get_mark(bufnr, ">")

  -- Derive start/end lines
  local start_line = math.min(start_pos[1], end_pos[1])
  local end_line   = math.max(start_pos[1], end_pos[1])

  -- Total lines in buffer
  local total = api.nvim_buf_line_count(bufnr)

  -- Nothing to do?
  if start_line > total or end_line < 1 then
    return
  end

  -- Switch to manual folding
  api.nvim_win_set_option(winnr, "foldmethod", "manual")
  api.nvim_win_set_option(winnr, "foldenable", true)
  api.nvim_win_set_option(winnr, "foldminlines", 1)

  -- Clear existing folds
  vim.cmd("silent! normal! zE")

  -- Fold above selection
  if start_line > 1 then
    vim.cmd(("%d,%dfold"):format(1, start_line - 1))
  end

  -- Fold below selection
  if end_line < total then
    vim.cmd(("%d,%dfold"):format(end_line + 1, total))
  end

  -- Center view on selection start
  api.nvim_win_set_cursor(winnr, { start_line, 0 })
  vim.cmd("normal! zz")
end

-- Map in visual mode
vim.keymap.set("v", "a", fold_except_selection, {
  desc = "Fold everything except visual selection",
  silent = true,
})


vim.opt.autochdir = true -- Automatically change directory to the file's directory (Consider potential side effects)

--[[
================================================================================
  ON-DEMAND POPOUT WINDOW (Single File Version)
  - Added logic to jump back to the previous window.
================================================================================
--]]

-- Create a table to act as a namespace for our functions and variables.
local popout = {}

--- CONFIGURATION ---
popout.default_height = 5
popout.position = 'bottom'
---------------------

-- This variable will hold the buffer number you want to open.
popout.target_bufnr = nil
-- This will hold the window ID to jump back to.
popout.previous_win_id = nil

---Sets the current buffer as the target for the popout window.
function popout.set_target_buffer()
  popout.target_bufnr = vim.api.nvim_get_current_buf()
  local fname = vim.api.nvim_buf_get_name(popout.target_bufnr)
  print(string.format("Popout target set to buffer %d: %s", popout.target_bufnr, vim.fn.fnamemodify(fname, ":t")))
end

---Toggles the popout window position between top and bottom.
function popout.toggle_position()
  if popout.position == 'bottom' then
    popout.position = 'top'
  else
    popout.position = 'bottom'
  end
  print("Popout position set to: " .. popout.position)
end

---Opens, jumps to, or jumps back from the popout window.
function popout.open_in_split()
  -- 1. Validate that a target buffer has been set.
  if not popout.target_bufnr or not vim.api.nvim_buf_is_valid(popout.target_bufnr) then
    vim.notify("No valid target buffer set. Use 'set target' keymap first.", vim.log.levels.WARN, { title = "Popout" })
    return
  end

  local current_win_id = vim.api.nvim_get_current_win()
  local current_buf_id = vim.api.nvim_win_get_buf(current_win_id)

  -- 2. JUMP-BACK LOGIC: If we're already in the popout, jump back.
  if current_buf_id == popout.target_bufnr then
    if popout.previous_win_id and vim.api.nvim_win_is_valid(popout.previous_win_id) then
      local jump_back_target = popout.previous_win_id
      popout.previous_win_id = nil -- Clear the state after use
      vim.api.nvim_set_current_win(jump_back_target)
    else
      vim.notify("No previous window to jump back to.", vim.log.levels.WARN, { title = "Popout" })
    end
    return
  end

  -- If not jumping back, we're jumping *to* the popout.
  -- Store the current window so we can jump back to it later.
  popout.previous_win_id = current_win_id

  -- 3. JUMP-TO LOGIC: Find an existing window with the target buffer.
  local target_win_id = nil
  for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(win_id) == popout.target_bufnr then
      target_win_id = win_id
      break
    end
  end

  if target_win_id then
    -- If the window exists, just jump focus to it.
    vim.api.nvim_set_current_win(target_win_id)
    return
  end

  -- 4. CREATE LOGIC: If the window doesn't exist, create it.
  local height = vim.v.count > 0 and vim.v.count or popout.default_height
  local split_cmd = (popout.position == 'top') and 'topleft' or 'botright'
  vim.cmd(string.format("%s %d split", split_cmd, height))
  vim.api.nvim_win_set_buf(0, popout.target_bufnr)
end

--- KEYMAPS ---
vim.keymap.set({'n', 't'}, '<leader>ps', popout.set_target_buffer, {
  desc = "[P]opout [S]et Target Buffer"
})

vim.keymap.set({'n', 't'}, '<leader>pt', popout.toggle_position, {
  desc = "[P]opout [T]oggle Position (Top/Bottom)"
})

vim.keymap.set('n', '<C-h>', popout.open_in_split, {
  desc = "[P]opout [O]pen, Jump To, or Jump Back"
})


-- print(vim.fn.stdpath('data'))
print 'speed is life' -- Confirmation message




