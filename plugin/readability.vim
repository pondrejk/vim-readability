"==============================================================================
"Script Title: Readability per line
"Script Version: 0.1.0
"Author: Peter Ondrejka
"User Commands:
"	:ReadGradeOn
"	:ReadGradeOff
"	:ReadGradeToggle
"==============================================================================

if exists('g:read_loaded') || &cp || version < 700
  finish
endif

let g:read_loaded = 1

" sign column active?
let gutterOn = 0
let g:readability_onsave = 0

" setting highlight groups
fun! SetHlGroups()
  execute "highlight hlDumb guifg=#000000 guibg=#41ae76"
  execute "highlight hlEasy guifg=#000000 guibg=#238b45"
  execute "highlight hlMedium guifg=#000000 guibg=#006d2c"
  execute "highlight hlHard guifg=#000000 guibg=#ff6666"
  execute "highlight hlBloat guifg=#000000 guibg=#ff0000"
endf

" iterate lines for sign placement
fun! ReadGradeEnable()
  call SetHlGroups()
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

fun! ReadGradeToggle()
  if g:gutterOn == 1
    call ReadGradeDisable()
  else
    call ReadGradeEnable()
  endif
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

" ruby function that calculates the index
fun! FleschKincaidGrade(inTxt)
  ruby << EOF

require 'odyssey'

inTxt = VIM::evaluate("a:inTxt")
report = Odyssey.Flesch_kincaid_GL(inTxt, true)

if report["string_length"] == 0 or report["sentence_count"] == 0 or report["syllable_count"] == 0 or report["letter_count"] == 0 or report["word_count"] == 0 or report["average_words_per_sentence"] == 1 then
  score = 0
else if report["score"] < -9
  score = 0
else
  score = report["score"]
end
end

score = Integer(score)
VIM.command("let g:funreturn="+String(score))

EOF
endf

" user commands
command! ReadGradeOn call ReadGradeEnable()
command! ReadGradeOff call ReadGradeDisable()
command! ReadGradeToggle call ReadGradeToggle()

" autorun on save -- how to turn off by default?
if g:readability_onsave
  autocmd! BufWritePost,FileChangedShellPost * 
        \  if g:gutterOn == 1 |
        \   call ReadGradeEnable() |
        \  endif
endif
