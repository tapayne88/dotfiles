# Restore Oh My Zsh completion behaviors (without the conflicting completion system)
WORDCHARS=''

# Load complist module for enhanced completion menus
zmodload -i zsh/complist

# Completion behavior options
unsetopt menu_complete     # don't autoselect the first completion entry
unsetopt flowcontrol      # disable Ctrl+S/Ctrl+Q flow control
setopt auto_menu          # show completion menu on successive tab press
setopt complete_in_word   # allow completion in middle of words
setopt always_to_end      # move cursor to end after completion

# Enhanced completion menu with arrow key navigation
zstyle ':completion:*:*:*:*:*' menu select
bindkey -M menuselect '^o' accept-and-infer-next-history

# Case insensitive completion (adjust based on your preference)
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

# Process completion with colors
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
if [[ "$OSTYPE" = solaris* ]]; then
  zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm"
else
  zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"
fi

# Prioritize local directories for cd completion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Enable completion caching
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.cache/zsh

# Don't complete uninteresting system users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs '_*'

# Show ignored matches if they're the only option
zstyle '*' single-ignored show

# Load bash completion compatibility
autoload -U +X bashcompinit && bashcompinit
