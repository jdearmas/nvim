-- ~/.config/nvim/lua/plugins/ai.lua
-- AI/LLM integration plugins

return {
  {
    "yetone/avante.nvim",
    cmd = { "AvanteAsk", "AvanteChat", "AvanteToggle" },
    keys = { { "<leader>aa", "<cmd>AvanteAsk<cr>", desc = "Avante Ask" } },
    version = false,
    build = vim.fn.has("win32") ~= 0
        and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
        or "make",
    opts = {
      provider = "claude",
      mode = "agentic",

      providers = {
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-sonnet-4-20250514",
          timeout = 30000,
          extra_request_body = {
            temperature = 0.75,
            max_tokens = 20480,
          },
        },
        ["claude-opus"] = {
          __inherited_from = "claude",
          model = "claude-opus-4-5-20251101",
          display_name = "claude-opus-4.5",
          timeout = 60000,
          extra_request_body = {
            temperature = 0.75,
            max_tokens = 20480,
          },
        },
      },

      behaviour = {
        auto_apply_diff_after_generation = true,
        auto_suggestions = false,
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_focus_sidebar = true,
        minimize_diff = true,
        enable_token_counting = true,
        support_paste_from_clipboard = true,
        auto_add_current_file = true,
        auto_approve_tool_permissions = true,
        confirmation_ui_style = "inline_buttons",
        acp_follow_agent_locations = true,
      },

      instructions_file = "AGENTS.md",
      ignore_patterns = { "%.git", "%.worktree", "__pycache__", "node_modules" },

      windows = {
        position = "right",
        wrap = true,
        width = 30,
        sidebar_header = {
          enabled = true,
          align = "center",
          rounded = true,
        },
        input = {
          prefix = "> ",
          height = 8,
        },
        ask = {
          floating = false,
          start_insert = true,
          border = "rounded",
          focus_on_apply = "ours",
        },
      },

      selector = {
        provider = "telescope",
      },

      input = {
        provider = "snacks",
      },

      diff = {
        autojump = true,
        override_timeoutlen = 500,
      },

      mappings = {
        diff = {
          ours = "co",
          theirs = "ct",
          all_theirs = "ca",
          both = "cb",
          cursor = "cc",
          next = "]x",
          prev = "[x",
        },
        submit = {
          normal = "<CR>",
          insert = "<C-s>",
        },
        sidebar = {
          apply_all = "A",
          apply_cursor = "a",
          switch_windows = "<Tab>",
          remove_file = "d",
          add_file = "@",
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
      "stevearc/dressing.nvim",
      "folke/snacks.nvim",
      "hrsh7th/nvim-cmp",
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = { insert_mode = true },
            use_absolute_path = true,
          },
        },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = { file_types = { "markdown", "Avante" } },
        ft = { "markdown", "Avante" },
      },
    },
  },
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    keys = {
      { "<leader>'",  nil,                              desc = "AI/Claude Code" },
      { "<leader>'c", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
      { "<leader>'f", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
      { "<leader>'r", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
      { "<leader>'C", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>'m", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>'b", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
      { "<leader>'s", "<cmd>ClaudeCodeSend<cr>",        mode = "v",                  desc = "Send to Claude" },
      {
        "<leader>'s",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      },
      -- Diff management
      { "<leader>'a", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>'d", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny diff" },
    },
  }
}
