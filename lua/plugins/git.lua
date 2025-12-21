-- ~/.config/nvim/lua/plugins/git.lua
-- Git integration plugins

return {
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'nvim-telescope/telescope.nvim',
    },
    cmd = 'Neogit',
    config = true,
  },

  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles' },
    config = function()
      require('diffview').setup {
        enhanced_diff_hl = true,
        view = {
          merge_tool = {
            layout = "diff3_mixed",
          },
          file_panel = {
            listing_style = "tree",
            win_config = {
              position = "left",
              width = 50,
            },
          },
        },
      }
    end,
  },

  {
    "harrisoncramer/gitlab.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "stevearc/dressing.nvim",
      "nvim-tree/nvim-web-devicons",
      "folke/which-key.nvim",
    },
    build = function()
      require("gitlab.server").build(true)
    end,
    keys = { { "<leader>gl", desc = "+GitLab" } },
    config = function()
      require("diffview")
      local gitlab = require("gitlab")
      gitlab.setup({
        keymaps = {
          global = { disable_all = true },
          help = "?",
          popup = {
            next_field = "<Tab>",
            prev_field = "<S-Tab>",
            perform_action = "<CR>",
            perform_linewise_action = "<C-CR>",
            discard_changes = "q",
          },
          discussion_tree = {
            toggle_node = "<CR>",
            toggle_all_discussions = "za",
            toggle_resolved_discussions = "zr",
            toggle_unresolved_discussions = "zu",
            jump_to_file = "gf",
            jump_to_reviewer = "gd",
            open_in_browser = "gx",
            copy_node_url = "yu",
            reply = "r",
            edit_comment = "e",
            delete_comment = "dd",
            toggle_resolved = "<Space>",
            publish_draft = "P",
            add_emoji = "+",
            delete_emoji = "-",
            switch_view = "<C-n>",
            toggle_tree_type = "<C-t>",
            toggle_draft_mode = "<C-d>",
            toggle_date_format = "<C-f>",
            toggle_sort_method = "<C-s>",
            refresh_data = "R",
            print_node = "<leader>p",
          },
          reviewer = {
            create_comment = "gc",
            create_suggestion = "gs",
            move_to_discussion_tree = "gD",
          },
        },
        discussion_tree = {
          auto_open = true,
          default_view = "discussions",
          position = "bottom",
          size = "20%",
        },
      })

      local wk = require("which-key")
      wk.add({
        { "<leader>gl", group = "GitLab" },
        { "<leader>glc", gitlab.choose_merge_request, desc = "Choose MR" },
        { "<leader>glC", gitlab.create_mr, desc = "Create MR" },
        { "<leader>gls", gitlab.summary, desc = "Summary" },
        { "<leader>glS", gitlab.review, desc = "Start Review" },
        { "<leader>glM", gitlab.merge, desc = "Merge" },
        { "<leader>glA", gitlab.approve, desc = "Approve" },
        { "<leader>glR", gitlab.revoke, desc = "Revoke Approval" },
        { "<leader>gld", gitlab.toggle_discussions, desc = "Toggle Discussions" },
        { "<leader>gln", gitlab.create_note, desc = "Create Note" },
        { "<leader>glD", gitlab.toggle_draft_mode, desc = "Toggle Draft Mode" },
        { "<leader>glP", gitlab.publish_all_drafts, desc = "Publish All Drafts" },
        { "<leader>glp", gitlab.pipeline, desc = "Pipeline" },
        { "<leader>gla", group = "Assignees" },
        { "<leader>glaa", gitlab.add_assignee, desc = "Add" },
        { "<leader>glad", gitlab.delete_assignee, desc = "Remove" },
        { "<leader>glr", group = "Reviewers" },
        { "<leader>glra", gitlab.add_reviewer, desc = "Add" },
        { "<leader>glrd", gitlab.delete_reviewer, desc = "Remove" },
        { "<leader>gll", group = "Labels" },
        { "<leader>glla", gitlab.add_label, desc = "Add" },
        { "<leader>glld", gitlab.delete_label, desc = "Remove" },
        { "<leader>glo", gitlab.open_in_browser, desc = "Open in Browser" },
        { "<leader>gly", gitlab.copy_mr_url, desc = "Copy URL" },
      })
    end,
  },
}

