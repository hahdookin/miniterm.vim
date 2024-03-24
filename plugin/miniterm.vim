vim9script

import autoload "miniterm.vim"

# Configuration
g:miniterm_proportion = get(g:, "miniterm_proportion", 0.28)
g:miniterm_position = get(g:, "miniterm_position", "bottom")
g:miniterm_dont_list = get(g:, "miniterm_dont_list", false)
g:miniterm_dont_map = get(g:, "miniterm_dont_map", false)

# Helper to map in normal and terminal mode
def TerminalMap(map: string, com: string)
    execute $"nnoremap <silent> {map} {com}"
    execute $"tnoremap <silent> {map} <C-w>{com}"
enddef

command! MinitermToggle       miniterm.GetManager().ToggleTerminal()
command! -nargs=* MinitermNew miniterm.GetManager().NewTerminal(<q-args>)
command! MinitermNext         miniterm.GetManager().OffsetTerminal(1)
command! MinitermPrev         miniterm.GetManager().OffsetTerminal(-1)
command! MinitermDeleteAll    miniterm.GetManager().DeleteAll()
command! MinitermDelete       miniterm.GetManager().DeleteCurrent()

command! MinitermList       miniterm.GetManager().ListTerminals()

if !g:miniterm_dont_map
    TerminalMap("<leader>tt", ":MinitermToggle<CR>")
    TerminalMap("<leader>tn", ":MinitermNew<CR>")
    TerminalMap("<leader>tl", ":MinitermNext<CR>")
    TerminalMap("<leader>th", ":MinitermPrev<CR>")
    TerminalMap("]t", ":MinitermNext<CR>")
    TerminalMap("[t", ":MinitermPrev<CR>")
    TerminalMap("<leader>td", ":MinitermDelete<CR>")
    TerminalMap("<leader>tq", ":MinitermDeleteAll<CR>")
endif
