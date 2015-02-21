let s:sign = 'reach_marks'
silent! exec 'sign define ' . s:sign . ' linehl= text==> texthl=WarningMsg'

function! reach#mark(lnum)
  let next_id = s:top_id() + 1
  silent exec 'sign place ' . next_id . ' line=' . a:lnum
        \ . ' name=' . s:sign . ' buffer=' . bufnr('%')
endfunction

function! reach#unmark(lnum)
  for id in s:get_signs(a:lnum)
    silent! exec 'sign unplace ' . id . ' buffer=' . bufnr('%')
  endfor
endfunction

function! reach#is_marked(lnum)
  return !empty(s:get_signs(a:lnum))
endfunction

function! reach#do(...)
  " TODO when should the signs be removed? before/after every run of the given
  " command, at the begginning/end of the whole thing or not at all?
  " XXX using a pattern could be slow for files with a lot (thousands?)
  " of marked lines but it's the simplest way right now.
  let cmd = get(a:, 1, '')
  let pat = join(map(keys(s:get_signs()), '"\\%".v:val."l"'), '\|')
  if empty(pat)
    " say something
    return
  endif
  let keep = exists(':keeppatterns') ? 'keeppatterns ' : ''
  exec keep . 'g/\m' . pat . '/' . cmd
  if !exists(':keeppatterns')
    call histdel('search', -1)
    silent .g//
  endif
endfunction

function! reach#list()
  return sort(map(keys(s:get_signs()), 'str2nr(v:val)'))
endfunction

function! reach#clear()
  let ids = []
  call map(values(s:get_signs()), 'extend(ids, v:val)')
  for id in ids
    silent! exec 'sign unplace ' . id . ' buffer=' . bufnr('%')
  endfor
endfunction

function! s:top_id()
  let output = s:redir('sign place')
  let lines = map(split(output, '\n')[2:], 'split(v:val, ''\s\+\w\+='')')
  call filter(lines, 'v:val[0] =~# "^\\d"')
  call map(lines, 'v:val[1]')
  if empty(lines)
    return -1
  endif
  return max(lines)
endfunction

function! s:get_signs(...)
  let lines = split(s:redir('sign place buffer=' . bufnr('%')), '\n')
  call map(lines, 'split(v:val, ''\s\+\w\+='')')
  call filter(lines, 'len(v:val) == 3 && v:val[2] ==# s:sign')
  let lnums = {}
  while !empty(lines)
    let [lnum, id; _] = remove(lines, 0)
    if !has_key(lnums, lnum)
      let lnums[lnum] = [id]
    else
      call add(lnums[lnum], id)
    endif
  endwhile
  if a:0
    return get(lnums, a:1, [])
  endif
  return lnums
endfunction

function! s:redir(cmd)
  let lang = v:lang
  silent! language messages C
  redir => output
    silent! sign place
  redir END
  silent! exec 'language messages ' . lang
  return output
endfunction
