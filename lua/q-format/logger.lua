local M = {}

M.setup_logger = function (user)
  M.notify = function (...)
    if user.verbose then
      vim.notify(...)
    end
  end
end

return M
