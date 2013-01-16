# Basics of the Mustache specification

Mustache, http://mustache.github.com/, is a specification for logic-less templates. It is implemented in many different languages. This package ports the `mustache.js` code into `julia`.

The mustache specification is fairly simple, and made even simpler here by not implementing partials. 
The most basic use is

```julia
mtrender(tpl, view)
```

Where `tpl` is a template and `view` some specification as to where to look up values specified by the template.

A template can be specified as a string or can be pre-parsed using the non-standard string literal `mt`. The latter may be faster if the same template is being reused, as parsing happens at compile time.

A template has values to be substituted wrapped within mustache pair: `{{ }}`.

For example, the following would substitute for `x`:

```julia
mtrender(mt"x is {{x}}", {"x" => "ex"})
```

The key in `{{x}}` is looked up in the view, in this case the Dict. If found, the value replaces `{{x}}`, otherwise an empty string is used for replacement.

The basic templates have the following simple logic:

## comments

Use a tag like `{{! comment }}` to make an inline comment

## conditional values

The `#` tag is used in different ways. For non iterable-objects it can be used to put in conditional text. 

```julia
tpl = mt"{{#a}}I see {{a}}{{/a}}"
mtrender(tpl, {"b" => "a is not there"})
mtrender(tpl, {"a" => "a is there"})
```

### when a value is not there
The `^` tag is used in the opposite manner to `#`. It will print the text if there is no value for that key.

```julia
tpl = mt"{{^a}}a is not there{{/a}}"
mtrender(tpl, {"b" => "no a"})
mtrender(tpl, {"a" => "a is there"})
```

## iterable objects

For `DataFrame` objects or `Array` objects, the `{{#key}}` tag can be used to iterate. The data frames are iterated over their rows (not columns, as an R user might expect). The array objects should be arrays of something one can use as a view, such as a `Dict`.

For example
```j
a = [{"x" => 1, "y" => "one"},
     {"x" => 2, "y" => "two"}]

tpl = mt"
{{#a}}
The number {{x}} is written as '{{y}}'
{{/a}}
"

mtrender(tpl) ## Main is default
```


For data frames we have something similar:

```julia
using DataFrames
d = DataFrame(quote
  x = 1:4
  y = ["one", "two", "three", "four"]
end)
mtrender(tpl, {"a" => d}) | print
```


## Views

The variable lookup happens within the specified view. The default view is `Main`. One can specify a Dict or a CompositeType as well. For iterable objects, an array can be used.

```julia
type ThrowAway
  x
  y
end

mtrender(mt"x is {{x}} and y is {{y}}", ThrowAway(1,2))
``` 
