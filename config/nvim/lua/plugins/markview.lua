return {
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    config = function(_, opts)
      require("markview").setup(opts)
      vim.schedule(function()
        pcall(vim.cmd, "Markview Disable")
      end)
    end,
    keys = {
      { "<leader>um", "<cmd>Markview Toggle<cr>", desc = "Toggle Markview" },
    },
  },
}
