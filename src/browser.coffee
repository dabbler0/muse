# ## includes
Chart = require '../vendor/chart.js'
dsp = require '../vendor/dsp.js'

capture = require './capture.coffee'
classify = require './classify.coffee'
hmm = require './hmm.coffee'
{SemitoneFilterbank} = require './semitones.coffee'

_toArray = (dict) ->
  arr = []
  for key, val of dict
    arr[key] = val
  return arr

_sum = (dict) ->
  t = 0
  t += val for key, val of dict
  return t

_normalize = (dict) ->
  t = _sum dict
  dict[key] /= t for key, val of dict
  return dict

# Initialize the chart
canvas = document.querySelector 'canvas'
ctx = canvas.getContext '2d'
chart = new Chart(ctx).Bar({
  labels: ['A', 'Bb', 'B', 'C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab']
  datasets: [
    {
      label: "Semitone filterbank"
      fillColor: "rgba(220,220,220,0.5)",
      strokeColor: "rgba(220,220,220,0.8)",
      highlightFill: "rgba(220,220,220,0.75)",
      highlightStroke: "rgba(220,220,220,1)",
      data: (0 for [1..12])
    }
    {
      label: "Cumulative sum"
      fillColor: "rgba(100,220,220,0.5)",
      strokeColor: "rgba(100,220,220,0.8)",
      highlightFill: "rgba(100,220,220,0.75)",
      highlightStroke: "rgba(100,220,220,1)",
      data: (0 for [1..12])
    }
  ]
}, {
  animation: false
  scaleOverride: true
  scaleStartValue: 0
  scaleStepWidth: 0.1
  scaleSteps: 10
})

# ## constants
FRAME_SIZE = 2048

frameRate =
  fft =
  filterbank = null

cumulativeSum = (0 for [1..12])
totalSum = 0

# ## callback
# Record the frame rate for processFrame
callback = (info) ->
  frameRate = info.rate
  fft = new dsp.FFT FRAME_SIZE, frameRate
  filterbank = new SemitoneFilterbank FRAME_SIZE, frameRate

# ## processFrame
processFrame = (frame) ->
  fft.forward frame.inputBuffer.getChannelData 0
  spectrum = fft.spectrum
  powers = filterbank.apply fft.spectrum
  powerSum = _sum powers

  for bar, i in chart.datasets[0].bars
    chart.datasets[0].bars[i].value = powers[i] / powerSum
    cumulativeSum[i] += powers[i]
    totalSum += powers[i]

  for bar, i in chart.datasets[1].bars
    chart.datasets[1].bars[i].value = cumulativeSum[i] / totalSum

  chart.update()

capture.capture FRAME_SIZE, processFrame, callback
