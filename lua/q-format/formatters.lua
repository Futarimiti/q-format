---@alias formatter fun(content: string): string
---@alias user-formatter string | formatter
---@alias formatters table<ft, formatter>
---@alias user-formatters table<ft, user-formatter>

local M = {}

-- empty formatters set.
M.empty = {}

---@return string
local run_formatter_process = function (formatter, content)
    local stdout_file = vim.fn.tempname()
    local stderr_file = vim.fn.tempname()

    local process = string.format('%s 1> %s 2> %s', formatter, stdout_file, stderr_file)
    local h = assert(io.popen(process, 'w'))
    h:write(content)
    h:flush()
    h:close()

    local stderr_r = assert(io.open(stderr_file, 'r'))
    local stderr = stderr_r:read('*a')
    stderr_r:flush()
    stderr_r:close()

    if stderr ~= '' then
        local stderr_w = assert(io.open(stderr_file, 'w'))
        stderr_w:write ''
        stderr_w:close()
        error(stderr)
    end

    local stdout_r = assert(io.open(stdout_file, 'r'))
    local stdout = stdout_r:read('*a')
    stdout_r:flush()
    stdout_r:close()

    local stdout_w = assert(io.open(stdout_file, 'w'))
    stdout_w:write ''
    stdout_w:close()

    return stdout
end

-- convert from user
---@param user user-formatter
---@return formatter
M.from_user = function (user)
    if type(user) == 'string' then
        return function (content)
            local ok, out = pcall(run_formatter_process, user, content)

            if not ok then
                error('[q-format] error raised by formatter: ' .. out)
            end

            return out
        end
    else
        return user
    end
end

---@param users user-formatters
---@return formatters
M.from_users = function (users)
    return vim.tbl_map(M.from_user, users)
end

return M

