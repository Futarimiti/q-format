local typecheck = function (config)
  vim.validate {}
end

local defaults = {}

assert(pcall(typecheck, defaults))

return { defaults = defaults, typecheck = typecheck }
