module AramisAPI

using HTTP
using Oxygen

include("server.jl")

const MODULE_FOLDER = pkgdir(@__MODULE__)

function __init__()
    global initial_grid = read(joinpath([MODULE_FOLDER, "networks", "initial_grid.json"]), String)
end

precompile(start_server, ())

end
