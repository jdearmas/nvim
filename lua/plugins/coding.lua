-- ~/.config/nvim/lua/plugins/coding.lua
-- Language-specific plugins

return {
  -- Rust
  { 'mrcjkb/rustaceanvim' },

  -- Go
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {},
    config = function(_, opts)
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
    event = { "CmdlineEnter" },
    ft = { "go", 'gomod' },
    build = ':lua require("go.install").update_all_sync()'
  },

  -- Conform (formatting)
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "[F]ormat buffer",
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_fallback = true }
      end,
      formatters_by_ft = {
        python = { "ruff_format", "ruff_fix" },
      },
      formatters = {
        ruff_format = {
          command = "uv",
          args = { "run", "ruff", "format", "-" },
          stdin = true,
        },
        ruff_fix = {
          command = "uv",
          args = { "run", "ruff", "check", "--fix", "-" },
          stdin = true,
        },
      },
    },
  },
}

