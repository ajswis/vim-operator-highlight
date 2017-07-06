" Copyright (C) 2011 by Strahinja Markovic
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.

if exists( 'g:loaded_operator_highlight' )
  finish
else
  let g:loaded_operator_highlight = 1
endif

if !exists( 'g:ophigh_color_gui' )
  let g:ophigh_color_gui = "cyan"
endif

if !exists( 'g:ophigh_highlight_link_group' )
  let g:ophigh_highlight_link_group = ""
endif

if !exists( 'g:ophigh_container_color_gui' )
  let g:ophigh_container_color_gui = "orange"
endif

if !exists( 'g:ophigh_highlight_container_link_group' )
  let g:ophigh_highlight_container_link_group = ""
endif

if !exists( 'g:ophigh_color' )
  let g:ophigh_color = "cyan"
endif

if !exists( 'g:ophigh_container_color' )
  let g:ophigh_container_color = "cyan"
endif

if !exists( 'g:ophigh_filetypes_to_ignore' )
  let g:ophigh_filetypes_to_ignore = {}
endif

fun! s:IgnoreFiletypeIfNotSet( file_type )
  if get( g:ophigh_filetypes_to_ignore, a:file_type, 1 )
    let g:ophigh_filetypes_to_ignore[ a:file_type ] = 1
  endif
endfunction

call s:IgnoreFiletypeIfNotSet('help')
call s:IgnoreFiletypeIfNotSet('markdown')
call s:IgnoreFiletypeIfNotSet('qf') " This is for the quickfix window
call s:IgnoreFiletypeIfNotSet('conque_term')
call s:IgnoreFiletypeIfNotSet('diff')
call s:IgnoreFiletypeIfNotSet('html')
call s:IgnoreFiletypeIfNotSet('css')
call s:IgnoreFiletypeIfNotSet('less')
call s:IgnoreFiletypeIfNotSet('xml')
call s:IgnoreFiletypeIfNotSet('sh')
call s:IgnoreFiletypeIfNotSet('bash')
call s:IgnoreFiletypeIfNotSet('notes')
call s:IgnoreFiletypeIfNotSet('jinja')
" Too many edge cases
call s:IgnoreFiletypeIfNotSet('eruby')
call s:IgnoreFiletypeIfNotSet('jsp')
call s:IgnoreFiletypeIfNotSet('haml')
call s:IgnoreFiletypeIfNotSet('coffee')

fun! s:HighlightOperators()
  if get( g:ophigh_filetypes_to_ignore, &filetype, 0 )
    return
  endif

  " Ruby edgecases:
  "   add :: and : but ignore for ruby symbols
  "   block params | hightlighting
  if (&filetype == "ruby")
    "syn match OperatorChars +/\(.\{-}/\)\@!+ " FIXME: regex region match
    syn match OperatorChars /::\|:\(\w\)\@!/
    syn match OperatorChars /||\||=\||\(\d\)\@=\||\(\w\)\@!\(.\{-\}|\)\@!/
  else
    syn match OperatorChars /[|:]/
  endif

  " LaTeX edgecase: % is special
  if !(&filetype == "tex")
    syn match OperatorChars /%/
  endif

  " Lua comment edgecase: highlight -, but not --
  if (&filetype == "lua")
    syn match OperatorChars /-\(-\)\@!/
  else
    syn match OperatorChars /-/
  endif

  " Go type assertion edgecase: consuming both . and ( clobers go type assertion
  " region matching
  if (&filetype == "go")
    syn match OperatorChars /\.\((\)\@!/
  else
    syn match OperatorChars /\./
  endif

  syn match OperatorChars +/\(/\|*\)\@!+
  " These are generally safe...
  syn match OperatorChars /[?+*;,<>&!~=]/

  syn region ParenContainer   matchgroup=ContainerChars start=/(/ end=/)/ transparent
  syn region BraceContainer   matchgroup=ContainerChars start=/{/ end=/}/ transparent
  syn region BracketContainer matchgroup=ContainerChars start=/\[/ end=/\]/ transparent

  if g:ophigh_highlight_link_group != ""
    exec "hi link OperatorChars " . g:ophigh_highlight_link_group
  else
    exec "hi OperatorChars guifg=" . g:ophigh_color_gui . " gui=NONE"
    exec "hi OperatorChars ctermfg=" . g:ophigh_color . " cterm=NONE"
  endif

  if g:ophigh_highlight_container_link_group != ""
    exec "hi link ContainerChars " . g:ophigh_highlight_container_link_group
  else
    exec "hi ContainerChars guifg=" . g:ophigh_container_color_gui . " gui=NONE"
    exec "hi ContainerChars ctermfg=" . g:ophigh_container_color . " cterm=NONE"
  endif

endfunction

au Syntax * call s:HighlightOperators()
au ColorScheme * call s:HighlightOperators()

