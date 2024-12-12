local M = {}

---@param message string
---@param log_level? integer
function M.notify(message, log_level)
  if require('refjump').get_options().verbose then
    vim.notify(message, log_level or vim.log.levels.INFO)
  end
end

return M
