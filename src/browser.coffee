# Visualization dependency
Chart = require '../vendor/chart.js'

helper = require './helper.coffee'

# FFT dependency
dsp = require '../vendor/dsp.js'

# Other sound stuff
chords = require './sound/chords.coffee'
capture = require './sound/capture.coffee'
annotated = require './sound/annotated.coffee'
{SemitoneFilterbank} = require './sound/semitones.coffee'

# Statistics stuff
estimator = require './stats/estimator.coffee'
markov = require './stats/markov.coffee'
hmm = require './stats/hmm.coffee'

# I/O stuff
fs = require 'fs'

wav = require 'wav'

_reverse = (buffer) ->
  result = new Float32Array buffer.length
  for el, i in buffer
    result[buffer.length - i] = el
  return result

# # Audio Setup
# Activate capture module with
# options
FRAME_SIZE = 2048
SAMPLE_RATE = 44100

capture.activateInput FRAME_SIZE, (info) ->
  SAMPLE_RATE = info.sampleRate

capture.activateOutput FRAME_SIZE

# # Inspector frame
# Right hand pane; contains functionality for analysing
# and playng back audio
class Inspector
  constructor: (@wrapper, @frameSize = FRAME_SIZE, @frameRate = SAMPLE_RATE) ->
    # Set up the chart canvas
    canvas = document.createElement('canvas')
    canvas.width = canvas.height = 500

    @ctx = canvas.getContext '2d'
    @canvas = $ canvas

    # Init chart.js
    @chart = new Chart(@ctx).Bar({
      labels: ['A', 'Bb', 'B', 'C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab']
      datasets: [
        {
          label: 'Semitone filterbank'
          fillColor: 'rgba(120, 220, 220, 0.5)'
          strokeColor: 'rgba(120, 220, 220, 0.8)'
          highlightFill: 'rgba(120, 220, 220, 0.75)'
          highlightStroke: 'rgba(120, 220, 220, 1)'
          data: (0 for [1..12])
        }
      ]
    }, {
      animation: false
      showScale: false
    })

    # Init fft and semitone filterbank
    @fft = new dsp.FFT @frameSize, @frameRate
    @filterbank = new SemitoneFilterbank @frameSize, @frameRate

    # Playback slider
    @slider = $('<input type="range">')
    @slider.val 0
    @slider.attr 'max', 0

    # Simple frame-num display for the slider
    @sliderDisplay = $('<div>')
    @frameNum = 0

    @slider.on 'input', =>
      unless @playingForward or @playingBackward
        @frameNum = Number @slider.val()
        @redraw()

    # Override the default behaviour of the slider
    @slider.on 'keypress', => return false

    # Listen to the forward/backward keys to know when to play
    @slider.on 'keydown', (event) =>
      if event.which is 39
        @playingForward = true
      if event.which is 37
        @playingBackward = true
    @slider.on 'keyup', (event) =>
      if event.which is 39
        @playingForward = false
      if event.which is 37
        @playingBackward = false

    # Ouptut playing forward/backward
    capture.output =>
      if @playingForward
        frame = @data[@frameNum++]
      else if @playingBackward
        frame = _reverse @data[@frameNum--]
      else
        return new Float32Array 2048
      @redraw()
      return frame

    @data = []
    @changes = {}
    @setter = null

    # Chord input
    @chordInput = $('<input class="form-control">')
    @chordInput.on 'input', =>
      @changes[@frameNum] = @chordInput.val()
      if @setter? then @setter @changes
      @redraw()

    # Populate
    @wrapper.append($('<div>').append @canvas).append(@slider)
      .append(@sliderDisplay).append($('<div>').append @chordInput)

    @nextFrame = null

  getChord: (frameNum) ->
    lastChord = 'N.C.'
    for frame, chord of @changes
      if frame > frameNum
        return lastChord
      lastChord = chord
    return lastChord

  redraw: ->
    @slider.val @frameNum
    frame = @data[@frameNum]
    chord = @getChord @frameNum

    # Display the frame number and chord name
    @sliderDisplay.text "#{@slider.val()} -- #{chord}"
    @chordInput.val chord

    # Apply the forward filterbank
    @fft.forward frame
    powers = @filterbank.apply @fft.spectrum

    # Put it in the chart
    for bar, i in @chart.datasets[0].bars
      @chart.datasets[0].bars[i].value = powers[i]
    @chart.update()

  inspect: (file, setter) ->
    @setter = setter
    readWav file, (@data) =>
      @slider.val 0
      @slider.attr 'max', @data.length - 1
      @redraw()

readWav = (file, cb) ->
  data = []

  # Read in the file.
  reader = new wav.Reader()
  fs.createReadStream(file).pipe reader

  # Add frames of proper size to the
  # data array
  buffer = new Float32Array FRAME_SIZE; i = 0
  reader.on 'data', (chunk) ->
    offset = 0

    # Read off all the bytes in the chunk we just read;
    until offset is chunk.length
      buffer[i] = chunk.readInt16LE(offset) / 32767
      offset += 2; i += 1

      # Append and reset buffer when it fills up
      if i is buffer.length
        data.push buffer; i = 0
        buffer = new Float32Array FRAME_SIZE

  # Callback
  reader.on 'end', ->
    cb? data

inspector = new Inspector $('#inspector-frame')

# Track list
do ->
  files = fs.readdirSync 'data'
  wrapper = $ '#tracks-list-wrapper'
  for file in files then do (file) ->
    wrapper.append $('<div>').text(file).click ->
      inspector.inspect 'data/' + file, (chords) ->
        fs.writeFile 'data/' + file + '.chords', JSON.stringify chords, null, 2
