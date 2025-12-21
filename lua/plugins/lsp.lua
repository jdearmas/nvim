-- ~/.config/nvim/lua/plugins/lsp.lua
-- LSP, completion, and snippets configuration

-- LSP attach callback
local lsp_attach_callback = function(client, bufnr)
  local map = function(mode, lhs, rhs, opts)
    opts = vim.tbl_extend('force', { buffer = bufnr, noremap = true, silent = true }, opts or {})
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  print('LSP attached to buffer ' .. bufnr .. ': ' .. client.name)

  map('n', 'gd', vim.lsp.buf.definition, { desc = 'LSP Go to Definition' })
  map('n', 'gD', vim.lsp.buf.declaration, { desc = 'LSP Go to Declaration' })
  map('n', 'gr', vim.lsp.buf.references, { desc = 'LSP Go to References' })
  map('n', 'gi', vim.lsp.buf.implementation, { desc = 'LSP Go to Implementation' })
  map('n', 'H', vim.lsp.buf.hover, { desc = 'LSP Hover' })
  map('n', '<C-g>', vim.lsp.buf.signature_help, { desc = 'LSP Signature Help' })
  map('i', '<C-g>', vim.lsp.buf.signature_help, { desc = 'LSP Signature Help' })
  map('n', '<F2>', vim.lsp.buf.rename, { desc = 'LSP Rename' })
  map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { desc = 'LSP Code Action' })
  map('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, { desc = 'LSP Format Buffer' })
end

return {
  -- LSP Zero (LSP + Completion bundle)
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v4.x',
    dependencies = {
      { 'neovim/nvim-lspconfig' },
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },
      { 'hrsh7th/nvim-cmp' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-path' },
      { 'L3MON4D3/LuaSnip' },
    },
    config = function()
      local lsp_zero = require('lsp-zero')
      lsp_zero.extend_lspconfig()
      lsp_zero.on_attach(lsp_attach_callback)

      require('mason').setup {}
      require('mason-lspconfig').setup {
        ensure_installed = {
          'clangd', 'lua_ls', 'pylsp', 'terraformls', 'bashls',
          'jsonls', 'yamlls', 'dockerls', 'eslint', 'html',
          'cssls', 'rust_analyzer', 'gopls', 'marksman',
        },
        handlers = {
          lsp_zero.default_setup,
          lua_ls = function()
            local lua_opts = lsp_zero.nvim_lua_ls()
            require('lspconfig').lua_ls.setup(lua_opts)
          end,
        },
      }

      local cmp = require('cmp')
      local cmp_action = lsp_zero.cmp_action()

      cmp.setup {
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip', keyword_length = 2 },
          { name = 'buffer', keyword_length = 3 },
          { name = 'path' },
        },
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<CR>'] = cmp.mapping.confirm { select = false },
          ['<C-Space>'] = cmp.mapping.complete(),
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
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = lsp_zero.cmp_format(),
      }

      lsp_zero.format_on_save {
        format_opts = { async = false, timeout_ms = 10000 },
        servers = nil,
      }
    end,
    event = { 'BufReadPre', 'BufNewFile' },
  },

  -- Snippets Engine
  {
    'L3MON4D3/LuaSnip',
    version = 'v2.*',
    dependencies = { 'rafamadriz/friendly-snippets' },
    event = 'InsertEnter',
  },
}

