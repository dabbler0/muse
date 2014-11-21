###
Muse hidden markov model implementation.
Copyright (c) 2014 Anthony Bau.
MIT License.
###

{argmax, blank, LinkedList} = require './helper.coffee'

# # HMM
# Hidden Markov Model class
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
    emitProbs = @emission.apply observation

    # For each pair, compute transition probabilities
    for oldLabel, val of @state
      transitProbs = @transition.apply oldLabel

      # Update max probabilities if necessary
      for newLabel in @categories
        estimatedProb = emitProbs[newLabel] + transitProbs[newLabel]
        newState[newLabel] = Math.max newState[newLabel], estimatedProb

        # Record which predecessor it was that was the max for this one
        bestPredecessors[newLabel] = oldLabel

    # Update history with backward-pointing linked list
    newHistory = {}
    for oldLabel, newLabel of bestPredecessors
      newHistory[newLabel] = new LinkedList newLabel, @history[oldLabel]

    # Put new dicts in place
    @history = newHistory
    @state = newState

  # ## getBest
  # Get the current best estimated sequence.
  getBest: -> @history[argmax @state]
