
if zettel#iszettel()
  if strridx(&filetype,'.zettel') == -1  
    let &filetype=&filetype . '.zettel'
  endif
endif
