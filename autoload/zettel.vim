function zettel#get_link()
  let l:save_clipboard = &clipboard
  set clipboard= " Avoid clobbering the selection and clipboard registers.
  let l:save_reg = getreg('"')
  let l:save_regmode = getregtype('"')
  normal! mPyi[`P
  let l:text = @@ " Your text object contents are here.
  call setreg('"', l:save_reg, l:save_regmode)
  let &clipboard = l:save_clipboard
  if filereadable(l:text . '.md')
    return l:text
  endif

  let l:mfnames = systemlist('fd ".*' . l:text . '.*.md" .')
  if len(l:mfnames)
    return l:mfnames[0]
  endif

  let l:mftitles = systemlist('grep -li -E "^#.* ' . l:text . '" *.md')
  if len(l:mftitles)
    return l:mftitles[0]
  endif

endfunction

function zettel#get_links()
  let l:save_clipboard = &clipboard
  set clipboard= " Avoid clobbering the selection and clipboard registers.
  let l:save_reg = getreg('"')
  let l:save_regmode = getregtype('"')
  normal! mPyi[`P
  let l:text = @@ " Your text object contents are here.
  call setreg('"', l:save_reg, l:save_regmode)
  let &clipboard = l:save_clipboard

  if filereadable(l:text)
    return [[l:text,1,'']]
  endif

  if filereadable(l:text . '.md')
    return [[l:text . '.md',1,'']]
  endif

  let l:mfnames = systemlist('fd ".*' . l:text . '.*.md" .')
  let l:mfnamesQ = map(l:mfnames, {ix,a -> [a,1,''] })

  let l:mftitles = systemlist('grep -ni -E "^# .*' . l:text . '" *.md')
  let l:mftitlesQ = map(l:mftitles, {ix,a -> split(a,':') })

  let l:mallQ = l:mfnamesQ + l:mftitlesQ
  
  return l:mallQ

endfunction

function zettel#review_links()
  let l:links = zettel#get_links()
  if len(l:links) == 0
    return 1
  endif
  if len(l:links) == 1
    execute 'vnew ' . l:links[0][0]
  else
    call setqflist(map(l:links,{i,a -> {'filename':a[0], 'lnum':a[1], 'text':join(a[2:],':') } }),'r')
    copen
  endif
endfunction

function zettel#preview_links()
  let l:links = zettel#get_links()
  if len(l:links)
    let l:lines = []
    if len(l:links) > 1
      call add(l:lines,'Link Ambiguo')
      call extend(l:lines , map(l:links, {i,a -> join([a[0],join(a[2:],':'),join(systemlist('tail -n +1 "' . a[0] .'" | head -n 1'),' ')],' ')}))
    else
      call extend(l:lines , map(l:links, {i,a -> join([a[0],join(a[2:],':'),join(systemlist('tail -n +1 "' . a[0] .'" | head -n 10'),' ')],' ')}))
    endif

    call popup_atcursor(l:lines,{})

  endif
endfunction

function zettel#set_link()
  let l:links = zettel#get_links()
  if len(l:links) > 1
    let l:lines = mapnew(l:links, {i,a -> join([a[0],join(a[2:],':')],' ')})
    call popup_menu( l:lines , {'callback' : { i,r -> execute('normal! ci[' . fnamemodify(l:links[r-1][0],':r') ) }})
    return 0
  endif
  if len(l:links) == 1
    execute('normal! ci[' . fnamemodify(l:links[0][0],':r'))
  endif
endfunction

function zettel#copy_tag()
  let l:save_clipboard = &clipboard
  set clipboard= " Avoid clobbering the selection and clipboard registers.
  let l:save_reg = getreg('"')
  let l:save_regmode = getregtype('"')
  normal! mPbyE`P
  let l:text = @@ " Your text object contents are here.
  call setreg('"', l:save_reg, l:save_regmode)
  let &clipboard = l:save_clipboard
  return l:text
endfunction

function zettel#get_taged(tag)

  let l:mftitles = systemlist('grep -Hn -E "^# .*" $(grep -li "'. a:tag .'" *.md)')
  let l:mftitlesQ = map(l:mftitles, {ix,a -> split(a,':') })

  return l:mftitlesQ

endfunction

function zettel#preview_tag(...)
  if a:0 == 0
    let l:tag = zettel#copy_tag()
  else
    let l:tag = join(a:000,' ')
  endif

  "echo l:tag
  let l:links = zettel#get_taged(l:tag)

  if len(l:links)
    let l:lines = []
    call extend(l:lines , map(l:links, {i,a -> join([a[0],join(a[2:],':'),system('head -n 1 "' . a[0] .'"')],' ')}))

    call popup_atcursor(l:lines,{})

  endif
endfunction

function zettel#review_tag()
  let l:links = zettel#get_taged()
  if len(l:links)
    call setqflist(map(l:links,{i,a -> {'filename':a[0], 'lnum':a[1], 'text':join(a[2:],':') } }),'r')
    copen
  endif
endfunction

function Otcb(lines,i,r)
  if a:r == -1
    return -1
  else
    execute 'new' . a:lines[a:r -1][0]
    return 0
  endif
endfunction

function zettel#open_tag(...)
  if a:0 == 0
    let l:tag = zettel#copy_tag()
  else
    let l:tag = join(a:000,' ')
  endif

  "echo l:tag
  let l:links = zettel#get_taged(l:tag)

  if len(l:links) > 0
    let l:lines = mapnew(l:links, {i,a -> join([a[0],join(a[2:],':')],' ')})
    "call popup_menu( l:lines , {'callback' : { i,r -> execute('normal! :new ' . l:links[r-1][0] . '<CR>' ) }})
    call popup_menu( l:lines , {'callback' : funcref("Otcb",[l:links]) })
    return 0
  endif
  "if len(l:links) == 1
  "  execute('new ' . l:links[0][0] . '<CR>' )
  "endif
endfunction

function zettel#get_tsname()
  let l:name = systemlist("date -u -Iseconds | sed 's/\+.*//;s/[^0-9]//g'")[0]
  return l:name
endfunction

"function zettel#iszettel(...)
"  if a:0 == 0
"    let l:patt = '%:p'
"  else
"    let l:patt = a:1
"  endif
"
"  let l:file = expand(l:patt.':h')
"
"  if l:file == '/'
"    return 0
"  endif
"
"  if filereadable(l:file.'/.zettel')
"    return 1
"  else 
"    return zettel#iszettel(l:patt.':h')
"  endif
"endfunction


function zettel#nameiszettel(name)
  if a:name == '/'
    return 0
  endif
  if a:name == '.'
    let a:name = fnamemodify(a:name,':p:h')
  endif

  if filereadable(a:name.'/.zettel')
    return 1
  else 
    return zettel#nameiszettel(fnamemodify(a:name,':h'))
  endif
endfunction

function zettel#iszettel()
  return zettel#nameiszettel(expand('%:p'))
endfunction

function zettel#get_titles()

  let l:mftitles = systemlist('grep -ni -E "^# .*" *.md')
  let l:mftitlesQ = map(l:mftitles, {ix,a -> split(a,':') })

  return l:mftitlesQ
endfunction

function Ofcb(lines,i,r)
  if a:r == -1
    return -1
  else
    execute 'badd' . a:lines[a:r -1][0]
    execute 'bdelete'
    "let @/ = a:lines[a:r -1][1]
    "execute 'normal n' 
    execute a:lines[a:r -1][1]
    return 0
  endif
endfunction

function zettel#open_title()
  let l:links = zettel#get_titles()

  if len(l:links) > 0
    let l:lines = mapnew(l:links, {i,a -> join([a[0],join(a[2:],':')],' ')})
    "call popup_menu( l:lines , {'callback' : { i,r -> execute('normal! :new ' . l:links[r-1][0] . '<CR>' ) }})
    call popup_menu( l:lines , {'callback' : funcref("Ofcb",[l:links]), 'maxheight': &lines - 5, 'filter': 'MyMenuFilter' })
    return 0
  endif
  "if len(l:links) == 1
  "  execute('new ' . l:links[0][0] . '<CR>' )
  "endif
endfunction

func MyMenuFilter(id, key)
  " Handle shortcuts
  "if a:key == 's'
  "  call popup_hide(a:id)
  "  call popup_menu(['1','2','3'],{})
  "  call popup_show(a:id)
  "endif

  if a:key == 'l'
    for l:v in [1,2,3,4,5,6,7,8,9,10]
      call popup_filter_menu(a:id, 'k')
    endfor
  endif

  if a:key == 'h'
    for l:v in [1,2,3,4,5,6,7,8,9,10]
      call popup_filter_menu(a:id, 'j')
    endfor
  endif

  " No shortcut, pass to generic filter
  return popup_filter_menu(a:id, a:key)
endfunc
