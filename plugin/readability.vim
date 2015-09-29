"==============================================================================
"Script Title: Readability per line
"Script Version: 0.0.1
"Author: Peter Ondrejka
"User Commands:
"	:ReadGradeOn
"	:ReadGradeOff
"==============================================================================

if exists('g:read_loaded') || &cp || version < 700
    finish
endif
let g:read_loaded = 1

" sign column active?
let gutterOn = 0

" setting highlight groups
execute "highlight hlDumb guifg=#000000 guibg=#41ae76"
execute "highlight hlEasy guifg=#000000 guibg=#238b45"
execute "highlight hlMedium guifg=#000000 guibg=#006d2c"
execute "highlight hlHard guifg=#000000 guibg=#ff6666"
execute "highlight hlBloat guifg=#000000 guibg=#ff0000"

" iterate lines for sign placement
fun! ReadGradeEnable()
  let l:winview = winsaveview()
  if g:gutterOn == 1
    call ReadGradeDisable()
  endif
  :g/.*/call PlaceLoop()
  let g:gutterOn = 1
  call winrestview(l:winview)
endf

" iterate lines for sign removal
fun! ReadGradeDisable()
  let l:winview = winsaveview()
  :g/.*/call UnplaceLoop()
  let g:gutterOn = 0
  call winrestview(l:winview)
endf

" classification and placing signs
fun! PlaceLoop()
  let curr_line = getline('.')
  call FleschKincaidGrade(curr_line)
  let grade = g:funreturn

  if grade != 0
    if 5 > grade
      execute "sign define dumb texthl=hlDumb text=" . grade
      execute 'sign place '.line(".").' name=dumb line='.line(".").' buffer='.winbufnr(0)
    elseif 10 > grade
      execute "sign define easy texthl=hlEasy text=" . grade
      execute 'sign place '.line(".").' name=easy line='.line(".").' buffer='.winbufnr(0)
    elseif 15 > grade
      execute "sign define medium texthl=hlMedium text=" . grade
      execute 'sign place '.line(".").' name=medium line='.line(".").' buffer='.winbufnr(0)
    elseif 20 > grade
      execute "sign define hard texthl=hlHard text=" . grade
      execute 'sign place '.line(".").' name=hard line='.line(".").' buffer='.winbufnr(0)
    else
      execute "sign define bloat texthl=hlBloat text=" . grade
      execute 'sign place '.line(".").' name=bloat line='.line(".").' buffer='.winbufnr(0)
    endif
  endif
endf

" removing signs
fun! UnplaceLoop()
  execute 'sign unplace '.line(".").' buffer='.winbufnr(0)
endf

" python function that calculates the index
fun! FleschKincaidGrade(inTxt)
  python << endpython

import vim
from textstat.textstat import textstat
import re

inTxt = vim.eval("a:inTxt")
unwanted = re.compile(r'\<filename>(.*?)\</filename>|\<command>(.*?)\</command>|\<option>(.*?)\<option>|\<package>(.*?)\</package>|\<screen>(.*?)\</screen>|\<synopsis>(.*?)\</synopsis>|\<xref(.*?)/>|\<ulink(.*?)\</ulink>')

if (textstat.sentence_count(inTxt) == 0):
  index = 0
elif (textstat.flesch_kincaid_grade(inTxt) <= 0):
  index = 0
else:
  stripped = re.sub(unwanted, "", inTxt)
  stripped = re.sub("<.*?>", "", stripped)
  if (textstat.sentence_count(stripped) != 0):
    index = textstat.flesch_kincaid_grade(stripped)

index = int(index)
vim.command("let g:funreturn="+str(index))

endpython
endf

" user commands
command! ReadGradeOn call ReadGradeEnable()
command! ReadGradeOff call ReadGradeDisable()
