" ============================================================================
" File:        import_cost.vim
" Author:      Yarden Sod-Moriah
" Description: Display import size for JavaScript packages
" License:     MIT
" ============================================================================

" Initial checks {{{

if exists('g:loaded_import_cost') || &compatible
  finish
endif

let g:loaded_import_cost = 1

" Check if `node` exists in $PATH
if !executable('node')
  finish
endif

" }}}
" Settings {{{

function! s:InitSettings(settings)
  let l:template = "let g:import_cost_%s = get(g:, 'import_cost_%s', %s)"

  for [key, value] in items(a:settings)
    execute printf(l:template, key, key, string(value))
  endfor
endfunction

let s:default_settings = {
  \ 'show_gzipped': 1,
  \ 'always_open_split': 1,
  \ 'split_size': 50,
  \ 'split_pos': 'left',
  \ 'disable_async': 0,
  \ 'virtualtext': 1,
  \ 'virtualtext_hl_group': 'LineNr',
  \ 'virtualtext_prefix': ' > ',
  \ }

call s:InitSettings(s:default_settings)

" }}}
" Commands {{{

function! s:InitCommands()
  command! -buffer -range=0 ImportCost call import_cost#ImportCost(<count>, <line1>, <line2>)
  command! -buffer          ImportCostSingle call import_cost#ImportCost(1, <line1>, <line1>)

  if import_cost#IsVirtualTextSupported() && g:import_cost_virtualtext && !g:import_cost_disable_async
    augroup import_cost_auto_run
      autocmd!
      autocmd InsertLeave * call import_cost#ImportCost(0, 0 ,0)
      autocmd BufEnter * call import_cost#ImportCost(0, 0 ,0)
      autocmd CursorHold * call import_cost#ImportCost(0, 0 ,0)
    augroup END
  endif
endfunction

" }}}
" Autocommands {{{

augroup import_cost_au
  autocmd!

  autocmd FileType javascript      call <SID>InitCommands()
  autocmd FileType javascript.jsx  call <SID>InitCommands()
  autocmd FileType typescript      call <SID>InitCommands()
  autocmd FileType typescript.jsx  call <SID>InitCommands()
  autocmd FileType typescriptreact call <SID>InitCommands()
augroup END

" }}}
