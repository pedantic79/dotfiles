return {
  { "ellisonleao/gruvbox.nvim" },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  -- the following fixes a bug. it should be deleted eventually
  {
    "catppuccin/nvim",
    commit = "f19cab18ec4dc86d415512c7a572863b2adbcc18",
  },
}
