{log, floor, ceil, abs} = require '../helper.coffee'
{Filterbank} = require './filterbank.coffee'

# ## getSemitonality
# Get a frequency's approximate position on the semitone cycle. Exact A 440 is 0
semitonality = (frequency) -> log(frequency / 440, 2) * 12

# # SemitoneFilterbank
# Filterbank for the 12 semitones
exports.SemitoneFilterbank = class SemitoneFilterbank extends Filterbank
  constructor: (@framesize, @samplerate) ->
    # Initialize zero vectors
    @vectors = {}

    for i in [0...12]
      @vectors[i] = (0 for [0...@framesize])

    # Fill up vectors with semitone scale. Exclude 0, which
    # provides no info about semitones.
    for frequency in [1...@framesize]
      tonality = semitonality frequency * @samplerate / (@framesize + 1)

      @vectors[floor(tonality) %% 12][frequency] = (1 - abs tonality - floor tonality)
      @vectors[ceil(tonality) %% 12][frequency] = (1 - abs tonality - ceil tonality)
