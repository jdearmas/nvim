-- ~/.config/nvim/lua/plugins/lsp.lua
-- LSP, completion, and snippets configuration

---@type table<string, vim.lsp.Config>
local server_configs = {
  -- Lua: configured for Neovim development
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        workspace = {
          checkThirdParty = false,
          library = vim.api.nvim_get_runtime_file('', true),
        },
        diagnostics = { globals = { 'vim' } },
        telemetry = { enable = false },
        completion = { callSnippet = 'Replace' },
      },
    },
  },
  -- Python
  pylsp = {
    settings = {
      pylsp = {
        plugins = {
          pycodestyle = { maxLineLength = 120 },
        },
      },
    },
  },
  -- C/C++
  clangd = {
    cmd = { 'clangd', '--background-index', '--clang-tidy' },
  },
  -- Rust
  rust_analyzer = {
    settings = {
      ['rust-analyzer'] = {
        checkOnSave = { command = 'clippy' },
      },
    },
  },
  -- Go
  gopls = {
    settings = {
      gopls = {
        analyses = { unusedparams = true },
        staticcheck = true,
        gofumpt = true,
      },
    },
  },
  -- YAML with schema support
  yamlls = {
    settings = {
      yaml = {
        schemaStore = { enable = true, url = 'https://www.schemastore.org/api/json/catalog.json' },
        validate = true,
      },
    },
  },
  -- JSON with schema support
  jsonls = {
    settings = {
      json = {
        schemas = (function()
          local ok, schemastore = pcall(require, 'schemastore')
          if ok then
            return schemastore.json.schemas()
          else
            return {}
          end
        end)(),
        validate = { enable = true },
      },
    },
  },
  -- Servers with default configs (no special settings needed)
  terraformls = {},
  bashls = {},
  dockerls = {},
  eslint = {},
  html = {},
  cssls = {},
  marksman = {},
}

-- Servers to auto-install via Mason
local ensure_installed = vim.tbl_keys(server_configs)

return {
  -- Mason: Package manager for LSP servers, formatters, linters
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    build = ':MasonUpdate',
    opts = {
      ui = {
        icons = {
          package_installed = '✓',
          package_pending = '➜',
          package_uninstalled = '✗',
        },
        border = 'rounded',
      },
    },
  },

  -- Mason-lspconfig: Bridge between Mason and lspconfig
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp',
      'b0o/schemastore.nvim', -- JSON/YAML schemas
    },
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lspconfig = require('lspconfig')
      local mason_lspconfig = require('mason-lspconfig')

      -- Enhanced capabilities with nvim-cmp
      local capabilities = vim.tbl_deep_extend(
        'force',
        vim.lsp.protocol.make_client_capabilities(),
        require('cmp_nvim_lsp').default_capabilities()
      )

      -- LSP attach: keymaps and buffer-local settings
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
        callback = function(ev)
          local bufnr = ev.buf
          local client = vim.lsp.get_client_by_id(ev.data.client_id)

          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = 'LSP: ' .. desc })
          end

          -- Navigation
          map('n', 'gd', vim.lsp.buf.definition, 'Go to Definition')
          map('n', 'gD', vim.lsp.buf.declaration, 'Go to Declaration')
          map('n', 'gr', vim.lsp.buf.references, 'Go to References')
          map('n', 'gi', vim.lsp.buf.implementation, 'Go to Implementation')
          map('n', 'gt', vim.lsp.buf.type_definition, 'Go to Type Definition')

          -- Info & Actions
          map('n', 'H', vim.lsp.buf.hover, 'Hover Documentation')
          map({ 'n', 'i' }, '<C-g>', vim.lsp.buf.signature_help, 'Signature Help')
          map('n', '<F2>', vim.lsp.buf.rename, 'Rename Symbol')
          map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'Code Action')
          map('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, 'Format Buffer')

          -- Diagnostics
          map('n', '[d', vim.diagnostic.goto_prev, 'Previous Diagnostic')
          map('n', ']d', vim.diagnostic.goto_next, 'Next Diagnostic')
          map('n', '<leader>e', vim.diagnostic.open_float, 'Show Diagnostic')
          map('n', '<leader>q', vim.diagnostic.setloclist, 'Diagnostics to Loclist')
        end,
      })

      -- Setup Mason-lspconfig with handlers
      mason_lspconfig.setup {
        ensure_installed = ensure_installed,
        automatic_installation = true,
      }

      mason_lspconfig.setup_handlers {
        -- Default handler for all servers
        function(server_name)
          local config = server_configs[server_name] or {}
          config.capabilities = vim.tbl_deep_extend('force', capabilities, config.capabilities or {})

          lspconfig[server_name].setup(config)
        end,
      }

      -- Diagnostic appearance
      vim.diagnostic.config {
        virtual_text = { prefix = '●', spacing = 2 },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = 'rounded', source = 'always' },
      }
      -- Diagnostic signs in gutter
      local signs = { Error = ' ', Warn = ' ', Hint = '󰌵 ', Info = ' ' }
      for type, icon in pairs(signs) do
        local hl = 'DiagnosticSign' .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
      end
    end,
  },

  -- Completion
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip', keyword_length = 2 },
        }, {
          { name = 'buffer', keyword_length = 3 },
          { name = 'path' },
        }),
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm { select = false },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          format = function(entry, vim_item)
            local icons = {
              Text = '󰉿', Method = '󰆧', Function = '󰊕', Constructor = '',
              Field = '󰜢', Variable = '󰀫', Class = '󰠱', Interface = '',
              Module = '', Property = '󰜢', Unit = '󰑭', Value = '󰎠',
              Enum = '', Keyword = '󰌋', Snippet = '', Color = '󰏘',
              File = '󰈙', Reference = '󰈇', Folder = '󰉋', EnumMember = '',
              Constant = '󰏿', Struct = '󰙅', Event = '', Operator = '󰆕',
              TypeParameter = '',
            }
            vim_item.kind = string.format('%s %s', icons[vim_item.kind] or '', vim_item.kind)
            vim_item.menu = ({
              nvim_lsp = '[LSP]',
              luasnip = '[Snip]',
              buffer = '[Buf]',
              path = '[Path]',
            })[entry.source.name]
            return vim_item
          end,
        },
      }
    end,
  },

  -- Snippets
  {
    'L3MON4D3/LuaSnip',
    version = 'v2.*',
    build = 'make install_jsregexp',
    event = 'InsertEnter',
    dependencies = { 'rafamadriz/friendly-snippets' },
    config = function()
      require('luasnip.loaders.from_vscode').lazy_load()
    end,
  },

  -- Schema store for JSON/YAML
  { 'b0o/schemastore.nvim', lazy = true },

  -- Lazydev: Fast Lua development (replaces slow runtime scanning)
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        { path = 'lazy.nvim', words = { 'LazySpec' } },
      },
    },
  },
}

