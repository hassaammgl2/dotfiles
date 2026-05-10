return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        emmet_ls = {
          filetypes = { "html", "css", "javascript", "javascriptreact", "typescriptreact" },
          init_options = {
            html = {
              options = {
                ["bem.enabled"] = false,
              },
            },
          },
        },
      },
    },
  },
}
