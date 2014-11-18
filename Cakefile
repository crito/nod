# =====================================
# Imports

fsUtil       = require('fs')
pathUtil     = require('path')
{exec,spawn} = require('child_process')

# =====================================
# Variables

NODE          = process.execPath
NPM           = 'npm'
GIT           = "git"
APP_DIR       = process.cwd()
PACKAGE_PATH  = pathUtil.join(APP_DIR, "package.json")
PACKAGE_DATA  = require(PACKAGE_PATH)
DOCS_DIR      = pathUtil.join(APP_DIR, "docs")
DOCS_INPUT    = pathUtil.join(APP_DIR, "src", "*")
SRC_DIR       = pathUtil.join(APP_DIR, "src")
OUT_DIR       = pathUtil.join(APP_DIR, "")
TEST_DIR      = pathUtil.join(APP_DIR, "test")
OUT_TEST_DIR  = pathUtil.join(APP_DIR, "dist")
MODULES_DIR   = pathUtil.join(APP_DIR, "node_modules")
BIN_DIR       = pathUtil.join(MODULES_DIR, ".bin")
CAKE          = pathUtil.join(BIN_DIR, "cake")
COFFEE        = pathUtil.join(BIN_DIR, "coffee")
MOCHA         = pathUtil.join(BIN_DIR, "mocha")

# =====================================
# Generic

safe = (next,fn) ->
  fn ?= next  # support only one argument
  return (err) ->
    # success status code
    if err is 0
      err = null

    # error status code
    else if err is 1
      err = new Error('Process exited with error status code')

    # Error
    return next(err)  if err

    # Continue
    return fn()

finish = (err) ->
  throw err  if err
  console.log('OK')

# =====================================
# Actions

actions =
  clean: (opts, next) ->
    (next = opts; opts = {}) unless next?
    args = ['-Rf', OUT_DIR, DOCS_DIR]
    for path in [APP_DIR, TEST_DIR]
      args.push(
        pathUtil.join(path,  'node_modules')
        pathUtil.join(path,  '*out')
        pathUtil.join(path,  '*log')
      )
    # rm
    spawn('rm', args, {stdio: 'inherit', cwd: APP_DIR}).on('close', safe next)

  install: (opts, next) ->
    (next = opts; opts = {}) unless next?
    step1 = ->
      # npm install (for app)
      spawn(NPM, ['install'], {stdio: 'inherit', cwd: APP_DIR})
        .on('close', safe next, step2)
    step2 = ->
      fsUtil.exists TEST_DIR, (exists) ->
        return next() unless exists
        # npm install (for test)
        spawn(NPM, ['install'], {stdio: 'inherit', cwd: TEST_DIR})
          .on('close', safe next)
    step1()

  compile: (opts, next) ->
    (next = opts; opts = {}) unless next?
    # cake install
    actions.install opts, safe next, ->
      # coffee compile
      spawn(COFFEE, ['-mco', OUT_DIR, SRC_DIR], {stdio: 'inherit', cwd: APP_DIR})
        .on('close', safe next)

  test: (opts, next) ->
    (next = opts; opts = {}) unless next?
    args = ['--compilers', 'coffee:coffee-script/register',
            '--require', 'coffee-script',
            '--require', 'test/test_helper.coffee',
            '--colors',
            '--recursive']
    process.env["NODE_ENV"] = "test"
    spawn(MOCHA, args, {stdio: 'inherit', cwd: APP_DIR, env: process.env})
      .on('close', safe next)

  prepublish: (opts, next) ->
    (next = opts; opts = {}) unless next?
    step1 = ->
      # cake compile
      actions.compile(opts, safe next, step2)
    step2 = ->
      # npm test
      actions.test(opts, safe next)
    step1()

  publish: (opts, next) ->
    (next = opts; opts = {}) unless next?
    actions.prepublish opts, safe next, ->
      step1 = ->
        # Bump version
        spawn(NPM, ['version', 'patch', '-m', 'Bumped to version %s.'],
          {stdio: 'inherit', cwd: APP_DIR}).on('close', safe next, step2)
      step2 = ->
        # npm publish
        spawn(NPM, ['publish'], {stdio: 'inherit', cwd: APP_DIR})
          .on('close', safe next, step3)
      step3 = ->
        # git tag
        spawn(GIT, ['tag', 'v'+PACKAGE_DATA.version, '-a'],
          {stdio: 'inherit', cwd: APP_DIR}).on('close', safe next, step4)
      step4 = ->
        # git push origin master
        spawn(GIT, ['push', 'origin', 'master'],
          {stdio: 'inherit', cwd: APP_DIR}).on('close', safe next, step5)
      step5 = ->
        # git push tags
        spawn(GIT, ['push', 'origin', '--tags'],
          {stdio: 'inherit', cwd: APP_DIR}).on('close', safe next)
      step1()

# =====================================
# Commands

commands =
  clean:       'clean up instance'
  install:     'install dependencies'
  compile:     'compile our files (runs install)'
  test:        'run our tests (runs compile)'
  prepublish:  'prepare our package for publishing'
  publish:     'publish our package (runs prepublish)'

Object.keys(commands).forEach (key) ->
  description = commands[key]
  fn = actions[key]
  task key, description, (opts) ->  fn(opts, finish)
