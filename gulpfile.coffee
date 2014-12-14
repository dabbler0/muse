gulp = require 'gulp'
gutil = require 'gulp-util'
browserify = require 'browserify'
coffeeify = require 'caching-coffeeify'
uglify = require 'gulp-uglify'
transform = require 'vinyl-transform'
rename = require 'gulp-rename'
coffee = require 'gulp-coffee'
zip = require 'gulp-zip'

gulp.task 'browser', ->
  browserified = transform (filename) ->
    b = browserify(filename, standalone: 'muse')
    b.transform(coffeeify)
    return b.bundle()

  gulp.src('src/browser.coffee')
      .pipe(browserified)
      .pipe(rename 'browser.js')
      .pipe(gulp.dest './build/')

gulp.task 'nw', ->
  gulp.src(['./**/*', '!build/app.nw', '!data/**/*'])
      .pipe(zip('app.nw'))
      .pipe(gulp.dest('build'))

gulp.task 'default', ['browser']
gulp.task 'all', ['browser', 'nw']
