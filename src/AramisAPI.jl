module AramisAPI

using HTTP
using Oxygen
using YAML

const MODULE_FOLDER = pkgdir(@__MODULE__)

include("dto.jl")
include("validators.jl")
include("server.jl")

precompile(start_server, ())

end
