matchdep = require('matchdep')

module.exports = (grunt) ->
	matchdep.filterDev('grunt-*').filter((dep) -> dep != 'grunt-cli').forEach(grunt.loadNpmTasks)
	
	grunt.registerTask('default', ['test', 'build'])
	grunt.registerTask('test', ['karma'])
	grunt.registerTask('build', ['coffee'])
	
	grunt.initConfig 
		coffee:
			compile:
				options:
					bare: false
					sourceMap: false
				expand: true
				flatten: false
				cwd: 'src'
				src: '**/*.coffee'
				dest: 'dist'
				ext: '.js'

		karma:
			unit:
				options:
					files: [
						'bower_components/angular/angular.js'
						'bower_components/angular-mocks/angular-mocks.js'
						'bower_components/lodash/dist/lodash.js'
						'src/**/*.coffee'
						'test/**/*.coffee'
					]
				preprocessors:
					'**/*.coffee': ['coffee']

				browsers: ['PhantomJS']
				frameworks: ['jasmine']
				singleRun: true
				coffeePreprocessor:
					options:
						bare: false
						sourceMap: false
					transformPath: (path)->
						return path.replace(/\.coffee$/, '.js')
