
if exists("b:base_current_syntax")
  finish
endif
let s:keepcpo= &cpo
set cpo&vim

let b:base_current_syntax = "vim"

syntax region IfZero start="^\s*if\s\+0\s*$" end=/^\s*endif\s*$/ keepend
highlight link IfZero Comment

