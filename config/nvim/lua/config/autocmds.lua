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

-- Glow preview in a terminal tab (ANSI colors preserved).
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    vim.keymap.set("n", "<leader>mG", function()
      local file = vim.fn.expand("%:p")
      vim.cmd("tabnew")
      vim.fn.termopen({ "glow", "-s", "dark", "-p", file })
      vim.cmd("startinsert")
    end, { buffer = args.buf, desc = "Glow (tab)" })
  end,
})
