always = (value) ->
  ->
    value

alwaysFail = always(false)
alwaysFail.message = 'Some Message'

alwaysSucceed = always(true)

describe 'The nod library', ->
  it 'defines the global Nod function', ->
    expect(nod).toBeDefined()

  it 'implements a no conflict mode', ->
    nod2 = nod.noConflict()

    # Since nod wasn't defined before, it should be undefined
    expect(nod).toBeUndefined()

    # Test that the new nod function implements the API
    expect(_.isFunction nod2).toBe true
    expect(_.isFunction nod2.makeCheck).toBe true

    # Restore again the nod object
    window.nod = nod2

describe 'The nod function', ->
  it 'returns another function', ->
    validator = nod()
    expect(_.isFunction validator).toBe true

describe 'Validator function', ->
  it 'returns an empty array if no checks are defined', ->
    validator = nod()
    expect(validator {}).toEqual []

  it 'returns an error when a check fails', ->
    validator = nod alwaysFail
    expect(validator {}).toEqual ['Some Message']

  it 'returns an empty array when the check succeeds', ->
    validator = nod alwaysSucceed
    expect(validator {} ).toEqual([])

  it 'returns an empty array when no check is defined, but data is checked', ->
    validator = nod()
    expect(validator {age: 42}).toEqual []

describe 'Checks creation', ->
  it 'can create a check function with message', ->
    checker = nod.makeCheck 'Message', alwaysSucceed

    expect(_.isFunction checker).toBe true
    expect(checker.message).toEqual 'Message'

  it 'makes valid checker for nod', ->
    checker = nod.makeCheck 'Message', alwaysFail
    validator = nod checker

    expect(validator {}).toEqual ['Message']

describe 'The validator workflow', ->
  it 'can test an object on several checks', ->
    validator = nod nod.makeCheck('All good', alwaysSucceed),
                    nod.makeCheck('BOOM!', alwaysFail),
                    nod.makeCheck('All good', alwaysSucceed),
                    nod.makeCheck('BOOM Again!', alwaysFail)
    errs = validator {}
    expect(errs.length).toBe 2
    expect(errs).toEqual ['BOOM!', 'BOOM Again!']

describe 'Library of checks', ->
  it 'is defined', ->
    expect(nod.checks).toBeDefined()
    expect(_.isObject nod.checks).toBe true

  _.each(['anObject', 'anArray', 'aString', 'aNumber', 'aDate', 'aRegExp',
    'aFunction', 'hasKeys', 'prop', 'max', 'min'], ((elem) ->
    it "defines #{elem}", ->
      expect(nod.checks[elem]).toBeDefined()
    ))

  _.each(['anObject', 'anArray', 'aString', 'aNumber', 'aDate', 'aRegExp',
    'aFunction'], ((elem) ->
    it "#{elem} has an error message", ->
      expect(nod.checks[elem].message).toBeDefined()
    ))

  _.each(['hasKeys', 'prop', 'max', 'min'], ((elem) ->
    it "#{elem} returns the actual check function", ->
      check = nod.checks[elem](4)
      expect(_.isFunction check).toBe true
    ))

  describe 'anObject', ->
    it 'tests if the data is an object', ->
      validator = nod nod.checks.anObject

      expect(validator {}).toEqual []
      expect(validator('not an object').length).toBe 1

    it 'doesn\'t accept Functions or Arrays as objects', ->
      validator = nod nod.checks.anObject

      expect(validator([]).length).toBe 1
      expect(validator(validator).length).toBe 1

  describe 'anArray', ->
    it 'tests if the data is a list', ->
      validator = nod nod.checks.anArray

      expect(validator []).toEqual []
      expect(validator('not a list').length).toBe 1

  describe 'aString', ->
    it 'tests if the data is a string', ->
      validator = nod nod.checks.aString

      expect(validator '').toEqual []
      expect(validator 'string').toEqual []
      expect(validator([]).length).toBe 1

  describe 'aNumber', ->
    it 'tests if the data is a number', ->
      validator = nod nod.checks.aNumber

      expect(validator 1).toEqual []
      expect(validator 1.23).toEqual []
      expect(validator('1').length).toBe 1
      expect(validator([]).length).toBe 1

  describe 'aDate', ->
    it 'tests if the data is a date object', ->
      validator = nod nod.checks.aDate

      expect(validator new Date('december 17, 1995 03:24:00')).toEqual []
      expect(validator('Tue Aug 06 2013 17:11:50 GMT+0200 (CEST)').length)
        .toBe 1

  describe 'aRegExp', ->
    it 'tests if the data is a regexp object', ->
      validator = nod nod.checks.aRegExp

      expect(validator /r/).toEqual []
      expect(validator([]).length).toBe 1

  describe 'aFunction', ->
    it 'tests if the data is a function', ->
      validator = nod nod.checks.aFunction

      expect(validator ->).toEqual []
      expect(validator([]).length).toBe 1

  describe 'hasKeys', ->
    it 'tests if the object has the required properties', ->
      validator = nod nod.checks.hasKeys('msg', 'type')

      expect(validator {msg: true, type: true}).toEqual []
      expect(validator({msg: true}).length).toBe 1
      expect(validator({}).length).toBe 1

  describe 'max', ->
    it 'checks strings', ->
      validator = nod nod.checks.max(4)

      expect(validator 'AHA').toEqual []
      expect(validator('Led Zeppelin').length).toBe 1

    it 'checks arrays', ->
      validator = nod nod.checks.max(3)

      expect(validator [1, 2, 3]).toEqual []
      expect(validator([1, 2, 3, 4]).length).toBe 1

    it 'checks numbers', ->
      validator = nod nod.checks.max(3)

      expect(validator 3).toEqual []
      expect(validator(4).length).toBe 1

  describe 'min', ->
    it 'checks strings', ->
      validator = nod nod.checks.min(4)

      expect(validator 'Led Zeppelin').toEqual []
      expect(validator('AHA').length).toBe 1

    it 'checks arrays', ->
      validator = nod nod.checks.min(3)

      expect(validator [1, 2, 3]).toEqual []
      expect(validator([1, 2]).length).toBe 1

    it 'checks numbers', ->
      validator = nod nod.checks.min(3)

      expect(validator 3).toEqual []
      expect(validator(2).length).toBe 1

  describe 'prop', ->
    it 'succeeds if no data is defined', ->
      validator = nod nod.checks.prop('msg')

      expect(validator {}).toEqual []

    it 'fails if the field is missing', ->
      validator = nod nod.checks.prop('msg', nod())

      expect(validator({}).length).toBe 1

    it 'tests a single property of an object', ->
      validator = nod nod.checks.prop('msg', nod(nod.checks.aString))

      expect(validator {msg: 'hello', count: 23}).toEqual []
      expect(validator({count: 23}).length).toBe 1
      expect(validator({msg: 42, count: 23}).length).toBe 1

    it 'returns an array of arrays with the error message', ->
      validator = nod nod.checks.prop('msg', nod(nod.checks.aString,
                                                 nod.checks.anArray))
      errors = validator {msg: 23}

      expect(errors.length).toBe 1
      expect(errors[0].length).toBe 2

    it 'can check multiple validator functions', ->
      validator = nod nod.checks.prop('msg', nod(nod.checks.aString,
                                                 nod.checks.anArray))
      errors = validator {msg: 23}

      expect(errors[0].length).toBe 2
