type MustacheTokens
    tokens
end


## after parsing off to squash, nest and render the tokens

## Make the intial set of tokens before squashing and nesting
function make_tokens(template, tags)

    
    tags = ["{{", "}}"]         # we hard code tags!
    tagRes = ["\{\{", "\}\}"]   # escaped to be regular expressions


    scanner = Scanner(template)
    
    sections = Array(Any,0)
    tokens = Array(Any,0)
    spaces = Array(Integer,0)
    hasTag = false
    nonSpace = false
    
    function stripSpace(hasTag, nonSpace) 
        if hasTag && !nonSpace
            while length(spaces) > 0
                delete!(tokens, pop!(spaces))
            end
        else
            spaces = Array(Integer, 0)
        end
        
        hasTag = false
        nonSpace = false
    end
    
    while !eos(scanner)
        start = scanner.pos
        
        value = scanUntil!(scanner, tagRes[1])
        
        if !falsy(value) 
            for i in 1:length(value)
                chr = string(value[i])
                
                if isWhitespace(chr)
                    push!(spaces, length(tokens))
                else
                    nonSpace = true
                end
                
                push!(tokens, {"text", chr, start, start + 1})
                start += 1
                
                if chr == "\n"
                    #stripSpace(hasTag, nonSpace)
                end
                
            end
        end
        
        if scan(scanner, tagRes[1]) == ""
            break
        end
        
        hasTag = true
        
        ## find type #,/,^,{, ...
        _type = scan(scanner, tagRe)
        

        if _type == ""
            _type = "name"
        end
        
        if _type == "="
            value = scanUntil!(scanner, eqRe)
            scan(scanner, eqRe)
            scanUntil!(scanner, tagRes[2])
        elseif _type == ""
            ## XXX hard code tags
            value = scanUntil!(scanner, r"\\s*\}\}\}") 
            scan(scanner, curlyRe)
            scanUntil!(scanner, tagRes[2])
            _type = "&"
        else
            value = scanUntil!(scanner, tagRes[2])
        end
        
        if scan(scanner, tagRes[2]) == ""
            error("Unclosed tag at " * string(scanner.pos))
        end
        
        
        token = {_type, value, start, scanner.pos}
        

        push!(tokens, token)
        
        if _type == "#" || _type == "^"
            push!(sections, token)
        elseif _type == "/"
            ## section nestinng
            if length(sections) == 0
                error("Unopened section $value at $start")
            end
            
            openSection = pop!(sections)
            if openSection[2] != value 
                error("Unclosed section" * openSection[2] * " at $start")
            end
            
        elseif _type == "name" || _type == "{" || _type == "&"
            nonSpace = true
        elseif _type == "="
            tags = split(value, spaceRe)
            if length(tags) != 2
                error("Invalid tags at $start:" * join(tags, ", "))
            end
            
        end
    end
        
    if length(sections) > 0
        openSection = pop!(sections)
        error("Unclosed section " * openSection[2] * "at " * scanner.pos)
    end
    
    return(tokens)
end

## take single character tokens and collaps into chunks
function squashTokens(tokens)
    squashedTokens = Array(Any, 0)
    
    lastToken = nothing
    for i in 1:length(tokens)
        token = tokens[i]
        if !falsy(lastToken) && token[1] == "text"  && lastToken[1] == "text"
            lastToken[2] *= token[2]
            lastToken[4] = token[4]
        else
            lastToken = token
            push!(squashedTokens, token)
        end
    end
    
    return(squashedTokens)
end



## Forms the given array of `tokens` into a nested tree structure where
## tokens that represent a section have two additional items: 1) an array of
## all tokens that appear in that section and 2) the index in the original
## template that represents the end of that section.
function nestTokens (tokens)
    tree = Array(Any,0)
    collector = tree
    sections = Array(Any, 0)
    
    for i in 1:length(tokens)
        token = tokens[i]
        ## a {{#name}}...{{/name}} will iterate over name
        ## a {{^name}}...{{/name}} does ... if we have no name
        ## start nesting
        if token[1] == "^" || token[1] == "#" 
            push!(sections, token)
            push!(collector, token)
            push!(token, Array(Any, 0))
            collector = token[5]
        elseif token[1] == "/"
            section = pop!(sections)
            push!(section, token[3])
            collector = length(sections) > 0 ? sections[length(sections)] : tree
        else
            push!(collector, token)
        end
    end

    function print_tree(x, k)
        for i in x
            if length(i) > 4
                println((k, i[1:4]))
                print_tree(i[5], k + 1)
            else
                println((k, i))
            end
        end
    end
    ## print_tree(tree, 1)

    return(tree) ## ?? Tree?
end


## Low-level function that renders the given `tokens` using the given `writer`
## and `context`. The `template` string is only needed for templates that use
## higher-order sections to extract the portion of the original template that
## was contained in that section.

function renderTokens(tokens, writer, context, template)

    buffer = ""
    
    for i in 1:length(tokens)
        token = tokens[i]
        tokenValue = token[2]


        if token[1] == "#"
            ## iterate over value if Dict, Array or DataFrame, 
            ## or display conditionally
            value = lookup(context, tokenValue)

            ##  many things based on value of value
            if isa(value, Dict)
                for (k, v) in value
                    buffer *= renderTokens(token[5], writer, ctx_push(context, v), template)
                end
            elseif isa(value, Array)
                for v in value
                    buffer *= renderTokens(token[5], writer, ctx_push(context, v), template)
                end
            elseif isa(value, DataFrame)
                for i in 1:size(value)[1] ## iterate along row, Call one for each row
                    buffer *= renderTokens(token[5], writer, ctx_push(context, value[i,:]), template)
                end
            elseif !falsy(value)
                buffer *= renderTokens(token[5], writer, context, template)

            end

        elseif token[1] == "^"
            ## display if falsy, unlike #
            value = lookup(context, tokenValue)

            if falsy(value)
                buffer *= renderTokens(token[5], writer, context, template)
            end


        elseif token[1] == ">"
            ## need partials to do this

        elseif token[1] == "&"
            value = lookup(context, tokenValue)
            if value != nothing
                buffer *= value
            end
    

        elseif token[1] == "name"
            value = lookup(context, tokenValue)
            if value != nothing
                buffer *= escape_html(value)
            end

        elseif token[1] == "text"
            buffer *= tokenValue

        end

    end

    return(buffer)
end
