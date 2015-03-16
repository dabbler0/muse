numeric = require 'numeric'

class Regressor
  constructor: (@dim) ->
    @left = ((0 for [0...@dim]) for [0...@dim])
    @right = ([0] for [0...@dim])

  feed: (inputs, output) ->
    # Increment left side (A-transpose * A)
    for a, i in inputs
      for b, j in inputs
        left[i][j] += a * b

    # Increment right side
    for a, i in inputs
      @right[0][i] += output * a

  flush: ->
    return numeric.solve @left, @right
