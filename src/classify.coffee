###
Muse classifier functions.
Copyright (c) 2014 Anthony Bau.
MIT License.
###

{log, normalize, pow, argmax} = require './helper.coffee'

# ## formatData
# Turn categorised data into binary 0/1-mapped data
# for training with linear regression.
_formatData = (data, category) ->
  data.map (datum) ->
    input: data.input
    output: (if datum.category is category then 1 else 0)

# # Classifier
# A general regression classifier.
exports.Classifier = class Classifier
  constructor: (@regressor, data) ->
    @regressors = {}

    # Get all the output categories from the data
    @categories = {}
    for datum in data
      @categories[datum.category] = true

    # Regress them all
    for category of @categories
      @regressors[category] = @regressor()
      @regressors[category].regress _formatData data, category

  # ## probs
  # Get the probabilities, weighted softmax-style by `e^x`,
  # of each category
  probs: (input) ->
    probs = {}
    for category of @categories
      probs[category] = pow @regressors[category].apply category
    return normalize probs

  # ## logProbs
  # The log probabilites, useful in long chains of repeated
  # actions (like HMM).
  logProbs: (input) -> @probs(input).map (x) -> log x

  # ## classify
  # Get the highest probability input.
  classify: (input) -> argmax @probs input
