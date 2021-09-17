#!/usr/bin/env python3

#https://stackoverflow.com/questions/2017045/python-recursively-create-dictionary-from-paths

import Base.Util as util


a = util.dictnew('a.b.dfsf','aa')
import pdb; pdb.set_trace()

#class Stats(object):
   #def __init__(self):
      #self.count = 0
      #self.subdirs = {}

#counts = Stats()
#paths = 'a/b/c/d'

#for p in paths:
   #parts = p.split('/')
   #branch = counts
   #for part in parts[1:]:
      #branch = branch.subdirs.setdefault(part, Stats())
   #branch.count += 1

#def dictnew(dct, path, val):
    #while path.startswith('.'):
      #path = path[1:]
    #parts = path.split('.', 1)
    #if len(parts) > 1:
        #branch = dct.setdefault(parts[0], {})
        #dictnew(branch, parts[1], val)
    #else:
        #if not parts[0] in dct:
          #dct[parts[0]] = val

#d = {}
#dictnew(d, 'a.b.c', 'vv')
#dictnew(d, 'a.b.c', 'w')

#import pdb; pdb.set_trace()
