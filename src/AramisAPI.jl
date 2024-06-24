module AramisAPI

using HTTP
using Oxygen
using JSON3
using YAML
using PowerModels

include("dto.jl")
include("validators.jl")
include("handlers.jl")
include("server.jl")

precompile(start_server, ())

end
