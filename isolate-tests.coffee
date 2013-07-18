Tinytest.add 'isolate-value', (test) ->

  weather = 'sunny'
  weatherDep = new Deps.Dependency()

  # track how many times getWeather is called

  getCount = 0

  getWeather = ->
    ++getCount
    weatherDep.depend()
    return weather

  setWeather = (w) ->
    weather = w;
    weatherDep.changed();
    return

  isSunny = ->
    isolateValue(-> getWeather() is 'sunny')

  updates = 0
  sunnyStatus = null
  comp = Deps.autorun ->
    ++updates
    sunnyStatus = isSunny()
    return

  # We get one update right away.
  test.isTrue sunnyStatus
  test.equal getCount, 1
  test.equal updates, 1

  # Change sunny to rainy.
  setWeather 'rainy'
  Deps.flush()
  test.isFalse sunnyStatus
  # getWeather gets called twice, the first time invalidates the computation
  # and the second time when the computation is rerun: so incr by 2
  test.equal getCount, 3  # +2
  # and we have an update because the sunny status has changed
  test.equal updates, 2   # +1

  # # Changing rainy to snowing doesn't change isSunny.
  setWeather 'snowing'
  Deps.flush()
  test.isFalse sunnyStatus
  test.equal getCount, 4  # +1
  test.equal updates, 2   # +0

  # # But changing back to sunny does change isSunny.
  setWeather 'sunny'
  Deps.flush()
  test.isTrue sunnyStatus
  test.equal getCount, 6  # +2
  test.equal updates, 3   # +1

  # Stopping our computation also stops the autorun inside of
  # isolateValue, so no more calls are made to getWeather.
  comp.stop()
  setWeather 'dark'
  Deps.flush()
  test.equal getCount, 6  # +0
