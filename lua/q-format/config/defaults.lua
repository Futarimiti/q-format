local typecheck = function (config)
  vim.validate
  { config = { config, 'table' }
  }
end

local defaults = {}

assert(pcall(typecheck, defaults))

return { defaults = defaults, typecheck = typecheck }
