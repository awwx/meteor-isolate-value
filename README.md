# isolate-value

Meteor keeps track of reactive dependencies, and automatically reruns
computations when their dependencies change.  Templates are built on
top of the reactive system, and so automatically rerender when a
dependency changes, and so automatically display new information.

However computations are rerun (and templates rerendered) when *any*
of their dependencies change, even if the change turns out not to make
a difference to the computation or to the template.  This can lead to
inefficiencies, such as templates being rerendered excessively when they
don't need to be.

Examples include:

* Parts of a document (a template only uses `doc.name`, but rerenders
  if any field in doc changes).

* Summaries (a template only shows a count or a total, but rerenders
  if anything in the collection changes, even if the change doesn't
  affect the summary).

* Conditions (a template only cares if `Session.get('list')` contains
  `foo` or not, but rerenders whenever the list changes).

The `isolateValue` function provides an easy way for a template or any
reactive computation to only depend on the end result of a
computation, and so will only rerender or rerun if that result
changes.

Note that isolate-value is a *performance optimization*.  If instead
you want to *prevent* templates from re-rendering when you don’t want
them to (such as when you want to preserve element state or you’ve
added your own elements that you don’t want Meteor to remove), using
isolate-value for this purpose will likely lead to a fragile design
&mdash; one where you may find yourself needing to look for more
places to prevent your templates from re-rendering.
To keep elements from changing even if reactive data changes,
[constant](http://docs.meteor.com/#constant) and
[preserve](http://docs.meteor.com/#template_preserve) are usually
better choices.


## Version

2.0.2


## API

```
isolateValue(fn)
```

Calls `fn` and returns the value that `fn` returns.

`fn` is called in a new
[computation](http://docs.meteor.com/#deps_computation).  When the
inner computation is invalidated (by something `fn` depends on), `fn`
is called again, and `isolateValue` checks if the value returned by
`fn` has changed (via
[`EJSON.equals`](http://docs.meteor.com/#ejson_equals)).

The outer computation (the one of the caller to `isolateValue`) is
only invalidated when the value is different.

The value returned by the function needs to be an [EJSON-compatible
value](http://docs.meteor.com/#ejson).


## Exports

When used with the Meteor linker, the package exports `isolateValue`.

When used with Meteor 0.6.4.1 and below, `isolateValue` is exported into
the global namespace.


## Examples

### Presence in a list

```
  Template.hello.isFoo = function () {
    return _.contains(Session.get('list'), 'foo');
  };
```

The template helper `isFoo` returns `true` if the session variable
`list` contains "foo" (`['abc', 'foo', 'def']`) and returns `false` if
it doesn't (`['abc', 'def']`).

But the templates using `isFoo` will rerender whenever the session
variable `list` changes, even if the change doesn't affect whether
"foo" is in the list or not (for example, if the list changes from
`['abc', 'foo', 'def']` to `['abc', 'foo']`).

Adding `isolateValue` causes the template to rerender only when "foo"
is added or removed from the list:

```
  Template.hello.isFoo = function () {
    return isolateValue(function () {
      return _.contains(Session.get('list'), 'foo');
    });
  };
```

### Using a template data value

Here the template is rendered with a document or other object that has
a `name` field.  This helper checks if the name is on the list:

```
  Template.hello.isOnList = function () {
    return _.contains(Session.get('list'), this.name);
  };
```

To convert to using `isolateValue`, we need to capture either `this`:

```
  Template.hello.isOnList = function () {
    var self = this;
    return isolateValue(function () {
      return _.contains(Session.get('list'), self.name);
    });
  };
```

or the name itself, whichever is more convenient:

```
  Template.hello.isOnList = function () {
    var name = this.name;
    return isolateValue(function () {
      return _.contains(Session.get('list'), name);
    });
  };
```


### Equals

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


For example, this inefficient version of `isSunny` triggers an invalidation
when the weather changes from "cloudy" to "rainy", even though `isSunny`
returns `false` for both... and so a computation using `isSunny` would
be rerun needlessly:

```
// inefficient
var isSunny = function () {
  return Session.get("weather") === "sunny";
};
```


Using `Session.equals` fixes the inefficiency:

```
// efficient
var isSunny = function () {
  return Session.equals("weather", "sunny");
};

```


If `Session.equals` didn't exist, we could do the same thing with:

```
// also efficient
var isSunny = function () {
  return isolateValue(function () {
    return Session.get("weather") === "sunny";
  });
};
```


`isolateValue` is more general because it can be used with any EJSON-compatible
value, not just for an equality test returning `true` or `false`.

For example, suppose `getWeather()` returned an object with fields like
`temperature`, `outlook`, and `windSpeed`..., but you were only using
the `outlook` field.  You could isolate the outlook value with:

```
var getOutlook = function () {
  return isolateValue(function () {
    return getWeather().outlook;
  });
};
```

Calling `getOutlook()` won't trigger an invalidation if the temperature or
wind speed changes as long as the outlook stays the same.


## Donate

An easy and effective way to support the continued maintenance of this
package and the development of new and useful packages is to [donate
through Gittip](https://www.gittip.com/awwx/).

Gittip is a [platform for sustainable
crowd-funding](https://www.gittip.com/about/faq.html).

Help build an ecosystem of well maintained, quality Meteor packages by
joining the
[Gittip Meteor Community](https://www.gittip.com/for/meteor/).


## Hire

Need support, debugging, or development for your project?  You can
[hire me](http://awwx.ws/hire-me) to help out.
