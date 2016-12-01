" File: meta-x.vim
" Description: insane.vim - Don't be wild. Be insane!
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

" todos {{{
" BETA 1
" escape special keys
" up/down - history, shortcut for history complete as well
" auto escape pattern 'kkkkk' as well as hjl. or same key in short period?
" horizontal scroll if longer that &column
" sub favorits. related to part. commands
" do not draw cxt too freq.? on key holding?
" buffer source, show number + easycomplete?
" substitute (and others) preview. show first found item and result above
" 	substitude complete from current buff
" '$' prefix for shell commands
" auto cancel cmd entering by timeout. show in favorits cancelled cmd
" find all buildin command abbrevs. auto +10 priority if matched. show like "h[elp]" in completion
"
" BETA 2
" try to hide cursor if possible
" multiple lines for candidates
" auto priority by MRU
" classic drawer
" snippets: ":s -> :s/{0}/{1}/{3='g'}" ; jump between {} by tab
" }}}

" syntax {{{
hi def link MxCommand Macro
hi def link MxComplete Comment
hi def link MxCursor Cursor
hi def link MxSelCandidate Nornal
hi def link MxEasyRun Keyword
hi def link MxEasyComplete Include
hi def link MxInfoMsg String
hi def link MxWarnMsg Special
hi def link MxErrorMsg Error
hi def link MxSpecialSymbols SpecialKey
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
nnoremap <silent> ; :call MetaX('')<cr>
"}}}

" vim: set et fdm=marker sts=4 sw=4:
