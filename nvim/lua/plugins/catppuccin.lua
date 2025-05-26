return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  opts = {
    transparent = true,
    styles = {
      sidebars = "transparent",
      floats = "transparent"
    },
    transparent_background = true,
    integrations = {
      cmp = true,
      gitsigns = true,
      nvimtree = true,
      telescope = true,
      which_key = true,
      treesitter = true,
      native_lsp = {
        enabled = true,
        underlines = {
          errors = "undercurl",
          hints = "undercurl",
          warnings = "undercurl",
          information = "undercurl",
        },
      },
    },
  },
}
