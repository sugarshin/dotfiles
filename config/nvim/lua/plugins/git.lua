return {
  -- 行末に virtual text で「いつ・誰が・どのcommitで・何を」を常時表示
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 300,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = "  <author>, <author_time:%Y-%m-%d> • <abbrev_sha> • <summary>",
    },
    keys = {
      {
        "<leader>gB",
        function() require("gitsigns").blame_line({ full = true }) end,
        desc = "Blame line (full popup)",
      },
      { "<leader>gT", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle inline blame" },
      { "<leader>gF", "<cmd>Gitsigns blame<cr>", desc = "Blame whole file" },
    },
  },

  -- カーソル行の commit から PR を引いてブラウザで開く / URL コピー
  {
    "inari111/git-trace.nvim",
    cmd = { "GitTracePR", "GitTracePRCopy", "GitTraceOpen" },
    keys = {
      { "<leader>gp", "<cmd>GitTracePR<cr>",     desc = "Open PR of current line" },
      { "<leader>gy", "<cmd>GitTracePRCopy<cr>", desc = "Copy PR URL" },
      { "<leader>go", "<cmd>GitTraceOpen<cr>",   mode = { "n", "v" }, desc = "Open on GitHub" },
    },
    opts = { pr_state = "merged" },
  },
}
