vim-readability
=================

A Vim plug-in that calculates the [Flesch-Kincaid readability grade](https://en.wikipedia.org/wiki/Flesch%E2%80%93Kincaid_readability_tests) for every line in your document and displays the result in the sign column.

## Dependencies

Plug-in requires the [odyssey](<https://github.com/cameronsutter/odyssey>) ruby library for calculating the index.

## Installation

* With [pathogen.vim](https://github.com/tpope/vim-pathogen):

        cd ~/.vim/bundle
        git clone git://github.com/pondrejk/vim-readability.git

* With [Vundle](https://github.com/gmarik/vundle):

        " .vimrc
        Bundle 'pondrejk/vim-readability'

## Usage

To initialize the sign column:

> :ReadGradeOn

To turn it off:

> :ReadGradeOff

There is also the `:ReadGradeToggle` command you can map to a selected key in your .vimrc, for example:

```Vim
nmap <silent> <F11> :ReadGradeToggle<CR>
imap <silent> <F11> <ESC>:ReadGradeToggle<CR>
cmap <silent> <F11> <ESC>:ReadGradeToggle<CR>
```

To automatically update the column on buffer save (disabled by default), put this into your .vimrc:

```Vim
let g:readability_onsave = 0
```

## Notes & known issues

* readability metrics provided by odyssey are designed for English only
* right now, there is just one sign column in Vim, so if you use git-gutter or similar plug-in, vim-readability will overwrite signs made by these plug-ins, sorry

## TODO

* implement other readability metrics provided by odyssey
* customization and autorefresh
