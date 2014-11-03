# Compat
navigator.getUserMedia = navigator.getUserMedia ?
  navigator.webkitGetUserMedia ?
  navigator.mozGetUserMedia ?
  navigator.msGetUserMedia
AudioContext = window.AudioContext ? window.webkitAudioContext

canvas = document.querySelector '#rolling'
canvas2 = document.querySelector '#fft'
ctx = canvas.getContext '2d'
ctx2 = canvas2.getContext '2d'

_dot = (a, b) ->
  p = 0
  for el, i in a
    p += el * b[i]
  return p

_mag = (a) ->
  mag = 0
  for el in a
    mag += el * el
  return Math.sqrt mag

_cosineSimilarity = (a, b) ->
  return _dot(a, b) / (_mag(a) * _mag(b))

_absoluteDifference = (a, b) ->
  sum = 0
  for el, i in a
    sum += (el - b[i]) ** 2
  return sum

_copy = (f32) ->
  n = new Float32Array f32.length
  for k, i in f32
    n[i] = k
  return n

rollingGraph = new RollingGraph canvas, 500, 4

lastSpectrum = null

navigator.getUserMedia audio: true, ((stream) ->
  context = new AudioContext()
  processor = context.createScriptProcessor(1024, 1, 1)

  audioInput = context.createMediaStreamSource stream
  audioInput.connect processor

  # Plug the result of the processor into nowhere
  voider = context.createGain()
  voider.gain.value = 0
  processor.connect voider
  voider.connect context.destination

  fft = new FFT 1024, 44100

  processor.onaudioprocess = (event) ->
    buffer = event.inputBuffer
    fft.forward buffer.getChannelData 0
    power = 0
    for signal in buffer.getChannelData 0#fft.spectrum
      power += signal ** 2

    ctx2.clearRect 0, 0, canvas2.width, canvas2.height
    ctx2.beginPath()
    ctx2.moveTo 0, canvas2.height
    for signal, i in fft.spectrum
      ctx2.lineTo canvas2.width * (i / fft.spectrum.length), canvas2.height - signal * 10000

    ctx2.strokeStyle = '#F00'
    ctx2.stroke()

    if lastSpectrum?
      similarity = _cosineSimilarity fft.spectrum, lastSpectrum
      if similarity is similarity
        rollingGraph.feed similarity + 1, 2
      rollingGraph.feed _absoluteDifference(fft.spectrum, lastSpectrum) / power, 3
    lastSpectrum = _copy fft.spectrum

    rollingGraph.feed power, 0
  ), (->)
