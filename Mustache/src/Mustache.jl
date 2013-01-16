module Mustache

using DataFrames

include("utils.jl")
include("tokens.jl")
include("scanner.jl")
include("context.jl")
include("writer.jl")
include("parse.jl")

export @mt_str, mtrender

## Macro to comile simple parsing outside of loops
## use as mt"{{a}} and {{b}}", say
macro mt_str(s)
    parse(s)
end


## Main function for use with compiled strings
## @param tokens  Created using mt_str macro, as in mt"abc do re me"
function mtrender(tokens::MustacheTokens, view)
    _writer = Writer()
    render(_writer, tokens, view)
end

## Exported call without first parsing tokens via mt"literal"
##
## @param template a string containing the template for expansion
## @param view a Dict, Module, CompositeType, DataFrame holding variables for expansion
function mtrender(template::ASCIIString, view)
    _writer = Writer()
    render(_writer, parse(template), view)
end

## Use Main as the default
mtrender(template::ASCIIString) = mtrender(template, Main)
mtrender(tokens::MustacheTokens) = mtrender(tokens, Main)


end