-- Autocmds are automatically loaded on the VeryLazy event
-- Add any additional autocmds here

-- Disable LazyVim's wrap_spell autocmd for markdown etc.
vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
