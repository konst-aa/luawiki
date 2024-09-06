local M = {}

function M.setup(user_config)
    local default_config = {
    }

    M.config = vim.tbl_deep_extend("force", default_config, user_config or {})

    require("luawiki_require")
end


if not pcall(debug.getlocal, 4, 1) then
    M.setup()
end

return M
