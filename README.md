angular-watch-require
=============
Require and re-use ```$watch``` feature for AngularJS expressions, which has a syntax similar to a directive's ```require: '^expression'```. Walks up scope hierarchy until a watch on an identical expression is found and re-uses it.

### Usage

```bower install angular-watch-require```

Add ```'ngWatchRequire'``` to your application or module.

##### Expression syntax
The expression syntax is baked into $parse and can be used in $scope.$watch[*], templates, and directives.
```
$scope.$watch('^myModel', function(){
	// Add listener to watch if defined on parent
})
```

**Options**

* '?expression' - Attempt to attach to already defined ```$watch``` on current ```$scope```, creating a new ```$watch``` if necessary.
* '^expression' - Attach to an already defined ```$watch``` on current ```$scope``` or first parent.
* '?^expression' - Attempt to attach to already defined ```$watch``` on current ```$scope``` or first parent. Creating a new ```$watch``` on current ```$scope``` necessary.

### See also
[angular-watch-when](https://github.com/pcw216/angular-watch-when) - Makes use of this module to produce 'one-time' watches that recycle when another expression changes.
