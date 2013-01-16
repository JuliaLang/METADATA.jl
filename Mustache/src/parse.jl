## Main function to parse a template This works in several steps: each
## character parsed into a token, the tokens are squashed, then
## nested, then rendered.
function parse(template, tags)

    tokens = make_tokens(template, tags)
    tokens = squashTokens(tokens)
    out = nestTokens(tokens)
    
    ##out
    MustacheTokens(out)
end

## use default tags
parse(template) = parse(template, ["{{", "}}"])