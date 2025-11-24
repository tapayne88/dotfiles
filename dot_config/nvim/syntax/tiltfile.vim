" Vim syntax file for Tiltfile
" Language: Tiltfile (uses Python syntax)
" Maintainer: Tom Payne

if exists("b:current_syntax")
  finish
endif

" Source Python syntax highlighting
runtime! syntax/python.vim

" Set comment string for Tiltfiles (Python-style comments)
setlocal commentstring=#\ %s

let b:current_syntax = "tiltfile"
