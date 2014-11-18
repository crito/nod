_ = require('lodash')
nod = require '../src/nod'

alwaysFail = _.constant(false)
alwaysFail.message = 'Some Message'

alwaysSucceed = _.constant(true)

describe 'The nod library', ->
  it 'defines the global Nod function', ->
    nod.should.exist()

  xit 'implements a no conflict mode', ->
    nod2 = nod.noConflict()

    # Since nod wasn't defined before, it should be undefined
    nod.should.not.exist()

    # Test that the new nod function implements the API
    _.isFunction(nod2).should.be.true
    _.isFunction(nod2.makeCheck).should.be.true

    # Restore again the nod object
    window.nod = nod2

describe 'The nod function', ->
  it 'returns another function', ->
    validator = nod()
    _.isFunction(validator).should.be.true

describe 'Validator function', ->
  it 'returns an empty array if no checks are defined', ->
    validator = nod()
    validator({}).should.eql []

  it 'returns an error when a check fails', ->
    validator = nod alwaysFail
    validator({}).should.eql ['Some Message']

  it 'returns an empty array when the check succeeds', ->
    validator = nod alwaysSucceed
    validator({}).should.eql []

  it 'returns an empty array when no check is defined, but data is checked', ->
    validator = nod()
    validator({age: 42}).should.eql []

describe 'Checks creation', ->
  it 'can create a check function with message', ->
    checker = nod.makeCheck 'Message', alwaysSucceed

    _.isFunction(checker).should.be.true
    checker.message.should.equal 'Message'

  it 'makes valid checker for nod', ->
    checker = nod.makeCheck 'Message', alwaysFail
    validator = nod checker

    validator({}).should.eql ['Message']

describe 'The validator workflow', ->
  it 'can test an object on several checks', ->
    validator = nod nod.makeCheck('All good', alwaysSucceed),
                    nod.makeCheck('BOOM!', alwaysFail),
                    nod.makeCheck('All good', alwaysSucceed),
                    nod.makeCheck('BOOM Again!', alwaysFail)
    errs = validator {}
    errs.length.should.equal 2
    errs.should.eql ['BOOM!', 'BOOM Again!']

describe 'Library of checks', ->
  it 'is defined', ->
    nod.checks.should.exist()
    _.isObject(nod.checks).should.be.true

  _.each(['anObject', 'anArray', 'aString', 'aNumber', 'aDate', 'aRegExp',
    'aFunction', 'hasKeys', 'prop', 'max', 'min'], ((elem) ->
    it "defines #{elem}", ->
      nod.checks[elem].should.exist()
    ))

  _.each(['anObject', 'anArray', 'aString', 'aNumber', 'aDate', 'aRegExp',
    'aFunction'], ((elem) ->
    it "#{elem} has an error message", ->
      nod.checks[elem].message.should.exist()
    ))

  _.each(['hasKeys', 'prop', 'max', 'min'], ((elem) ->
    it "#{elem} returns the actual check function", ->
      check = nod.checks[elem](4)
      _.isFunction(check).should.be.true
    ))

  describe 'anObject', ->
    it 'tests if the data is an object', ->
      validator = nod nod.checks.anObject

      validator({}).should.eql []
      validator('not an object').length.should.equal 1

    it 'doesn\'t accept Functions or Arrays as objects', ->
      validator = nod nod.checks.anObject

      validator([]).length.should.equal 1
      validator(validator).length.should.equal 1

  describe 'anArray', ->
    it 'tests if the data is a list', ->
      validator = nod nod.checks.anArray

      validator([]).should.eql []
      validator('not a list').length.should.equal 1

  describe 'aString', ->
    it 'tests if the data is a string', ->
      validator = nod nod.checks.aString

      validator('').should.eql []
      validator('string').should.eql []
      validator([]).length.should.equal 1

  describe 'aNumber', ->
    it 'tests if the data is a number', ->
      validator = nod nod.checks.aNumber

      validator(1).should.eql []
      validator(1.23).should.eql []
      validator('1').length.should.equal 1
      validator([]).length.should.equal 1

  describe 'aDate', ->
    it 'tests if the data is a date object', ->
      validator = nod nod.checks.aDate

      validator(new Date('december 17, 1995 03:24:00')).should.eql []
      validator('Tue Aug 06 2013 17:11:50 GMT+0200 (CEST)')
        .length.should.equal 1

  describe 'aRegExp', ->
    it 'tests if the data is a regexp object', ->
      validator = nod nod.checks.aRegExp

      validator(/r/).should.eql []
      validator([]).length.should.equal 1

  describe 'aFunction', ->
    it 'tests if the data is a function', ->
      validator = nod nod.checks.aFunction

      validator(->).should.eql []
      validator([]).length.should.equal 1

  describe 'hasKeys', ->
    it 'tests if the object has the required properties', ->
      validator = nod nod.checks.hasKeys('msg', 'type')

      validator({msg: true, type: true}).should.eql []
      validator({msg: true}).length.should.equal 1
      validator({}).length.should.equal 1

  describe 'max', ->
    it 'checks strings', ->
      validator = nod nod.checks.max(4)

      validator('AHA').should.eql []
      validator('Led Zeppelin').length.should.equal 1

    it 'checks arrays', ->
      validator = nod nod.checks.max(3)

      validator([1, 2, 3]).should.eql []
      validator([1, 2, 3, 4]).length.should.equal 1

    it 'checks numbers', ->
      validator = nod nod.checks.max(3)

      validator(3).should.eql []
      validator(4).length.should.equal 1

  describe 'min', ->
    it 'checks strings', ->
      validator = nod nod.checks.min(4)

      validator('Led Zeppelin').should.eql []
      validator('AHA').length.should.equal 1

    it 'checks arrays', ->
      validator = nod nod.checks.min(3)

      validator([1, 2, 3]).should.eql []
      validator([1, 2]).length.should.equal 1

    it 'checks numbers', ->
      validator = nod nod.checks.min(3)

      validator(3).should.eql []
      validator(2).length.should.equal 1

  describe 'prop', ->
    it 'succeeds if no data is defined', ->
      validator = nod nod.checks.prop('msg')

      validator({}).should.eql []

    it 'fails if the field is missing', ->
      validator = nod nod.checks.prop('msg', nod())

      validator({}).length.should.equal 1

    it 'tests a single property of an object', ->
      validator = nod nod.checks.prop('msg', nod(nod.checks.aString))

      validator({msg: 'hello', count: 23}).should.eql []
      validator({count: 23}).length.should.equal 1
      validator({msg: 42, count: 23}).length.should.equal 1

    it 'returns an array of arrays with the error message', ->
      validator = nod nod.checks.prop('msg', nod(nod.checks.aString,
                                                 nod.checks.anArray))
      errors = validator {msg: 23}

      errors.length.should.equal 1
      errors[0].length.should.equal 2

    it 'can check multiple validator functions', ->
      validator = nod nod.checks.prop('msg', nod(nod.checks.aString,
                                                 nod.checks.anArray))
      errors = validator {msg: 23}

      errors[0].length.should.equal 2
