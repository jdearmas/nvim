-- ~/.config/nvim/lua/plugins/init.lua
-- Main plugin loader - imports all plugin modules

-- Helper to merge plugin tables
local function merge_plugins(...)
  local result = {}
  for _, plugins in ipairs({ ... }) do
    for _, plugin in ipairs(plugins) do
      table.insert(result, plugin)
    end
  end
  return result
end

-- Import all plugin modules
return merge_plugins(
  require('plugins.lsp'),
  require('plugins.treesitter'),
  require('plugins.telescope'),
  require('plugins.git'),
  require('plugins.ui'),
  require('plugins.editor'),
  require('plugins.coding'),
  require('plugins.debug'),
  require('plugins.ai'),
  require('plugins.orgmode'),
  require('plugins.overseer')
)





