----------------------------------------------------------------------------------------------------
##### Modes

```
1.  Change to normal mode           : <ctrl-c> or <esc> (normal mode) 

2.  Change to insert mode           : i

3.  Change to visual mode           : v
```

----------------------------------------------------------------------------------------------------
##### Files, Buffers and Panes (Normal Mode)

```
1.  Open file                       : :e <filename>

2.  Write file                      : w and w <filename>

3.  Create new file                 : :n and :n! (discard changes)

4.  Reload file                     : :e

5.  Open directory explorer         : :e .

6.  Close file                      : q and q! (discard changes).

7.  Save file and close             : ZZ

8.  List Buffers                    : :ls

9.  Open Buffer                     : :b <buffer name> and :b <buffer number>
```

----------------------------------------------------------------------------------------------------
#### Vim Windows (Normal Mode - All windows commands begin with: <ctrl-W>)

```
1.  New window                      : <ctrl-W>n

2.  Window navigation               : <ctrl-W>k (up) and ctrl-W>j (down)
                                    : <ctrl-W>h (left) and ctrl-W>l (right)
                                    : <ctrl-W>w (cycle)

3.  Adjust window size              : <ctrl-w>+ (increase) and <ctrl-w>- (decrease)
                                    : <ctrl-w>_ (maximise) and <ctrl-w>= (equalize)
```

----------------------------------------------------------------------------------------------------
#### Vim Panes (Normal Mode)

```
1.  Create vertical split pane      : :sv <filename>

2.  Create horizontal split pane    : :vs <filename>
```

----------------------------------------------------------------------------------------------------
#### Vim Tabs (Normal Mode)

```
1.  New tab                         : :tabe <filename>

2.  Tab movement                    : :tabp (previous), :tabn (next)
```

----------------------------------------------------------------------------------------------------
#### File Movement (Normal Mode)

1.  Cursor movement                 : h (left), j (down), k(up), and l (right)

2.  Word movement                   : b (begining of word), e (end of word)
                                    : w (begining of next word)

3.  Line movement                   : 0 (start) and $ (end)
                                    : ^ (first non-whitespace) 

4.  Paragraph movement              : { (previous blank line) and } (next blank line)

5.  File line movement              : gg (start) and G (end)
                                    : 5G (go to line 5)

6.  File scroll movement            : <ctrl-B> (up full screen) and <ctrl-F> (down full screen)
                                    : <ctrl-U> (up half screen) and <ctrl-D> (down half screen)
                                    : <ctrl-Y> (up one line) and <ctrl-E> (down one line)
                                    : zz (ctentre cursor line)

7.  Marker based movement           : mx (set marker x)
                                    : 'x (go to mark x) and '' (go back to last point before jump)
                                    : '. (go back to last edit point)

8.  Number powered movement         : 5w (forward 5 words), 3b (back 3 words)


----------------------------------------------------------------------------------------------------
##### Inserting (Normal Mode) => (Insert Mode)

```
1.  Insert text                     : i (at cursor) and I (at start of line).

2.  Append text                     : a (after cursor) and A (at end of line).

3.  Insert new line                 : O (open above cursor) and o (open below cursor).
```

----------------------------------------------------------------------------------------------------
##### Changing (Normal Mode) 

1.  Change single character         : s

2.  Replace character               : r, e.g. rq (replace current character with q) and R (multiple chracters)

3.  Swap characters                 : xp (cute character to buffer and pastes) 

4.  Change word                     : cw (change to end of word) and bcw (change word) 

5.  Change line                     : C (change to end of line) and cc (change whole line)

6.  Change block                    : c<motion> (change text in direction of motion)

7.  Changes inside parentheses      : ci


----------------------------------------------------------------------------------------------------
##### Deleting (Normal Mode)

```
1.  Delete character                : x (delete at cursor position) and X (backspace delete)

2.  Delete word                     : dw (delete to end of word) and bdw (delete word)

3.  Delete block                    : d<motion> (delete text in direction of motion)

4.  Delete a character              : x (delete at cursor position) and X (backspace delete)
```

----------------------------------------------------------------------------------------------------
##### Cut and Paste (Normal Mode)

```
1.  Cut a word to buffer            : d, e.g. bdw (cursor must be inside word)

2.  Cut a line to buffer            : dd

3.  Copy/Yank a word to buffer      : y, e.g. byw (cursor must be inside word)

4.  Copy/Yank a line to buffer      : yy

5.  Paste buffer                    : P (paste before) and p (paste after)  

6.  Toggle past mode                : :set paste, :set nopaste, :set pastetoggle
```

----------------------------------------------------------------------------------------------------
##### Visual Blocks (Normal Mode)

```
1. Enter visual block stream mode   : v

2. Enter visual block line mode     : V

3. Enter visual block column mode   : <crtl-V>

4. Moves cursor to other block end  : o

5. Cut block into paste buffer      : d or x

6. Change block indentation         : < (unindent) and > (indent).

7. Reselect last visual block       : gv
```

----------------------------------------------------------------------------------------------------
##### Commands (Normal Mode)

```
1.  Undo                            : u (undo via history) [NB: U corrects an entire line, but, doe not use history]

2.  Redo                            : <ctrl-R> (redo via history)

3.  Repeat last editing command     : . (repeat the last command)

4.  Insert text repeatedly          : 3iSomeText<esc>
```

----------------------------------------------------------------------------------------------------
##### Searching (Normal Mode)

```
1.  Find a character on line        : f (forward), F (backward), e.g. 3fx (5th occurance of x)

2.  Find character under cursor     : ; (forward) and , (backward)

3.  Find matching parentheses       : %

4.  Find word under cursor          : * (forward) and # (backward)

5.  Search forward                  : /text_or_regex<enter> then n (find next) and N (find previous)

6.  Search backward                 : ?text_or_regex<enter> then n (find next) and N (find previous)

7.  Jump to local sumbol definition : gd and <ctrl-0> (to return)

8.  Jump to global sumbol definition: <ctrl-]> and <ctrl-T> (to return) [NB: requires tags file]
```

----------------------------------------------------------------------------------------------------
##### Syntastic

* The Syntastic plugin must be installed and configured.

* Any linters and checkers must be installed and configured globally,

```
1.  Check/Lint file                     : :SyntasticCheck

2.  Close location (error) window       : :SyntasticReset

3.  Open/Close location (error) window  : :lopen (open), :lclose (close)

4.  Next/Previous location error        : :lne[xt] and :lp[revious]
```


