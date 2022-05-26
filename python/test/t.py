
import os,re,sys
import Base.Util as util

home = os.environ.get('HOME')
plg = os.environ.get('PLG')
base = os.path.join(plg,'base')

#os.chdir(os.path.join(home, 'perlgem'))
#os.chdir(plg)
os.chdir(home)
os.chdir(base)

cmd = 'git ls'
#cmd = 'find . -name "*.vim" '

r = util.shell({ 'cmd' : cmd })

import pdb; pdb.set_trace()
