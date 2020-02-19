

#### Related Material

- Fredrik Ekre juliacon 2019 talk

- Julia user manual

  

  

#### Working in environments

By default, if you do not specify an environment julia will be able to acces the libraries found in
`~/.julia/environments/v1.2` (in the case you are working in julia 1.2).

Inside the folder `~/.julia/environments/v1.2` there are two `.toml` objects that define the environment
in which julia will operate. You can see the files:

```
ls ~/.julia/environments/v1.2
Manifest.toml	Project.toml
```


- A project is a pair `Project.toml` `Manifest.toml` in a folder. This definition is quite open, 
  meaning that anyone can create a julia project.



#### Packages vs Projects

- Is a package a project? Yes
- Are all projects a package? No
- What is a package? A package is a project with 
  ```
   name="PackageName"
   uuid="some_uuid"
  ```
    - The `name` and `uuid` are in `Project.toml` and `src/PackageName.jl` that defines the `PackageName`
      module
      
      

### About .toml files

The following info about .toml files comes from the wikipedia: https://en.wikipedia.org/wiki/TOML

**TOML** is a [configuration file](https://en.wikipedia.org/wiki/Configuration_file) format that is intended to be easy to read and write due to obvious semantics which aim to be "minimal", and is designed to map unambiguously to a [dictionary](https://en.wikipedia.org/wiki/Associative_array). Its specification is open-source, and receives community contributions. TOML is used in a number of software projects.

TOML's syntax primarily consists of `key = "value"` pairs, `[section names]`, and `# comments`. TOML's syntax somewhat resembles that of .[INI files](https://en.wikipedia.org/wiki/INI_file), but it includes a formal specification, whereas the [INI file](https://en.wikipedia.org/wiki/INI_file) format suffers from many competing variants.

Its specification includes a list of supported data types: String, Integer, Float, Boolean, Datetime, Array, and Table.

```
# This is a TOML document.

title = "TOML Example"

[owner]
name = "Tom Preston-Werner"
dob = 1979-05-27T07:32:00-08:00 # First class dates

[database]
server = "192.168.1.1"
ports = [ 8001, 8001, 8002 ]
connection_max = 5000
enabled = true

[servers]

  # Indentation (tabs and/or spaces) is allowed but not required
  [servers.alpha]
  ip = "10.0.0.1"
  dc = "eqdc10"

  [servers.beta]
  ip = "10.0.0.2"
  dc = "eqdc10"

[clients]
data = [ ["gamma", "delta"], [1, 2] ]

# Line breaks are OK when inside arrays
hosts = [
  "alpha",
  "omega"
]
```



## About `Project.toml`

The `Project.toml` decribes the project on a high level. In particular it contains:

- Dependencies (in `[deps]` section).
- Compatibility contrains (in the `[compat]` section).

If the project is a package then  `Project.toml` has to store `name` and `UUID`.

  `Project.toml` is what users interact and modify (usually through Pkg).

#### Example `Project.toml`

```toml
name = "MyPackage"
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b778f"

[deps]
JSON = "accfe93b-1ab2-ssea-b432-e2awdf39b348a"

[compat]
JOSN = "0.16.3"     # notation "^1.16.3 means [1.16.3, 1.17]"
julia = "1.2"       # notation "^1.2 means [1.2.3, 1.3.0]"
```





##### Adding packages and Project.toml

When a user writes `pkg> add Package` then the input of the default project is `Package@*` + current julia version (for example v1.2)



#### About `Manifest.toml`

- `Manifest.toml` Describesthe absulute state of the project. It includes
  - The full dependency graph (direct + indirect dependencies)
  - Exact versions of all packages (direct + indirect dependencies)

- `Manifest.toml` is the output from `Pkg`'s resolver
  - For example: when writting `pkg> add Package`  the output of this function all is the new dependency graph containing specific versions for all packages (e.g `Package@0.5.4`)
  - For a package: `Manifest.toml` is not used in packages.
- `Manifesst.toml` **is generated by julia. editing manually is not recommended**.



## LOAD_PATH

`LOAD_PATH` defines a stack of projects. By default it is

```julia
julia> LOAD_PATH
3-element Array{String,1}:
 "@"          # Explicitly activated project by user
 "@v#.#"      # Default environment, for example: ~/julia/environments/v1.2
 "@stdlib"    # contains julia standard library: Random, Test,...
```

We can expand the `LOAD_PATH` using the function Base.load_path()`

```julia
julia> Base.load_path()
2-element Array{String,1}:
 "/Users/david/.julia/environments/v1.2/Project.toml"                          
 "/Applications/Julia-1.2.app/Contents/Resources/julia/share/julia/stdlib/v1.2"
```

`LOAD_PATH` can be modified:

- **Inside julia**. Example  `push!(LOAD_PATH, "./")` for adding the curent folder.
- **Outside julia**: changing `JULIA_LOAD_PATH` environment variable.



## Activate a project

We can use **`pkg> activate path_project`** to allow julia to find code from our project.

For example, the `LOAD_PATH` for developing package `X` should be:

```julia
julia> Base.load_path()
3-element Array{String,1}:
 "/Users/david/dev/X/Project.toml"                
 "/Users/david/.julia/environments/v1.2/Project.toml"                          
 "/Applications/Julia-1.2.app/Contents/Resources/julia/share/julia/stdlib/v1.2"
```



## Loading code

###### What happens when you type `using X` in your code?

1) Julia looks through project in `LOAD_PATH[1], LOAD_PATH[2],...` in each of this folders it looks for a `.toml` containing:

```
[deps]
X = "X_UUID"
```

2) Once `X_UUID` in `Manifest.toml` is found then gives julia retrieves:

- 2.1) The version of `X` (and where the source code of `X` is stored)
- 2.2) THe UUIDs of the dependecies of `X`

3) The file `path_to_X/src/X.jl` is loaded.



#### Code loading with `using`

What is allowed to be loaded when you use `using`?

- Any package found in a `[deps]` section of a project in `LOAD_PATH`
- From inside a module of a package: Any package found in `[deps]` section of the package `Project.toml`

 

#### Ensuring reproducible environments

In the event you want to force to import modules that are in a project you can do

```shell
export JULIA_LOAD_PATH=path_of_the_project
```

If we open a julia REPL after changing `JULIA_LOAD_PATH` then julia will not have access to the libraries installed in the standard project.

```julia
julia> Base.load_path()
1-element Array{String,1}:
 "/Users/david/Documents/git_stuff/MLJBase.jl/Project.toml"
```

In the event you want to install the packages specified in a  `Project.toml` file you can open a julia session in the folder containing the `Project.toml` and the use **`instanciate`**:

```
(MLJBase) pkg> instantiate
```


