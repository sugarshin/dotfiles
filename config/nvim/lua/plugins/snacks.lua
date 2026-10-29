return {
  {
    "folke/snacks.nvim",
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        once = true,
        callback = function()
          local group = vim.api.nvim_create_augroup("snacks_image_hover", { clear = true })

          -- 画像フロートの上限を画面サイズに合わせる (枠線と statusline / cmdline の分は引く)。
          -- 縦横比は snacks が保つので、上限を画面いっぱいにしておけば横長でも縦長でも最大になる。
          -- max_width / max_height は数値しか受け付けないので、起動時とリサイズ時に書き換える。
          local function fit()
            local doc = Snacks.image.config.doc
            doc.max_width = vim.o.columns - 4
            doc.max_height = vim.o.lines - vim.o.cmdheight - 4
          end
          fit()
          vim.api.nvim_create_autocmd("VimResized", { group = group, callback = fit })

          -- snacks 標準のホバー (doc.float) は後から止められないので切ってあり、
          -- 同じことを自前の CursorMoved で行って <leader>uM で表示を切り替えられるようにする。
          local langs = Snacks.image.langs()
          vim.api.nvim_create_autocmd("CursorMoved", {
            group = group,
            callback = vim.schedule_wrap(function()
              local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
              if vim.g.snacks_image_hover ~= false and vim.tbl_contains(langs, lang) then
                Snacks.image.hover()
              end
            end),
          })
          Snacks.toggle
            .new({
              id = "image_hover",
              name = "Image Preview",
              get = function()
                return vim.g.snacks_image_hover ~= false
              end,
              set = function(state)
                vim.g.snacks_image_hover = state
                if state then
                  Snacks.image.hover()
                else
                  Snacks.image.doc.hover_close()
                end
              end,
            })
            :map("<leader>uM")
        end,
      })
    end,
    opts = {
      image = {
        enabled = true,
        -- 本文に画像を差し込むと行がずれて編集の邪魔になるので、カーソルがブロック上にあるときだけ
        -- フロートで表示する。フロートは上の CursorMoved で自前で出すので、snacks 側は両方切る。
        doc = { inline = false, float = false },
        convert = {
          -- mmdc は既定で図を 800px 幅に縮めて出力するので、大きい図だと文字が潰れる。
          -- useMaxWidth を切った設定を渡して、図本来のサイズで出力させる。
          mermaid = function()
            local theme = vim.o.background == "light" and "neutral" or "dark"
            -- stylua: ignore
            return {
              "-i", "{src}", "-o", "{file}", "-b", "transparent", "-t", theme, "-s", "{scale}",
              "-c", vim.fn.stdpath("config") .. "/mermaid.json",
            }
          end,
        },
      },
      styles = {
        -- 画面いっぱいまで広がるので、カーソル基準ではなく画面中央に出す。
        snacks_image = {
          relative = "editor",
          row = function(win)
            return math.max(0, math.floor((vim.o.lines - win.opts.height) / 2) - 1)
          end,
          col = function(win)
            return math.max(0, math.floor((vim.o.columns - win.opts.width) / 2) - 1)
          end,
        },
      },
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
