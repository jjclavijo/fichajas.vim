" JavierZettel
"
:vnoremap gx y:!gio open "<C-r>""<CR><CR>

:vnoremap <C-t> y :call zettel#open_tag('<C-r>"')<CR>
:nnoremap <C-t> :call zettel#open_tag()<CR>
:nnoremap <C-t><C-t> :call zettel#preview_links()<CR>
:nnoremap <C-o> :call zettel#review_links()<CR>
:nnoremap <C-t><C-o> :call zettel#review_links()<CR>
:nnoremap <C-t><C-t><C-t> :call zettel#set_link()<CR>

:nnoremap zzo :call zettel#open_tag()<CR>
:nnoremap zzl :call zettel#review_links()<CR>
:nnoremap zzy :call zettel#copy_this_zettel_name()<CR>

:nnoremap zzb :call zettel#fzbacklinks()<CR>

:nnoremap zzf :call zettel#fzlinks()<CR>

command NewZettel execute 'new' . zettel#get_tsname().'.md'

" unite zotero citation

let g:citation_vim_mode="zotero"
let g:citation_vim_zotero_path="~/Zotero" 
let g:citation_vim_zotero_version=5

let g:citation_vim_zotero_attachment_path="~/PDFZotero" 

let g:citation_vim_cache_path='~/.vim/citation_cache/'

let g:citation_vim_outer_prefix="["
let g:citation_vim_inner_prefix="@"
let g:citation_vim_suffix="]"

let g:citation_vim_et_al_limit=2

" Keybinds

nmap <leader>u [unite]
nnoremap [unite] <nop>

nnoremap <silent>[unite]c :<C-u>Unite -buffer-name=citation-start-insert -default-action=append citation/key<cr>
nnoremap <silent>[unite]co :<C-u>Unite -input=<C-R><C-W> -default-action=start -force-immediately citation/file<cr>
nnoremap <silent><leader>cu :<C-u>Unite -input=<C-R><C-W> -default-action=start -force-immediately citation/url<cr>
nnoremap <silent>[unite]cf :<C-u>Unite -input=<C-R><C-W> -default-action=file -force-immediately citation/file<cr>
nnoremap <silent>[unite]ci :<C-u>Unite -input=<C-R><C-W> -default-action=preview -force-immediately citation/combined<cr>
nnoremap <silent>[unite]cp :<C-u>Unite -default-action=yank citation/your_source_here<cr>
nnoremap <silent>[unite]cs :<C-u>Unite  -default-action=yank  citation/key:<C-R><C-W><cr>
vnoremap <silent>[unite]cs :<C-u>exec "Unite  -default-action=start citation/key:" . escape(@*,' ') <cr>
nnoremap <silent>[unite]cx :<C-u>exec "Unite  -default-action=start citation/key:" . escape(input('Search Key : '),' ') <cr>
































