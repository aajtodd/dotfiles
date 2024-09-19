
vim.keymap.set("n", "<leader>xx", function() require("trouble").toggle("diagnostics") end, { desc = "trouble: toggle diagnostics"})
vim.keymap.set("n", "<leader>xw", function() require("trouble").toggle("workspace_diagnostics") end, { desc = "trouble: toggle workspace diagnostics" })
vim.keymap.set("n", "<leader>xd", function() require("trouble").toggle("document_diagnostics") end, { desc = "trouble: toggle document diagnostics" })
vim.keymap.set("n", "<leader>xq", function() require("trouble").toggle("quickfix") end, { desc = "trouble: toggle quickfix" })
vim.keymap.set("n", "<leader>xl", function() require("trouble").toggle("loclist") end, { desc = "trouble: toggle loclist" })
-- vim.keymap.set("n", "gR", function() require("trouble").toggle("lsp_references") end, { desc = "trouble: toggle lsp references" })


-- Not trouble specific but makes sense here to group
-- diagnostics
vim.keymap.set("n", "<leader>df",  vim.diagnostic.open_float, { desc = "show [d]iagnostic [f]loat" })

g_virtual_text = {}
g_virtual_text.show = true

local toggle_virtual_text = function()
    g_virtual_text.show = not g_virtual_text.show
    print("toggle virtual text: " .. tostring(g_virtual_text.show) )
    vim.diagnostic.config( { virtual_text = g_virtual_text.show } )
end

vim.keymap.set("n", "<leader>dv",  toggle_virtual_text, { desc = "toggle [d]iagnostic [v]irtual text" })
-- TODO - integrate with telescope?
