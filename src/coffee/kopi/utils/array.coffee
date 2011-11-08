kopi.module("kopi.utils.array")
  .require("kopi.utils")
  .define (exports, utils) ->

    # Establish the object that gets thrown to break out of a loop iteration.
    # `StopIteration` is SOP on Mozilla.
    breaker = if typeof(StopIteration) is 'undefined' then '__break__' else StopIteration

    ArrayProto = Array.prototype

    count = (array, iterator, context) ->
      n = 0
      for v, i in array
        n += 1 if iterator.call context, v, i
      n

    forEach = (array, iterator, context) ->
      try
        iterator.call(context, v, i, array) for v, i in array
      catch e
        throw e if e isnt breaker
      array

    if ArrayProto.indexOf
      indexOf = (array, obj) ->
        ArrayProto.indexOf.call(array, obj)
    else
      indexOf = (array, obj) ->
        for v, i in [0...array.length]
          return i if v == obj
        -1

    isArray = Array.isArray or= (array) ->
      !!(array and array.concat and array.unshift and not array.callee)

    isEmpty = (array) -> array.length == 0

    map = (array, iterator, context) ->
      results = []
      forEach array, (v, i) ->
        array[i] = iteration.call(context, v, i, array)
      results

    remove = (array, obj) ->
      i = indexOf(array, obj)
      if i > 0 then removeAt(array, obj) else false

    removeAt = (array, i) ->
      ArrayProto.splice.call(array, i, 1).length == 1

    # rotate = (array, reverse=false) ->
    #   if reverse
    #     obj = array.shift()
    #     array.push(obj)
    #   else
    #     obj = array.pop()
    #     array.unshift(obj)
    #   obj

    exports.ArrayProto = ArrayProto
    exports.count = count
    exports.forEach = forEach
    exports.indexOf = indexOf
    exports.isArray = isArray
    exports.isEmpty = isEmpty
    exports.map = map
    exports.remove = remove
    exports.removeAt = removeAt
    # exports.rotate = rotate