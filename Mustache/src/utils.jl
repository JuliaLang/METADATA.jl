
## regular expressions to use
whiteRe = r"\s*"
spaceRe = r"\s+"
nonSpaceRe = r"\S"
eqRe = r"\s*="
curlyRe = r"\s*\}"
#tagRe = r"#|\^|\/|>|\{|&|=|!"
tagRe = r"^[#^/>{&=!]" 


isWhitespace(x) = ismatch(whiteRe, x)
function stripWhitepace(x) 
    y = replace(x, r"^\s+", "")
    replace(y, r"\s+$", "")
end


## this is for falsy value
## Falsy is true if x is false, 0 length, "", ...
falsy(x::Bool) = !x
falsy(x::Array) = length(x) == 0
falsy(x::ASCIIString) = x == ""
falsy(x::Nothing) = true
falsy(x::Real) = x == 0
falsy(x) = false                #  default

## escape_html with entities

entityMap = {"&" => "&amp;",
             "<" => "&lt;",
             ">" => "&gt;",
             "'" => "&#39;",
             "\"" => "&quot;",
             "/" => "&#x2F;"
             }
             
function escape_html(x)
    y = string(x)
    for (k,v) in entityMap
        y = replace(y, k, v)
    end
    y
end

## Make these work
function escapeRe(string)
    replace(string, r"[\-\[\]{}()*+?.,\\\^$|#\s]", "\\$&");
end

function escapeTags(tags)
   [Regex(escapeRe(tags[1]) * "\\s*"),
    Regex("\\s*" * escapeRe(tags[2]))]
end

