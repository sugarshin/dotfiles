return {
  {
    "hat0uma/csvview.nvim",
    ft = { "csv", "tsv" },
    cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle", "CsvViewInfo" },
    opts = {
      view = {
        display_mode = "border",
        sticky_header = { enabled = true },
      },
    },
    keys = {
      { "<leader>uc", "<cmd>CsvViewToggle<cr>", desc = "Toggle CsvView" },
    },
  },
}
