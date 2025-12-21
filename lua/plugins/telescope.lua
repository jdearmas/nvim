-- ~/.config/nvim/lua/plugins/telescope.lua
-- Telescope and fuzzy finding

return {
  {
    "MattesGroeger/vim-bookmarks",
    keys = { 'mm', 'mi', 'mn', 'mp', 'ma', 'mc', 'mx' },
    cmd = { 'BookmarkToggle', 'BookmarkAnnotate', 'BookmarkShowAll' },
    config = function()
      vim.g.bookmark_sign = "⚑"
      vim.g.bookmark_highlight_lines = 1
    end,
  },

  { "tom-anders/telescope-vim-bookmarks.nvim", lazy = true },

  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      'nvim-telescope/telescope-media-files.nvim',
      'MattesGroeger/vim-bookmarks',
      { 'amiroslaw/telescope-jumps.nvim' },
    },
    keys = {
      {
        "<leader>ft",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find({
            prompt_title = "🔍 Buffer Search",
            initial_mode = "insert",
            default_text = "* ",
          })
        end,
        desc = "Fuzzy search in current buffer",
      },
      {
        "<leader>fb",
        function()
          require("telescope.builtin").buffers({
            sort_lastused = true,
            ignore_current_buffer = true,
            show_all_buffers = true,
            previewer = true,
          })
        end,
        desc = "Buffers (with preview)",
      },
    },
    config = function()
      local telescope = require 'telescope'
      telescope.load_extension('jumps')
      local actions = require('telescope.actions')
      local action_layout = require('telescope.actions.layout')

      telescope.setup {
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
            preview_cutoff = 1,
          },
          sorting_strategy = 'ascending',
          file_ignore_patterns = { 'node_modules', '.git' },
          path_display = { 'truncate' },
          mappings = {
            i = {
              ['<C-n>'] = actions.move_selection_next,
              ['<C-p>'] = actions.move_selection_previous,
              ['<C-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
              ['<Down>'] = actions.move_selection_next,
              ['<Up>'] = actions.move_selection_previous,
              ['<esc>'] = actions.close,
              ['<M-p>'] = action_layout.toggle_preview,
            },
            n = {
              ['<M-p>'] = action_layout.toggle_preview,
            },
          },
        },
        pickers = {
          buffers = {
            sort_lastused = true,
            ignore_current_buffer = true,
            show_all_buffers = true,
            previewer = true,
            mappings = {
              i = {
                ["<CR>"] = actions.select_horizontal,
                ["<C-o>"] = actions.select_default,
              },
              n = {
                ["<CR>"] = actions.select_horizontal,
                ["<C-o>"] = actions.select_default,
              },
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
          },
          media_files = {},
        },
      }

      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'media_files')
      pcall(telescope.load_extension, 'vim_bookmarks')
    end,
  },

  { 'junegunn/fzf', build = './install --bin', lazy = true },
  {
    'junegunn/fzf.vim',
    cmd = { 'FZF', 'Files', 'Buffers', 'Lines', 'BLines', 'Tags', 'BTags', 'Commits', 'BCommits', 'History', 'Snippets', 'Commands' },
    dependencies = { 'junegunn/fzf' },
  },
}

