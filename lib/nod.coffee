'use strict'

root = this

nod = nod or= ->

if typeof define == 'function' && define.amd
  define ->
    nod
else if typeof module isnt 'undefined' and module.exports
  module.exports = nod
else
  root.nod = nod
