###
Muse math utility functions.
Copyright (c) 2014 Anthony Bau.
MIT License.
###

module.exports = {
  log: log = (a, b = Math.E) -> Math.log(a) / Math.log(b)
  ceil: ceil = Math.ceil
  floor: floor = Math.floor
  abs: abs = Math.abs
  pow: (a, b = Math.E) -> Math.pow(b, a)
  rand: rand = (x) ->
    if x instanceof Array
      return x[rand x.length]
    else
      return Math.floor Math.random() * x
  weightedRand: weightedRand = (arr) ->
    barrier = Math.random() * sum(arr); point = 0
    for el, i in arr
      point += el
      if point > barrier
        return i
    return arr.length
  blank: (dict, def = 0) ->
    newdict = {}
    newdict[key] = def for key, val of dict
    return newdict
  argmax: argmax = (dict) ->
    best = null; max = -Infinity
    for key, val of dict
      if val >= max
        best = key; max = val
    return best
  sum: sum = (dict) ->
    t = 0
    t += val for key, val of dict
    return t
  normalize: (dict) ->
    t = sum(dict)
    dict[key] /= t for key, val of dict
    return dict
  clamp: (a, b, c) -> Math.max a, Math.min b, c
  mergeBuffers: (buffers) ->
    t = 0
    for buffer in buffers
      t += buffer.length
    result = new Float32Array t

    offset = 0
    for buffer in buffers
      result.set buffer, offset
      offset += buffer.length

    return result
  copy: (arr) ->
    copy = new Float32Array arr.length
    copy.set arr, 0
    return copy
  LinkedList: class LinkedList
    constructor: (@data, @next) ->
    toArray: ->
      head = @; arr = []
      while head?
        arr.unshift head.data; head = head.next
      return arr
}
