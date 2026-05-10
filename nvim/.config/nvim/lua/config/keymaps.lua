vim.keymap.set("n", "<leader>ih", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

vim.keymap.set("n", "<leader>o", "<cmd>Neotree focus<cr>", { desc = "open neotree" })
vim.keymap.set("i", "<C-o>", "<Esc><cmd>Neotree focus<cr>", { desc = "open neotree" })

local float_term = nil
vim.keymap.set("n", "<leader>tf", function()
  if not float_term then
    float_term = require("toggleterm.terminal").Terminal:new({
      direction = "float",
      close_on_exit = true,
    })
  end
  float_term:toggle()
end, {
  desc = "Floating terminal",
})
