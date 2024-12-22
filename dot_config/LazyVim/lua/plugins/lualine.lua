return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local icons = LazyVim.config.icons

    opts.options.component_separators = { left = "", right = "" }
    opts.options.section_separators = { left = "", right = "" }

    opts.sections = {
      lualine_a = {
        {
          "mode",
          fmt = function()
            return " "
          end,
          padding = 0,
        },
        {
          "mode",
          fmt = string.lower,
          color = { gui = "reverse" },
          separator = { "" },
        },
      },
      lualine_b = { { "branch", icon = "󰊢" } },
      lualine_c = {
        { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
        { LazyVim.lualine.pretty_path() },
        {
          "%r",
          fmt = function()
            return ""
          end,
          cond = function()
            return vim.bo.readonly
          end,
        },
        {
          "diff",
          symbols = {
            added = icons.git.added,
            modified = icons.git.modified,
            removed = icons.git.removed,
          },
          source = function()
            local gitsigns = vim.b.gitsigns_status_dict
            if gitsigns then
              return {
                added = gitsigns.added,
                modified = gitsigns.changed,
                removed = gitsigns.removed,
              }
            end
          end,
        },
      },
      lualine_x = {
        Snacks.profiler.status(),
        -- stylua: ignore
        {
          function() return "  " .. require("dap").status() end,
          cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
          color = function() return { fg = Snacks.util.color("Debug") } end,
        },
        {
          "diagnostics",
          symbols = {
            error = icons.diagnostics.Error,
            warn = icons.diagnostics.Warn,
            info = icons.diagnostics.Info,
            hint = icons.diagnostics.Hint,
          },
        },
      },
      lualine_y = { { "location", padding = { left = 0, right = 1 } } },
      lualine_z = {
        { "progress", separator = " " },
      },
    }
  end,
}
