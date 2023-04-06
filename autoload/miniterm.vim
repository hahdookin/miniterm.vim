vim9script

# Configuration
# g:miniterm_proportion = get(g:, "miniterm_proportion", 0.28)
# g:miniterm_position = get(g:, "miniterm_position", "bottom")

# Terminal class
def Terminal(cmd = ''): dict<any>
    final self: dict<any> = {
        bufnr: 0,
    }

    self.bufnr = term_start($SHELL, { 
        hidden: 1, 
        term_kill: 'hup' 
    })
    setbufvar(self.bufnr, "&buflisted", 0)
    if cmd != ''
        term_sendkeys(self.bufnr, $"{cmd}\<CR>")
    endif

    return self
enddef

# Terminal manager class
def TerminalManager(): dict<any>
    final self: dict<any> = {
        terminals: [],
        current: {}
    }

    # Whether or not the manager has a current terminal
    self.HasCurrent = (): bool => {
        return !self.current->empty()
    }

    self.OpenTerminal = (term: dict<any>) => {
        exec $"bot sbuffer {term.bufnr}"
        exec $"resize {float2nr(&lines * g:miniterm_proportion)}"
        setlocal winfixheight
        setlocal nonumber norelativenumber
        setlocal hidden
    }

    self.CloseTerminal = (term: dict<any>) => {
        for winid in win_findbuf(term.bufnr)
            win_execute(winid, 'close!')
        endfor
    }

    # Returns what index the terminal is in the list
    self.IndexOfTerm = (term: dict<any>): number => {
        var index = -1
        for i in range(len(self.terminals))
            var t = self.terminals[i]
            if t.bufnr == term.bufnr
                index = i
                break
            endif
        endfor
        return index
    }

    # Removes a terminal with bufnr from list if it exists
    self.RemoveBufnr = (bufnr: number) => {
        self.terminals = self.terminals->filter((i, v) => v.bufnr != bufnr)
    }

    self.AddTerm = (cmd = ''): dict<any> => {
        var term = Terminal(cmd)
        self.terminals->add(term)
        return term
    }

    self.IsTermOpen = (term: dict<any>): bool => {
        return win_findbuf(term.bufnr)->len() > 0
    }

#   - if first time (no current terminal buffer):
#       - run "Toggle" logic
#   - else
#       - if terminal window is open
#           - close that terminal window
#       - create new terminal buffer
#       - open new terminal window
    self.NewTerminal = (cmd = '') => {
        if !self.HasCurrent()
            self.ToggleTerminal(cmd)
        else
            if self.IsTermOpen(self.current)
                self.CloseTerminal(self.current)
            endif
            self.current = self.AddTerm(cmd)

            self.OpenTerminal(self.current)
        endif
    }

#   - if first time (no current terminal buffer):
#       - create a new terminal buffer
#       - set new buffer as current
#   - if terminal window is open:
#       - close terminal window
#   - else if terminal window isnt open:
#       - open terminal window
    self.ToggleTerminal = (cmd = '') => {
        if !self.HasCurrent()
            self.current = self.AddTerm(cmd)
        endif
        if self.IsTermOpen(self.current)
            self.CloseTerminal(self.current)
        else
            self.OpenTerminal(self.current)
        endif
    }

    # Get index of current terminal in terminal list
    self.CurrentIndex = (): number => {
        return self.IndexOfTerm(self.current)
    }

    # Swap current terminal to another based on an index offset
    self.OffsetTerminal = (offset: number) => {
        if len(self.terminals) > 0
            var next_index = (self.CurrentIndex() + offset) % len(self.terminals)
            while next_index < 0
                next_index += len(self.terminals)
            endwhile
            self.CloseTerminal(self.current)
            self.current = self.terminals[next_index]
            self.OpenTerminal(self.current)
        endif
    }

    # Delete the current terminal window and do NOT reopen
    self.DeleteCurrent = (dont_open_next: bool = false) => {
        if self.HasCurrent()
            # Wipe current's buffer
            self.CloseTerminal(self.current)
            self.RemoveBufnr(self.current.bufnr)
            execute $":{self.current.bufnr}bwipeout!"
            if type(self.terminals->get(-1)) == v:t_dict
                self.current = self.terminals->get(-1)
                self.OpenTerminal(self.current)
            else
                self.current = {}
            endif
        else
            Error("There are no current terminals to delete")
        endif
    }

    # Wipe all buffers managed by this
    self.DeleteAll = () => {
        self.CloseTerminal(self.current)
        for term in self.terminals
            self.RemoveBufnr(term.bufnr)
            execute $":{term.bufnr}bwipeout!"
        endfor
        self.current = {}
        self.terminals = []
    }

    # Prints out all active terminals
    # i.e. 0 1 [2] 3
    # if terminal at index 2 is the current
    self.ListTerminals = () => {
        if len(self.terminals) == 0
            echo "No terminals active"
        else
            echo self.terminals->mapnew((idx, term) => {
                return term.bufnr == self.current.bufnr ? $"[{idx}]" : $"{idx}"
            })->join(' ')
        endif
    }

    return self
enddef

####################################
# Helpers
def Error(msg: string)
    echoerr $"miniterm.vim: {msg}"
enddef

final manager = TerminalManager()
export def g:GetManager(): dict<any>
    return manager
enddef
