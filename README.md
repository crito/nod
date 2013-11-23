# nod

[![Build Status](http://img.shields.io/travis-ci/crito/nod.png?branch=master)](http://travis-ci.org/crito/nod "Check this project's build status on TravisCI")
[![NPM version](http://badge.fury.io/js/nod.png)](https://npmjs.org/package/nod "View this project on NPM")
[![Gittip donate button](http://img.shields.io/gittip/crito.png)](https://www.gittip.com/crito/ "Donate weekly to this project using Gittip")

Some functions in JavaScript to support object validation.

After reading the excellent [Functional Javascript](http://functionaljavascript.com/)
I took the idea of a functional object validator presented in the book.

## Requirements

If your JavaScript environment doesn't implement ECMAScript 5, then `nod`
requires [`underscore`](http://underscorejs.org). It relies on a few functions
such as map that are not available prior to that standard. It uses `underscore`
in any case if available, otherwise falls back to the native implementations.

## Usage

`nod` is fairly simple.

You create a new validation function by calling `nod` and give it a list of
check functions as arguments. These functions perform the different checks for
the data.

    var validator = nod(); // This validation function has no checks (it will
                           // always succeed):
    validator({});
    // -> []

Validation functions return an array with error messages for every check that
failed. If the data validates, the array is empty.

To create a validator that actually includes some checks, you can use some
predefined checks:

    var validator = nod(nod.checks.anArray);

    validator({});
    // -> ['must be a list']

You can add several checks to one validator function:

    var validator = nod(nod.checks.anObject,
                        nod.checks.hasKeys('msg'))

    validator([]);
    // -> ["must be an object", "Must have values for keys: msg"]

## Predefined checks

`nod` provides already a range of checks, that you can use. Those checks are
all collected in `nod.checks`.

Checks come in two flavors: Those that need configuration and those that
don't. Configurable checks take arguments and return based on that the actual
check.

    var propCheckerMessage = nod.checks.hasKeys('msg', 'type');
    var propCheckerPerson  = nod.checks.hasKeys('name', 'birthday');

    var messageValidator = nod(propCheckerMessage);
    var personValidator = nod(propCheckerPerson);

Checks that are not configurable can be used as they come:

    var validator = nod(nod.checks.anArray);

- [aNumber](#aNumber)
- [aString](#aString)
- [anObject](#anObject)
- [anArray](#anArray)
- [aDate](#aDate)
- [aRegExp](#aRegExp)
- [aFunction](#aFunction)
- [hasKeys](#hasKeys)
- [prop](#prop)
- [max](#max)
- [min](#min)

### aNumber

Checks if the data is a JavaScript number. This check is not configurable. Data
that is an integer as well as a float passes this check.

    var validator = nod(nod.checks.aNumber);

    validator(1);
    // -> []

    validator(1.23);
    // -> []

    validator('1');
    // -> ['not a number']

### aString

Checks if the data is a JavaScript string. This check is not configurable.

    var validator = nod(nod.checks.aString);

    validator('hello');
    // -> []

    validator([]);
    // -> ['not a string']

### anObject

Checks if the data is a JavaScript object. This check is not configurable. This
check passes if the data is plain object, not a JavaScript object. {} passes,
[] not neither do functions.

    var validator = nod(nod.checks.anObject);

    validator({});
    // -> []

    validator([]);
    // -> ['not an object']

### anArray

Checks if the data is an array. This check is not configurable.

    var validator = nod(nod.checks.anArray);

    validator([]);
    // -> []

    validator({});
    // -> ['must be an array']

### aDate

Checks if the data is a date object. This check is not configurable. The test
only checks the type of the data. Strings that represent dates are not
recognized.

    var validator = nod(nod.checks.aDate);

    validator(new Date("December 17, 1995 03:24:00"));
    // -> []

    validator("Tue Aug 06 2013 17:11:50 GMT+0200 (CEST)");
    // -> ['must be a date']

### aRegExp

Checks if the data is a regular expression object. This check is not
configurable.

    var validator = nod(nod.checks.aRegExp);

    validator(/r/);
    // -> []

    validator({});
    // -> ['must be a regexp']

### aFunction

Checks if the data is a function. This check is not configurable.

    var validator = nod(nod.checks.aFunction);

    validator(function () {});
    // -> []

    validator({});
    // -> ['must be a regexp']

### hasKeys

Check if the object has certain properties. This check needs to be configured
with the properties to check for.

    var validator = nod(nod.checks.hasKeys('msg'));

    validator({});
    // -> ['Must have values for keys: msg']

    validator({msg: 42});
    // -> []

### prop

This is not so much a check by itself. It runs a validation function only on
one property of an object. It takes two arguments, the first is the name of the
property of the object, the second argument is the validation function created
by `nod`.

You can also specify more than one validation function.

This check returns an array of arrays, containing every error that occurred.

    var stringField     = nod(nod.checks.aString);
    var modelValidation = nod(nod.checks.prop('msg', stringField))

    modelValidation({count: 42});
    // -> [['msg: not found']]

    modelValidation({msg: 42, count: 23});
    // -> [['msg: must be a string']]

    modelValidation({msg: "hello", count: 23});
    // -> []

### max

Dependent on the data, this check does different things:

- Checks if a string exceeds a given length,
- if an array exceeds a number of elements,
- or an integer is higher than the given value.

This check needs to be configured with the maximum value.

    var validator = nod(nod.checks.max(6));

    validator("Hello");
    // -> []

    validator([1, 2, 3, 4, 5, 6, 7]);
    // -> ['exceeds the maximum of 6']

    validator(7);
    // -> ['exceeds the maximum of 6']

### min

Dependent on the data, this check does different things:

- Checks if a string has at least a given length,
- if an array has at least a number of elements,
- or an integer is not lower than the given value.

This check needs to be configured with the maximum value.

    var validator = nod(nod.checks.min(4));

    validator("Hello");
    // -> []

    validator([1, 2, 3]);
    // -> ['less than the minimum of 4']

    validator(7);
    // -> ['less than the minimum of 4']

## Define your own checks with `makeCheck`

Checks are simple functions that return true if the data validates or else
return false. Furthermore checks provide error messages. `nod` provides a
helper function that helps to create such a function.

    var checkFor23 = nod.makeCheck('must be 23', function (data) {
      return data === 23;
    });

    var validator = nod(checkFor23);

## Using `nod` with Backbone

You can easily use `nod` in combination with your backbone models validation.

    // We throw an ValidationError to catch in case the model doesn't validate.
    var ValidationError = function (errors) {
      this.errors = errors;
    }

    // This is our validator function for that model.
    var myModelValidator = nod(nod.checks.hasKey('msg', 'type'));

    // We define a validate method for our model.
    var MyModel = Backbone.Model.extend({
      validate: function (attrs, options) {
        var errs = myModelValidator(attrs);
        if (errs.length > 0) throw new ValidationError(errs);
      }
    });

    // Create our model and lets try to save it.
    var model = new MyModel({msg: 42});

    try {
      model.save();
    } catch(e) {
      console.log(e.errors);
    }
    // -> ["Must have values for keys: msg, type"]

## Building

You need to have node and npm installed. To install all dependencies run:

    npm install

You can run all tests by running:

    grunt  # or grunt test

Build nod by running:

    grunt build

That will create all build files in `./dist`.

## Backers

### Maintainers

These amazing people are maintaining this project:

- Christo Buschek <crito@cryptodrunks.net> (https://github.com/crito)

### Sponsors

No sponsors yet! Will you be the first?

[![Gittip donate button](http://img.shields.io/gittip/crito.png)](https://www.gittip.com/crito/ "Donate weekly to this project using Gittip")

### Contributors

These amazing people have contributed code to this project:

- Christo Buschek <crito@cryptodrunks.net> (https://github.com/crito) - [view contributions](https://github.com/crito/nod/commits?author=crito)

[Become a contributor!](https://github.com/crito/nod/blob/master/Contributing.md#files)

## License

Licensed under the incredibly [permissive](http://en.wikipedia.org/wiki/Permissive_free_software_licence) [MIT license](http://creativecommons.org/licenses/MIT/)

Copyright &copy; 2013+ Christo Buschek <crito@cryptodrunks.net>
(https://github.com/crito)
