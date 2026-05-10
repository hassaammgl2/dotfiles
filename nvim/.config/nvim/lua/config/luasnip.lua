local ls = require("luasnip")

-- Load all Lua snippets from your snippets folder
require("luasnip.loaders.from_lua").lazy_load({ paths = vim.fn.stdpath("config") .. "/lua/snippets" })

-- ============================
-- FILETYPE EXTENSIONS / INHERITANCE
-- ============================

-- JS family
ls.filetype_extend("javascript", { "javascript" })             -- JS base
ls.filetype_extend("javascriptreact", { "javascript", "react" }) -- JSX + JS + React
ls.filetype_extend("vue", { "javascript", "typescript", "vue" }) -- Vue (JS/TS parts)
ls.filetype_extend("html", { "javascript" })                   -- Inline JS

-- TS family
ls.filetype_extend("typescript", { "javascript", "typescript" }) -- TS inherits JS
ls.filetype_extend("typescriptreact", { "javascript", "typescript", "react" }) -- TSX inherits all
ls.filetype_extend("angular", { "typescript", "angular" }) -- Angular components

-- ============================
-- NESTJS SNIPPETS
-- ============================
ls.filetype_extend("nestjs", { "typescript" })      -- inherit TS helpers
ls.filetype_extend("angular", { "nestjs" })        -- Angular + NestJS if used together
