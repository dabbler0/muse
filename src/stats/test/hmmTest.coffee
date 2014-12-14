hmm = require '../hmm.coffee'
regression = require '../regression.coffee'
estimator = require '../estimator.coffee'
markov = require '../markov.coffee'
{normalize, weightedRand} = require '../../helper.coffee'

# This experiment has 5 types of tokens and a 10-dimensional
# observation vector.

# Transition classifies from tokens to tokens
transitionClassifier = new markov.MarkovModel [0...5]

# Emission classifies from observation vector to tokens
emissionRegressor = ->
  new regression.StaticRegressor regression.combinationBases 10, 1
emissionClassifier = new estimator.Classifier emissionRegressor, [0...5]

# True emitters
trueEmitterThetas = []
for [0...5]
  trueEmitterThetas.push (Math.random() * 10 for [0...10])
emit = (category) -> (Math.random() * trueEmitterThetas[category][i] for i in [0...10])

# True transition matrix
transitionMatrix = (normalize(Math.random() for [0...5]) for [0...5])

# State advancer
class State
  constructor: ->
    @state = 0

  advance: ->
    @state = weightedRand transitionMatrix[@state]
    return {
      token: @state
      emission: emit @state
    }

state = new State()

# Train the transition classifier and emission classifiers
TRAINING_CASES = 2500
console.log 'Feeding training data...'
lastToken = 0
for [1..TRAINING_CASES]
  {token, emission} = state.advance()

  transitionClassifier.feed lastToken, token
  emissionClassifier.feed emission, token

  lastToken = token

console.log 'Running analyses...'
transitionClassifier.flush()
emissionClassifier.flush()

console.log 'Running tests...'
# Make the model
model = new hmm.HiddenMarkovModel [0...5], transitionClassifier, emissionClassifier

# Make a new state for validation
TEST_CASES = 1000

state = new State()
history = [0]
for [1..TEST_CASES]
  {token, emission} = state.advance()
  history.push token
  model.feed emission

correct = 0
for el, i in model.getBest().toArray()
  if history[i].toString() is el.toString()
    correct += 1
console.log 'ACCRUACY:', correct / TEST_CASES
