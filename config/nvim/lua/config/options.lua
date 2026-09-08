-- Options are automatically loaded before lazy.nvim startup
-- Add any additional options here
vim.opt.spell = false
vim.opt.clipboard = "unnamedplus"

-- 空白の可視化 (LazyVim は list = true だが listchars は Vim デフォルトのまま)
vim.opt.list = true
vim.opt.listchars = {
  tab = "» ",
  space = "·",
  trail = "␣",
  nbsp = "␣",
  extends = "›",
  precedes = "‹",
}

-- filetype 未設定のバッファ (拡張子なしファイル等) では LazyVim が formatoptions に r/o を
-- 入れているため、Neovim 既定の comments にある `fb:-` / `fb:•` が comment leader として働き、
-- `- foo` で改行するとマーカー幅ぶん字下げされる (markdown は ftplugin が r/o を外すので無害)。
-- リストを書くときに邪魔なので、リスト用の leader だけ外す。`//` や `#` の継続は残る。
vim.opt.comments:remove("fb:-")
vim.opt.comments:remove("fb:•")
