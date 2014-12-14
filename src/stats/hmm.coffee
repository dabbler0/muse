###
Muse hidden markov model implementation.
Copyright (c) 2014 Anthony Bau.
MIT License.
###

{argmax, blank, LinkedList} = require '../helper.coffee'

# # HMM
# Hidden Markov Model class
#
# `@categories` -- `Array`
# `@transition` -- `MarkovModel`
# `@emission` -- `Estimator`
#
# For example usage see test/hmmTest
exports.HiddenMarkovModel = class HiddenMarkovModel
  constructor: (@categories, @transition, @emission) ->
    # Init DP state
    @state = {} # Current probabilities that each state was last
    @history = {} # Linked lists of all the most probable histories with each state being last
    for key, val of @categories
      @state[key] = 0
      @history[key] = new LinkedList key, null

  # ## feed
  # Add a new observation to the list of observations,
  # and update all the estimates in the trellis.
  feed: (observation) ->
    newState = blank @categories, -Infinity
    bestPredecessors = blank @categories, null

    # Get emission probabilities
    emitProbs = @emission.estimate observation

    # For each pair, compute transition probabilities
    for oldLabel, val of @state
      transitProbs = @transition.estimate oldLabel

      # Update max probabilities if necessary
      for newLabel in @categories
        estimatedProb = emitProbs[newLabel] + transitProbs[newLabel] + val

        # Record which predecessor it was that was the max for this one
        if estimatedProb >= newState[newLabel]
          newState[newLabel] = estimatedProb
          bestPredecessors[newLabel] = oldLabel

    # Update history with backward-pointing linked list
    newHistory = {}
    for newLabel, oldLabel of bestPredecessors
      newHistory[newLabel] = new LinkedList newLabel, @history[oldLabel]

    # Put new dicts in place
    @history = newHistory
    @state = newState

  # ## getBest
  # Get the current best estimated sequence.
  getBest: ->
    return @history[argmax @state]
