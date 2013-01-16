Try to make mustache.js for `julia`


The mustache folks say:

    Mustache is a logic-less template syntax. It can be used for HTML,
    config files, source code - anything. It works by expanding tags in a
    template using values provided in a hash or object.


This code is a fairly faithful translation of code of
https://github.com/janl/mustache.js/blob/master/mustache.js

All credit should go there. All bugs are my own.

Some basic examples with `julia`:

```julia
using Mustache; 

tpl = mt"the position is {{x}} and tail is  {{y}}"

## a dict
out = mtrender(tpl, {"x"=>1, "y"=>2})
println(out)
```

Yields

```julia
the position is 1 and tail is  2
```

We export `mtrender`, as `render` seemed a bit too generic, Though
`render` seems traditional with Mustache.

The non-standard string literal `mt`, used above to make the `tpl`
object, is optional. If used, then the parsing is done at compile time
and should be faster when used in a loop, say. (Thanks Patrick!)

Similarly, we can use a module as a view such as `Main`:

```julia
x = 1; y = "two"
mtrender(tpl, Main)
```

gives

```julia
"the position is 1 and tail is  two"
```

One can use Composite Kinds. This may make writing `show` methods easier:

```julia
using Distributions
tpl = "Beta distribution with alpha={{alpha}}, beta={{beta}}"
mtrender(tpl, Beta(1, 2))
```

gives

```julia
"Beta distribution with alpha=1.0, beta=2.0"
```

One can iterate over data frames. Here is a template for making a web page:

```julia
tpl = "
<html>
<head>
<title>{{Title}}</title>
</head>
<body>
<table>
<tr><th>name</th><th>summary</th></tr>
{{#d}}
<tr><td>{{names}}</td><td>{{summs}}</td></tr>
{{/d}}
</body>
</html>
"
```
This can be used to generate a web page for `whos`-like values:

```julia
_names = Array(String, 0)
_summaries = Array(String, 0)
m = Main
for s in sort(map(string, names(m)))
    v = symbol(s)
    if isdefined(m,v)
        push!(_names, s)
        push!(_summaries, summary(eval(m,v)))
    end
end

using DataFrames
d = DataFrame({"names" => _names, "summs" => _summaries})

out = mtrender(tpl, {"Title" => "A quick table", "d" => d})
print(out)
```


This can be compared to using an array of `Dict`s, convenient if you have data by the row:

```julia
A = [{"a" => "eh", "b" => "bee"},
     {"a" => "ah", "b" => "buh"}]
tpl = mt"{{#A}} pronounce a as {{a}} and b as {{b}}.{{/A}}"
mtrender(tpl, {"A" => A}) | print
```

yielding

```julia
pronounce a as eh and b as bee. pronounce a as ah and b as buh.
```



This project deviates from that of http://mustache.github.com in a few significant ways:

* I've punted on implementing partials (the `>` tag). I've never been that fancy.
* I hard code the tags, so one uses `{{` and `}}` to demark objects.
* Julian structures are used, not JavaScript objects. As illustrated,
  one can use Dicts, Modules, DataFrames





