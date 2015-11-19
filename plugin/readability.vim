"==============================================================================
"Script Title: Readability per line
"Script Version: 0.1.1
"Author: Peter Ondrejka
"User Commands:
"	:ReadGradeOn
"	:ReadGradeOff
"	:ReadGradeToggle
"==============================================================================

if exists('g:read_loaded') || &cp || version < 700
  finish
endif

if &hls
  let g:is_hlsearch = 1
endif

let g:read_loaded = 1

" sign column active?
let gutterOn = 0

" redraw on save
let g:readability_onsave = 0

" enable_blacklist
let g:readability_blacklist_on = 0
let g:readability_blacklist_path = ".vim/bundle/vim-readability/blacklist.txt"
let g:readability_blacklist = []
if g:readability_blacklist_on
  let g:readability_blacklist = CompileBlacklist()
end

" coloring -- GUI
let g:read_guifg = "#000000"
let g:read_guibg_dumb="#41ae76"
let g:read_guibg_easy="#238b45"
let g:read_guibg_medium="#006d2c"
let g:read_guibg_hard="#ff6666"
let g:read_guibg_bloat="#ff0000"

" coloring -- console
let g:read_ctermfg = "Black"
let g:read_ctermbg_dumb="LightGreen"
let g:read_ctermbg_easy="Green"
let g:read_ctermbg_medium="DarkGreen"
let g:read_ctermbg_hard="LightMagenta"
let g:read_ctermbg_bloat="Red"

" setting highlight groups
fun! SetHlGroups()
  execute "highlight hlDumb guifg="g:read_guifg " guibg="g:read_guibg_dumb " ctermfg="g:read_ctermfg "ctermbg="g:read_ctermbg_dumb ""
  execute "highlight hlEasy guifg="g:read_guifg " guibg="g:read_guibg_easy "ctermfg="g:read_ctermfg "ctermbg="g:read_ctermbg_easy ""
  execute "highlight hlMedium guifg="g:read_guifg " guibg="g:read_guibg_medium "ctermfg="g:read_ctermfg "ctermbg="g:read_ctermbg_medium ""
  execute "highlight hlHard guifg="g:read_guifg " guibg="g:read_guibg_hard "ctermfg="g:read_ctermfg "ctermbg="g:read_ctermbg_hard ""
  execute "highlight hlBloat guifg="g:read_guifg " guibg="g:read_guibg_bloat "ctermfg="g:read_ctermfg "ctermbg="g:read_ctermbg_bloat ""
endf

" iterate lines for sign placement
fun! ReadGradeEnable()
  call SetHlGroups()
  if g:is_hlsearch
    set nohls
  endif
  let l:winview = winsaveview()
  if g:gutterOn == 1
    call ReadGradeDisable()
  endif
  :g/.*/call PlaceLoop()
  let g:gutterOn = 1
  call winrestview(l:winview)
  if g:is_hlsearch
    set hls
  endif
endf

" iterate lines for sign removal
fun! ReadGradeDisable()
  if g:is_hlsearch
    set nohls
  endif
  let l:winview = winsaveview()
  :g/.*/call UnplaceLoop()
  let g:gutterOn = 0
  call winrestview(l:winview)
  if g:is_hlsearch
    set hls
  endif
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
blacklist = VIM::evaluate("g:readability_blacklist")

unless blacklist.empty? then
   tmpArray = inTxt.scan(/[\w'-]+|[[:punct:]]+/)
   inTxt = tmpArray.delete_if{|x| blacklist.include?(x.downcase)}.join(' ')
end 

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

" load blacklist
fun! CompileBlacklist()
  return readfile(g:readability_blacklist_path)
endf

" user commands
command! ReadGradeOn call ReadGradeEnable()
command! ReadGradeOff call ReadGradeDisable()
command! ReadGradeToggle call ReadGradeToggle()

" autorun on save
if g:readability_onsave
  autocmd! BufWritePost,FileChangedShellPost * 
        \  if g:gutterOn == 1 |
        \   call ReadGradeEnable() |
        \  endif
endif
