-- ~/.config/nvim/lua/plugins/editor.lua
-- Editor enhancements

return {
  -- Terminal
  {
    'chomosuke/term-edit.nvim',
    version = '1.*',
    event = 'TermOpen',
    config = function()
      require('term-edit').setup { prompt_end = { '%$ ', '> ' } }
    end
  },

  {
    'voldikss/vim-floaterm',
    cmd = 'FloatermNew',
    config = function()
      vim.g.floaterm_width = 0.95
      vim.g.floaterm_height = 0.95
    end
  },

  { 'mtikekar/nvim-send-to-term', keys = { '<Plug>SendLine', '<Plug>Send' }, cmd = 'SendHere' },

  -- Autopairs
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
  },

  -- Motion
  {
    'smoka7/hop.nvim',
    version = "*",
    keys = {
      { 'f', function() require('hop').hint_words() end, mode = '', desc = "Hop words" },
      { 'F', function() require('hop').hint_char1({ direction = require('hop.hint').HintDirection.BEFORE_CURSOR, current_line_only = true }) end, mode = '', desc = "Hop char backward" },
      { 't', function() require('hop').hint_char1({ direction = require('hop.hint').HintDirection.AFTER_CURSOR, current_line_only = true, hint_offset = -1 }) end, mode = '', desc = "Hop till char forward" },
      { 'T', function() require('hop').hint_char1({ direction = require('hop.hint').HintDirection.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 }) end, mode = '', desc = "Hop till char backward" },
    },
    opts = {
      keys = 'etovxqpdygfblzhckisuran'
    }
  },

  -- Harpoon
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup({
        settings = {
          save_on_toggle = true,
          sync_on_ui_close = true,
          key = function()
            return "global"
          end,
        },
        default = {
          create_list_item = function(config, name)
            name = name or vim.fn.expand("%:p")
            return {
              value = name,
              context = {
                row = vim.api.nvim_win_get_cursor(0)[1],
                col = vim.api.nvim_win_get_cursor(0)[2],
              },
            }
          end,
        },
      })

      -- Quick select keymaps (non-leader, kept here for plugin context)
      vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end, { desc = "Harpoon 1" })
      vim.keymap.set("n", "<C-j>", function() harpoon:list():select(2) end, { desc = "Harpoon 2" })
      vim.keymap.set("n", "<C-k>", function() harpoon:list():select(3) end, { desc = "Harpoon 3" })
      vim.keymap.set("n", "<C-l>", function() harpoon:list():select(4) end, { desc = "Harpoon 4" })
      -- Leader keymaps are in config/keymaps.lua via which-key
    end,
  },

  -- Legendary (command palette)
  {
    'mrjones2014/legendary.nvim',
    keys = { { '<leader>ll', ':Legendary<CR>', desc = 'Open Legendary' } },
    cmd = 'Legendary',
    dependencies = { 'kkharji/sqlite.lua' },
    config = function()
      local file_path = vim.fn.stdpath('data') .. '/legendary-commands.json'

      local function load_commands()
        if vim.fn.filereadable(file_path) == 0 then return {} end
        local content = table.concat(vim.fn.readfile(file_path), '\n')
        local ok, data = pcall(vim.json.decode, content)
        return ok and data or {}
      end

      local function save_commands(cmds)
        vim.fn.writefile({ vim.json.encode(cmds) }, file_path)
      end

      local function get_visual_selection()
        vim.cmd('noau normal! "vy')
        return vim.fn.getreg('v')
      end

      local function add_command(cmd)
        cmd = cmd or get_visual_selection()
        cmd = vim.trim(cmd)
        if cmd == '' then return end

        vim.ui.input({ prompt = 'Description: ' }, function(desc)
          if not desc then return end
          local cmds = load_commands()
          table.insert(cmds, { cmd = cmd, desc = desc })
          save_commands(cmds)
          require('legendary').command({ ':' .. cmd:gsub('^:', ''), description = desc })
          vim.notify('Added: ' .. cmd, vim.log.levels.INFO)
        end)
      end

      local function delete_command()
        local cmds = load_commands()
        if #cmds == 0 then
          vim.notify('No saved commands', vim.log.levels.WARN)
          return
        end
        local items = {}
        for i, c in ipairs(cmds) do
          table.insert(items, string.format('%d. [%s] %s', i, c.desc, c.cmd))
        end
        vim.ui.select(items, { prompt = 'Delete command:' }, function(_, idx)
          if not idx then return end
          local removed = table.remove(cmds, idx)
          save_commands(cmds)
          vim.notify('Deleted: ' .. removed.cmd, vim.log.levels.INFO)
          vim.notify('Restart nvim to update Legendary', vim.log.levels.INFO)
        end)
      end

      -- Load saved commands
      local cmds = load_commands()
      for _, c in ipairs(cmds) do
        require('legendary').command({ ':' .. c.cmd:gsub('^:', ''), description = c.desc })
      end

      -- Register keymaps via which-key after it loads
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        once = true,
        callback = function()
          local ok, wk = pcall(require, "which-key")
          if ok then
            wk.add({
              { "<leader>la", add_command, desc = "Add to Legendary", mode = "v" },
              { "<leader>la", function()
                vim.ui.input({ prompt = 'Command: ' }, function(cmd)
                  if cmd then add_command(cmd) end
                end)
              end, desc = "Add to Legendary", mode = "n" },
              { "<leader>ld", delete_command, desc = "Delete from Legendary", mode = "n" },
            })
          end
        end,
      })
    end,
  },

  -- Utilities
  { 'tpope/vim-commentary', keys = { 'gc', 'gcc', { 'gc', mode = 'v' } } },
  { 'mbbill/undotree', cmd = 'UndotreeToggle' },
  { 'sbdchd/neoformat', cmd = 'Neoformat', event = 'BufWritePre' },
  { 'ptzz/lf.vim', cmd = 'Lf', dependencies = { 'voldikss/vim-floaterm' } },
  { 'mattn/emmet-vim', ft = { 'html', 'css', 'javascript', 'typescript', 'jsx', 'tsx' } },
  { 'tpope/vim-dispatch', cmd = { 'Dispatch', 'Make', 'Focus', 'Start' } },
  { 'jdearmas/vim-dispatch-neovim', dependencies = { 'tpope/vim-dispatch' }, cmd = 'Dispatch' },
}

