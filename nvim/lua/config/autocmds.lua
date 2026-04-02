-- Autocmds are automatically loaded on the VeryLazy event
-- Add any additional autocmds here

-- LazyVim sets wrap + spell for markdown etc.
-- Keep wrap but disable spell only.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "norg", "rmd", "org" },
  callback = function()
    vim.opt_local.spell = false
  end,
})
