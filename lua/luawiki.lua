local function ind(s, i)
    return string.sub(s, i, i)
end
local function starts(s, pre)
   return string.sub(s,1,string.len(pre))==pre
end
local function ends(s, post)
    return string.sub(s, -string.len(post))==post
end

local function replace_line(row, new)
    vim.api.nvim_buf_set_lines(0, row-1, row, true, { new } )
end

local function keymap_a(mode, lhs, rhs, opts)
    opts = opts or { buffer = 0 }
    vim.keymap.set(mode, lhs, rhs, opts)
end

local cr = vim.api.nvim_replace_termcodes("<CR>", true, true, true)
local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)

local function istodo(line)
    -- 0 if no, 1 if empty, 2 if checked
    -- second return value is number of spaces
    local i = string.find(line, "-")
    if i == nil then
        return 0, 0
    end
    line = string.sub(line, i)
    if starts(line, "- [ ] ") then
        return 1, i - 1
    elseif starts(line, "- [X] ") then
        return 2, i - 1
    end
    -- unreachable
    return 0, i - 1
end

local function todo()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_buf_get_lines(0, row-1, row, {})[1]
    local new = ""
    local todo_info, spaces = istodo(line)

    if todo_info == 0 then
        if line == "" then
            replace_line(row, "- [ ] ")
            vim.api.nvim_feedkeys("A", "n", false)
        end
        return
    end

    line = string.sub(line, spaces+1)
    if todo_info == 1 then
        new = "- [X] "
    elseif todo_info == 2 then
        new = "- [ ] "
    else
        return
    end
    local contents = string.sub(line, string.len("- [ ] ")+1)
    new = string.rep(" ", spaces) .. new .. contents
    replace_line(row, new)
    -- vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, string.len(new), {new})
end

local function continue_todo()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_buf_get_lines(0, row-1, row, {})[1]
    local res, spaces = istodo(line)
    if res == 0 then
        return false
    end
    local t = string.sub(line, spaces)
    
    -- https://www.reddit.com/r/neovim/comments/xueish/comment/iqw5o8s
    -- switch to buf set text at some point
    local rmi = vim.api.nvim_replace_termcodes("cc0<C-D>", true, true, true)
    if t == "- [ ] " then
        -- hitting enter twice exits out of todo
        vim.api.nvim_feedkeys(
          esc .. rmi, "n", false
        )
    else
        vim.api.nvim_feedkeys(
          cr .. esc .. rmi .. string.rep(" ", spaces) .. "- [ ] ", "n", false
        )
    end

    return true -- if continued
end

local Config = {
    filemaps = {
        markdown = {
            pattern = {"*.md"},
            linkstart = "[",
            linkstop = ")",
            getlink = function(block)
                -- swap ro regex later
                local t = string.find(block, "%(")
                return string.sub(block, t+1, string.len(block) - 1)
            end,
            formatlink = function(block)
                return "[" .. block .. "](" .. block .. ".md)"
            end,
            extras = function()
                -- todo shortcuts
                keymap_a('n', '<S-CR>', function() todo() end)
                keymap_a('i', '<CR>', function()
                    if not continue_todo() then
                        return '<CR>'
                    end
                end,
                    { expr = true, noremap = true, buffer = 0 }
                )
            end
        },
        wiki = {
            pattern = {"*.wiki"},
            linkstart = "[[",
            linkstop = "]]",
            getlink = function(block)
                local word = string.sub(block, 3, string.len(block) - 2)
                if not ends(word, ".md") then
                    word = word .. ".wiki"
                end

                return word
            end,
            formatlink = function(block)
                return "[[" .. block .. "]]"
            end
        }
    }
}


local function link(filetype)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_buf_get_lines(0, row-1, row, {})[1]
    local s = col
    local e = col+1
    local filemap = Config.filemaps[filetype]

    while s > 0 and ind(line, s) ~= ' ' do
        s = s - 1
    end
    while e <= string.len(line) and ind(line, e) ~= ' ' do
        e = e + 1
    end

    local block = string.sub(line, s, e)

    if starts(block, " ") then
        block = string.sub(block, 2, string.len(block))
    end
    if ends(block, " ") then
        block = string.sub(block, 1, string.len(block) - 1)
    end


    if (starts(block, filemap.linkstart) and ends(block, filemap.linkstop)) then
        table.insert(Depth, vim.api.nvim_buf_get_name(0))
        vim.cmd("e " .. filemap.getlink(block))
    elseif (string.len(block) > 0) then
        vim.api.nvim_buf_set_text(0, row - 1, s, row - 1, e-1, { filemap.formatlink(block) })
    end
end


local function goback()
    if #Depth > 0 then
        vim.cmd("e " .. table.remove(Depth))
    end
end

local function setup(params)
    Config = vim.tbl_deep_extend("force", Config, params or {})

    for filetype, tbl in pairs(Config.filemaps) do
        vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
            pattern = tbl.pattern,
            callback = function()
                vim.schedule(function()
                    keymap_a('n', '<CR>', function() link(filetype) end)
                    keymap_a('n', '<BS>', goback)
                    if tbl.extras ~= nil then
                        tbl.extras()
                    end
                end)
            end
        })
    end
end

Depth = {}


return {
    setup = setup,
}
