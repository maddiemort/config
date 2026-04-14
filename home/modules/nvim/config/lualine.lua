vim.opt.showmode = false

-- gsplit: iterate over substrings in a string separated by a pattern
-- 
-- Parameters:
-- text (string)    - the string to iterate over
-- pattern (string) - the separator pattern
-- plain (boolean)  - if true (or truthy), pattern is interpreted as a plain
--                    string, not a Lua pattern
-- 
-- Returns: iterator
--
-- Usage:
-- for substr in gsplit(text, pattern, plain) do
--   doSomething(substr)
-- end
local function gsplit(text, pattern, plain)
    ---@type number?
    local splitStart = 1
    ---@type number
    local length = #text

    return function ()
        if splitStart then
            local sepStart, sepEnd = string.find(text, pattern, splitStart, plain)
            local ret
            if not sepStart then
                ret = string.sub(text, splitStart)
                splitStart = nil
            elseif sepEnd < sepStart then
                -- Empty separator!
                ret = string.sub(text, splitStart, sepStart)
                if sepStart < length then
                    splitStart = sepStart + 1
                else
                    splitStart = nil
                end
            else
                ret = sepStart > splitStart and string.sub(text, splitStart, sepStart - 1) or ''
                splitStart = sepEnd + 1
            end
            return ret
        end
    end
end

local function blame_components()
    local components = {}

    if not require'jjblame'.is_blame_text_available() then
        return nil
    end

    local blame = require'jjblame'.get_current_blame_text()
    blame = string.gsub(blame, '⬥ ', '')

    for str in gsplit(blame, "⬦", true) do
        table.insert(components, (string.gsub(str, "^%s*(.-)%s*$", "%1")))
    end

    return components
end

require'lualine'.setup {
    options = {
        theme = 'catppuccin-nvim',
        component_separators = {
            left = '',
            right = '',
        },
        section_separators = {
            left = '',
            right = '',
        },
        globalstatus = true,
    },
    sections = {
        lualine_a = {
            'mode',
        },
        lualine_b = {
            {
                'filename',
                path = 1,
            },
        },
        lualine_c = {
            'diff',
            {
                'diagnostics',
                symbols = {
                    error = '☣ ',
                    warn = '☢ ',
                    info = '❄ ',
                    hint = '⚙ ',
                },
            },
            {
                function() return blame_components()[1] end,
                cond = function() return blame_components() ~= nil end,
            },
            {
                function() return blame_components()[2] or "" end,
                cond = function() return blame_components() ~= nil end,
            },
            {
                function() return blame_components()[3] or "" end,
                cond = function() return blame_components() ~= nil end,
            },
            {
                function() return blame_components()[4] or "" end,
                cond = function() return blame_components() ~= nil end,
            },
        },
        lualine_x = {
            'encoding',
            {
                'fileformat',
                symbols = {
                    unix = 'lf',
                    dos = 'crlf',
                    mac = 'cr',
                },
            },
            'filetype',
        },
        lualine_y = {
            'branch',
        },
        lualine_z = {
            'progress',
            'location',
        },
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
            {
                'filename',
                path = 1,
            },
        },
        lualine_x = {
            'location',
        },
        lualine_y = {},
        lualine_z = {}
    },
}
