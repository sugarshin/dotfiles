return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        menu = {
          auto_show = false,
        },
        -- LazyVim が vim.g.ai_cmp = true にするため inline ghost text が出る。
        -- AI 補完プラグインは入れていないので無効化する。
        ghost_text = {
          enabled = false,
        },
      },
    },
  },
}
