" File: meta-x.vim
" Description: Meta-X register handler
" Author: Oleg Khalidov <brooth@gmail.com>
" License: MIT

function! mx#handlers#register#handle(ctx) abort
    if mx#tools#isdebug()
        call mx#tools#log('mx#handlers#register#handle(' . string(a:ctx) . ')')
    endif

    if a:ctx.input == 18 "C-r
        let regctx = copy(a:ctx)
        let regctx.info = '<paste>'
        let regctx.registermode = 1
        let regctx.input = ''
        let regctx.candidates = []
        let regresult = mx#loop(regctx)
        if mx#tools#isdebug()
            call mx#tools#log('regresult:' . string(regresult))
        endif
        if has_key(regresult, 'regcontent')
            let a:ctx.cmd = a:ctx.cmd . regresult.regcontent
        elseif regresult.input == 3 "C-c
            return g:MX_RES_EXIT
        endif
        let a:ctx.input = ''
        let a:ctx.cursor = len(a:ctx.cmd)
        return
    endif

    let registermode = get(a:ctx, 'registermode')
    if registermode
        if !empty(get(a:ctx, 'error', ''))
            unlet a:ctx.error
        endif

        if a:ctx.registermode == 1 "loop started
            let a:ctx.registermode = 2
            return g:MX_RES_BREAK
        elseif registermode == 2 "simple reg mode
            if a:ctx.input == 61 "start expression mode
                let expregctx = copy(a:ctx)
                let expregctx.info = '<exp>'
                let expregctx.registermode = 3
                let expregctx.welcome_sign = '='
                let expregctx.cmd = ''
                let expregctx.input = ''
                let expregctx.candidates = []
                let expregresult = mx#loop(expregctx)
                if mx#tools#isdebug()
                    call mx#tools#log('expregresult:' . string(expregresult))
                endif
                if has_key(expregresult, 'expregcontent')
                    let a:ctx.regcontent = expregresult.expregcontent
                elseif expregresult.input == 3 "C-c
                    return g:MX_RES_EXIT
                endif
            elseif type(a:ctx.input) == 0 && getregtype(nr2char(a:ctx.input)) != ''
                let a:ctx.regcontent = getreg(nr2char(a:ctx.input))
            endif
            return g:MX_RES_EXIT
        elseif registermode == 3 "expression mode
            if a:ctx.input == 13 "CR
                try
                    let a:ctx.expregcontent = string(eval(a:ctx.cmd))
                    return g:MX_RES_EXIT
                catch
                    let a:ctx.error = v:exception
                    return g:MX_RES_BREAK
                endtry
            endif
            return
        endif
    endif
endfunction
