(function() {
  var NgWatchRequire, NgWatchRequireMultiListener, wrap,
    __slice = [].slice,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  wrap = function(listener, toDo, invokeAlways, isDefined) {
    return _.wrap(toDo, function() {
      var args, originalFn, value, valueIsDefined;
      originalFn = arguments[0], value = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      valueIsDefined = isDefined(value);
      if (!invokeAlways && !valueIsDefined) {
        return;
      }
      originalFn.call.apply(originalFn, [this, value].concat(__slice.call(args)));
      if (valueIsDefined) {
        return listener.cleanup();
      }
    });
  };

  angular.module('ngWatchRequire', []).constant('ngWatchRequireRegEx', /^(\?\^|\?|\^)([^\:]+)$/).value('ngWatchRequireCloneExpression', function(getter) {
    var clone;
    clone = function() {
      return getter.apply(this, arguments);
    };
    return _.merge(clone, getter);
  }).config(function($provide) {
    $provide.decorator('$parse', function($delegate) {
      return _.wrap($delegate, function() {
        var $parse, args, expression, str;
        $parse = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        str = _.first(args);
        expression = $parse.apply(this, args);
        if (angular.isString(str)) {
          expression.$$expression = str.trim();
        }
        return expression;
      });
    });
    return $provide.decorator('$parse', function($delegate, ngWatchRequireRegEx, ngWatchRequire, ngWatchRequireCloneExpression) {
      return _.wrap($delegate, function($parse, exp, interceptor) {
        var args, expression, match, requireType, str, unparsed;
        if (angular.isString(exp) && (match = exp.match(ngWatchRequireRegEx))) {
          unparsed = match[0], requireType = match[1], str = match[2];
          str = str.trim();
          args = [str];
          if (interceptor) {
            args.push(interceptor);
          }
          expression = ngWatchRequireCloneExpression($parse.apply(this, args));
          expression.$$watchDelegate = ngWatchRequire.delegateFactory(requireType, expression);
          expression.$$requireType = requireType;
          return expression;
        } else {
          args = [exp];
          if (interceptor != null) {
            args.push(interceptor);
          }
          return $parse.apply(this, args);
        }
      });
    });
  }).value('ngWatchRequireMultiListener', NgWatchRequireMultiListener = (function() {
    function NgWatchRequireMultiListener(expression, objectEquality) {
      this.expression = expression;
      this.objectEquality = objectEquality;
      this.onChange = __bind(this.onChange, this);
      this.removeListener = __bind(this.removeListener, this);
      this.addListener = __bind(this.addListener, this);
      this.$$watchers = [];
    }

    NgWatchRequireMultiListener.prototype.addListener = function(scope, listener) {
      var destroyListener, watcher;
      watcher = {
        scope: scope,
        listener: listener
      };
      this.$$watchers.push(watcher);
      destroyListener = (function(_this) {
        return function() {
          return _this.removeListener(watcher);
        };
      })(this);
      scope.$on('$destroy', destroyListener);
      return destroyListener;
    };

    NgWatchRequireMultiListener.prototype.removeListener = function(watcher) {
      _.remove(this.$$watchers, function(w) {
        return w === watcher;
      });
      if (this.$$watchers.length === 0) {
        return this.deregister();
      }
    };

    NgWatchRequireMultiListener.prototype.onChange = function(newValue, oldValue, scope) {
      var watcher, _i, _len, _ref, _results;
      _ref = this.$$watchers;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        watcher = _ref[_i];
        _results.push(watcher.listener.call(watcher.scope, newValue, oldValue, watcher.scope));
      }
      return _results;
    };

    return NgWatchRequireMultiListener;

  })()).service('ngWatchRequire', NgWatchRequire = (function() {
    function NgWatchRequire(ngWatchRequireMultiListener) {
      this.ngWatchRequireMultiListener = ngWatchRequireMultiListener;
      this.delegateFactory = __bind(this.delegateFactory, this);
      this.findMultiListener = __bind(this.findMultiListener, this);
      this.createMultiListener = __bind(this.createMultiListener, this);
    }

    NgWatchRequire.prototype.createMultiListener = function(scope, expressionStr, objectEquality) {
      var multiListener, watcher;
      multiListener = new this.ngWatchRequireMultiListener(expressionStr, objectEquality);
      multiListener.deregister = scope.$watch(expressionStr, multiListener.onChange, objectEquality);
      watcher = _.first(scope.$$watchers);
      watcher.$multiListener = multiListener;
      return multiListener;
    };

    NgWatchRequire.prototype.findMultiListener = function(scope, expressionStr, objectEquality, climbParent) {
      var watcher;
      if (climbParent == null) {
        climbParent = false;
      }
      watcher = null;
      while (true) {
        watcher = _.find(scope.$$watchers, function(w) {
          var _ref, _ref1;
          return ((_ref = w.$multiListener) != null ? _ref.expression : void 0) === expressionStr && ((_ref1 = w.$multiListener) != null ? _ref1.objectEquality : void 0) === objectEquality;
        });
        scope = scope.$parent;
        if (!((watcher == null) && climbParent && (scope != null))) {
          break;
        }
      }
      return watcher != null ? watcher.$multiListener : void 0;
    };

    NgWatchRequire.prototype.delegateFactory = function(requireType, expression) {
      return _.wrap(expression.$$watchDelegate, (function(_this) {
        return function(originalDelegate, scope, listener, objectEquality, parsedExpression) {
          var expressionStr, multiListener, options;
          options = (function() {
            switch (requireType) {
              case '?':
                return {
                  createIfNeeded: true
                };
              case '?^':
                return {
                  createIfNeeded: true,
                  climbParent: true
                };
              case '^':
                return {
                  climbParent: true
                };
            }
          })();
          expressionStr = parsedExpression.$$expression;
          multiListener = _this.findMultiListener(scope, expressionStr, objectEquality, options.climbParent);
          if (multiListener == null) {
            if (!options.createIfNeeded) {
              throw new Error("ngWatchRequire: Expression " + expressionStr + " requires an existing $watch but none was found.");
            }
            multiListener = _this.createMultiListener(scope, expressionStr, objectEquality);
          }
          return multiListener.addListener(scope, listener);
        };
      })(this));
    };

    return NgWatchRequire;

  })());

}).call(this);
