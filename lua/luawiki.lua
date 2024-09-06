local function ind(s, i)
    return string.sub(s, i, i)
end
local function starts(s, pre)
    print(string.sub(s,1,string.len(pre)))
   return string.sub(s,1,string.len(pre))==pre
end
local function ends(s, post)
    return string.sub(s, -string.len(post))==post
end

local function setup(params)
end


Depth = {}

local function link()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_buf_get_lines(0, row-1, row, {})[1]
    local s = col
    local e = col+1

    while s > 0 and ind(line, s) ~= ' ' and ind(line, e) ~= '[' do
        s = s - 1
    end
    while e <= string.len(line) and ind(line, e) ~= ' ' and ind(line, e) ~= ')' do
        e = e + 1
    end

    local block = string.sub(line, s, e)

    if starts(block, " ") then
        block = string.sub(block, 2, string.len(block))
    end
    if ends(block, " ") then
        block = string.sub(block, 1, string.len(block) - 1)
    end

    if (starts(block, "[") and ends(block, ')')) then
        local t = 1
        while ind(block, t) ~= '(' do
            t = t + 1
        end

        local name = string.sub(block, t+1, string.len(block) - 1)
        -- print(#Depth)
        table.insert(Depth, vim.api.nvim_buf_get_name(0))
        vim.cmd("e " .. name)
    elseif (string.len(block) > 0) then
        vim.api.nvim_buf_set_text(0, row - 1, s, row - 1, s, { "[" })
        vim.api.nvim_buf_set_text(0, row - 1, e, row - 1, e, { "](" .. block .. ".md)" })
    end
end
local function goback()
    if #Depth > 0 then
        vim.cmd("e " .. table.remove(Depth))
    end
end


vim.api.nvim_create_autocmd("FileType", {
    pattern = {"markdown"},
    callback = function()
        vim.schedule(function()
            vim.keymap.set('n', '<CR>', link)
            vim.keymap.set('n', '<BS>', goback)
        end)
    end
})

return {
    setup = setup,
}
