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

---@type string?
local last_raw_blame = nil

---@type boolean
local blame_has_refreshed = true

---@type string[]
local blame_components = {}

local function refresh_blame_components()
    if not require'jjblame'.is_blame_text_available() then
        last_raw_blame = nil
        blame_components = {}
        blame_has_refreshed = true
        return
    end

    local raw_blame = require'jjblame'.get_current_blame_text()
    if not last_raw_blame or raw_blame ~= last_raw_blame then
        last_raw_blame = raw_blame

        blame_components = {}
        local blame = string.gsub(raw_blame, '⬥ ', '')

        for str in gsplit(blame, "⬦", true) do
            table.insert(blame_components, (string.gsub(str, "^%s*(.-)%s*$", "%1")))
        end

        blame_has_refreshed = true
    end
end

---@return string[]
local function get_blame_components()
    refresh_blame_components()
    blame_has_refreshed = false
    return blame_components
end

vim.api.nvim_create_autocmd(
    {
        'CursorMoved',
        'CursorMovedI',
    },
    {
        group = vim.api.nvim_create_augroup('refresh-blame-components', {}),
        callback = function()
            refresh_blame_components()
            if blame_has_refreshed then
                require'lualine'.refresh()
            end
        end,
    }
)

---@type string?
local current_bookmark = nil

---@return string
local function refresh_current_bookmark()
    local result = vim.system(
        {
            'jj',
            'log',
            '--ignore-working-copy',
            '--no-graph',
            '--no-pager',
            '--color=never',
            '-r',
            'current_bookmark(@)',
            '-T',
            'bookmarks.join(" ")'
        },
        { text = true }
    ):wait()
    if result.code == 0 and result.stdout then
        return result.stdout
    else
        return ""
    end
end

---@return string
local function get_current_bookmark()
    if current_bookmark == nil then
        current_bookmark = refresh_current_bookmark()
    end

    return current_bookmark
end

vim.api.nvim_create_autocmd(
    {
        'BufRead',
        'BufNewFile',
        'SessionLoadPost',
        'FileChangedShellPost',
        'FocusGained',
    },
    {
        group = vim.api.nvim_create_augroup('current-bookmark', {}),
        callback = function()
            current_bookmark = refresh_current_bookmark()
            require'lualine'.refresh()
        end,
    }
)

vim.api.nvim_create_autocmd('User',
    {
        pattern = 'RooterChDir',
        group = vim.api.nvim_create_augroup('current-bookmark', {}),
        callback = function()
            current_bookmark = refresh_current_bookmark()
            require'lualine'.refresh()
        end,
    }
)

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
        refresh = {
            events = {
                'WinEnter',
                'BufEnter',
                'BufWritePost',
                'SessionLoadPost',
                'FileChangedShellPost',
                'VimResized',
                'Filetype',
                'CursorMoved',
                'CursorMovedI',
                'ModeChanged',
                'FocusGained',
            },
        },
    },
    extensions = {
        'fzf',
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
            {
                function() return get_blame_components()[1] or "" end,
            },
            {
                function() return get_blame_components()[2] or "" end,
            },
            {
                function() return get_blame_components()[3] or "" end,
            },
            {
                function() return get_blame_components()[4] or "" end,
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
            {
                'diagnostics',
                symbols = {
                    error = '●',
                    warn = '◎',
                    info = '○',
                    hint = '◌',
                },
            },
            {
                'diff',
                symbols = {
                    added = '+',
                    modified = '~',
                    removed = '-',
                },
            },
            {
                get_current_bookmark,
                draw_empty = false,
            }
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
