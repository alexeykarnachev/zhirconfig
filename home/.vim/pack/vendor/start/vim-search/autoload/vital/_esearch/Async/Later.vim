" ___vital___
" NOTE: lines between '" ___vital___' is generated by :Vitalize.
" Do not modify the code nor insert new lines before '" ___vital___'
function! s:_SID() abort
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze__SID$')
endfunction
execute join(['function! vital#_esearch#Async#Later#import() abort', printf("return map({'set_max_workers': '', 'call': '', 'get_max_workers': '', 'set_error_handler': '', 'get_error_handler': ''}, \"vital#_esearch#function('<SNR>%s_' . v:key)\")", s:_SID()), 'endfunction'], "\n")
delfunction s:_SID
" ___vital___
let s:tasks = []
let s:workers = []
let s:max_workers = 50
let s:error_handler = v:null

function! s:call(fn, ...) abort
  call add(s:tasks, [a:fn, a:000])
  if empty(s:workers)
    call add(s:workers, timer_start(0, s:Worker, { 'repeat': -1 }))
  endif
endfunction

function! s:get_max_workers() abort
  return s:max_workers
endfunction

function! s:set_max_workers(n) abort
  if a:n <= 0
    throw 'vital: Async.Later: the n must be a positive integer'
  endif
  let s:max_workers = a:n
endfunction

function! s:get_error_handler() abort
  return s:error_handler
endfunction

function! s:set_error_handler(handler) abort
  let s:error_handler = a:handler
endfunction

function! s:_default_error_handler() abort
  let ms = split(v:exception . "\n" . v:throwpoint, '\n')
  echohl ErrorMsg
  for m in ms
    echomsg m
  endfor
  echohl None
endfunction

function! s:_worker(...) abort
  if v:dying
    return
  endif
  let n_workers = len(s:workers)
  if empty(s:tasks)
    if n_workers
      call timer_stop(remove(s:workers, 0))
    endif
    return
  endif
  try
    call call('call', remove(s:tasks, 0))
  catch
    if s:error_handler is# v:null
      call s:_default_error_handler()
    else
      call s:error_handler()
    endif
  endtry
  if n_workers < s:max_workers
    call add(s:workers, timer_start(0, s:Worker, { 'repeat': -1 }))
  endif
endfunction

let s:Worker = funcref('s:_worker')
