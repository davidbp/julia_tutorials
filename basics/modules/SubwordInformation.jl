module SubwordInformation

export islowercaseword, isuppercaseword

@inline isuppercased(c::Char) = !islowercase(c)

"""
    islowercaseword(word::String)

Returns false if all the characters in a string are lowercase

# Examples

```julia-repl
julia> islowercaseword("castaña")
true

julia> islowercaseword("Castaña")
false
```
"""
function islowercaseword(word::String)
    all_lower = true
    for c in word
        all_lower *= islowercase(c)
    end
    return all_lower
end


"""
    islowercaseword(word::String)

Returns false if all the characters in a string are lowercase

# Examples

```julia-repl
julia> islowercaseword("castaña")
true

julia> islowercaseword("Castaña")
false
```
"""
function isuppercaseword(word::String)
    all_uppercase = true
    for c in word
        all_uppercase *= isuppercased(c)
    end
    return all_uppercase
end

end #module