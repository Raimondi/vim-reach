function! ReachMark(expr) range
  let keep = exists(':keeppatterns') ? 'keeppatterns ' : ''
  exec keep . a:firstline . ';' . a:lastline
        \. 'g/^/ if empty(a:expr) || eval(a:expr) | call reach#mark(line(".")) | endif'
  if !exists(':keeppatterns')
    call histdel('search', -1)
    silent .g//
  endif
endfunction

command! -range -nargs=* ReachMark <line1>;<line2>call ReachMark(<q-args>)
command! -range ReachUnmark call map(range(<line1>, <line2>), 'reach#unmark(v:val)')
command! ReachList call reach#do()
command! ReachClear call reach#clear()
command! -nargs=+ ReachDo call reach#do(<q-args>)
