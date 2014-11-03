_max = (arr) ->
  top = -Infinity
  top = Math.max(top, el) for el, i in arr
  return top

window.RollingGraph = class RollingGraph
  constructor: (@canvas, @len, @channels = 2) ->
    @ctx = @canvas.getContext '2d'
    @buffers = (new Float64Array(@len) for [0...@channels])
    @indices = (0 for [0...@channels])
    @maximums = (0 for [0...@channels])
    @colors = ['#00F', '#0FF', '#F0F', '#F00', '#FF0', '#0F0']
    @convexHullData = []
    @listening = true

  index: -> _max(@indices)

  convexHull: (data) ->
    if data.length is 0 then return []
    convexHull = new Float64Array(data.length)
    i = 0; j = data.length - 1
    ci = data[0]; cj = data[j]
    until i >= j
      if cj > ci
        until data[i] > ci or i >= j
          convexHull[i] = ci
          i++
      else
        until data[j] > cj or j <= i
          convexHull[j] = cj
          j--

      ci = data[i]
      cj = data[j]

    return convexHull

  feed: (data, channel = 0) ->
    @buffers[channel][@indices[channel] %% @len] = data
    @maximums[channel] = Math.max data, @maximums[channel]
    @indices[channel]++
    @render()

    if data > 0.01 and channel is 0
      @listening = true
      @convexHullData.push data
    else if channel is 0
      if @listening
        for el in @convexHull @convexHullData
          @feed el, 1

        @convexHullData = []

      @feed 0, 1

      @listening = false

  render: ->
    @ctx.clearRect 0, 0, @canvas.width, @canvas.height

    index = @index()
    for buffer, channel in @buffers
      @ctx.strokeStyle = @colors[channel]
      @ctx.beginPath()
      @ctx.moveTo 0, @canvas.height
      for el, i in buffer when i + index < @indices[channel] + @len
        el = buffer[(i + index) %% @len]
        @ctx.lineTo @canvas.width * i / @len, @canvas.height * (1 - el / @maximums[channel])

      @ctx.stroke()
