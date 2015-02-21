command! -range -nargs=* ReachMark <line1>;<line2>g/\m^/if empty(<q-args>) || <args> | call reach#mark(line(".")) | endif
command! -range ReachUnmark call map(range(<line1>, <line2>), 'reach#unmark(v:val)')
command! ReachList call reach#do()
command! ReachClear call reach#clear()
command! -nargs=+ ReachDo call reach#do(<q-args>)
