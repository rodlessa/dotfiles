return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "macchiato",
        transparent_background = true,
        term_colors = false,
        styles = {
          comments = { "italic" },
          functions = { "italic" },
          keywords = { "italic" },
          strings = {},
          variables = {},
        },
        integrations = {
          treesitter = true,
          native_lsp = {
            enabled = true,
          },
          lsp_trouble = false,
          lsp_saga = false,
          gitgutter = false,
          gitsigns = true,
          telescope = true,
          which_key = true,
          indent_blankline = { enabled = true, colored_indent_levels = true },
          dashboard = true,
          neogit = false,
          vim_sneak = false,
          fern = false,
          barbar = false,
          bufferline = true,
          markdown = false,
          lightspeed = false,
          ts_rainbow = true,
          hop = false,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
