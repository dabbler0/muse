regression = require '../regression.coffee'
assert = require 'assert'

combine = (a, b) ->
  result = []
  for ai, i in a
    for bj, j in b
      result.push ai * bj
  return result

# Polynomial basis generation test
do ->
  bases = regression.polynomialBases 2, 2

  map = {}
  for basis in bases
    map[basis([2, 3])] = true

  for result in combine([1, 2, 4], [1, 3, 9])
    assert result of map

# Combination basis generation test
do ->
  bases = regression.combinationBases 3, 2

  assert bases.length is 10

  map = {}
  for basis in bases
    map[basis([2, 3, 5])] = true

  for result in [1, 4, 9, 25, 6, 10, 15]
    assert result of map

EPSILON = 0.001

# Linear regressor tests with quadratic combination functions
testRegressor = (Regressor, inputs, bases, cases, epsilon) ->
  trueThetas = ((Math.random() * 10 - 5) for _ in bases)

  f = (x) ->
    sum = 0
    for basis, i in bases
      sum += trueThetas[i] * basis(x)
    return sum

  regressor = new Regressor bases

  for [1..cases]
    input = (Math.random() for [0...inputs])
    regressor.feed input, f input

  for [1..100]
    input = (Math.random() for [0...inputs])
    output = f input
    estimate = regressor.estimate input

    assert Math.abs(estimate - output) < epsilon

# Static regressor
console.log 'Testing static regressor on 450000 cases (approx. 100 songs)'
testRegressor regression.StaticRegressor, 12, regression.polynomialBases(12, 1), 450000, 1e-10

# Gradient regressor
console.log 'Testing gradient regressor'
testRegressor regression.GradientRegressor, regression.polynomialBases(2, 2), 100000, 0.5
