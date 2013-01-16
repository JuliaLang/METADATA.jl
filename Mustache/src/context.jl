## context


## A context stores objects where named values are looked up.
type Context
    view ## of what? a Dict, Module, CompositeKind, DataFrame
    parent ## a context or nothing
    _cache::Dict
end
Context(view) = Context(view, nothing, Dict())
Context(view, parent) = Context(view, parent, Dict())

## used by renderTokens
function ctx_push(ctx::Context, view)
    Context(view, ctx) ## add context as a parent
end

## Lookup value by key in the context
function lookup(ctx::Context, key)
    if has(ctx._cache, key)
        value = ctx._cache[key]
    else
        context = ctx
        value = nothing
        while value == nothing && context != nothing
            ## does name have a .?
            if ismatch(r"\.", key)
                ## do something with "."
                error("Not implemented. Can use Composite Kinds in the view.")
            else
                ## strip leading, trailing whitespace in key
                value = lookup_in_view(context.view, stripWhitepace(key))
            end

            context = context.parent
        
        end

        ## cache
        ctx._cache[key] = value
    end

    if is(value, Function)
        value = value()
    end

    return(value)
end

## Lookup value in an object by key
## This of course varies based on the view.
function lookup_in_view(view::Dict, key)

    ## is it a symbol?
    if ismatch(r"^:", key)
        key = symbol(key[2:end])
    end

    if has(view, key)
        view[key]
    else
        nothing
    end
end

function lookup_in_view(view::DataFrame, key)
    if has(view, key)
        view[1, key] ## first element only
    else
        nothing
    end
end

function lookup_in_view(view::Module, key)
    hasmatch = false
    re = Regex("^$key" * E"$") ## watch the $
    for i in names(view)
        if ismatch(re, string(i))
            hasmatch = true
            break
        end
    end

    if hasmatch
        getfield(view, symbol(key))  ## view.key
    else
        nothing
    end
    

end

## Default is likely not great, but we use CompositeKind
function lookup_in_view(view, key)

    nms = names(view)
    re = Regex(key)
    has_match = false
    for i in nms
        if ismatch(Regex(key), string(i))
            has_match=true
            break
        end
    end

    if has_match
        getfield(view, symbol(key))  ## view.key
    else
        nothing
    end
end
    