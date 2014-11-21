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

# # capture
# Utility function for capturing audio from the browser.
exports.capture = (framesize, fn, cb, err) ->
  # Set up the handler for when we've gotten
  # microphone access
  onComplete = (stream) ->
    context = new AudioContext()
    samplerate = context.sampleRate

    # Make a js audio processor node
    processor = context.createScriptProcessor framesize, 1, 1

    # Pipe the media stream we got from requesting microphone access
    # into the audio processor node
    audioInput = context.createMediaStreamSource stream
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
    processor.onaudioprocess = fn

    # Call the one-time callback with
    # the information we know.
    if cb then cb {
      rate: samplerate
    }

  # Make the getUserMedia request
  getUserMedia {audio: true}, onComplete, err ? (->)
