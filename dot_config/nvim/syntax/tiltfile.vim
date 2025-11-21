" Vim syntax file for Tiltfile
" Language: Tiltfile (uses Python syntax)
" Maintainer: Tom Payne

if exists("b:current_syntax")
  finish
endif

" Source Python syntax highlighting
runtime! syntax/python.vim

let b:current_syntax = "tiltfile"