-- ~/.config/nvim/lua/config/keymaps.lua
-- All keybindings using which-key for leader mappings

local fn = require('config.functions')

-- ============================================================================
-- Non-leader mappings (immediate, no popup needed)
-- ============================================================================

local map = vim.keymap.set

-- Disable space in normal/visual (leader key)
map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Page navigation with j/k (without count)
map('n', 'j', 'v:count > 0 ? "j" : "<C-f>"', { expr = true, silent = true, desc = "Down / PageDown" })
map('n', 'k', 'v:count > 0 ? "k" : "<C-b>"', { expr = true, silent = true, desc = "Up / PageUp" })

-- Center screen on navigation
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
map("n", "n", "nzzzv", { desc = "Next search (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev search (centered)" })

-- Previous buffer
map('n', '<BS>', ':bp<CR>', { silent = true, desc = "Previous buffer" })

-- Equalize windows
map('n', '7', '<C-w>=', { desc = 'Equalize window sizes' })

-- Tab navigation
map('n', ']t', ':tabnext<CR>', { silent = true, desc = 'Next Tab' })
map('n', '[t', ':tabprevious<CR>', { silent = true, desc = 'Previous Tab' })

-- Diagnostic navigation
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
map('n', '<C-e>', vim.diagnostic.open_float, { desc = 'Diagnostic float' })

-- Dispatch
map('n', 'r', ':Dispatch<CR>', { silent = true, desc = "Run Dispatch" })

-- Set makeprg from line
map('n', ';', fn.process_and_set_makeprg, { silent = true, desc = "Set makeprg from line" })

-- Send line to terminal
map('n', 's', '<Plug>SendLine', { desc = "Send line to terminal" })

-- Go to file (create if needed)
map('n', 'gf', fn.goto_or_create, { silent = true, desc = "Go to file (create if missing)" })

-- Fine cmdline
map('n', '<CR>', '<cmd>FineCmdline<CR>', { desc = "Command line" })

-- Escape from insert
map('i', 'jk', '<esc>', { silent = true, desc = "Escape" })

-- File rename
map('n', 'F', ':f ', { desc = "Rename buffer" })

-- Visual mode: fold except selection
map('v', 'a', fn.fold_except_selection, { desc = "Fold except selection", silent = true })

-- ============================================================================
-- Which-key leader mappings
-- ============================================================================

local function setup_which_key()
  local wk = require("which-key")

  wk.add({
    -- ========================================================================
    -- Top-level leader mappings
    -- ========================================================================
    { "<leader><leader>", ":w!<CR>", desc = "Save file", mode = "n" },
    { "<leader>b", ":Telescope buffers<CR>", desc = "Buffers", mode = "n" },
    { "<leader>c", ":close<CR>", desc = "Close window", mode = "n" },
    { "<leader>e", ":edit $MYVIMRC<CR>", desc = "Edit config", mode = "n" },
    { "<leader>i", ":new | terminal<CR>", desc = "New terminal", mode = "n" },
    { "<leader>m", ":NoNeckPain<CR>", desc = "Toggle NoNeckPain", mode = "n" },
    { "<leader>r", ":only<CR>", desc = "Close other windows", mode = "n" },
    { "<leader>u", ":Lf<CR>", desc = "File manager (Lf)", mode = "n" },
    { "<leader>x", ":SendHere<CR>", desc = "Send to terminal", mode = "n" },
    { "<leader>=", ":%!jq .<CR>", desc = "Format JSON (jq)", mode = "n" },
    { "<leader>:", "<cmd>Telescope command_history<CR>", desc = "Command history", mode = "n" },

    -- Quick actions
    { "<leader>D", ":bd!<CR>", desc = "Force delete buffer", mode = "n" },
    { "<leader>E", ":OverseerToggle<CR>", desc = "Toggle Overseer", mode = "n" },
    { "<leader>G", function()
      require("orgmode").action("org_mappings.insert_todo_heading_respect_content")
      require("orgmode").action("org_mappings.do_demote")
    end, desc = "Org: Insert TODO heading", mode = "n" },
    { "<leader>O", fn.pipe_messages_to_buffer, desc = "Messages to buffer", mode = "n" },
    { "<leader>Q", fn.close_undisplayed_buffers, desc = "Close hidden buffers", mode = "n" },
    { "<leader>S", fn.save_quickfix_to_file, desc = "Save quickfix to file", mode = "n" },
    { "<leader>T", ":OverseerRun<CR>", desc = "Run Overseer task", mode = "n" },
    { "<leader>U", ":UndotreeToggle<CR>", desc = "Toggle Undotree", mode = "n" },

    -- ========================================================================
    -- Window management: <leader>w, <leader>s, <leader>v, <leader>hjkl
    -- ========================================================================
    { "<leader>s", ":split<CR>", desc = "Horizontal split", mode = "n" },
    { "<leader>v", ":vsplit<CR>", desc = "Vertical split", mode = "n" },
    { "<leader>w", ":lua require('nvim-window').pick()<CR>", desc = "Pick window", mode = "n" },
    { "<leader>h", "<C-w>h", desc = "Window left", mode = "n" },
    { "<leader>j", "<C-w>j", desc = "Window down", mode = "n" },
    { "<leader>k", "<C-w>k", desc = "Window up", mode = "n" },
    { "<leader>l", "<C-w>l", desc = "Window right", mode = "n" },

    -- ========================================================================
    -- Tabs: <leader>t
    -- ========================================================================
    { "<leader>t", group = "Tabs" },
    { "<leader>tn", ":tabnew<CR>", desc = "New tab", mode = "n" },
    { "<leader>tc", ":tabclose<CR>", desc = "Close tab", mode = "n" },
    { "<leader>to", ":tabonly<CR>", desc = "Close other tabs", mode = "n" },
    { "<leader>tr", ":TabooRename ", desc = "Rename tab", mode = "n" },
    { "<leader>tt", fn.toggle_diagnostics, desc = "Toggle diagnostics", mode = "n" },

    -- ========================================================================
    -- Find/Telescope: <leader>f
    -- ========================================================================
    { "<leader>f", group = "Find" },
    { "<leader>fb", function()
      require("telescope.builtin").buffers({
        sort_lastused = true,
        ignore_current_buffer = true,
        show_all_buffers = true,
      })
    end, desc = "Buffers", mode = "n" },
    { "<leader>fc", ":Rg<CR>", desc = "Ripgrep (fzf)", mode = "n" },
    { "<leader>ff", ":Telescope find_files<CR>", desc = "Files", mode = "n" },
    { "<leader>fg", ":Telescope live_grep<CR>", desc = "Live grep", mode = "n" },
    { "<leader>fh", ":Telescope help_tags<CR>", desc = "Help tags", mode = "n" },
    { "<leader>fj", ":Telescope jumps changes<CR>", desc = "Jumps & changes", mode = "n" },
    { "<leader>fl", ":Telescope lsp_document_symbols<CR>", desc = "LSP symbols (doc)", mode = "n" },
    { "<leader>fL", ":Telescope lsp_workspace_symbols<CR>", desc = "LSP symbols (workspace)", mode = "n" },
    { "<leader>fo", ":Telescope oldfiles<CR>", desc = "Recent files", mode = "n" },
    { "<leader>ft", function()
      require("telescope.builtin").current_buffer_fuzzy_find({
        prompt_title = "🔍 Buffer Search",
        default_text = "* ",
      })
    end, desc = "Fuzzy find in buffer", mode = "n" },
    { "<leader>fz", ":FZF<CR>", desc = "FZF", mode = "n" },

    -- ========================================================================
    -- Git: <leader>g
    -- ========================================================================
    { "<leader>g", group = "Git" },
    { "<leader>gb", ":Telescope current_buffer_fuzzy_find<CR>", desc = "Buffer fuzzy find", mode = "n" },
    { "<leader>gc", ":Telescope git_commits<CR>", desc = "Commits", mode = "n" },
    { "<leader>gd", ":DiffviewOpen<CR>", desc = "Diffview open", mode = "n" },
    { "<leader>gD", ":DiffviewClose<CR>", desc = "Diffview close", mode = "n" },
    { "<leader>gh", ":Telescope git_status<CR>", desc = "Status", mode = "n" },
    { "<leader>gj", ":Telescope jumplist<CR>", desc = "Jumplist", mode = "n" },
    { "<leader>gk", function()
      local base = vim.fn.system("git config neogit.baseBranch"):gsub("%s+", "")
      if base == "" then base = "origin/develop" end
      vim.cmd("DiffviewOpen " .. base .. "...HEAD")
    end, desc = "Diff vs base (commits)", mode = "n" },
    { "<leader>gK", function()
      local base = vim.fn.system("git config neogit.baseBranch"):gsub("%s+", "")
      if base == "" then base = "origin/develop" end
      vim.cmd("DiffviewOpen " .. base)
    end, desc = "Diff vs base (all)", mode = "n" },
    { "<leader>go", ":Telescope vim_bookmarks all<CR>", desc = "Bookmarks", mode = "n" },
    { "<leader>gs", ":Neogit<CR>", desc = "Neogit", mode = "n" },

    -- ========================================================================
    -- Diagnostics: <leader>d
    -- ========================================================================
    { "<leader>d", group = "Diagnostics/Delete" },
    { "<leader>dl", vim.diagnostic.open_float, desc = "Open float", mode = "n" },
    { "<leader>dq", vim.diagnostic.setloclist, desc = "Set loclist", mode = "n" },

    -- Delete to void register
    { "<leader>d", [["_d]], desc = "Delete (void)", mode = { "n", "v" } },

    -- ========================================================================
    -- Yank/Paste: <leader>y, <leader>p
    -- ========================================================================
    { "<leader>y", '"+y', desc = "Yank to clipboard", mode = { "n", "v" } },
    { "<leader>Y", '"+Y', desc = "Yank line to clipboard", mode = "n" },
    { "<leader>p", group = "Paste" },
    { "<leader>pp", fn.copy_full_path_to_clipboard, desc = "Copy file path:line", mode = "n" },
    { "<leader>p", '"_dP', desc = "Paste (keep register)", mode = "x" },

    -- ========================================================================
    -- Org: <leader>o
    -- ========================================================================
    { "<leader>o", group = "Org/Output" },
    { "<leader>oa", ':lua require("orgmode").action("org_agenda")<CR>', desc = "Agenda", mode = "n" },
    { "<leader>oc", ':lua require("orgmode").action("org_capture")<CR>', desc = "Capture", mode = "n" },
    { "<leader>oh", function()
      fn.org_heading_to_tmp_and_run({
        dir = "~/public",
        ext = ".org",
        cmd = { "python3", "~/upload.py" },
      })
    end, desc = "Heading → upload", mode = "n" },
    { "<leader>om", fn.pipe_messages_to_buffer, desc = "Messages to buffer", mode = "n" },
    { "<leader>oM", ":messages<CR>", desc = "Show messages", mode = "n" },
    { "<leader>ot", fn.create_c_template, desc = "Create C template", mode = "n" },
    { "<leader>ou", ":AerialNavToggle<CR>", desc = "Aerial toggle", mode = "n" },
    { "<leader>ofc", function()
      require('telescope').extensions.orgmode.search_headings({ only_current_file = true })
    end, desc = "Search headings (file)", mode = "n" },

    -- Visual mode org
    { "<leader>o", fn.surround_visual_with_org_block, desc = "Surround with org block", mode = "v" },
    { "<leader>O", fn.surround_visual_with_example_org_block, desc = "Surround with example block", mode = "v" },
    { "<leader>B", fn.surround_visual_with_bash_org_block, desc = "Surround with bash block", mode = "v" },

    -- ========================================================================
    -- Zen/Focus: <leader>z
    -- ========================================================================
    { "<leader>z", group = "Zen" },
    { "<leader>za", ":TZAtaraxis<CR>", desc = "Ataraxis", mode = "n" },
    { "<leader>zf", ":TZFocus<CR>", desc = "Focus", mode = "n" },
    { "<leader>zm", ":TZMinimalist<CR>", desc = "Minimalist", mode = "n" },
    { "<leader>zn", ":TZNarrow<CR>", desc = "Narrow", mode = "n" },
    { "<leader>zn", ":'<,'>TZNarrow<CR>", desc = "Narrow selection", mode = "v" },
    { "<leader>zz", function()
      local ataraxis = require("true-zen.ataraxis")
      local minimalist = require("true-zen.minimalist")
      local narrow = require("true-zen.narrow")
      local focus = require("true-zen.focus")
      if ataraxis.running then ataraxis.off() end
      if minimalist.running then minimalist.off() end
      if vim.b.tz_narrowed_buffer then narrow.off() end
      if focus.running then focus.off() end
    end, desc = "Exit all zen modes", mode = "n" },

    -- ========================================================================
    -- Legendary: <leader>l
    -- ========================================================================
    { "<leader>l", group = "Legendary/Lua" },
    { "<leader>ll", ":Legendary<CR>", desc = "Open Legendary", mode = "n" },
    { "<leader>lr", ":luafile %<CR>", desc = "Reload lua file", mode = "n" },

    -- ========================================================================
    -- Quote prefix: <leader>'
    -- ========================================================================
    { "<leader>'", group = "Misc" },
    { "<leader>''", fn.toggle_quickfix, desc = "Toggle quickfix", mode = "n" },
    { "<leader>'a", function()
      local overseer = require("overseer")
      local tasks = overseer.list_tasks({})
      if #tasks == 0 then
        vim.notify("No tasks", vim.log.levels.INFO)
        return
      end
      vim.ui.select(tasks, {
        prompt = "Overseer Tasks",
        format_item = function(task)
          return string.format("[%s] %s", task.status, task.name)
        end,
      }, function(task)
        if task then task:open_output() end
      end)
    end, desc = "Select Overseer task", mode = "n" },
    { "<leader>'h", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon menu", mode = "n" },
    { "<leader>'r", function()
      vim.cmd("source $MYVIMRC")
      print("Config reloaded!")
    end, desc = "Reload config", mode = "n" },

    -- ========================================================================
    -- Makeprg: <leader>m (visual)
    -- ========================================================================
    { "<leader>m", fn.set_makeprg_from_visual_selection, desc = "Set makeprg from selection", mode = "v" },

    -- ========================================================================
    -- Harpoon quick marks: <leader>1
    -- ========================================================================
    { "<leader>1", function() require("harpoon"):list():add() end, desc = "Harpoon add", mode = "n" },
  })
end

-- Register which-key mappings after plugin loads
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    pcall(setup_which_key)
  end,
})

-- ============================================================================
-- User commands
-- ============================================================================

vim.api.nvim_create_user_command('Nr', function(opts_cmd)
  vim.cmd('new')
  vim.cmd('r! ' .. opts_cmd.args)
end, { nargs = '+' })
