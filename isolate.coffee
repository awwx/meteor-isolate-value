isolateValue = (fn, _test_changeCallback) ->
  firstTime = true
  lastValue = null
  theComputation = null
  dep = new Deps.Dependency()
  Deps.autorun (c) ->
    if theComputation?.stopped
      c.stop()
      return
    _test_changeCallback?()
    value = fn()
    if firstTime
      lastValue = value
      firstTime = false
    else
      if not EJSON.equals(value, lastValue)
        lastValue = value
        dep.changed()
    return
  ->
    theComputation = Deps.currentComputation
    dep.depend()
    return lastValue


(@awwx or = {}).isolateValue = isolateValue
