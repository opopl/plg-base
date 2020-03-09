
function! base#menus#add (menulist)
	let allmenus = base#varget('allmenus',{})
	for mn in a:menulist
		call base#menu#additem(get(allmenus,mn,{}))
	endfor
endfunction

if 0
	call tree
		called by
			base#init
endif

function! base#menus#init ()

		 let menus = base#qw('scp ssh buffers bufact menus')
		 for m in menus
		 		call base#menu#add(m)
		 endfor

     let allmenus = {}

     for i in base#listnewinc(1, 10, 1)
        let allmenus[ 'ToolBar.sep' . i ]=  {
             \ 'item'    : '-sep' . i .'-',  
             \ 'fullcmd' : 'an ToolBar.-sep' . i . '- <Nop>',  
             \ }
     endfor

          let menus={
            \ 'ToolBar.PlainTexRun' : {
                  \ 'icon' : 'PlainTexRun', 
                  \ 'item' : 'ToolBar.PlainTexRun', 
                  \ 'cmd'  : 'PlainTexRun', 
                  \ 'tmenu': 'PlainTexRun' },
            \ 'ToolBar.MAKE' : {
                  \ 'icon' : 'MAKE', 
                  \ 'item' : 'ToolBar.MAKE',  
                  \ 'cmd'  : 'PrjMake', 
                  \ 'tmenu': 'MAKE' },
            \ 'ToolBar.VIEWPDF' : {
                  \ 'icon' : 'VIEWPDF', 
                  \ 'item' : 'ToolBar.VIEWPDF', 
                  \ 'cmd'  : 'call DC_PrjView("pdf")', 
                  \ 'tmenu': 'View PDF' },
            \ 'ToolBar.VIEWLOG' : {
                  \ 'icon' : 'VIEWLOG',   
                  \ 'item' : 'ToolBar.VIEWLOG', 
                  \ 'cmd'  : 'call DC_PrjView("log")', 
                  \ 'tmenu': 'View TeX Log File' },
            \ 'ToolBar.MAIN' : {
                  \ 'icon' : 'MAIN', 
                  \ 'item' : 'ToolBar.MAIN',  
                  \ 'cmd'  : 'VSECBASE _main_', 
                  \ 'tmenu': 'Open root project file' },
            \ 'ToolBar.BODY' : {
                  \ 'icon' : 'BODY', 
                  \ 'item' : 'ToolBar.BODY',  
                  \ 'cmd'  : 'VSECBASE body', 
                  \ 'tmenu': 'Open body TeX file' },
            \ 'ToolBar.PREAMBLE' : {
                  \ 'icon' : 'PREAMBLE', 
                  \ 'item' : 'ToolBar.PREAMBLE',  
                  \ 'cmd'  : 'VSECBASE preamble', 
                  \ 'tmenu': 'Open preamble TeX file' },
            \ 'ToolBar.PACKAGES' : {
                  \ 'icon' : 'PACKAGES', 
                  \ 'item' : 'ToolBar.PACKAGES',  
                  \ 'cmd'  : 'VSECBASE packages',
                  \ 'tmenu': 'Open TeX file with packages' ,
                  \ },
            \ 'ToolBar.DEFS' : {
                  \ 'icon' : 'DEFS', 
                  \ 'item' : 'ToolBar.DEFS',  
                  \ 'cmd'  : 'VSECBASE defs',
                  \ 'tmenu': 'Open TeX file with definitions' ,
                  \ },
            \ 'ToolBar.HTLATEX' : {
                  \ 'icon' : 'HTLATEX', 
                  \ 'item' : 'ToolBar.HTLATEX', 
                  \ 'cmd'  : 'PrjMakeHTLATEX',
                  \ 'tmenu': 'Run TeX4HT using HTLATEX' ,
                  \ },
            \ 'ToolBar.VIEWHTML' : {
                  \ 'icon' : 'VIEWHTML', 
                  \ 'item' : 'ToolBar.VIEWHTML',  
                  \ 'cmd'  : 'PrjViewHtml',
                  \ 'tmenu': 'View generated HTML' ,
                  \ },
            \ 'TOOLS.VIEWPDF' : {
                  \ 'item' : '&TOOLS.&VIEWPDF', 
                  \ 'tab' : 'View\ compiled\ PDF',  
                  \ 'cmd' : 'PrjPdfView', 
                  \ },
            \ 'TOOLS.VIEWLOG' : {
                  \ 'item' : '&TOOLS.&VIEWLOG', 
                  \ 'tab' : 'View\ TeX\ Log\ file', 
                  \ 'cmd' : 'call DC_PrjView("log")', 
                  \ },
            \ 'TOOLS.VIEW.idx' : {
                  \ 'item' : '&TOOLS.&VIEW.&idx', 
                  \ 'tab' : 'View\ idx',  
                  \ 'cmd' : 'call DC_PrjView("idx")', 
                  \ },
            \ 'TOOLS.VIEW.ind' : {
                  \ 'item' : '&TOOLS.&VIEW.&ind', 
                  \ 'tab' : 'View\ ind',  
                  \ 'cmd' : 'call DC_PrjView("ind")', 
                  \ },
            \ 'TOOLS.VIEW.aux' : {
                  \ 'item' : '&TOOLS.&VIEW.&aux', 
                  \ 'tab' : 'View\ aux',  
                  \ 'cmd' : 'call DC_PrjView("aux")', 
                  \ },
            \ 'TOOLS.VIEW.lof' : {
                  \ 'item' : '&TOOLS.&VIEW.&lof', 
                  \ 'tab' : 'View\ lof',  
                  \ 'cmd' : 'call DC_PrjView("lof")', 
                  \ },
            \ 'TOOLS.VIEW.lot' : {
                  \ 'item' : '&TOOLS.&VIEW.&lot', 
                  \ 'tab' : 'View\ lot',  
                  \ 'cmd' : 'call DC_PrjView("lot")', 
                  \ },
            \ 'TOOLS.RWPACK' : {
                  \ 'item' : '&TOOLS.&RWPACK',  
                  \ 'tab' : 'Rewrite\ packages',  
                  \ 'cmd' : 'call DC_PrjRewritePackages()', 
                  \ },
            \ }

		call extend(allmenus,menus)
		call base#varset('allmenus',allmenus)

endfunction

