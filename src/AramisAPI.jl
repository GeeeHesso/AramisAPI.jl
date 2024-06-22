module AramisAPI

using HTTP
using Oxygen
using JSON3
using YAML
using PowerModels

const MODULE_FOLDER = pkgdir(@__MODULE__)
const INITIAL_GRID = parse_file(joinpath([MODULE_FOLDER, "networks", "initial_grid.json"]))

include("dto.jl")
include("validators.jl")
include("mocks.jl")
include("server.jl")

precompile(start_server, ())

end
