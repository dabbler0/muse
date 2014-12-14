tab64 = require 'tab64'

exports.AnnotatedSong = class AnnotatedSong
  constructor: ->
    @frames = []
    @chordData = []

  serialize: ->
    @frames.map (x, i) => {
      frame: tab64.encode(x)
      chord: @chordData[i]
    }

AnnotatedSong.parse = (song) ->
  annotatedSong = new AnnotatedSong()
  for frame in song
    annotatedSong.frames.push tab64.decode frame.frame, 'float32'
    annotatedSong.chordData.push frame.chord
  return annotatedSong
