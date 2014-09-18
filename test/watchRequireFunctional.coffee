describe 'ngWatchRequire:func', ->

	describe 'using $scope.$watch', ->

		beforeEach ->
			module 'ngWatchRequire'
			inject (@$rootScope)->
			
			@$scope = @$rootScope.$new()
			spyOn(@$scope, '$watch').andCallThrough()			

		it 'should register and re-use a $watch', ->
			expect(@$scope.$$watchers).toBeNull()
			listeners = (jasmine.createSpy("listener #{num}") for num in [1,2,3])
			for listener in listeners
				@$scope.$watch '?expression', listener
			expect(@$scope.$$watchers.length).toEqual(1)
			@$scope.$digest()
			for listener in listeners
				expect(listener).toHaveBeenCalled()
			
		it 'should deregister the multi $watch after all listeners are deregistered', ->
			expect(@$scope.$$watchers).toBeNull()
			listeners = ({fn: jasmine.createSpy("listener #{num}")} for num in [1,2,3])
			for listener in listeners
				listener.deregister = @$scope.$watch '?expression', listener.fn

			expect(@$scope.$$watchers.length).toEqual(1)

			for listener in listeners[..-2] # all but the last
				listener.deregister()
				expect(@$scope.$$watchers.length).toEqual(1)

			listeners[-1..][0].deregister()
			expect(@$scope.$$watchers.length).toEqual(0)

		it 'should re-use a $parent $watch', ->
			@$parent = @$scope
			@$scope = @$parent.$new()
			expect(@$scope.$$watchers).toBeNull()
			
			listeners = (jasmine.createSpy("listener #{num}") for num in [1,2])
			@$parent.$watch('?expression', listeners[0])
			@$scope.$watch('^expression', listeners[1])

			expect(@$parent.$$watchers.length).toEqual(1)
			expect(@$scope.$$watchers).toBeNull()
			@$parent.$digest()
			for listener in listeners
				expect(listener).toHaveBeenCalled()

		it 'should error if a $parent $watch is required but non-existent', ->
			expect(-> @$scope.$watch('^expression', listeners[1])).toThrow()

