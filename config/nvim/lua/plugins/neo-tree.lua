return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        mappings = {
          ["Y"] = function(state)
            local node = state.tree:get_node()
            local absolute = node:get_id()
            local relative = vim.fn.fnamemodify(absolute, ":." )
            vim.fn.setreg("+", relative)
            vim.notify("Copied: " .. relative)
          end,
        },
      },
      filesystem = {
        follow_current_file = {
          enabled = true,
          leave_dirs_open = true,
        },
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
          never_show = {
            ".git",
            "node_modules",
          },
        },
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = false },
    },
  },
}
