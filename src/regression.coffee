###
Muse strict linear regression implementation
Copyright (c) 2014 Anthony Bau
MIT License.
###

numeric = require '../vendor/numeric.js'

# # Regressor
# Linear combination regressor class.
exports.Regressor = class Regressor
  constructor: (@bases) ->

  # ## regress
  # Given map of objects {input: [numbers], output: number}, perform
  # direct linear regression.
  regress: (map) ->
    y = ([data.output] for data in map)
    q = ((basis(data.input) for basis in @bases) for data in map)
    t = numeric.transpose q

    return numeric.dot(numeric.inv(numeric.dot(t, q)), numeric.dot(t, y))

  # ## apply
  # Apply the linear combination on a given input to get
  # predicted output.
  apply: (regression, input) ->
    q = (basis(input) for basis in @bases)
    return numeric.dot(q, regression)[0]

# # PolynomialRegressor
# Linear combination regressor on nth-degree monomial terms
exports.PolynomialRegressor = class PolynomialRegressor extends Regressor
  # ## _getBasisFunctions
  # Get all the polynomial bases of degree p for an n-dimensional
  # space.
  _getBasisFunctions = (n, p) ->
    # Base case for recursion -- 0-dimensional space
    # has only one basis function (bias term)
    if n is 0
      return [(x) -> 1]
    else
      # Recurse -- get polynomial bases for (n-1)-dimensional space
      bases = _getBasisFunctions n - 1, p

      # Add all the possible new powers for the new base
      newBases = []
      for power in [0..p] then do (power) ->
        for base in bases then do (base) ->
          newBases.push (x) -> Math.pow(x[n - 1], power) * base(x)

      return newBases

  # ## constructor
  # Assign polynomial basis functions.
  constructor: (@dimensions, @degree) ->
    @bases = _getBasisFunctions @dimensions, @degree
