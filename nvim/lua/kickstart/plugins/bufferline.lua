-- bufferline

return {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = { 
        'nvim-tree/nvim-web-devicons',
    },
    opts = {
        options = {
        mode = "buffers",
        themable = true,
        color_icons = true,
        offsets = {
            {
                filetype = "neo-tree",
                text = "File Explorer",
                text_align = "left",
                separator = true,
            }
        },
    },
    },
}

