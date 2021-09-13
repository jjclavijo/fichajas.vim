if expand('%') == ''
  if zettel#nameiszettel(getcwd()) 
    set filetype=zettelroot
    autocmd VimEnter * :call zettel#open_title()
  endif
endif
