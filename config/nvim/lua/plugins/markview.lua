return {
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      preview = {
        enable = false,
      },
    },
    keys = {
      { "<leader>um", "<cmd>Markview Toggle<cr>", desc = "Toggle Markview" },
    },
  },
}
