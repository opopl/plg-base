
let b:comps_BufAct = []

let comps = []
call extend(comps,base#varget('comps_BufAct_html',[]))

let b:comps_BufAct = comps
