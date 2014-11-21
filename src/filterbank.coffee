###
Muse filterbank wrapper.
Copyright (c) 2014 Anthony Bau
MIT License.
###

# # Filterbank
# Utility wrapper for an FFT filterbank
exports.Filterbank = class Filterbank
  constructor: ->

  # ## apply
  # Get the sound energy of each
  # filter in the filterbank.
  apply: (frame) ->
    powers = {}
    for key, vector of @vectors
      powers[key] = 0
      for el, i in frame
        powers[key] += (el * vector[i]) ** 2
    return powers

  # ## toString
  # For debugging purposes
  toString: -> JSON.stringify @vectors, null, 2
