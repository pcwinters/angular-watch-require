describe 'ngWatchRequire', ->

	describe 'using $scope.$watch', ->

		beforeEach ->
			module 'ngWatchRequire'
			inject (@$rootScope)->
			
			@$scope = @$rootScope.$new()
			spyOn(@$scope, '$watch').andCallThrough()			

		it "should register and re-use the same watch", ->
			console.log '*****RUNNING TEST'
			listeners = (jasmine.createSpy(num) for num in [1,2])
			@$scope.$watch '?expression', listeners[0]
			@$scope.$watch '?expression', listeners[1]
			expect(@$scope.$$watchers.length).toEqual(1)
			@$scope.$digest()

			for listener in listeners
				expect(listener).toHaveBeenCalled()
			console.log '*****TEST DONE'
