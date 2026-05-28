return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = {
            hidden = true,
          },
          grep = {
            hidden = true,
          },
        },
      },
    },
    keys = {
      { "<leader>gp", false },
    },
  },
}
