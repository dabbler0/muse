###
Muse audio capture helper functions.
Copyright (c) 2014 Anthony Bau
MIT License.
###

# # Browser compatability
# ## getUserMedia
# This is different almost everywhere
_getUserMedia = navigator.getUserMedia = navigator.getUserMedia ?
  navigator.webkitGetUserMedia ?
  navigator.mozGetUserMedia ?
  navigator.msGetUserMedia

exports.getUserMedia = getUserMedia = ->
  _getUserMedia.apply navigator, arguments

# ## AudioContext
# Webkit has a special one.
exports.AudioContext = AudioContext = window.AudioContext ? window.webkitAudioContext
context = new AudioContext()

listeners = []
exports.sampleRate = sampleRate = null

# # activateInput
# Start listening to data from the browser.
exports.activateInput = (framesize, cb, err) ->
  # ## audio input

  # Set up the handler for when we've gotten
  # microphone access
  onComplete = (stream) ->
    samplerate = context.sampleRate

    # Make a js audio processor node
    processor = context.createScriptProcessor framesize, 1, 1

    # Workaround for garbage-collection bug;
    # unless we export the processor, it gets
    # garbage collected.
    exports._inputProcessor = processor

    # Pipe the media stream we got from requesting microphone access
    # into the audio processor node
    exports.audioInput = audioInput = context.createMediaStreamSource stream
    audioInput.connect processor

    # Pipe the output of the processor node
    # into a gain of value 0. This will allow
    # sound bits to keep flowing through the node
    # without actually producing any sound on the speaker.
    voider = context.createGain()
    voider.gain.value = 0
    processor.connect voider
    voider.connect context.destination

    # Attach the given callback to the processor.
    processor.onaudioprocess = ->
      for listener in listeners
        listener.apply this, arguments

    # Call the one-time callback with
    # the information we know.
    exports.sampleRate = sampleRate = samplerate
    if cb then cb {
      rate: samplerate
    }

  # Make the getUserMedia request
  getUserMedia {audio: true}, onComplete, err ? (->)

# ## listen and unlisten
# Register/unregister listeners with
# the stream.
exports.listen = (fn) ->
  listeners.push fn
  return

exports.unlisten = (fn) ->
  listeners = listeners.filter (x) -> x isnt fn
  return

# ## play
# Playback
exports.play = (buffer) ->
  source = context.createBufferSource()
  source.buffer = context.createBuffer 2, buffer.length, context.sampleRate
  source.buffer.getChannelData(0).set buffer
  source.connect context.destination
  source.start 0

# ## output
outputters = []
outputListeners = []

exports.activateOutput = (framesize) ->
  oscillator = context.createOscillator()
  voider = context.createGain(); voider.gain.value = 0
  processor = context.createScriptProcessor framesize

  # Workaround for garbage-collection bug;
  # unless we export the processor, it gets
  # garbage collected.
  exports._outputProcessor = processor

  volume = 1
  processor.onaudioprocess = (frame) ->
    outputBuffer = frame.outputBuffer.getChannelData 0

    # Null out the output buffer
    for el, i in outputBuffer
      outputBuffer[i] = 0

    # Call the outputters
    for outputter in outputters
      componentBuffer = outputter()
      for el, i in componentBuffer
        outputBuffer[i] += el
        outputBuffer[i] = Math.min 1, Math.max -1, outputBuffer[i]

    # Call the listeners
    for listener, i in outputListeners
      listener outputBuffer

    return null

  oscillator.connect voider
  voider.connect processor
  processor.connect context.destination

  oscillator.noteOn 0

exports.output = (fn) ->
  outputters.push fn

exports.whenOutput = (fn) ->
  outputListeners.push fn
