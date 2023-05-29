-- statusline in lua
return {
  {
    -- TODO: Revert to nvim-lualine/lualine.nvim when upstream neovim issue is
    -- resolved - https://github.com/neovim/neovim/issues/19464
    'tapayne88/lualine.nvim',
    branch = 'suppress-winbar-no-room-error',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      local lsp_symbol = require('tap.utils.lsp').symbol
      local highlight_group_attrs = require('tap.utils').highlight_group_attrs
      local require_plugin = require('tap.utils').require_plugin
      local get_lsp_clients = require('tap.utils.lsp').get_lsp_clients

      local conditions = {
        has_lsp = function()
          return #get_lsp_clients() > 0
        end,
        is_wide_window = function()
          return vim.fn.winwidth(0) > 80
        end,
        is_navic_available = function()
          -- navic is lazy and loaded only when an LSP supports the correct capabilities
          return package.loaded['nvim-navic']
            and require('nvim-navic').is_available()
        end,
        is_copilot_available = function()
          return package.loaded['copilot']
            and require('copilot.client').buf_is_attached()
        end,
      }

      local function literal(str)
        local comp = require('lualine.component'):extend()
        function comp:draw(default_highlight)
          self.status = str or ''
          self.applied_separator = ''
          self:apply_highlights(default_highlight)
          self:apply_section_separators()
          return self.status
        end

        return comp
      end

      ---Copied from lualine.component and modified to allow empty status to render
      ---driver code of the class
      ---@param default_highlight string default hl group of section where component resides
      ---@param is_focused boolean|number whether drawing for active or inactive statusline.
      ---@return string stl formatted rendering string for component
      local empty_draw = function(self, default_highlight, is_focused)
        self.status = ''
        self.applied_separator = ''
        if self.options.cond ~= nil and self.options.cond() ~= true then
          return self.status
        end
        self.default_hl = default_highlight
        local status = self:update_status(is_focused)
        if self.options.fmt then
          status = self.options.fmt(status or '', self)
        end
        -- if type(status) == 'string' and #status > 0 then
        self.status = status
        self:apply_icon()
        self:apply_padding()
        self:apply_on_click()
        self:apply_highlights(default_highlight)
        self:apply_section_separators()
        self:apply_separator()
        -- end
        return self.status
      end

      local filetype = require('lualine.components.filetype'):extend()
      function filetype:draw(...)
        return empty_draw(self, ...)
      end

      local diagnostic_empty =
        require('lualine.components.diagnostics'):extend()
      function diagnostic_empty:draw(...)
        return empty_draw(self, ...)
      end

      local function modified()
        if vim.bo.modified then
          return ''
        end
        return ''
      end

      local function tscVersion()
        local tsc_version = require_plugin(
          'tap.plugins.lsp.servers.tsserver',
          function(tsserver)
            return tsserver.get_tsc_version()
          end
        )

        return tsc_version and string.format('v%s', tsc_version) or ''
      end

      local function window_zoom_enabled()
        local ok, is_zoomed = pcall(function()
          return vim.fn['zoom#statusline']() == 'zoomed'
        end)

        if ok then
          return is_zoomed
        end
        return false
      end

      local section_separators = { left = '', right = '' }

      local diagnostic_section = function(cfg)
        local default_cfg = {
          diagnostic_empty,
          source = { 'nvim_diagnostic' },
          separator = {
            left = section_separators.right,
            right = section_separators.left,
          },
          -- no padding so the slanty isn't too wide when no diagnostics
          padding = 0,
          fmt = function(status)
            if tonumber(status, 10) > 0 then
              -- stitch the icon onto the count
              return string.format(
                '%s%s%s',
                cfg.pad_left and ' ' or '',
                cfg.symbol,
                status
              )
            end

            -- Count is 0 so don't return content
            return ''
          end,
          -- supress the symbols, default still shows 'E: 1' etc.
          symbols = { error = '', warn = '', hint = '', info = '' },
          -- don't want any color output adding to the diagnostics
          colored = false,
          -- always show the slanty, it'll be empty if there are none for that type
          always_visible = true,
          -- only show when we have an lsp attached - this may need updating if I
          -- use other sources for diagnostics
          cond = conditions.has_lsp,
        }
        return vim.tbl_extend('force', default_cfg, cfg)
      end

      local sections = {
        lualine_a = {
          {
            'mode',
            fmt = function()
              return ' '
            end,
            padding = 0,
          },
          {
            'mode',
            fmt = string.lower,
            color = { gui = 'reverse' },
            separator = { '' },
          },
        },
        lualine_b = { { 'branch', icon = '󰊢' } },
        lualine_c = {
          {
            'filename',
            file_status = false,
            fmt = function(filename)
              local is_zoomed = window_zoom_enabled()
              local zoom_text = is_zoomed and ' 󰛭' or ''
              return filename .. zoom_text
            end,
          },
          modified,
          {
            'diff',
            symbols = { added = ' ', modified = ' ', removed = ' ' },
          },
          {
            '%r',
            fmt = function()
              return ''
            end,
            cond = function()
              return vim.bo.readonly
            end,
          },
        },
        lualine_x = {
          {
            function()
              return ''
            end,
            separator = {
              left = section_separators.right,
              right = section_separators.left,
            },
            padding = 0,
            colored = false,
            color = 'LualineCopilot',
            cond = conditions.is_copilot_available,
          },
          literal ' ',
          { tscVersion, cond = conditions.is_wide_window },
          diagnostic_section {
            sections = { 'error' },
            color = 'LualineDiagnosticError',
            symbol = lsp_symbol 'error',
            pad_left = false,
          },
          diagnostic_section {
            sections = { 'warn' },
            color = 'LualineDiagnosticWarn',
            symbol = lsp_symbol 'warning',
            pad_left = true,
          },
          diagnostic_section {
            sections = { 'hint' },
            color = 'LualineDiagnosticHint',
            symbol = lsp_symbol 'hint',
            pad_left = true,
          },
          diagnostic_section {
            sections = { 'info' },
            color = 'LualineDiagnosticInfo',
            symbol = lsp_symbol 'info',
            pad_left = true,
          },
          diagnostic_section {
            sections = { 'error', 'warn', 'hint', 'info' },
            color = 'LualineDiagnosticOk',
            fmt = function(status)
              -- diagnostics will only report numbers so if they are all 0
              -- then we are all ok
              if status == '0 0 0 0' then
                return string.format(' %s ', lsp_symbol 'ok')
              end
              return ''
            end,
          },
          literal ' ',
        },
        lualine_y = {
          literal ' ',
          {
            filetype,
            colored = false,
            padding = 0,
            fmt = function(status)
              return conditions.is_wide_window() and status .. ' ' or ''
            end,
          },
          {
            literal '┃',
            color = function()
              local hi_attrs = highlight_group_attrs 'lualine_c_normal'
              return { fg = hi_attrs.bg }
            end,
          },
          { '%l:%c', icon = '' },
        },
        lualine_z = { { '%p%%', cond = conditions.is_wide_window } },
      }

      require('tap.utils').apply_user_highlights(
        'Lualine',
        function(highlight, palette)
          highlight('LualineDiagnosticError', {
            bg = highlight_group_attrs('DiagnosticError').fg,
            fg = palette.mantle,
          })
          highlight('LualineDiagnosticWarn', {
            bg = highlight_group_attrs('DiagnosticWarn').fg,
            fg = palette.mantle,
          })
          highlight('LualineDiagnosticHint', {
            bg = highlight_group_attrs('DiagnosticHint').fg,
            fg = palette.mantle,
          })
          highlight('LualineDiagnosticInfo', {
            bg = highlight_group_attrs('DiagnosticInfo').fg,
            fg = palette.mantle,
          })
          highlight('LualineDiagnosticOk', {
            bg = highlight_group_attrs('DiagnosticOk').fg,
            fg = palette.mantle,
          })
          highlight('LualineCopilot', {
            bg = palette.lavender,
            fg = palette.mantle,
          })
        end
      )

      local winbar_y = {
        modified,
        {
          'filename',
          file_status = false,
          path = 0,
          cond = function()
            return vim.bo.filetype ~= 'oil'
          end,
        },
        {
          'filename',
          file_status = false,
          path = 1,
          cond = function()
            return vim.bo.filetype == 'oil'
          end,
        },
      }
      local filetype_icon_only = {
        filetype,
        colored = false,
        padding = 0,
        fmt = function()
          return ''
        end,
      }

      require('lualine').setup {
        options = {
          theme = 'catppuccin',
          component_separators = { left = '', right = '' },
          section_separators = section_separators,
          globalstatus = true,
          disabled_filetypes = {
            winbar = vim.tbl_flatten {
              'alpha',
              'fugitive',
              'gitcommit',
              'neo-tree',
              'outputpanel',
              'packer',
              'qf',
              'Trouble',
              require('tap.utils').dap_filetypes,
            },
          },
        },
        sections = sections,
        inactive_sections = vim.tbl_deep_extend(
          'force',
          sections,
          { lualine_a = {}, lualine_x = {} }
        ),
        winbar = {
          lualine_a = {
            {
              function()
                if vim.bo.filetype == 'oil' then
                  return '󰙅'
                end
                if conditions.is_navic_available() then
                  return '󰆧'
                end
                return ''
              end,
            },
          },
          lualine_b = {},
          lualine_c = {
            {
              function()
                local loc = require('nvim-navic').get_location {
                  highlight = true,
                }
                -- Need to append lualine_c_normal highlight to avoid a gap of
                -- bg=NONE, not sure where this is coming from
                return loc .. '%#lualine_c_normal#'
              end,
              cond = conditions.is_navic_available,
            },
          },
          lualine_x = {},
          lualine_y = winbar_y,
          lualine_z = { filetype_icon_only },
        },
        inactive_winbar = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = winbar_y,
          lualine_z = { filetype_icon_only },
        },
      }
    end,
  },

  {
    'SmiteshP/nvim-navic',
    dependencies = 'neovim/nvim-lspconfig',
    lazy = true,
    opts = {
      icons = {
        File = '󰈙 ',
        Module = ' ',
        Namespace = '󰌗 ',
        Package = ' ',
        Class = '󰌗 ',
        Method = '󰆧 ',
        Property = ' ',
        Field = ' ',
        Constructor = ' ',
        Enum = '󰕘 ',
        Interface = '󰕘 ',
        Function = '󰊕 ',
        Variable = '󰆧 ',
        Constant = '󰏿 ',
        String = '󰀬 ',
        Number = '󰎠 ',
        Boolean = '◩ ',
        Array = '󰅪 ',
        Object = '󰅩 ',
        Key = '󰌋 ',
        Null = '󰟢 ',
        EnumMember = ' ',
        Struct = '󰌗 ',
        Event = ' ',
        Operator = '󰆕 ',
        TypeParameter = '󰊄 ',
        Macro = '󰉨 ',
      },
    },
    init = function()
      require('tap.utils').apply_user_highlights('Navic', function(hl, palette)
        local bg = palette.mantle

        -- Set Navic highlights manually to ensure the bg value updates when the
        -- colorscheme changes
        --
        -- Copy of Navic highlights from
        -- https://github.com/catppuccin/nvim/blob/fa9a4465672fa81c06b23634c0f04f6a5d622211/lua/catppuccin/groups/integrations/navic.lua
        hl('NavicIconsFile', { fg = palette.blue, bg = bg })
        hl('NavicIconsModule', { fg = palette.blue, bg = bg })
        hl('NavicIconsNamespace', { fg = palette.blue, bg = bg })
        hl('NavicIconsPackage', { fg = palette.blue, bg = bg })
        hl('NavicIconsClass', { fg = palette.yellow, bg = bg })
        hl('NavicIconsMethod', { fg = palette.blue, bg = bg })
        hl('NavicIconsProperty', { fg = palette.green, bg = bg })
        hl('NavicIconsField', { fg = palette.green, bg = bg })
        hl('NavicIconsConstructor', { fg = palette.blue, bg = bg })
        hl('NavicIconsEnum', { fg = palette.green, bg = bg })
        hl('NavicIconsInterface', { fg = palette.yellow, bg = bg })
        hl('NavicIconsFunction', { fg = palette.blue, bg = bg })
        hl('NavicIconsVariable', { fg = palette.flamingo, bg = bg })
        hl('NavicIconsConstant', { fg = palette.peach, bg = bg })
        hl('NavicIconsString', { fg = palette.green, bg = bg })
        hl('NavicIconsNumber', { fg = palette.peach, bg = bg })
        hl('NavicIconsBoolean', { fg = palette.peach, bg = bg })
        hl('NavicIconsArray', { fg = palette.peach, bg = bg })
        hl('NavicIconsObject', { fg = palette.peach, bg = bg })
        hl('NavicIconsKey', { fg = palette.pink, bg = bg })
        hl('NavicIconsNull', { fg = palette.peach, bg = bg })
        hl('NavicIconsEnumMember', { fg = palette.red, bg = bg })
        hl('NavicIconsStruct', { fg = palette.blue, bg = bg })
        hl('NavicIconsEvent', { fg = palette.blue, bg = bg })
        hl('NavicIconsOperator', { fg = palette.sky, bg = bg })
        hl('NavicIconsTypeParameter', { fg = palette.blue, bg = bg })
        hl('NavicText', { fg = palette.teal, bg = bg })
        hl('NavicSeparator', { fg = palette.text, bg = bg })
      end)
      require('tap.utils.lsp').on_attach(function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          require('nvim-navic').attach(client, bufnr)
        end
      end)
    end,
  },
}
