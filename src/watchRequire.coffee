wrap = (listener, toDo, invokeAlways, isDefined) ->
	return _.wrap toDo, (originalFn, value, args...)->
		valueIsDefined = isDefined(value)
		# allow for the watch callback to defer until the value is defined
		if not invokeAlways and not valueIsDefined then return
		originalFn.call(this, value, args...)
		if valueIsDefined then listener.cleanup() # clear the watch

angular.module('ngWatchRequire', [])
.constant 'ngWatchRequireRegEx', /^(\?\^|\?|\^)([^\:]+)$/
.config ($provide)->
	$provide.decorator '$parse', ($delegate)->
		return _.wrap $delegate, ($parse, args...)->
			str = _.first(args)
			console.log 'parsing expression', str
			expression = $parse.apply(@, args)
			if angular.isString(str)
				expression.$$expression = str.trim()
			return expression

	$provide.decorator '$parse', ($delegate, ngWatchRequireRegEx, ngWatchRequire)->
		return _.wrap $delegate, ($parse, exp, interceptor)->
			if angular.isString(exp) and match = exp.match(ngWatchRequireRegEx)
				console.log 'matched', exp, match
				[unparsed, requireType, str] = match
				str = str.trim()
				
				args = [str]
				if interceptor then args.push(interceptor)
				expression = $parse.apply(@, args)				
				expression.$$watchDelegate = ngWatchRequire.delegateFactory(requireType, expression)
				expression.$$requireType = requireType
				return expression
			else
				console.log 'no match, passthrough', exp
				args = [exp]
				if interceptor? then args.push interceptor
				expression = $parse.apply(@, args)
				delete expression.$$requireType
				delete expression.$$watchDelegate
				console.log 'passed through require type is', expression.$$requireType
				return expression

.value 'ngWatchRequireMultiListener', class NgWatchRequireMultiListener
	constructor: (@expression, @objectEquality)->
		@$$watchers = []

	addListener: (scope, listener)=>
		watcher = {scope,listener}
		@$$watchers.push(watcher)
		destroyListener = ()=> @removeListener(watcher)
		scope.$on '$destroy', destroyListener
		return destroyListener

	removeListener: (watcher)=>
		_.remove @$$watchers, (w)-> w is watcher
		if @$$watchers.length is 0
			@deregister() # Should be attached by whoever binds this multi listener

	onChange: (newValue, oldValue, scope)=>
		for watcher in @$$watchers
			watcher.listener.call(watcher.scope, newValue, oldValue, watcher.scope)


.service 'ngWatchRequire', 
	class NgWatchRequire
		
		constructor: (@ngWatchRequireMultiListener)->

		createMultiListener: (scope, expressionStr, objectEquality)=>
			console.log 'create new multiListener', expressionStr, objectEquality
			multiListener = new @ngWatchRequireMultiListener(expressionStr, objectEquality)
			multiListener.deregister = scope.$watch(expressionStr, multiListener.onChange, objectEquality)
			watcher = _.first(scope.$$watchers) # watchers are added with unshift
			watcher.$multiListener = multiListener
			return multiListener

		findMultiListener: (scope, expressionStr, objectEquality, climbParent=false)=>
			watcher = null
			while true
				watcher = _.find scope.$$watchers, (w)->
					w.$multiListener?.expression is expressionStr and w.$multiListener?.objectEquality is objectEquality
				scope = scope.$parent
				console.log 'found watcher', watcher
				break unless (not watcher?) and climbParent and scope?
			return watcher?.$multiListener

		delegateFactory: (requireType, expression)=>
			console.log 'wrapping expression.$$watchDelegate', expression.$$watchDelegate
			return _.wrap expression.$$watchDelegate, (originalDelegate, scope, listener, objectEquality, parsedExpression)=>
				# The $parse cache will re-use this delegate over and over
				console.log 'in delegate', requireType, parsedExpression.$$requireType, expression.$$watchDelegate
				# TODO this needs to be smarter
				if requireType isnt parsedExpression.$$requireType
					return originalDelegate(args[1..]...)

				console.log 'delegate factory', parsedExpression.$$expression, objectEquality
				options = switch requireType
					when '?' then {createIfNeeded: true}
					when '?^' then {createIfNeeded: true, climbParent: true}
					when '^' then {climbParent: true }

				expressionStr = parsedExpression.$$expression
				multiListener = @findMultiListener(scope, expressionStr, objectEquality, options.climbParent)
				console.log 'created multi listener'
				if not multiListener?
					if not options.createIfNeeded
						throw new Error("ngWatchRequire: Expression #{expressionStr} requires an existing $watch but none was found.")
					multiListener = @createMultiListener(scope, expressionStr, objectEquality) 

				return multiListener.addListener(scope, listener)

