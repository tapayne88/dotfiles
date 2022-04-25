vim.g.dashboard_default_executive = 'telescope'
vim.g.dashboard_custom_header = {
  '',
  '',
  '███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
  '████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
  '██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
  '██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
  '██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
  '╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
  '',
}
vim.g.dashboard_custom_footer = { '' }
vim.g.dashboard_custom_section = {
  row1 = {
    description = {
      '  Recent files                                      ',
    },
    command = 'Telescope oldfiles',
  },
  row2 = {
    description = {
      '  Git file                                <leader>gf',
    },
    command = 'norm ,gf',
  },
  row3 = {
    description = {
      '  Find file                               <leader>ff',
    },
    command = 'norm ,ff',
  },
  row4 = {
    description = {
      '  New file                                          ',
    },
    command = 'enew',
  },
  row5 = {
    description = {
      '  File browser                            <leader>fb',
    },
    command = 'norm ,fb',
  },
  row6 = {
    description = {
      '  Find word                               <leader>fg',
    },
    command = 'norm ,fg',
  },
  row7 = {
    description = {
      '  Jump to bookmarks                                 ',
    },
    command = 'Telescope marks',
  },
}
