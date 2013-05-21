# isolate-value

```
isolateValue(fn)
```

Returns a function which calls `fn` and returns the same value as `fn`
does, but in a reactive context only invalidates the current
computation when the value returned by the function *changes*.

The value returned by the function needs to be an [EJSON-compatible
value](http://docs.meteor.com/#ejson).


## Example

The Meteor documentation says this about
[`Session.equals`](http://docs.meteor.com/#session_equals):

> If value is a scalar, then these two expressions do the same thing:
>
> `(1) Session.get("key") === value`
>
> `(2) Session.equals("key", value)`
>
> ... but the second one is always better. It triggers fewer
> invalidations (template redraws), making your program more
> efficient.


For example, this version of `isSunny` triggers an invalidation when
the weather changes from "cloudy" to "rainy", even though `isSunny`
returns `false` for both:

```
var isSunny = function () {
  return Session.get("weather") === "sunny";
};
```


Using `Session.equals` fixes that:

```
var isSunny = function () {
  return Session.equals("weather", "sunny");
};

```


If `Session.equals` didn't exist, we could do the same thing with:

```
var isSunny = isolateValue(function () {
  return Session.get("weather") === "sunny";
});
```


`isolateValue` can also be used for more general reactive isolation.
Suppose `getWeather()` returned an object with fields like
`temperature`, `outlook`, `windSpeed`..., but you were only using the
`outlook` field.  You could use:

```
var getOutlook = isolateValue(function () {
  return getWeather().outlook;
});
```

Now `getOutlook()` won't trigger an invalidation if the temperature or
wind speed changes but the outlook stays the same.


## Exports

`isolateValue` is exported into the global namespace as
`awwx.isolateValue`.  From your own code you can use
`awwx.isolateValue` directly:

```
var getFoo = awwx.isolateValue(function () { ... });
```

or if you prefer you can "import" the function simply by assinging it
to a variable:

```
var isolateValue = awwx.isolateValue;

...

var getFoo = isolateValue(function () { ... });
```
