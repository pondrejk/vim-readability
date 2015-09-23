vim-readability
=================

A Vim plug-in that calculates the [Flesch-Kincaid readability grade](https://en.wikipedia.org/wiki/Flesch%E2%80%93Kincaid_readability_tests) for every line in your document an displays the result in the sign column.

## Dependencies

Plug-in requires the [textstat](<https://pypi.python.org/pypi/textstat/>) python library for calculating the index.

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

## TODO

* handle xml markup, blacklist certain text elements that skew the results (URLs, commands, file paths...)
* implement other readability metrics provided by textstat
* customization and autorefresh