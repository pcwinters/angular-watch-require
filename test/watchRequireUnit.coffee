# describe 'ngWatchWhen', ->

# 	describe 'ngWatchWhenRegEx', ->
# 		beforeEach ->
# 			module 'ngWatchWhen'
# 			inject (@ngWatchWhenRegEx)->

# 		it 'should not match an expression without a when clause', ->
# 			match = '::once'.match(@ngWatchWhenRegEx)
# 			expect(match).toBeNull()

# 		it 'should not match an expression without a complete when clause', ->
# 			match = 'when::once '.match(@ngWatchWhenRegEx)
# 			expect(match).toBeNull()

# 		xit 'should not match an expression without a complete once clause', ->
# 			match = '::when::  '.match(@ngWatchWhenRegEx)
# 			expect(match).toBeNull()

# 		it 'should match an expression with a when clause', ->
# 			match = '::when::once'.match(@ngWatchWhenRegEx)
# 			expect(match).toBeDefined()
# 			expect(match).not.toBeNull()
# 			[exp, whenExp, onceExp] = match
# 			expect(whenExp).toEqual('when')
# 			expect(onceExp).toEqual('::once')

# 	describe '$parse', ->
# 		describe 'decorator and $delegate', ->
# 			beforeEach ->
# 				@parsedCache = {}
# 				@$parseDelegate = jasmine.createSpy('$parse delegate')
# 				@$parseDelegate.andCallFake (exp)->
# 					@parsedCache[exp] = {
# 						$$watchDelegate: jasmine.createSpy("#{exp} $$watchDelegate")
# 					}
# 					return @parsedCache[exp]
				
# 				@ngWatchWhenDelegateFactory = jasmine.createSpy('ngWatchWhenDelegateFactory')

# 				module {
# 					$parse: @$parseDelegate
# 				}
# 				module 'ngWatchWhen'
# 				module {
# 					ngWatchWhenDelegateFactory: @ngWatchWhenDelegateFactory
# 				}
# 				inject (@$parse)->

# 			it 'should match watchWhen syntax', ->			
# 				exp = ':: hello ::who'
# 				@$parse(exp)
# 				expect(@$parseDelegate).not.toHaveBeenCalledWith(exp)

# 			it "should defer to $parse if a string expression doesn't match the $watchWhen syntax", ->
# 				exp = ':: fooo beans ::'
# 				@$parse(exp)
# 				expect(@$parseDelegate).toHaveBeenCalledWith(exp)
			
# 			it 'should defer to $parse if expression is not a string', ->
# 				exp = _.identity
# 				@$parse(exp)
# 				expect(@$parseDelegate).toHaveBeenCalledWith(exp)

# 			describe 'if matching when syntax', ->
# 				beforeEach ->
# 					@whenStr = 'when'
# 					@onceStr = 'once'
# 					@expStr = "::#{@whenStr}::#{@onceStr}"
					
# 				it "should return the parsed 'once' expression",->
# 					@exp = @$parse(@expStr)
# 					expect(@exp).toEqual(@parsedCache['::once'])

# 				it "should wrap the 'once' expressions $$watchDelegate with ngWatchWhenDelegateFactory", ->
# 					@ngWatchWhenDelegateFactory.andReturn 'foo'
# 					@exp = @$parse(@expStr)
# 					expect(@ngWatchWhenDelegateFactory).toHaveBeenCalledWith(@parsedCache['when'], @parsedCache['::once'])
# 					expect(@exp.$$watchDelegate).toEqual('foo')
