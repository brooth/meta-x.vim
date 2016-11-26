" File: meta-x.vim
" Description: insane.vim - Don't be wild. Be insane!
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

" todos {{{
" BETA 1
" buffer handler, show number + easycomplete?
" up/down - history, shortcut for history complete as well
" paste from registers
" sub favorits. related to part. commands
" while/black list for autocompletion. '!^' black by default
" substitute (and others) preview. show first found item and result above
" substitude complete from current buff
" '$' prefix for shell commands
" auto cancel cmd entering by timeout. ability to continue cancelled cmd
" try to hide cursor if possible
" find all buildin command abbrevs. auto +10 priority if matched.
"   show like "h[elp]" in completion
" BETA 2
" auto priority by MRU
" multiple complete drawers (cycle, flow, list, table)
" auto pairs
" snippets: ":s -> :s/{0}/{1}/{3='g'}" ; jump between {} by tab
" }}}

" syntax {{{
hi def link MxCommand Macro
hi def link MxComplete Comment
hi def link MxCursor Cursor
hi def link MxEasyRun Keyword
hi def link MxEasyComplete Include
" }}}

function! MetaX(line) "{{{
    call mx#tools#log('============== META-X (' . a:line . ') ===============')
    let ctx = {'cmd' : a:line}
    call mx#loop(ctx)
endfunction "}}}

" mapping {{{
cnoremap <C-t>c <C-\>e(mx#tools#cutcmdline())<CR>
cnoremap <C-t>p <C-\>e(mx#tools#getcmdpos())<CR>
cnoremap <C-t>P <C-\>e(mx#tools#setcmdpos())<CR>
nnoremap <c-j> :call MetaX('')<cr>
"}}}

" vim: set et fdm=marker sts=4 sw=4:
