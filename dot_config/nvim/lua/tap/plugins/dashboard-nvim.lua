return {
  'glepnir/dashboard-nvim',
  config = function()
    local db = require 'dashboard'

    db.custom_header = {
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
    db.custom_center = {
      {
        icon = '  ',
        desc = 'Recent files                                      ',
        action = 'Telescope oldfiles',
      },
      {
        icon = '  ',
        desc = 'Git file                                <leader>gf',
        action = 'norm ,gf',
      },
      {
        icon = '  ',
        desc = 'Find file                               <leader>ff',
        action = 'norm ,ff',
      },
      {
        icon = '  ',
        desc = 'New file                                          ',
        action = 'enew',
      },
      {
        icon = '  ',
        desc = 'File browser                            <leader>fb',
        action = 'norm ,fb',
      },
      {
        icon = '  ',
        desc = 'Find word                               <leader>fg',
        action = 'norm ,fg',
      },
      {
        icon = '  ',
        desc = 'Jump to bookmarks                                 ',
        action = 'Telescope marks',
      },
    }
  end,
}
