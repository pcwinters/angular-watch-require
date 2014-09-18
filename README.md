angular-watch-require
=============
Require and re-use ```$watch``` feature for AngularJS expressions, which has a syntax similar to a directive's ```require: '^expression'```. Walks up the scope hierarchy until a ```$watch``` on an identical expression is found (that was created with ngWatchRequire syntax)  and re-uses it.

### Usage

```bower install angular-watch-require```

Add ```'ngWatchRequire'``` to your application or module.

##### Expression syntax
The expression syntax is baked into ```$parse``` and can be used in ```$scope.$watch[*]```, templates, and directives.

**Use it in controllers**
```
$scope.$watch('?^myModel', function(){})
```

**Use it in templates**
```
<span>{{?^myModel}}</span>
<span ng-bind="?^myModel"></span>
```

**Options**

* '?expression' - Attempt to attach to already defined ```$watch``` on current ```$scope```, creating a new ```$watch``` if necessary.
* '^expression' - Attach to an already defined ```$watch``` on current ```$scope``` or first parent.
* '?^expression' - Attempt to attach to already defined ```$watch``` on current ```$scope``` or first parent. Creating a new ```$watch``` on current ```$scope``` necessary.

### How's it work?
AngularJS 1.3 introduces a ```$$watchDelegate``` property on expressions returned by the ```$parse``` service. Decorating the ```$parse``` service allows us to wrap the expression with a delegate that performs our custom logic.

Use with care. A proper understanding of scopes' prototypical inheritance and the mechanics of ```$scope.$digest()``` are recommended.

### See also
[angular-watch-when](https://github.com/pcw216/angular-watch-when) - Makes use of this module to produce 'one-time' watches that recycle when another expression changes.

