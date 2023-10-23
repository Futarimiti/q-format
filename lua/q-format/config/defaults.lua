local typecheck = function (config)
  vim.validate
  { config = { config, 'table' }
  , ['config.custom'] = { config.custom, 'table' }
  , ['config.preferences'] = { config.preferences, 'table' }
  , ['config.preferences.*'] = { config.preferences['*'], 'table' }
  }
end

local e = require 'q-format.formatters'

local defaults =
{ custom = {}  -- custom formatters, in the format that you would pass to formatprg
, preferences = { ['*'] = { e.CUSTOM, e.FORMATEXPR, e.FORMATPRG } }  -- preferences of formatters for each filetype
}

assert(pcall(typecheck, defaults))

return { defaults = defaults, typecheck = typecheck }
