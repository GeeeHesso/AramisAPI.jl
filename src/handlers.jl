
const MODULE_FOLDER = pkgdir(@__MODULE__)
const INITIAL_GRID = parse_file(joinpath([MODULE_FOLDER, "networks", "initial_grid.json"]))
const SLACK_LOADS = ["1543", "2012", "2018", "2025", "2243", "2287", "2407",
    "2474", "2481", "2498", "3551", "3576", "3595", "3671", "837", "839", "841"]


function initial_network() :: Dict{String, Any}
    return INITIAL_GRID
end


function real_network(params::DateTime) :: Dict{String, Any}
    grid = parse_file(joinpath([MODULE_FOLDER, "networks", "other_grid.json"]))
    # TODO: grid = deepcopy(INITIAL_GRID)
    # TODO: update gens, loads, and lines (with or without Power Flow?)
    return grid
end


function attacked_network(params::DateTimeAttack) :: Dict{String, Any}
    grid = parse_file(joinpath([MODULE_FOLDER, "networks", "other_grid.json"]))
    # TODO: grid = deepcopy(INITIAL_GRID)
    # TODO: update gens, loads, and lines (with or without Power Flow?)
    # TODO: create attack on each generator
    # TODO: perform power flow
    return grid
end


function algorithms(params::DateTimeAttackAlgo) :: Dict{String, Any}
    # TODO: implement
    # return mock
    return Dict(
        "MLPR" => Dict(
            "923" => true,
            "918" => false,
            "933" => false,
            "934" => false,
            "173" => false,
            "932" => false,
            "924" => false,
            "931" => false,
            "915" => false,
            "927" => false
        )
    )
end