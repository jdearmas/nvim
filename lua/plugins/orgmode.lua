-- ~/.config/nvim/lua/plugins/orgmode.lua
-- Orgmode configuration

return {
  {
    "nvim-orgmode/telescope-orgmode.nvim",
    dependencies = {
      "nvim-orgmode/orgmode",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("telescope").load_extension("orgmode")

      vim.keymap.set("n", "<leader>fh", require("telescope").extensions.orgmode.search_headings)
      vim.keymap.set("n", "<leader>li", require("telescope").extensions.orgmode.insert_link)
      vim.keymap.set("n", "<Leader>ofc", function()
        require('telescope').extensions.orgmode.search_headings({ only_current_file = true })
      end, { desc = "Find headlines in current file" })
    end,
  },

  {
    'nvim-orgmode/orgmode',
    lazy = true,
    ft = 'org',
    opts = {
      org_agenda_files = { '~/org/*', '~/orgs/**/*' },
      org_default_notes_file = '~/org/todo.org',
      org_todo_keywords = { 'TODO', 'IN-PROGRESS', 'BLOCKED', '|', 'DONE', 'FAILED' },
      org_capture_templates = {
        p = {
          description = 'New Project Directory',
          target =
          '%(local name = vim.fn.input("Enter Project Directory Name: "); if name == nil or name == "" then print("Capture aborted."); return "" end; local base_path = "~/org"; local project_dir = vim.fn.expand(base_path) .. "/" .. name; vim.fn.mkdir(project_dir, "p"); return project_dir .. "/index.org")',
          template = '#+TITLE: %^{Title}\n#+AUTHOR: %n\n\n* TASKS\n** TODO %?',
        },
      },
    },
    config = function(_, opts)
      local api = vim.api
      local uv = vim.loop

      -- Stopwatch state
      local state = {
        buf = nil,
        timer = nil,
        org_clock_start_hr = nil,
        org_clock_header = nil,
        header_line = nil,
        win = nil,
        pos = 'top',
      }

      local function get_buffer()
        if state.buf and api.nvim_buf_is_valid(state.buf) then
          return state.buf
        end
        state.buf = api.nvim_create_buf(true, true)
        api.nvim_buf_set_name(state.buf, 'OrgStopwatch')
        return state.buf
      end

      local function create_win()
        if state.win and api.nvim_win_is_valid(state.win) then return end
        local buf = get_buffer()
        local width, height = 60, 1
        local ui = api.nvim_list_uis()[1]
        local row = (state.pos == 'bottom') and (ui.height - height - 1) or 1
        local col = math.floor((ui.width - width) / 2)
        state.win = api.nvim_open_win(buf, false, {
          relative = 'editor',
          width = width,
          height = height,
          row = row,
          col = col,
          style = 'minimal',
          border = 'rounded',
          focusable = false,
          zindex = 50,
        })
      end

      local function close_win()
        if state.win and api.nvim_win_is_valid(state.win) then
          api.nvim_win_close(state.win, true)
        end
        state.win = nil
      end

      local function format_elapsed_ns(ns)
        local total_ms = ns / 1e6
        local ms = math.floor(total_ms % 1000)
        local total_s = math.floor(total_ms / 1000)
        local s = total_s % 60
        local m = math.floor((total_s % 3600) / 60)
        local h = math.floor(total_s / 3600)
        if h > 0 then
          return string.format('%d:%02d:%02d.%03d', h, m, s, ms)
        else
          return string.format('%02d:%02d.%03d', m, s, ms)
        end
      end

      local function ensure_float()
        if state.timer and (not state.win or not api.nvim_win_is_valid(state.win)) then
          create_win()
        end
      end

      local function toggle_position()
        state.pos = (state.pos == 'top') and 'bottom' or 'top'
        if state.timer then
          close_win()
          create_win()
        end
      end

      local function removeTODO(s)
        return s:gsub("^%s*TODO%s*", "")
      end

      local function clock_in_and_start()
        require('orgmode').action('clock.org_clock_in')
        vim.schedule(function()
          local lines = api.nvim_buf_get_lines(0, 0, -1, false)
          state.header_line = nil
          for idx, ln in ipairs(lines) do
            local y, mo, d, HH, MM = ln:match('CLOCK:%s*%[(%d+)%-(%d+)%-(%d+) [^ ]+ (%d+):(%d+)%]')
            if y and not ln:find('%-%-') then
              local ts = os.time {
                year = tonumber(y), month = tonumber(mo), day = tonumber(d),
                hour = tonumber(HH), min = tonumber(MM), sec = 0,
              }
              local now_hr = uv.hrtime()
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
            state.timer:stop()
            state.timer:close()
          end
          create_win()
          state.timer = uv.new_timer()
          state.timer:start(0, 100, vim.schedule_wrap(function()
            if not state.org_clock_start_hr then return end
            local elapsed_ns = uv.hrtime() - state.org_clock_start_hr
            local txt = string.format('%s | %s', format_elapsed_ns(elapsed_ns), state.org_clock_header or '')
            local buf = get_buffer()
            if api.nvim_buf_is_valid(buf) then
              api.nvim_buf_set_lines(buf, 0, -1, false, { txt })
            end
          end))
        end)
      end

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
          state.timer:stop()
          state.timer:close()
          state.timer = nil
          vim.defer_fn(function()
            close_win()
            state.org_clock_start_hr = nil
            state.org_clock_header = nil
            state.header_line = nil
          end, 2000)
        end
      end

      require('orgmode').setup(opts)

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'org',
        callback = function()
          vim.keymap.set('n', '<Space>oxi', clock_in_and_start, { buffer = true })
          vim.keymap.set('n', '<Space>oxo', clock_out_and_stop, { buffer = true })
          vim.keymap.set('n', '<Space>oxt', toggle_position, { buffer = true, desc = 'Toggle stopwatch position' })
        end,
      })

      vim.api.nvim_create_autocmd({ 'WinEnter', 'TabEnter', 'VimResized', 'WinClosed' }, {
        callback = vim.schedule_wrap(ensure_float),
      })
    end,
  },
}

