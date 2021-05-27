function tpm() {
  if [ "$1" = "-h" ]; then
    echo "NAME"
    echo "   tpm - a wrapper function for tmux plugin manager commands"
    echo ""
    echo "SYNOPSIS"
    echo "   tm [-h | install | update <plugin-name> | clean]"
    echo ""
    echo "OPTIONS"
    echo "   -h"
    echo "       Help, print his help message"
    echo ""
    echo "   install"
    echo "       Install all configured plugins (in .tmux.conf)"
    echo ""
    echo "   update [all | <plugin-name>]"
    echo "       Update all or <plugin-name> plugin"
    echo ""
    echo "   clean"
    echo "       Removed all non configured plugins"
    return
  fi

  if [ "$1" = "install" ]; then
    ${TMUX_PLUGIN_MANAGER_PATH}tpm/bin/install_plugins
    return
  fi
  if [ "$1" = "update" ]; then
    ${TMUX_PLUGIN_MANAGER_PATH}tpm/bin/update_plugins $2
    return
  fi
  if [ "$1" = "clean" ]; then
    ${TMUX_PLUGIN_MANAGER_PATH}tpm/bin/clean_plugins
    return
  fi
}
