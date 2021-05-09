let s:is_win = has('win32') || has('win64')
let s:job = v:null
let s:ctx = v:null

function! asyncomplete#tabnine#completor(opt, ctx)
    call s:get_response(a:opt, a:ctx)
endfunction

function! asyncomplete#tabnine#get_source_options(opts)
    call s:start_tabnine()
    return a:opts
endfunction

function! s:start_tabnine() abort
    let l:cmd = [
      \   'TabNine',
      \   '--log-file-path',
      \   '/tmp/tabnine.log',
      \ ]
    if has('nvim')
        let s:job = jobstart(l:cmd, {'on_stdout': function('s:on_stdout')})
    else
        let l:job = job_start(l:cmd, {'out_cb': function('s:out_cb')})
        if job_status(l:job) == 'run'
            let s:job = l:job
        endif
    endif
endfunction

function! s:get_response(opt, ctx) abort
    let l:config = get(a:opt, 'config', {'line_limit': 1000, 'max_num_result': 10})
    let l:line_limit = get(l:config, 'line_limit', 1000)
    let l:max_num_result = get(l:config, 'max_num_result', 10)
    let l:pos = getpos('.')
    let l:last_line = line('$')
    let l:before_line = max([1, l:pos[1] - l:line_limit])
    let l:before_lines = getline(l:before_line, l:pos[1])
    if !empty(l:before_lines)
        let l:before_lines[-1] = l:before_lines[-1][:l:pos[2]-1]
    endif
    let l:after_line = min([l:last_line, l:pos[1] + l:line_limit])
    let l:after_lines = getline(l:pos[1], l:after_line)
    if !empty(l:after_lines)
        let l:after_lines[0] = l:after_lines[0][l:pos[2]:]
    endif

    let l:region_includes_beginning = v:false
    if l:before_line == 1
        let l:region_includes_beginning = v:true
    endif

    let l:region_includes_end = v:false
    if l:after_line == l:last_line
        let l:region_includes_end = v:true
    endif

    let l:params = {
       \   'filename': a:ctx['filepath'],
       \   'before': join(l:before_lines, "\n"),
       \   'after': join(l:after_lines, "\n"),
       \   'region_includes_beginning': l:region_includes_beginning,
       \   'region_includes_end': l:region_includes_end,
       \   'max_num_result': l:max_num_result,
       \ }
    call s:request('Autocomplete', l:params, a:opt, a:ctx)
endfunction

function! s:request(name, param, opt, ctx) abort
    let l:req = {
      \ 'version': '3.3.101',
      \ 'request': {
      \     a:name: a:param,
      \   },
      \ }

    if s:job == v:null
        return
    endif

    let l:buffer = json_encode(l:req) . "\n"
    let s:ctx = a:ctx
    if has('nvim')
        call chansend(s:job, l:buffer)
    else
        call ch_sendraw(s:job, l:buffer)
    endif
endfunction

function! s:out_cb(channel, msg) abort
    call s:complete(a:msg)
endfunction

function! s:on_stdout(channel, msg, event) abort
    for l:line in a:msg
        if l:line != ''
            call s:complete(l:line)
        endif
    endfor
endfunction

function! s:complete(msg) abort
    let l:col = s:ctx['col']
    let l:typed = s:ctx['typed']

    let l:kw = matchstr(l:typed, '\w\+$')
    let l:lwlen = len(l:kw)

    let l:startcol = l:col - l:lwlen

    let l:response = json_decode(a:msg)
    let l:words = []
    for l:result in l:response['results']
        let l:word = {}

        let l:new_prefix = get(l:result, 'new_prefix')
        if l:new_prefix == ''
            continue
        endif
        let l:word['word'] = l:new_prefix

        if get(l:result, 'old_suffix', '') != '' || get(l:result, 'new_suffix', '') != ''
            let l:user_data = {
               \   'old_suffix': get(l:result, 'old_suffix', ''),
               \   'new_suffix': get(l:result, 'new_suffix', ''),
               \ }
            let l:word['user_data'] = json_encode(l:user_data)
        endif

        let l:word['menu'] = '[tabnine]'
        if get(l:result, 'detail')
            let l:word['menu'] .= ' ' . l:result['detail']
        endif
        call add(l:words, l:word)
    endfor
    call asyncomplete#complete('tabnine', s:ctx, l:startcol, l:words)
endfunction
