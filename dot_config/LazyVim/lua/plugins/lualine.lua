return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.sections.lualine_a = { { "mode", fmt = string.lower } }
    opts.sections.lualine_b = { { "branch", icon = "󰊢" } }
  end,
}
