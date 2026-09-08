return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      -- リストの `- ` (2 セル) を `●` (1 セル) に overlay 置換するため、
      -- anti_conceal で生テキストに戻るカーソル行だけ 1 セル右にずれて見える。
      -- 実テキストは変わらないが編集中に紛らわしいので置換をやめる。
      bullet = { enabled = false },
    },
  },
}
