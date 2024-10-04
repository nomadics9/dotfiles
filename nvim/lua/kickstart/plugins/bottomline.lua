-- bottomline

return {
    'mnjm/winline.nvim',
    dependencies = {  
        'lewis6991/gitsigns.nvim', 
        'nvim-tree/nvim-web-devicons' 
    },
   config = function()
        require('winline').setup {
            -- Enable winline
            enable = true,

            -- Minimal components for a status line that feels like a command line
            components = {
                left = {
                    {'mode'},          -- Shows the current mode (Normal, Insert, etc.)
                },
                right = {
                    {'line_col'},      -- Show line and column numbers
                },
            },

            -- Disable separators and reduce padding for a minimal look
            options = {
                separators = true,         -- No separators between components
                padding = 0,                -- Minimal padding for a compact look
            },

            -- Make it look cohesive with the command line
            colors = {
                active = '#282c34',         -- Dark background for the active window
                inactive = '#3e4451',       -- Slightly lighter background for inactive windows
            },
        }

        -- Set Neovim options to make the command line always visible and match the style
        vim.opt.cmdheight = 0              -- Always show the command line
        vim.cmd [[
            highlight StatusLine guibg=#282c34 guifg=#abb2bf
            highlight CmdLine guibg=#282c34 guifg=#abb2bf
        ]]
    end,
}

