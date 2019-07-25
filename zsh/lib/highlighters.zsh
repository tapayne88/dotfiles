typeset -a -x ZSH_HIGHLIGHT_HIGHLIGHTERS
typeset -A -x ZSH_HIGHLIGHT_STYLES

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# main
ZSH_HIGHLIGHT_STYLES[default]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[command]='fg=white'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=white'
ZSH_HIGHLIGHT_STYLES[alias]='fg=white'
ZSH_HIGHLIGHT_STYLES[function]='fg=white'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[path]='fg=cyan,underline'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=blue'
ZSH_HIGHLIGHT_STYLES[command-substitution]='fg=white'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=white'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]='fg=red'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]='fg=red'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]='fg=red'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]='fg=red'

# brackets
ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=red'
ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]='bg=black'
