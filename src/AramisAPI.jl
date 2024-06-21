module AramisAPI

using HTTP
using Oxygen
using YAML

const MODULE_FOLDER = pkgdir(@__MODULE__)
const INITIAL_GRID = read(joinpath([MODULE_FOLDER, "networks", "initial_grid.json"]), String)
const SWAGGER_SCHEMA = YAML.load_file(joinpath([MODULE_FOLDER, "src", "swagger", "swagger.yml"]))


include("server.jl")

precompile(start_server, ())

end
