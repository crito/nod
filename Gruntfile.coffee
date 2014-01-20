'use strict'

module.exports = (grunt) ->
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)

  grunt.initConfig
    yeoman:
      dist:      'dist'
      build:     './'
      src:       'src'
      distTest:  'dist.spec'
      srcTest:   'spec'
    clean:
      dist: ['<%= yeoman.dist %>', '<%= yeoman.distTest %>']
      build: ['<%= yeoman.build %>/nod.js',
              '<%= yeoman.build %>/nod.min.js',
              '<%= yeoman.build %>/nod.map.js']
    uglify:
      nod:
        files:
          '<%= yeoman.build %>/nod.min.js': ['<%= yeoman.build %>/nod.js']
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
      build:
        options:
          sourceMap: true
        files: [
          expand:  true
          cwd:     '<%= yeoman.src %>'
          src:     '{,*/}*.coffee'
          dest:    '<%= yeoman.build %>'
          ext:     '.js',
        ]
    jasmine:
      src: '<%= yeoman.dist %>/*.js'
      options:
        specs: '<%= yeoman.distTest %>/*.spec.js'
        vendor: 'node_modules/underscore/underscore.js'
    release:
      options:
        tagName: 'v<%= version %>'
        github:
          repo: 'crito/nod'

    grunt.registerTask 'dist', [
      'clean:dist'
      'coffeelint'
      'coffee:dist'
      'coffee:test'
    ]

    grunt.registerTask 'test', [
      'dist'
      'jasmine'
    ]

    grunt.registerTask 'build', [
      'test'
      'clean:build'
      'coffee:build'
      'uglify'
    ]

    grunt.registerTask 'publish', [
      'build'
      'release'
    ]

    grunt.registerTask 'default', [
      'test'
    ]
