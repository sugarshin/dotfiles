return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      enabled = false,
      pipe_table = {
        preset = "heavy",
        style = "full",
        cell = "padded",
        padding = 1,
        min_width = 10,
        alignment_indicator = "━",
      },
      code = {
        width = "block",
        left_pad = 2,
        right_pad = 2,
      },
      heading = {
        width = "block",
        left_pad = 1,
        right_pad = 4,
      },
    },
    keys = {
      { "<leader>um", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Render Markdown" },
    },
  },
}
