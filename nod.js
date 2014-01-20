(function() {
  var each, every, flatten, isType, map, nativeEvery, nativeForEach, nativeMap, nativeReduce, nod, previousnod, reduce, root, types, vowels, _, _each, _every, _flatten, _map, _reduce,
    __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  root = this;

  previousnod = root.nod;

  nativeReduce = Array.prototype.reduce;

  nativeForEach = Array.prototype.forEach;

  nativeEvery = Array.prototype.every;

  nativeMap = Array.prototype.map;

  _ = root._ || (root._ = {});

  _each = function(obj, iterator, context) {
    if (nativeForEach && obj.forEach === nativeForEach) {
      return obj.forEach(iterator, context);
    }
  };

  _reduce = function(obj, iterator, memo, context) {
    if (nativeReduce && obj.reduce === nativeReduce) {
      if (context) {
        iterator = _.bind(iterator, context);
      }
      return obj.reduce(iterator, memo);
    }
  };

  _every = function(obj, iterator, context) {
    if (nativeEvery && obj.every === nativeEvery) {
      return obj.every(iterator, context);
    }
  };

  _map = function(obj, iterator, context) {
    if (nativeMap && obj.map === nativeMap) {
      return obj.map(iterator, context);
    }
  };

  _flatten = function(input, output) {
    each(input, function(value) {
      if (isType(value, 'Array')) {
        return flatten(value, output);
      } else {
        return output.push(value);
      }
    });
    return output;
  };

  each = _.each || _each;

  reduce = _.reduce || _reduce;

  every = _.every || _every;

  map = _.map || _map;

  flatten = _.flatten || _flatten;

  isType = function(obj, type) {
    return Object.prototype.toString.call(obj) === '[object ' + type + ']';
  };

  nod = nod || (nod = function() {
    var validators;
    validators = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return function(obj) {
      return reduce(validators, function(errs, check) {
        if (!check(obj)) {
          errs.push(check.message);
        }
        return errs;
      }, []);
    };
  });

  nod.VERSION = '0.0.1';

  nod.noConflict = function() {
    root.nod = previousnod;
    return this;
  };

  nod.makeCheck = function(message, fun) {
    var f;
    f = function() {
      return fun.apply(this, arguments);
    };
    f.message = message;
    return f;
  };

  nod.checks = nod.checks || (nod.checks = {});

  vowels = ['A', 'E', 'I', 'O', 'U'];

  types = ['Object', 'Array', 'String', 'Number', 'Date', 'RegExp', 'Function'];

  each(types, function(name) {
    var preposition, _ref;
    preposition = (_ref = name[0], __indexOf.call(vowels, _ref) >= 0) ? 'an' : 'a';
    return nod.checks["" + preposition + name] = nod.makeCheck("must be " + preposition + " " + (name.toLowerCase()), function(obj) {
      return isType(obj, name);
    });
  });

  nod.checks.hasKeys = function() {
    var f, keys;
    keys = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    f = function(obj) {
      return every(keys, function(k) {
        return obj.hasOwnProperty(k);
      });
    };
    f.message = ['Must have values for keys:', keys.join(', ')].join(' ');
    return f;
  };

  nod.checks.max = function(maximum) {
    var f;
    f = function(obj) {
      if (isType(obj, 'String') || isType(obj, 'Array')) {
        return obj.length <= maximum;
      } else if (isType(obj, 'Number')) {
        return obj <= maximum;
      }
    };
    f.message = ['exceeds the maximum of ' + maximum];
    return f;
  };

  nod.checks.min = function(minimum) {
    var f;
    f = function(obj) {
      if (isType(obj, 'String') || isType(obj, 'Array')) {
        return obj.length >= minimum;
      } else if (isType(obj, 'Number')) {
        return obj >= minimum;
      }
    };
    f.message = ['less than the minimum of ' + minimum];
    return f;
  };

  nod.checks.prop = function() {
    var f, name, validators;
    name = arguments[0], validators = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    f = function(obj) {
      var errors, result;
      errors = [];
      if (validators.length === 0) {
        return true;
      }
      if (!isType(obj, 'Object')) {
        errors.push('not an object');
        result = false;
      } else if (!obj.hasOwnProperty(name)) {
        errors.push([name, 'not found'].join(': '));
        result = false;
      } else {
        result = reduce(validators, function(memo, v) {
          var run;
          run = v(obj[name]);
          if (run.length > 0) {
            memo = false;
            errors.push(map(run, function(value) {
              return [name, value].join(': ');
            }));
          }
          return memo;
        }, true);
      }
      f.message = flatten(errors, []);
      return result;
    };
    return f;
  };

  if (typeof define === 'function' && define.amd) {
    define(function() {
      return nod;
    });
  } else if (typeof module !== 'undefined' && module.exports) {
    module.exports = nod;
  } else {
    root.nod = nod;
  }

}).call(this);

/*
//@ sourceMappingURL=nod.js.map
*/