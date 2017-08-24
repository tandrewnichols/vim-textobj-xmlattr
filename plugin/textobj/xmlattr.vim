if exists('g:loaded_textobj_xmlattr')
  finish
endif

" Regexes
" Note that all regexes are surrounded by (), use that to your advantage.

" A word: `attr=value`, with no quotes.
let s:RE_WORD = '\(\w\+\)'
" An attribute name: `src`, `data-attr`, `strange_attr`.
let s:RE_ATTR_NAME = '\([a-zA-Z0-9\-_:@.]\+\)'
" A quoted string.
let s:RE_QUOTED_STR = '\(".\{-}"\)'
" A Jsx interpolated value
let s:RE_JSX = '\({.\{-}}\)'
" The value of an attribute: a word with no quotes or a quoted string.
let s:RE_ATTR_VALUE = '\(' . s:RE_QUOTED_STR . '\|' . s:RE_WORD . '\)'
" The right-hand side of an XML attr: an optional `=something` or `="str"`.
let s:RE_ATTR_RHS = '\(=' . s:RE_ATTR_VALUE . '\)\='

" The final regex.
let s:RE_HAS_JSX = '\(' . s:RE_ATTR_NAME . '=' . s:RE_JSX . '\)'
let s:RE_ATTR_I = '\(' . s:RE_ATTR_NAME . s:RE_ATTR_RHS . '\)'
let s:RE_ATTR_A = '\s\+' . s:RE_ATTR_I

call textobj#user#plugin('xmlattr', {
\   '_': {
\     'select-i-function': 'XmlTextObjI',
\     'select-i': 'ix',
\     'select-a-function': 'XmlTextObjA',
\     'select-a': 'ax',
\   },
\ })

function! XmlTextObjI()
  return s:XmlTextObj(s:RE_ATTR_I, 'i')
endfunction

function! XmlTextObjA()
  return s:XmlTextObj(s:RE_ATTR_A, 'a')
endfunction

function s:XmlTextObj(pattern, letter)
  let jsx_backward = searchpos(s:RE_HAS_JSX, 'bcWn', line('.'))
  let jsx_forward = searchpos(s:RE_HAS_JSX, 'ceWn', line('.'))
  if s:nomatch(jsx_forward) || s:nomatch(jsx_backward)
    return s:NonJsxSelection(a:pattern, a:letter)
  else
    return s:JsxSelection(jsx_backward, a:letter)
  endif
endfunction

function s:nomatch(pos)
  return a:pos[0] is 0 && a:pos[1] is 0
endfunction

function s:NonJsxSelection(pattern, letter)
  let selections = textobj#user#select(a:pattern, 'N', '<mode>')
  if selections isnot 0
    let [start, end] = selections
    return ['v', s:pad(start), s:pad(end)]
  else
    return 0
  endif
endfunction

function s:JsxSelection(pos, letter)
  let jsx_start = a:pos
  call cursor(jsx_start)
  normal! f{%
  let jsx_end = getpos('.')[1:2]
  if (a:letter ==? 'a')
    let jsx_start[1] = jsx_start[1] - 1
  endif
  return ['v', s:pad(jsx_start), s:pad(jsx_end)]
endfunction

function s:pad(list)
  return [0] + a:list
endfunction

let g:loaded_textobj_xmlattr = 1
