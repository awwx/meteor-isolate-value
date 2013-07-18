### @export isolateValue ###

isolateValue = (fn) ->
  firstTime = true
  lastValue = null
  outerComputation = Deps.currentComputation
  dep = new Deps.Dependency()
  Deps.autorun (c) ->
    if outerComputation?.stopped
      c.stop()
      return
    value = fn()
    if firstTime
      lastValue = value
      firstTime = false
    else
      if not EJSON.equals(value, lastValue)
        dep.changed()
    return
  dep.depend()
  return lastValue

unless Package?
  @isolateValue = isolateValue
