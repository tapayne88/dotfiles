#!/usr/bin/env bash

languages="$XDG_CONFIG_HOME/tmux-chtsh/languages"
commands="$XDG_CONFIG_HOME/tmux-chtsh/commands"

selected=$(cat "$languages" "$commands" | fzf)
if [[ -z $selected ]]; then
    exit 0
fi

read -r -p "Enter Query: " query

if grep -qs "$selected" "$languages"; then
    query=$(echo "$query" | tr ' ' '+')
    if bat --list-languages | grep -i "\b$selected\b"; then
        syntax="--language $selected"
    else
        syntax=""
    fi
    tmux neww bash -c "echo \"curl cht.sh/$selected/$query/\" & curl -s cht.sh/$selected/$query\?T | bat --paging always --style plain $syntax"
else
    tmux neww bash -c "echo \"curl cht.sh/$selected~$query/\" & curl -s cht.sh/$selected~$query\?T | bat --paging always --style plain --language bash"
fi
