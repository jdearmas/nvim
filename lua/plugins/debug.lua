-- ~/.config/nvim/lua/plugins/debug.lua
-- Debug Adapter Protocol (DAP) configuration

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
          require("mason-nvim-dap").setup({
            ensure_installed = { "codelldb" },
            handlers = {},
          })
        end,
      },
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        config = function()
          require("dapui").setup()
        end,
      },
      { "theHamsta/nvim-dap-virtual-text", opts = {} },
    },

    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Load paths from local config
      local ok, paths = pcall(require, "local.dap_paths")
      if not ok then
        vim.notify("DAP: lua/local/dap_paths.lua not found. Copy from dap_paths.lua.example", vim.log.levels.WARN)
        paths = { project_root = vim.fn.getcwd(), python_path = "python", pythonpath_dirs = {} }
      end
      local PROJECT_ROOT = paths.project_root
      local PYTHON_PATH = paths.python_path
      local PYTHONPATH = table.concat(paths.pythonpath_dirs or {}, ":")

      -- Python adapter
      dap.adapters.python = function(cb, config)
        if config.request == "attach" then
          local port = (config.connect or config).port
          local host = (config.connect or config).host or "127.0.0.1"
          cb({
            type = "server",
            port = assert(port, "`connect.port` is required"),
            host = host,
            options = { source_filetype = "python" },
          })
        else
          cb({
            type = "executable",
            command = PYTHON_PATH,
            args = { "-m", "debugpy.adapter" },
            options = { source_filetype = "python" },
          })
        end
      end

      -- Python configurations
      dap.configurations.python = {
        {
          name = "Launch current file",
          type = "python",
          request = "launch",
          program = "${file}",
          console = "integratedTerminal",
          pythonPath = PYTHON_PATH,
          cwd = PROJECT_ROOT,
          justMyCode = false,
          stopOnEntry = false,
          env = { PYTHONPATH = PYTHONPATH },
        },
        {
          name = "Launch file (stop on entry)",
          type = "python",
          request = "launch",
          program = "${file}",
          console = "integratedTerminal",
          pythonPath = PYTHON_PATH,
          cwd = PROJECT_ROOT,
          justMyCode = false,
          stopOnEntry = true,
          env = { PYTHONPATH = PYTHONPATH },
        },
        {
          name = "Launch file with arguments",
          type = "python",
          request = "launch",
          program = "${file}",
          args = function()
            local input = vim.fn.input("Arguments: ")
            return vim.split(input, " +")
          end,
          console = "integratedTerminal",
          pythonPath = PYTHON_PATH,
          cwd = PROJECT_ROOT,
          justMyCode = false,
          env = { PYTHONPATH = PYTHONPATH },
        },
        {
          name = "Core: Launch core.main",
          type = "python",
          request = "launch",
          module = "core.main",
          console = "integratedTerminal",
          pythonPath = PYTHON_PATH,
          cwd = PROJECT_ROOT,
          justMyCode = false,
          env = { PYTHONPATH = PYTHONPATH },
          args = function()
            local input = vim.fn.input("Arguments (e.g., -d /path/to/deps): ")
            if input == "" then return {} end
            return vim.split(input, " +")
          end,
        },
        {
          name = "Pytest: Current file",
          type = "python",
          request = "launch",
          module = "pytest",
          args = { "${file}", "-sv" },
          console = "integratedTerminal",
          pythonPath = PYTHON_PATH,
          cwd = PROJECT_ROOT,
          justMyCode = false,
          env = { PYTHONPATH = PYTHONPATH },
        },
        {
          name = "Pytest: Current function",
          type = "python",
          request = "launch",
          module = "pytest",
          args = function()
            local file = vim.fn.expand("%:p")
            local line = vim.fn.line(".")
            local test_name = nil
            for i = line, 1, -1 do
              local match = vim.fn.getline(i):match("def (test_[%w_]+)")
              if match then
                test_name = match
                break
              end
            end
            if test_name then
              return { file .. "::" .. test_name, "-sv" }
            end
            return { file, "-sv" }
          end,
          console = "integratedTerminal",
          pythonPath = PYTHON_PATH,
          cwd = PROJECT_ROOT,
          justMyCode = false,
          env = { PYTHONPATH = PYTHONPATH },
        },
        {
          name = "Pytest: Specific path",
          type = "python",
          request = "launch",
          module = "pytest",
          args = function()
            local input = vim.fn.input("Test path: ")
            local args = vim.split(input, " +")
            table.insert(args, "-sv")
            return args
          end,
          console = "integratedTerminal",
          pythonPath = PYTHON_PATH,
          cwd = PROJECT_ROOT,
          justMyCode = false,
          env = { PYTHONPATH = PYTHONPATH },
        },
        {
          name = "Module: Run with -m",
          type = "python",
          request = "launch",
          module = function()
            return vim.fn.input("Module name: ")
          end,
          console = "integratedTerminal",
          pythonPath = PYTHON_PATH,
          cwd = PROJECT_ROOT,
          justMyCode = false,
          env = { PYTHONPATH = PYTHONPATH },
        },
        {
          name = "Attach: localhost:5678",
          type = "python",
          request = "attach",
          connect = { host = "127.0.0.1", port = 5678 },
          pathMappings = {
            { localRoot = PROJECT_ROOT, remoteRoot = PROJECT_ROOT },
          },
          justMyCode = false,
        },
      }

      -- Tab-local session keymaps
      local debug_tab = nil

      local function in_debug_tab()
        return debug_tab ~= nil and vim.api.nvim_get_current_tabpage() == debug_tab
      end

      local function make_debug_keymap(key, fn)
        return function()
          if in_debug_tab() then
            fn()
          else
            local escaped = vim.api.nvim_replace_termcodes(key, true, false, true)
            vim.api.nvim_feedkeys(escaped, "n", false)
          end
        end
      end

      local debug_keys = {
        { "c", dap.continue, "Continue" },
        { "o", dap.step_over, "Step Over" },
        { "i", dap.step_into, "Step Into" },
        { "u", dap.step_out, "Step Out" },
        { "b", dap.toggle_breakpoint, "Toggle Breakpoint" },
        { "r", dap.run_to_cursor, "Run to Cursor" },
        { "R", dap.restart, "Restart" },
        { "q", dap.terminate, "Quit/Terminate" },
      }

      local function set_session_keymaps()
        debug_tab = vim.api.nvim_get_current_tabpage()
        for _, map in ipairs(debug_keys) do
          vim.keymap.set("n", map[1], make_debug_keymap(map[1], map[2]), {
            desc = "DAP: " .. map[3],
            silent = true,
            nowait = true,
          })
        end
        vim.keymap.set("n", "K", function()
          if in_debug_tab() then
            require("dap.ui.widgets").hover()
          else
            vim.lsp.buf.hover()
          end
        end, { desc = "DAP: Hover / LSP Hover", silent = true })
        vim.keymap.set("n", "Q", function()
          if in_debug_tab() then
            dap.terminate()
            dapui.close()
          end
        end, { desc = "DAP: Quit & Close", silent = true })

        vim.notify("DAP [tab " .. debug_tab .. "]: c=cont o=over i=into u=out b=bp r=cursor q=quit", vim.log.levels.INFO)
      end

      local function del_session_keymaps()
        debug_tab = nil
        for _, map in ipairs(debug_keys) do
          pcall(vim.keymap.del, "n", map[1])
        end
        pcall(vim.keymap.del, "n", "K")
        pcall(vim.keymap.del, "n", "Q")
      end

      -- UI Listeners
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
        set_session_keymaps()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        del_session_keymaps()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        del_session_keymaps()
        dapui.close()
      end

      -- Global keymaps
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Condition: "))
      end, { desc = "Debug: Conditional Breakpoint" })
      vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debug: Start/Continue" })
      vim.keymap.set("n", "<leader>dr", dapui.toggle, { desc = "Debug: Toggle UI" })
      vim.keymap.set("n", "<leader>dR", dap.run_last, { desc = "Debug: Run Last" })
      vim.keymap.set("n", "<leader>dk", dap.terminate, { desc = "Debug: Terminate" })
    end,
  },
}

