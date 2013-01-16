## writer

type Writer
    _cache::Dict
    _partialCache::Dict
    _loadPartial ## Function or nothing
end

Writer() = Writer(Dict(), Dict(), nothing)

function clearCache(w::Writer)
    w._cache=Dict()
    w._partialCache=Dict()
end

function compile(w::Writer, template, tags)
    if has(w._cache, template)
        return(w._cache[template])
    end

##    tokens = parse(template, tags)
    tokens = template
    w._cache[template] = compileTokens(w, tokens.tokens, template)

    return(w._cache[template])
end

function compilePartial(w::Writer, name, template, tags)
    fn = compile(w, template, tags)
    w._partialCache[name] = fn
    fn
end

function getPartial(w::Writer, name)
## didn't do loadPartial, as not sure where template is
#    if !has(w._partialCache, name) && is(w._loadPartial, Function)
#        compilePartial(w, 

    w._partialCache[name]
end

function compileTokens(w::Writer, tokens, template)
    ## return a function
    function f(w::Writer, view) #  no partials
       renderTokens(tokens, w, Context(view), template)
    end
    return(f)
end

function render(w::Writer, template, view)
    f = compile(w, template, ["{{", "}}"])
    f(w, view)
end

