'use strict'

root = this

# Save the previous value of the `nod` variable, so that it can be restored
# later on, if `noConflict` is used.
previousnod = root.nod

nativeReduce  = Array::reduce
nativeForEach = Array::forEach
nativeEvery   = Array::every
nativeMap     = Array::map

# FIXME: find a way to better test for the existence of underscore that
#        works on node and AMD.
_ = root._ or= {}

# Helper Functions
# ----------------

_each = (obj, iterator, context) ->
  if nativeReduce and obj.forEach is nativeForEach
    obj.forEach(iterator, context)

_reduce = (obj, iterator, memo, context) ->
  if nativeReduce and obj.reduce is nativeReduce
    if context then iterator = _.bind iterator, context
    obj.reduce iterator, memo

_every = (obj, iterator, context) ->
  if nativeEvery and obj.every is nativeEvery
    obj.every iterator, context

_map = (obj, iterator, context) ->
  if nativeMap and obj.map is nativeMap
    obj.map iterator, context

_flatten = (input, output) ->
  each input, (value) ->
    if isType(value, 'Array') then flatten value, output
    else output.push(value)
  output

each    = _.each    or _each
reduce  = _.reduce  or _reduce
every   = _.every   or _every
map     = _.map     or _map
flatten = _.flatten or _flatten

isType = (obj, type) ->
  Object::toString.call(obj) is '[object ' + type + ']'

# Establish the root object, 'window' in the browser, 'global' on the
# server.
nod = nod or= ->
  [validators...] = arguments
  (obj) ->
    reduce validators, ((errs, check) ->
      if not check(obj) then errs.push(check.message)
      errs
    ), []

nod.VERSION = '0.0.1'

# Run nod.js in `noConflict` mode, returning the `nod` variable to its
# previous owner. Returns a reference to this `nod` object.
nod.noConflict = ->
  root.nod = previousnod
  return this

# Use the makeCheck function to create valid checkers for an validator.
nod.makeCheck = (message, fun) ->
  f = ->
    fun.apply(this, arguments)
  f.message = message
  f

# Common checks library
# ---------------------

# Define a library of common checks
nod.checks = nod.checks or= {}

vowels = ['A', 'E', 'I', 'O', 'U']
types  = ['Object', 'Array', 'String', 'Number', 'Date', 'RegExp', 'Function']

each(types, ((name) ->
  preposition = if name[0] in vowels then 'an' else 'a'
  nod.checks["#{preposition}#{name}"] = nod.makeCheck(
    "must be #{preposition} #{name.toLowerCase()}", (obj) ->
      isType(obj, name))
  ))

# Check if an object has the required proeprties
nod.checks.hasKeys = ->
  [keys...] = arguments

  f = (obj) ->
    every keys, (k) ->
      obj.hasOwnProperty k

  f.message = ['Must have values for keys:', keys.join ', '].join ' '
  f

# Check the maximum value of some input data
nod.checks.max = (maximum) ->
  f = (obj) ->
    if isType(obj, 'String') or isType(obj, 'Array')
      obj.length <= maximum
    else if isType obj, 'Number'
      obj <= maximum

  f.message = ['exceeds the maximum of ' + maximum]
  f

# Check the minimum value of some input data
nod.checks.min = (minimum) ->
  f = (obj) ->
    if isType(obj, 'String') or isType(obj, 'Array')
      console.log obj
      obj.length >= minimum
    else if isType obj, 'Number'
      obj >= minimum

  f.message = ['less than the minimum of ' + minimum]
  f

# Run checks only against one property of the object
nod.checks.prop = (name, validators...) ->
  f = (obj) ->
    errors = []

    if validators.length is 0 then return true
    if not isType obj, 'Object'
      errors.push 'not an object'
      result = false
    else if not obj.hasOwnProperty name
      errors.push [name, 'not found'].join(': ')
      result = false
    else
      result = reduce validators, ((memo, v) ->
        run = v obj[name]
        if run.length > 0
          memo = false
          errors.push(map run, (value) ->
            [name, value].join(': ')
          )
        memo
      ), true

    f.message = flatten errors, []
    result
  f


# Export `nod`
# ------------

if typeof define == 'function' && define.amd
  define ->
    nod
else if typeof module isnt 'undefined' and module.exports
  module.exports = nod
else
  root.nod = nod
