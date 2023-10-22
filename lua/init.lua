local M = {}

M.setup = function (raw)
  local config = require 'q-format.config'
  local user_ = require 'q-format.user'

  local user = config.validate(raw)

  user_.setup_format(user)
end

return M
