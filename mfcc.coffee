# Convenience notation
ln = Math.log

# Exponentiation
exp = (x) -> Math.pow Math.E, x

mel = (f) -> 1125 * Math.log(1 + f / 700)
invMel = (m) -> 700 * (exp(m/1225) - 1)


linArr = (low, high, n) ->
  step = (high - low) / n; head = low; arr = [head]
  until head >= high
    arr.push head += step

  return arr


getFilterbanks = (n, nfft, samplerate, lower = 300, upper = Math.min(8000, samplerate/2)) ->
  # Generate equally-spaced (on Mel scale) points between lower and upper
  points = linArr mel(lower), mel(upper), n

  # Convert points back to hertz
  points = points.map (x) -> invMel x
  points = points.map (x) -> Math.round (nfft + 1) * x / samplerate

  console.log points

  # Assemble the triangular window for the filterbanks
  bank = []

  prev = lower
  for point, m in points
    next = points[m] ? Math.ceil upper * nfft / samplerate
    bank.push {
      frequency: point
      vector: for k in [0...n]
        if k < prev then 0
        else if k > next then 0
        else if k < point then (k - prev) / (point - prev)
        else (next - k) / (next - point)
    }

  return bank

console.log getFilterbanks 10, 256, 300, 4000

#exports.mfcc = mfcc = (spectrum, samplingRate) ->
