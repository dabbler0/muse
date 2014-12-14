###
Muse classifier functions.
Copyright (c) 2014 Anthony Bau.
MIT License.
###

{log, normalize, pow, argmax, clamp} = require '../helper.coffee'

# # Estimator
# Base class for estimators
exports.Estimator = class Estimator
  constructor: ->
    @flushed = false

  feed: (input, output) ->
    @flushed = false

  estimate: (input) ->
    unless @flushed
      @flush()
    return 0

  flush: ->
    @flushed = true

# ## formatData
# Turn categorised data into binary 0/1-mapped data
# for training with linear regression.
_formatData = (data, category) ->
  data.map (datum) ->
    input: data.input
    output: (if datum.category is category then 1 else 0)

# # Classifier
# A general regression classifier.
#
# @estimator should be an estimator generator function.
exports.Classifier = class Classifier
  constructor: (@estimator, @categories) ->
    @estimators = {}

    # Instantiate a bunch of estimators
    for category in @categories
      @estimators[category] = @estimator()

    @flushed = true

  # ## feed
  feed: (input, category) ->
    # Feed a positive to the proper category
    @estimators[category].feed input, 1

    # Feed a negative to the other categories
    for other in @categories when other isnt category
      @estimators[other].feed input, 0

    @flushed = false
    return

  # ## flush
  # Wrapper to flush all child estimators
  flush: ->
    @flushed = true
    estimator.flush() for key, estimator of @estimators
    return

  # ## estimate
  # Get log probabilities.
  estimate: (input) ->
    probs = {}
    for category in @categories
      probs[category] = clamp 0, 1, @estimators[category].estimate input

    probs = normalize(probs)
    for key, val of probs
      probs[key] = log val

    return probs

  # ## classify
  # Get the highest probability input.
  classify: (input) -> argmax @estimate input
