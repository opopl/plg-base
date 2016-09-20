" Set up the colors for the status bar
function! base#neatstl#setcolorscheme()

    " Basic color presets
    exec 'hi User1 '.base#varget('color_normal')
    exec 'hi User2 '.base#varget('color_replace')
    exec 'hi User3 '.base#varget('color_insert')
    exec 'hi User4 '.base#varget('color_visual')
    exec 'hi User5 '.base#varget('color_position')
    exec 'hi User6 '.base#varget('color_modified')
    exec 'hi User7 '.base#varget('color_line')
    exec 'hi User8 '.base#varget('base_neatstl_color_filetype')

endfunc

" pretty mode display - converts the one letter status notifiers to words
function! base#neatstl#mode()
    redraw
    let l:mode = mode()
    
    if     mode ==# "n"  | exec 'hi User1 '.base#varget('color_normal')  | return "NORMAL"
    elseif mode ==# "i"  | exec 'hi User1 '.base#varget('color_insert')  | return "INSERT"
    elseif mode ==# "R"  | exec 'hi User1 '.base#varget('color_replace') | return "REPLACE"
    elseif mode ==# "v"  | exec 'hi User1 '.base#varget('color_visual')  | return "VISUAL"
    elseif mode ==# "V"  | exec 'hi User1 '.base#varget('color_visual')  | return "V-LINE"
    elseif mode ==# "" | exec 'hi User1 '.base#varget('color_visual')  | return "V-BLOCK"
    else                 | return l:mode
    endif
endfunc    
"
fun! base#neatstl#setup(...)

 let vv={
 	 	\ 'color_modified' : 'guifg=#ffffff guibg=#ff00ff ctermfg=15 ctermbg=5',
 	 	\ 'color_position' : 'guifg=#ffffff guibg=#000000 ctermfg=15 ctermbg=0',
 	 	\ 'color_visual'   : 'guifg=#ffffff guibg=#810085 gui=NONE ctermfg=15 ctermbg=53 cterm=NONE',
 	 	\ 'color_replace'  : 'guifg=#ffff00 guibg=#5b7fbb gui=bold ctermfg=190 ctermbg=67 cterm=bold',
		\	'color_insert'   : 'guifg=#ffffff guibg=#ff0000 gui=bold ctermfg=15 ctermbg=9 cterm=bold',
		\	'color_normal'   : 'guifg=#000000 guibg=#7dcc7d gui=NONE ctermfg=0 ctermbg=2 cterm=NONE',
		\	'separator'      : '|',
		\	'color_line'     : 'guifg=#ff00ff '
           \ .'guibg=#000000 '
           \ .'gui=bold '
           \ .'ctermfg=207 '
           \ .'ctermbg=0 '
           \ .'cterm=bold ' ,
		\	'color_filetype' : 'guifg=#000000 '
				   \ .'guibg=#00ffff '
				   \ .'gui=bold '
				   \ .'ctermfg=0 '
				   \ .'ctermbg=51 '
				   \ .'cterm=bold ' ,
 		\	}

  for [k,v] in items(vv)
		let vname='neatstl_'.v
		if !base#varexists(vname)
			call base#varset(vname,v)
		endif
  endfor
  
  call base#neatstl#setcolorscheme()

endf

call base#neatstl#setup()

"==============================================================================
"==============================================================================

"if has('statusline')

    " set up color scheme now
    "call base#neatstl#SetColorscheme()

    " Status line detail:
    " -------------------
    "
    " %f    file name
    " %F    file path
    " %y    file type between braces (if defined)
    "
    " %{v:servername}   server/session name (gvim only)
    "
    " %<    collapse to the left if window is to small
    "
    " %( %) display contents only if not empty
    "
    " %1*   use color preset User1 from this point on (use %0* to reset)
    "
    " %([%R%M]%)   read-only, modified and modifiable flags between braces
    "
    " %{'!'[&ff=='default_file_format']}
    "        shows a '!' if the file format is not the platform default
    "
    " %{'$'[!&list]}  shows a '*' if in list mode
    " %{'~'[&pm=='']} shows a '~' if in patchmode
    "
    " %=     right-align following items
    "
    " %{&fileencoding}  displays encoding (like utf8)
    " %{&fileformat}    displays file format (unix, dos, etc..)
    " %{&filetype}      displays file type (vim, python, etc..)
    "
    " #%n   buffer number
    " %l/%L line number, total number of lines
    " %p%   percentage of file
    " %c%V  column number, absolute column number
    " &modified         whether or not file was modified
    "
    " %-5.x - syntax to add 5 chars of padding to some element x
    "
    "function! SetStatusLineStyle()

        "" Determine the name of the session or terminal
        "if (strlen(v:servername)>0)
            "" If running a GUI vim with servername, then use that
            "let g:neatstatus_session = v:servername
        "elseif !has('gui_running')
            "" If running CLI vim say TMUX or use the terminal name.
            "if (exists("$TMUX"))
                "let g:neatstatus_session = 'tmux'
            "else
                "" Giving preference to color-term because that might be more
                "" meaningful in graphical environments. Eg. my $TERM is
                "" usually screen256-color 90% of the time.
                "let g:neatstatus_session = exists("$COLORTERM") ? $COLORTERM : $TERM
            "endif
        "else
            "" idk, my bff jill
            "let g:neatstatus_session = '?'
        "endif

    "endfunc

    "FIXME: hack to fix the repeated statusline issue in console version
    "if !has('gui_running')
        "au InsertEnter  * redraw!
        "au InsertChange * redraw!
        "au InsertLeave  * redraw!
    "endif

    "" whenever the color scheme changes re-apply the colors
    "au ColorScheme * call base#neatstl#SetColorscheme()

    "" Make sure the statusbar is reloaded late to pick up servername
    "au ColorScheme,VimEnter * call base#neatstl#SetStatusLineStyle()

    "" Switch between the normal and vim-debug modes in the status line
    "nmap _ds :call SetStatusLineStyle()<CR>
    "call SetStatusLineStyle()
    "" Window title
    "if has('title')
        "set titlestring="%t%(\ [%R%M]%)".expand(v:servername)
    "endif
"endif


