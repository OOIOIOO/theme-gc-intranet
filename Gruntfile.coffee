#global module:false
module.exports = (grunt) ->

	# Default task.
	@registerTask(
		"default"
		"Default task, that runs the production build"
		[
			"dist"
		]
	)

	@registerTask(
		"travis"
		"Task run by Travis-CI"
		[
			"dist"
		]
	)

	@registerTask(
		"dist"
		"Produces the production files"
		[
			"checkDependencies"
			"build"
			"assets-dist"
			"assemble"
			"htmlmin"
		]
	)

	#Alternate External tasks
	@registerTask(
		"debug"
		"Produces unminified files"
		[
			"build"
			"assemble:demos"
			"assemble:theme"
		]
	)

	@registerTask(
		"build"
		"Produces unminified files"
		[
			"clean:dist"
			"i18n_csv"
			"copy:wetboew"
			"assets"
			"css"
			"js"
		]
	)

	@registerTask(
		"init"
		"Only needed when the repo is first cloned"
		[
			"install-dependencies"
			"hub"
		]
	)

	@registerTask(
		"deploy"
		"Build and deploy artifacts to wet-boew-dist"
		->
			if process.env.TRAVIS_PULL_REQUEST isnt true and process.env.DIST_REPO isnt `undefined` and ( process.env.TRAVIS_TAG isnt `undefined` or process.env.TRAVIS_BRANCH is "master" )
				grunt.task.run [
					"copy:deploy"
					"gh-pages:travis"
					"wb-update-examples"
				]
	)

	@registerTask(
		"server"
		"Run the Connect web server for local repo"
		[
			"connect:server:keepalive"
		]
	)

	@registerTask(
		"css"
		"INTERNAL: Compiles Sass and vendor prefixes the result"
		[
			"sass"
			"autoprefixer"
			"cssmin"
		]
	)

	@registerTask(
		"assets-dist"
		"INTERNAL: Process non-CSS/JS assets to dist"
		[
			"copy:assets_min"
			"copy:wetboew_demo_min"
		]
	)

	@registerTask(
		"assets"
		"INTERNAL: Process non-CSS/JS assets to dist"
		[
			"copy:assets"
			"copy:wetboew_demo"
		]
	)

	@registerTask(
		"js"
		"INTERNAL: Brings in the custom JavaScripts."
		[
			"copy:js"
			"uglify"
		]
	)

	@registerTask(
		"test"
		"INTERNAL: Runs testing tasks except for SauceLabs testing"
		[
			"jshint"
			"jscs"
		]
	)

	@initConfig

		# Metadata.
		pkg: @file.readJSON("package.json")
		jqueryVersion: grunt.file.readJSON("lib/jquery/bower.json")
		jqueryOldIEVersion: grunt.file.readJSON("lib/jquery-oldIE/bower.json")
		banner: "/*!\n * Web Experience Toolkit (WET) / Boîte à outils de l'expérience Web (BOEW)\n * wet-boew.github.io/wet-boew/License-en.html / wet-boew.github.io/wet-boew/Licence-fr.html\n" +
				" * v<%= pkg.version %> - " + "<%= grunt.template.today('yyyy-mm-dd') %>\n *\n */"
		deployBranch: "<%= pkg.name %>"

		checkDependencies:
			all:
				options:
					npmInstall: false
		clean:
			dist: [ "dist"]

		copy:
			wetboew:
				expand: true
				cwd: "lib/wet-boew/dist"
				src: [
					"**/*.*"
					"!**/theme*.css"
					"!**/favicon*.*"
					"!demos/**/*.*"
					"!unmin/demos/**/*.*"
					"!theme/**/*.*"
					"!unmin/theme/**/*.*"
					"!**/logo.*"
				]
				dest: "dist/"
			wetboew_demo:
				expand: true
				cwd: "lib/wet-boew/dist/unmin"
				src: "demos/**/demo/*.*"
				dest: "dist/unmin/"
			wetboew_demo_min:
				expand: true
				cwd: "lib/wet-boew/dist"
				src: "demos/**/demo/*.*"
				dest: "dist/"
			assets:
				expand: true
				cwd: "src/assets"
				src: "**/*.*"
				dest: "dist/unmin/assets"
			assets_min:
				expand: true
				cwd: "src/assets"
				src: "**/*.*"
				dest: "dist/assets"
			js:
				expand: true
				cwd: "src"
				src: "**/*.js"
				dest: "dist/unmin/js"
			deploy:
				src: [
					"*.txt"
					"README.md"
				]
				dest: "dist"
				expand: true

		sass:
			base:
				expand: true
				cwd: "src"
				src: "theme*.scss"
				dest: "dist/unmin/css"
				ext: ".css"

		autoprefixer:
			options:
				browsers: [
					"last 2 versions"
					"ff >= 17"
					"opera 12.1"
					"bb >= 7"
					"android >= 2.3"
					"ie >= 8"
					"ios 5"
				]
			all:
				cwd: "dist/unmin/css"
				src: [
					"*theme*.css"
				]
				dest: "dist/unmin/css"
				expand: true

		cssmin:
			theme:
				options:
					banner: "<%= banner %>"
				expand: true
				cwd: "dist/unmin/css/"
				src: "*theme*.css"
				ext: ".min.css"
				dest: "dist/css"

		jshint:
			options:
				jshintrc: "lib/wet-boew/.jshintrc"

			lib_test:
				src: [
					"src/**/*.js"
				]

		jscs:
			all:
				src: [
					"src/**/*.js"
				]

		# Minify
		uglify:
			dist:
				options:
					banner: "<%= banner %>"
				expand: true
				cwd: "<%= copy.js.cwd %>"
				src: "<%= copy.js.src %>"
				dest: "dist/js/"
				ext: ".min.js"

		i18n_csv:
			list_locales:
				options:
					csv: "lib/wet-boew/src/i18n/i18n.csv"
					startCol: 1
					listOnly: true

		assemble:
			options:
				prettify:
					indent: 2
				marked:
					sanitize: false
				production: false
				data: [
					"lib/wet-boew/site/data/**/*.{yml,json}"
					"site/data/**/*.{yml,json}"
				]
				helpers: [
					"lib/wet-boew/site/helpers/helper-*.js"
					"site/helpers/helper-*.js"
				]
				partials: [
					"lib/wet-boew/site/includes/**/*.hbs"
					"site/includes/**/*.hbs"
				]
				layoutdir: "site/layouts"
				layout: "default.hbs"

			theme:
				options:
					assets: "dist/unmin"
					environment:
						jqueryVersion: "<%= jqueryVersion.version %>"
						jqueryOldIEVersion: "<%= jqueryOldIEVersion.version %>"
					flatten: true,
					plugins: ["assemble-contrib-i18n"]
					i18n:
						languages: "<%= i18n_csv.list_locales.locales %>"
						templates: [
							"site/pages/*.hbs"
							"!site/pages/splashpage*.hbs"
							"!site/pages/index*.hbs"
							"!site/pages/404*.hbs"
							"!site/pages/servermessage-*.hbs"
						]
				dest: "dist/unmin/"
				src: "!*.*"

			demos:
				options:
					assets: "dist/unmin"
					environment:
						jqueryVersion: "<%= jqueryVersion.version %>"
						jqueryOldIEVersion: "<%= jqueryOldIEVersion.version %>"
				files: [
						#site
						expand: true
						cwd: "site/pages"
						src: [
							"**/*.hbs"
							"!*.hbs"
							"splashpage*.hbs"
							"index*.hbs"
							"404*.hbs"
							"servermessage-*.hbs"
						]
						dest: "dist/unmin"
					,
						#plugins
						expand: true
						cwd: "lib/wet-boew/site/pages/demos"
						src: [
							"**/*.hbs"
						]
						dest: "dist/unmin/demos"
					,
						expand: true
						cwd: "lib/wet-boew/src/plugins"
						src: [
							"**/*.hbs"
						]
						dest: "dist/unmin/demos"
					,
						expand: true
						cwd: "lib/wet-boew/src/polyfills"
						src: "**/*.hbs"
						dest: "dist/unmin/demos"
					,
						expand: true
						cwd: "lib/wet-boew/src/other"
						src: "**/*.hbs"
						dest: "dist/unmin/demos"
				]

			theme_min:
				options:
					assets: "dist"
					environment:
						suffix: ".min"
						jqueryVersion: "<%= jqueryVersion.version %>"
						jqueryOldIEVersion: "<%= jqueryOldIEVersion.version %>"
					flatten: true,
					plugins: ["assemble-contrib-i18n"]
					i18n:
						languages: "<%= i18n_csv.list_locales.locales %>"
						templates: [
							"site/pages/*.hbs"
							"!site/pages/splashpage*.hbs"
							"!site/pages/index*.hbs"
							"!site/pages/404*.hbs"
							"!site/pages/servermessage-*.hbs"
						]
				dest: "dist/"
				src: "!*.*"

			demos_min:
				options:
					environment:
						suffix: ".min"
						jqueryVersion: "<%= jqueryVersion.version %>"
						jqueryOldIEVersion: "<%= jqueryOldIEVersion.version %>"
					assets: "dist"
				files: [
						#site
						expand: true
						cwd: "site/pages"
						src: [
							"**/*.hbs"
							"!*.hbs"
							"splashpage*.hbs"
							"index*.hbs"
							"404*.hbs"
							"servermessage-*.hbs"
						]
						dest: "dist"
					,
						#plugins
						expand: true
						cwd: "lib/wet-boew/site/pages/demos"
						src: [
							"**/*.hbs"
						]
						dest: "dist/demos"
					,
						expand: true
						cwd: "lib/wet-boew/src/plugins"
						src: [
							"**/*.hbs"
						]
						dest: "dist/demos"
					,
						expand: true
						cwd: "lib/wet-boew/src/polyfills"
						src: "**/*.hbs"
						dest: "dist/demos"
					,
						expand: true
						cwd: "lib/wet-boew/src/other"
						src: "**/*.hbs"
						dest: "dist/demos"
				]

		htmlmin:
			options:
				collapseWhitespace: true
				preserveLineBreaks: true
			all:
				cwd: "dist"
				src: [
					"**/*.html"
					"!unmin/**/*.html"
				]
				dest: "dist"
				expand: true

		hub:
			"wet-boew":
				src: [
					"lib/wet-boew/Gruntfile.coffee"
				]
				tasks: [
					"dist"
				]

		"install-dependencies":
			options:
				cwd: "lib/wet-boew"
				failOnError: false
				isDevelopment: true

		connect:
			options:
				port: 8000

			server:
				options:
					base: "dist"
					middleware: (connect, options, middlewares) ->
						middlewares.unshift(connect.compress(
							filter: (req, res) ->
								/json|text|javascript|dart|image\/svg\+xml|application\/x-font-ttf|application\/vnd\.ms-opentype|application\/vnd\.ms-fontobject/.test(res.getHeader('Content-Type'))
						))
						middlewares

		"gh-pages":
			options:
				clone: "themes-dist"
				base: "dist"

			travis:
				options:
					repo: process.env.DIST_REPO
					branch: "<%= deployBranch %>"
					message: ((
						if process.env.TRAVIS_TAG
							"Production files for the " + process.env.TRAVIS_TAG + " maintenance release"
						else
							"Travis build " + process.env.TRAVIS_BUILD_NUMBER
					))
					silent: true,
					tag: ((
						if process.env.TRAVIS_TAG then process.env.TRAVIS_TAG else false
					))
				src: [
					"**/*.*"
				]

		"wb-update-examples":
			travis:
				options:
					repo: process.env.DEMOS_REPO
					branch: process.env.DEMOS_BRANCH
					message: "<%= grunt.config('gh-pages.travis.options.message') %>"
					silent: true

	# These plugins provide necessary tasks.
	@loadNpmTasks "assemble"
	@loadNpmTasks "grunt-autoprefixer"
	@loadNpmTasks "grunt-check-dependencies"
	@loadNpmTasks "grunt-contrib-clean"
	@loadNpmTasks "grunt-contrib-connect"
	@loadNpmTasks "grunt-contrib-copy"
	@loadNpmTasks "grunt-contrib-cssmin"
	@loadNpmTasks "grunt-contrib-jshint"
	@loadNpmTasks "grunt-contrib-htmlmin"
	@loadNpmTasks "grunt-contrib-uglify"
	@loadNpmTasks "grunt-contrib-watch"
	@loadNpmTasks "grunt-gh-pages"
	@loadNpmTasks "grunt-hub"
	@loadNpmTasks "grunt-i18n-csv"
	@loadNpmTasks "grunt-install-dependencies"
	@loadNpmTasks "grunt-jscs-checker"
	@loadNpmTasks "grunt-sass"
	@loadNpmTasks "grunt-wet-boew-postbuild"

	require( "time-grunt" )( grunt )
	@
