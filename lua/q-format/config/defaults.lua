local typecheck = function (config)
  vim.validate
  { config = { config, 'table' }
  , custom = { config.custom, 'table' }
  , preferences = { config.preferences, 'table' }
  , ['preferences.*'] = { config.preferences['*'], 'table' }
  , verbose = { config.verbose, 'boolean' }
  , on_success = { config.on_success, 'function' }
  , on_failure = { config.on_failure, 'function' }
  , after = { config.after, 'function' }
  , notify_failure = { config.notify_failure, 'function' }
  }
end

local e = require 'q-format.formatters'

local defaults =
{ custom = {}  -- custom formatters, in the format that you would pass to formatprg
, preferences = { ['*'] = { e.CUSTOM, e.FORMATEXPR, e.FORMATPRG } }  -- preferences of formatters for each filetype
, verbose = false
, on_success = function (_) end  -- additional actions to take after a successful format, e.g. write buffer
, on_failure = function (_) end  -- additional actions to take after a failed format
, after = function (_) end  -- additional actions to take after a format, regardless of success or failure
, notify_failure = function (msg) vim.notify('[q-format] format error:\n' .. msg, vim.log.levels.ERROR) end  -- how to announce a format failure
}

assert(pcall(typecheck, defaults))

return { defaults = defaults, typecheck = typecheck }
