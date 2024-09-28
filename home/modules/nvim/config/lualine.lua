vim.opt.showmode = false

local onehalf = require'lualine.themes.onedark'
local git_blame = require'gitblame'

local colors = {
    fg = '#dcdfe4',
}

onehalf.normal.b.fg = colors.fg
onehalf.normal.c.fg = colors.fg

function blame_components()
    local components = {}

    if not git_blame.is_blame_text_available() then
        return components
    end

    -- Annoyingly, gitblame returns true for is_blame_text_available() when in
    -- an empty buffer.
    if vim.bo.filetype == '' then
        return components
    end

    local blame = git_blame.get_current_blame_text()
    for str in string.gmatch(blame, "([^•]+)") do
        table.insert(components, (string.gsub(str, "^%s*(.-)%s*$", "%1")))
    end

    return components
end

function blame_component(idx)
    local components = blame_components()
    local component = components[idx]
    return component
end

require'lualine'.setup {
    options = {
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
            -- {
            --     blame_components,
            --     cond = git_blame.is_blame_text_available,
            -- }
            {
                function() return blame_component(1) end,
                cond = function() return blame_component(1) ~= nil end,
                -- color = { fg = '#7c828c' },
            },
            {
                function() return blame_component(2) end,
                cond = function() return blame_component(2) ~= nil end,
                -- color = { fg = '#7c828c' },
            },
            {
                function() return blame_component(3) end,
                cond = function() return blame_component(3) ~= nil end,
                -- color = { fg = '#7c828c' },
            },
            {
                function() return blame_component(4) end,
                cond = function() return blame_component(4) ~= nil end,
                -- color = { fg = '#7c828c' },
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
