---@alias fp_option "'fp'" | false
-- use_fp: should we use fp for a filetype if its formatter is not given?
-- 'fp' -> use fp if formatter absent
-- false -> use neither
-- silent: should I remain silent if formatter not found?
---@alias options { use_fp?: fp_option, silent?: boolean }
---@alias user-opts { formatters?: user-formatters, opts?: options }
---@alias opts { formatters: user-formatters, opts: options }

local M = {}

-- id
---@param opts user-opts
---@return user-formatters
M.get_user_formatters = function (opts)
    ---@diagnostic disable-next-line: return-type-mismatch
    return opts.formatters
end

---@type opts
M.default_user_opts = { formatters = {}, opts = { use_fp = 'fp'
                                                , silent = false
                                                }
                      }

---@param user user-opts
---@return opts
M.validate = function (user)
    ---@cast user opts
    return vim.tbl_deep_extend('keep', user, M.default_user_opts)
end

M.get_user_options = function (user)
    return user.opts
end

return M
