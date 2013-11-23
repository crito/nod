'use strict'

module.exports = (grunt) ->
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)

  grunt.initConfig
    yeoman:
      dist:      'dist'
      src:       'src'
      distTest:  'dist.spec'
      srcTest:   'spec'
    clean:
      dist: ['<%= yeoman.dist %>', '<%= yeoman.distTest %>']
    uglify:
      nod:
        files:
          '<%= yeoman.dist %>/nod.min.js': ['<%= yeoman.dist %>/nod.js']
    coffeelint:
      gruntfile:
        src: 'Gruntfile.coffee'
      lib:
        src: '<%= yeoman.src %>/**/*.coffee'
      test:
        src: '<%= yeoman.srcTest %>/**/*.spec.coffee'
      options:
        no_trailing_whitespace:
          level: 'error'
        max_line_length:
          level: 'warn'
        no_empty_params_list:
          level: 'error'
    coffee:
      dist:
        options:
          sourceMap: true
        files: [
          expand:  true
          cwd:     '<%= yeoman.src %>'
          src:     '{,*/}*.coffee'
          dest:    '<%= yeoman.dist %>'
          ext:     '.js',
        ]
      test:
        options:
          sourceMap: true
        files: [
          expand:  true
          cwd:     '<%= yeoman.srcTest %>'
          src:     '{,*/}*.spec.coffee'
          dest:    '<%= yeoman.distTest %>'
          ext:     '.spec.js',
        ]
    jasmine:
      src: '<%= yeoman.dist %>/*.js'
      options:
        specs: '<%= yeoman.distTest %>/*.spec.js'
        vendor: 'node_modules/underscore/underscore.js'

    grunt.registerTask 'test', [
      'clean'
      'coffeelint'
      'coffee'
      'jasmine'
    ]

    grunt.registerTask 'build', [
      'test'
      'uglify'
    ]

    grunt.registerTask 'default', [
      'test'
    ]
