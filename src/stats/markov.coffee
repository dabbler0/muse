# # normalize
# Given a dict of counts, return
# dict of log probabilities
normalize = (dict) ->
  sum = 0
  for key, val of dict
    sum += val
  sum = Math.log sum

  result = {}
  for key, val of dict
    result[key] = Math.log(val) - sum

  return result

# # smoothHO
# Do 2-fold (held out) smoothing
# given training and held-out data
_smoothHO = (train, ho) ->
  bucketCounts = {}
  bucketSizes = {}

  for token, count of train
    # Init each bucket at 1 (not 0)
    # so that everything has a minimum
    # probability
    bucketCounts[count] = 1

    # Count bucket sizes
    # for redistribution later
    bucketSizes[count] ?= 0
    bucketSizes[count] += 1

  # Get the cross-validated counts
  for token, count of train
    bucketCounts[count] += ho[token]

  smoothedCounts = {}

  # Redistribute
  for token, count of train
    smoothedCounts[token] = bucketCounts[count] / bucketSizes[count]

  return smoothedCounts

# # sumDict
# Component sum
sumDict = (a, b) ->
  result = {}
  for key, val of a
    result[key] = val + b[key]
  return result

# # fullSmooth
# Do HO smoothing two ways and give
# average
fullSmooth = (left, right) ->
  a = _smoothHO left, right
  b = _smoothHO right, left

  return sumDict a, b

# # MarkovCounter
# Represents a set of bigram counts
class MarkovCounter
  constructor: (@alphabet) ->

    @counts = {}
    @totalCounts = {}

    for pred in @alphabet
      @totalCounts[pred] = 0

      @counts[pred] = {}
      for succ in @alphabet
        @counts[pred][succ] = 0
    @size = 0

  feed: (a, b) ->
    @size++
    @counts[a][b]++
    @totalCounts[a]++

  normalize: ->
    @totalCounts = normalize @totalCounts
    for token, obj of @counts
      @counts[token] = normalize obj

  cross: (other) ->
    newCounts = {}
    for token in @alphabet
      newCounts[token] = _smoothHO @counts[token], other.counts[token]

    newTotals = _smoothHO @totalCounts, other.totalCounts

    result = new MarkovCounter @alphabet

    result.counts = newCounts
    result.totalCounts = newTotals

    return result

# # MarkovModel
# Wrapper for MarkovModel
exports.MarkovModel = class MarkovModel
  constructor: (@alphabet) ->
    @left = new MarkovCounter @alphabet
    @right = new MarkovCounter @alphabet
    @smooth = null

  feed: (a, b) ->
    if @left.size < @right.size
      @left.feed a, b
    else
      @right.feed a, b

  flush: ->
    @smooth = @left.cross @right
    @smooth.normalize()

  estimate: (token) -> @smooth.counts[token]
