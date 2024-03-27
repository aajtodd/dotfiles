-- Display LSP progress and other notifications
require("fidget").setup {
    progress = {
        ignore_done_already = true, -- Ignore new tasks that are already complete

        -- Options related to how LSP progress messages are displayed as notifications
        display = {
            render_limit = 3, -- How many LSP messages to show at once
        },
    },
    notification = {
        override_vim_notify = true,
    },
}
