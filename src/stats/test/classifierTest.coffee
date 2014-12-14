{rand} = require '../../helper.coffee'
estimator = require '../estimator.coffee'
regression = require '../regression.coffee'
assert = require 'assert'

# Linear regression on ten bases
regressorGenerator = ->
  new regression.StaticRegressor regression.combinationBases 10, 1

# Generate fake "categories"
categoryThetas = []
for [1..5]
  categoryThetas.push (Math.random() * 10 for [0...10])

generate = (category) -> (Math.random() * categoryThetas[category][i] for i in [0...10])

# Classifier
classifier = new estimator.Classifier regressorGenerator, [0...5]

# Run training
for [1..200]
  category = rand 5
  classifier.feed generate(category), category

# Run testing
correct = 0; total = 1000
for [1..total]
  category = rand 5
  data = generate category
  if category.toString() is classifier.classify data
    correct += 1

# Assert accuracy
console.log 'accuracy is', correct / total
assert correct > 0.8 * total
