local M = {}

M.setup = function (raw)
  local config = require 'q-format.config'
  local user_ = require 'q-format.user'
  local logger = require 'q-format.logger'

  local user = config.validate(raw)

  logger.setup_logger(logger)
  user_.setup_format(user)
end

return M
