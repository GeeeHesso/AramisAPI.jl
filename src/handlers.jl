
const MODULE_FOLDER = pkgdir(@__MODULE__)
const INITIAL_GRID = parse_file(joinpath([MODULE_FOLDER, "networks", "initial_grid.json"]))
const SLACK_LOADS = ["1543", "2012", "2018", "2025", "2243", "2287", "2407",
    "2474", "2481", "2498", "3551", "3576", "3595", "3671", "837", "839", "841"]


function initial_network() :: Dict{String, Any}
    return INITIAL_GRID
end


function real_network(params::DateTime) :: Dict{String, Any}
    network = parse_file(joinpath([MODULE_FOLDER, "networks", "other_grid.json"]))
    # network = deepcopy(INITIAL_GRID)
    # TODO: update gens and loads
    powerflow!(network)
    return network
end


function attacked_network(params::DateTimeAttack) :: Dict{String, Any}
    network = parse_file(joinpath([MODULE_FOLDER, "networks", "other_grid.json"]))
    # network = deepcopy(INITIAL_GRID)
    # TODO: update gens and loads
    attack!(network, params.attacked_gens)
    powerflow!(network)
    return network
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


function attack!(network::Dict{String, Any}, gen_id::String)
    # identify the attacked generator
    gen = network["gen"][gen_id]
    p_max = gen["pmax"]
    p_before = gen["pg"]
    # change its active power generation
    p_after = p_before < p_max / 2 ? p_max : 0.0
    gen["pg"] = p_after
    # distribute the change onto the slack loads so that the power balance is respected
    p_diff = p_after - p_before / length(SLACK_LOADS)
    for load_id in SLACK_LOADS
        network["load"][load_id]["pd"] += p_diff
    end
    nothing
end

function attack!(network::Dict{String, Any}, gen_ids::Vector{String})
    for gen_id in gen_ids
        attack!(network, gen_id)
    end
    nothing
end


function powerflow!(network::Dict{String, Any})
    pf = compute_dc_pf(network)
    update_data!(network, pf["solution"])
    flows = calc_branch_flow_ac(network)
    update_data!(network, flows)
    nothing
end
