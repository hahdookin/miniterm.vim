vim9script

import autoload "miniterm.vim"

# Configuration
g:miniterm_proportion = get(g:, "miniterm_proportion", 0.28)
g:miniterm_position = get(g:, "miniterm_position", "bottom")

# Helper to map in normal and terminal mode
def TerminalMap(map: string, com: string)
    execute "nnoremap <silent> " .. map .. " " .. com
    execute "tnoremap <silent> " .. map .. " <C-\\><C-n>" .. com
enddef

command! MinitermToggle     miniterm.GetManager().ToggleTerminal() | g:AttachWipeoutHandler(miniterm.GetManager().current)
command! MinitermNew        miniterm.GetManager().NewTerminal() | g:AttachWipeoutHandler(miniterm.GetManager().current)
command! MinitermNext       miniterm.GetManager().OffsetTerminal(1)
command! MinitermPrev       miniterm.GetManager().OffsetTerminal(-1)
command! MinitermDeleteAll  miniterm.GetManager().DeleteAll()
command! MinitermDelete     miniterm.GetManager().DeleteCurrent()

command! MinitermList       manager.GetManager().ListTerminals()

TerminalMap("<leader>tt", ":MinitermToggle<CR>")
TerminalMap("<leader>tn", ":MinitermNew<CR>")
TerminalMap("<leader>tl", ":MinitermNext<CR>")
TerminalMap("<leader>th", ":MinitermPrev<CR>")
TerminalMap("<leader>td", ":MinitermDelete<CR>")
TerminalMap("<leader>tq", ":MinitermDeleteAll<CR>")
