###
Muse strict linear regression implementation
Copyright (c) 2014 Anthony Bau
MIT License.
###

numeric = require '../../vendor/numeric.js'
estimator = require './estimator.coffee'

# # StaticRegressor
# Linear combination regressor class; keeps a record of all
# inputs and ouputs and does a full linear regression retraining on every flush.
#
# More accurate but lower performance than `GradientRegressor`.
exports.StaticRegressor = class StaticRegressor extends estimator.Estimator
  constructor: (@bases) ->
    @map = []
    @regression = null

    super

  # ## flush
  # Given map of objects {input: [numbers], output: number}, perform
  # direct linear regression.
  flush: ->
    super

    y = ([data.output] for data in @map)
    q = ((basis(data.input) for basis in @bases) for data in @map)
    t = numeric.transpose q

    @regression = numeric.dot(numeric.inv(numeric.dot(t, q)), numeric.dot(t, y))
    return

  # ## feed
  # Add to @map
  feed: (input, output) ->
    super

    @map.push {
      input: input
      output: output
    }

  # ## estimate
  # Apply the linear combination on a given input to get
  # predicted output.
  estimate: (input) ->
    super

    q = (basis(input) for basis in @bases)
    return numeric.dot(q, @regression)[0]

# # GradientRegressor
# Keeps a running record of thetas; given new input/output maps,
# performs gradient descent linear regression on given basis functions.
exports.GradientRegressor = class GradientRegressor extends estimator.Estimator
  constructor: (@bases, rate = 1, @lambda = 0.1) ->
    @thetas = (0 for basis in @bases)
    @rate = rate / @bases.length

    super

  # ## estimate
  # Get the predicted output for the given input using
  # basis functions and current thetas.
  #
  # Returns sum(theta[i] * basis[i]).
  estimate: (input) ->
    super

    output = 0
    for basis, i in @bases
      output += @thetas[i] * basis(input)
    return output

  # ## feed
  # Given an input/output map, do another gradient descent iteration to improve
  # thetas.
  feed: (input, output) ->
    super

    # Get the gradient (error term)
    gradient = @estimate(input) - output
    for basis, i in @bases
      # Apply gradient descent formula. `@lambda` is the regularization term, and penalizes
      # high coefficients to avoid overfitting.
      @thetas[i] -= @rate * (gradient + @lambda * @thetas[i] / @thetas.length) * basis(input)

# # polynomialBases
# Get all possible polynomial combinations of a set of inputs,
# with each input being raised to a power no more than p.
exports.polynomialBases = polynomialBases = (n, p) ->
  # Base case for recursion -- 0-dimensional space
  # has only one basis function (bias term)
  if n is 0
    return [(x) -> 1]
  else
    # Recurse -- get polynomial bases for (n-1)-dimensional space
    bases = polynomialBases n - 1, p

    # Add all the possible new powers for the new base
    newBases = []
    for power in [0..p] then do (power) ->
      for base in bases then do (base) ->
        newBases.push (x) -> Math.pow(x[n - 1], power) * base(x)

    return newBases

# # combinationBases
# Return all possible polynomial combinations with each
# monomial having total degree less than p.
_combinationBases = (n, p) ->
  if p is 0
    return [(x) -> 1]
  else
    # Recurse
    bases = _combinationBases n, p - 1

    # Add all possible polynomial combinations
    newBases = []
    for basis in bases
      for i in [0...n] then do (basis, i) ->
        newBases.push (x) -> basis(x) * x[i]

    return newBases

exports.combinationBases = (n, p) ->
  bases = _combinationBases n, p
  bases.push (x) -> 1
  return bases
