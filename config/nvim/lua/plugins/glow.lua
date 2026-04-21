return {
  {
    "ellisonleao/glow.nvim",
    cmd = "Glow",
    ft = "markdown",
    opts = {
      style = "dark",
      width_ratio = 0.98,
      height_ratio = 0.95,
      border = "rounded",
    },
    keys = {
      { "<leader>mg", "<cmd>Glow<cr>", desc = "Glow (floating)", ft = "markdown" },
    },
  },
}
