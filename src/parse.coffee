fs = require 'fs'
tab64 = require 'tab64'

chords = require './sound/chords.coffee'

estimator = require './stats/estimator.coffee'
markov = require './stats/markov.coffee'
hmm = require './stats/hmm.coffee'
regression = require './stats/regression.coffee'

CHORDS = [
  'F'
  'Bb'
  'Bbmin'
  'Bbsus2'
  'C'
  'Gm'
  'Am'
  'Dm'
  'A'
]

NOTE_NAMES = [
  'bias'
  'A'
  'Bb'
  'B'
  'C'
  'Db'
  'D'
  'Eb'
  'E'
  'F'
  'Gb'
  'G'
  'Ab'
]

for chord, i in CHORDS
  CHORDS[i] = new chords.Chord(chord).trueName

regressorGenerator = ->
  new regression.Regressor regression.combinationBases 12, 1
classifier = new estimator.Classifier regressorGenerator, CHORDS
transition = new markov.MarkovModel CHORDS

fs.readFile '../data/Matilda-When_I_Grow_Up.wav.frames', (err, data) ->
  data = data.toString()
  last = 'Fmaj'

  for el, i in data.split '\n' when el.length > 0
    [chord, framestr] = el.split '\t'

    chord = new chords.Chord(chord).trueName
    frame = tab64.decode framestr, 'float64'
    transition.feed last, chord
    last = chord

    classifier.feed frame, chord

  classifier.flush()
  for c in CHORDS
    console.log c
    console.log '-----'
    console.log classifier.estimators[c].thetas.map((x, i) -> NOTE_NAMES[i] + '\t' + x).join '\n'

  transition.flush()
  console.log transition.smooth.counts

  hmm = new hmm.HiddenMarkovModel CHORDS, transition, classifier
  trueHistory = []

  for el, i in data.split '\n' when el.length > 0
    [chord, framestr] = el.split '\t'

    trueHistory.push chord = new chords.Chord(chord).trueName
    frame = tab64.decode framestr, 'float64'
    hmm.feed frame

  console.log (hmm.getBest().toArray().map (x, i) -> trueHistory[i] + '\t' + x).join '\n'
