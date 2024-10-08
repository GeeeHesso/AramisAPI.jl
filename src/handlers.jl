
const MODULE_FOLDER = pkgdir(@__MODULE__)

const INITIAL_GRID = parse_file(joinpath([MODULE_FOLDER, "data", "initial_grid.json"]))


function initial_network() :: Dict{String, Any}
    return INITIAL_GRID
end


function real_network(params::DateTime) :: Dict{String, Any}
    network = deepcopy(INITIAL_GRID)
    t = get_timestep(params)
    update_injections!(network, t, params.scale_factor)
    powerflow!(network)
    return network
end


function attacked_network(params::DateTimeAttack) :: Dict{String, Any}
    network = deepcopy(INITIAL_GRID)
    t = get_timestep(params)
    update_injections!(network, t, params.scale_factor)
    attack!(network, params.attacked_gens)
    powerflow!(network)
    return network
end


function algorithms(params::DateTimeAttackAlgo) :: Dict{String, Any}
    network = deepcopy(INITIAL_GRID)
    t = get_timestep(params)
    update_injections!(network, t, params.scale_factor)
    attack!(network, params.attacked_gens)
    x = get_features(network)
    return Dict(algo => Dict(gen => run_algorithm(algo, gen, x, t) for gen in ATTACKABLE_GENS)
        for algo in params.algorithms)
end
