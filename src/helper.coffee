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
  blank: (dict, def = 0) ->
    newdict = {}
    newdict[i] = def for key, val of dict
    return newdict
  argmax: argmax = (dict) ->
    best = null; max = -Infinity
    for key, val of dict
      if val > max
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
  LinkedList: class LinkedList
    constructor: (@data, @next) ->
    toArray: ->
      head = @; arr = [@data]
      until head is null
        arr.unshift (head = head.next).data
      return arr
}
