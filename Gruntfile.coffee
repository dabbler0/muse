path = require 'path'

notify = (message) ->
  grunt.util.spawn (
    cmd: 'notify-send'
    args: [message, '--urgency=low']
    fallback: 0
  ), ->

module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    coffee:
      options:
        sourceMap: true
      build:
        files: [
          {
            expand: true
            cwd: 'src/'
            src: ['*.coffee']
            dest: 'js/'
            ext: '.js'
          }
        ]


  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['coffee']
