isolateValue = awwx.isolateValue

Tinytest.add 'isolate-value', (test) ->

  weather = 'sunny'
  weatherDep = new Deps.Dependency()

  getWeather = ->
    weatherDep.depend()
    return weather

  setWeather = (w) ->
    weather = w;
    weatherDep.changed();
    return

  changes = 0

  isSunny = isolateValue(
    (-> getWeather() is 'sunny'),
    (-> ++changes)
  )

  updates = 0
  comp = Deps.autorun ->
    ++updates
    isSunny()
    return

  # We get one update right away.
  test.equal changes, 1
  test.equal updates, 1

  # Change sunny to rainy.
  setWeather 'rainy'
  Deps.flush()
  test.equal changes, 2
  test.equal updates, 2

  # Changing rainy to snowing doesn't change isSunny.
  setWeather 'snowing'
  Deps.flush()
  test.equal changes, 3
  test.equal updates, 2

  # But changing back to sunny does change isSunny.
  setWeather 'sunny'
  Deps.flush()
  test.equal changes, 4
  test.equal updates, 3

  # Stopping our computation also stops the autorun inside of
  # isolateValue, so we no longer see changes increment.
  comp.stop()
  setWeather 'dark'
  Deps.flush()
  test.equal changes, 4
