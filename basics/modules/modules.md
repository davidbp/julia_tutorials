

# Modules



The following code corresponds to a module with two functions (both of which are exported at the top) which is stored in **`SubwordInformation.jl`**.

```julia

module SubwordInformation

export islowercaseword, isuppercaseword

@inline isuppercased(c::Char) = !islowercase(c)

"""
    islowercaseword(word::String)

Returns false if all the characters in a string are lowercase

# Examples

​```julia-repl
julia> islowercaseword("castaña")
true

julia> islowercaseword("Castaña")
false
​```
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

​```julia-repl
julia> islowercaseword("castaña")
true

julia> islowercaseword("Castaña")
false
​```
"""
function isuppercaseword(word::String)
    all_uppercase = true
    for c in word
        all_uppercase *= isuppercased(c)
    end
    return all_uppercase
end

end #module
```



#### Using code outside of a Module

There are different ways to "import" a module. Notice  we write "import" because `import` is actually a reserved word with a specific meaning. The snipppets of code below should be executed after running `push!(LOAD_PATH, ".")` , otherwise the Modules would not be found by Julia.

- **`using SubwordInformation`**

  - **Exports the methods and variables** exported in the Module

  - **DOES NOT ALLOW method extension without the dot notation**.

  - ```julia
    julia> using SubwordInformation
    [ Info: Recompiling stale cache file /Users/david/.julia/compiled/v1.2/SubwordInformation.ji for SubwordInformation [top-level]
    
    # Allows exported method in Module to be called directly
    julia> isuppercaseword("hi")
    false
    
    julia> isuppercaseword("HI")
    true
    
    julia> SubwordInformation.isuppercaseword("HI")  
    true
        
    # Does not allow method extension without dot notation
    julia> isuppercaseword(x::AbstractFloat) = false
    ERROR: error in method definition: function SubwordInformation.isuppercaseword must be explicitly imported to be extended
          
     julia> SubwordInformation.isuppercaseword(x::AbstractFloat) = false
    
    ```

    

- **`import SubwordInformation`**

  - **DOES NOT Export methods and variables** (even if `export mymethod` is present in the module) `mymethod` will not be accessible outside the module unless it is accessed using the dot notation.

  - **ALLOWS method extension without the dot notation**.

  - ```julia
    julia> import SubwordInformation
    
    # DOES NOT Allow exported method in Module to be called directly
    julia> isuppercaseword("hi")
    ERROR: UndefVarError: isuppercaseword not defined
    Stacktrace:
     [1] top-level scope at REPL[3]:1
    
    julia> SubwordInformation.isuppercaseword("HI")
    true
    
    # Allows exported methods to be extended without dot notation
    julia> isuppercaseword(x::AbstractFloat) = false
    isuppercaseword (generic function with 1 method)
    
    ```

    

- **`include SubwordInformation`**:

  - **DOES NOT Export methods and variables** (even if `export mymethod` is present in the module) `mymethod` will not be accessible outside the module unless it is accessed using the dot notation.

    ```julia
    julia> include("SubwordInformation.jl")
    
    julia> isuppercaseword("hi")
    ERROR: UndefVarError: isuppercaseword not defined
    Stacktrace:
     [1] top-level scope at REPL[12]:1
    
    julia> SubwordInformation.isuppercaseword("hi")
    false
    
    # Allows exported methods to be extended without dot notation
    julia> isuppercaseword(x::AbstractFloat) = false
    isuppercaseword (generic function with 1 method)
    ```

    

