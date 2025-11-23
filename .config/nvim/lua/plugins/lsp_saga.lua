return {
    "nvimdev/lspsaga.nvim",
    config = function()
        local status, saga = pcall(require, "lspsaga")
        if not status then
            return
        end

        saga.setup({
            ui = {
                winblend = 10,
                border = "rounded",
                colors = {
                    normal_bg = "#002b36",
                },
            },
            lightbulb = {
                enable = false,
                enable_in_insert = false,
                sign = true,
                sign_priority = 40,
                virtual_text = true,
            },
        })

        local opts = { noremap = true, silent = true }
    end,
}
