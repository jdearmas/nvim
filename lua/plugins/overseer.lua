-- ~/.config/nvim/lua/plugins/overseer.lua
-- Task runner configuration

return {
  {
    "stevearc/overseer.nvim",
    dependencies = { "folke/snacks.nvim" },
    cmd = { "OverseerRun", "OverseerToggle", "OverseerTaskAction" },
    keys = {
      {
        "Q",
        function()
          local tasks = require("overseer").list_tasks()
          if #tasks == 0 then
            vim.notify("No tasks found", vim.log.levels.WARN)
            return
          end

          local items = {}
          for i, task in ipairs(tasks) do
            table.insert(items, {
              idx = i,
              score = i,
              text = task.name .. " " .. task.status,
              task = task,
              name = task.name,
              status = task.status,
            })
          end

          Snacks.picker({
            title = "Overseer Tasks",
            items = items,
            format = function(item)
              local status_hl = ({
                RUNNING = "DiagnosticInfo",
                SUCCESS = "DiagnosticOk",
                FAILURE = "DiagnosticError",
                CANCELED = "DiagnosticWarn",
                PENDING = "DiagnosticHint",
              })[item.status] or "Comment"

              return {
                { item.name, "SnacksPickerLabel" },
                { " " },
                { "[" .. item.status .. "]", status_hl },
              }
            end,
            confirm = function(picker, item)
              picker:close()
              if item then
                require("overseer").open({ enter = true })
                vim.schedule(function()
                  vim.fn.search("\\V" .. vim.fn.escape(item.name, "\\"), "w")
                end)
              end
            end,
          })
        end,
        desc = "Jump to task",
      },
    },
    opts = {
      task_list = {
        direction = 'bottom',
        min_height = 20,
        max_height = 40,
        default_detail = 2,
      },
    },
  },
}





