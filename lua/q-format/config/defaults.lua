local typecheck = function (config)
  vim.validate
  { config = { config, 'table' }
  , custom = { config.custom, 'table' }
  , preferences = { config.preferences, 'table' }
  , ['preferences.*'] = { config.preferences['*'], 'table' }
  , verbose = { config.verbose, 'boolean' }
  , centre = { config.centre, 'boolean' }
  }
end

local e = require 'q-format.formatters'

local defaults =
{ custom = {}  -- custom formatters, in the format that you would pass to formatprg
, preferences = { ['*'] = { e.CUSTOM, e.FORMATEXPR, e.FORMATPRG } }  -- preferences of formatters for each filetype
, verbose = false
, centre = false  -- zz to centre at cursor pos after formatting?
}

assert(pcall(typecheck, defaults))

return { defaults = defaults, typecheck = typecheck }
