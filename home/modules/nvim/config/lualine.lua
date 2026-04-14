vim.opt.showmode = false

local jj_blame = require'jjblame'

local function blame_components()
    local components = {}

    if not jj_blame.is_blame_text_available() then
        return nil
    end

    local blame = jj_blame.get_current_blame_text()
    for str in string.gmatch(blame, "([^•]+)") do
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
                function() return blame_components()[2] end,
                cond = function() return blame_components() ~= nil end,
            },
            {
                function() return blame_components()[3] end,
                cond = function() return blame_components() ~= nil end,
            },
            {
                function() return blame_components()[4] end,
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
