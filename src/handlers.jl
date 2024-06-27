
const MODULE_FOLDER = pkgdir(@__MODULE__)

const INITIAL_GRID = parse_file(joinpath([MODULE_FOLDER, "data", "initial_grid.json"]))
const GEN_IDS = string.(sort(parse.(Int, keys(INITIAL_GRID["gen"]))))
const LOAD_IDS = string.(sort(parse.(Int, keys(INITIAL_GRID["load"]))))
const SLACK_LOADS = ["2653", "2655", "2657", "4295", "4788", "4794", "4801", "5024",
    "5069", "5191", "5259", "5266", "5284", "7253", "7325", "7355", "7460"]

const GENS = DataDrop.retrieve_matrix(joinpath([MODULE_FOLDER, "data", "gens.h5"]))
const LOADS = DataDrop.retrieve_matrix(joinpath([MODULE_FOLDER, "data", "loads.h5"]))


function initial_network() :: Dict{String, Any}
    return INITIAL_GRID
end


function real_network(params::DateTime) :: Dict{String, Any}
    network = deepcopy(INITIAL_GRID)
    update_injections!(network, params)
    powerflow!(network)
    return network
end


function attacked_network(params::DateTimeAttack) :: Dict{String, Any}
    network = deepcopy(INITIAL_GRID)
    update_injections!(network, params)
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
        ),
        "NBC" => Dict(
            "923" => false,
            "918" => false,
            "933" => false,
            "934" => false,
            "173" => true,
            "932" => false,
            "924" => false,
            "931" => false,
            "915" => false,
            "927" => false
        )
    )
end


function update_injections!(network::Dict{String, Any},
        datetime::Union{DateTime, DateTimeAttack, DateTimeAttackAlgo})
    t = (
        12 * SEASONS[datetime.season]
        + 6 * DAYS[datetime.day]
        + HOURS[datetime.hour] + 1
        )
    for (i, load_id) ∈ enumerate(LOAD_IDS)
        network["load"][load_id]["pd"] = LOADS[i, t]
    end
    for (i, gen_id) ∈ enumerate(GEN_IDS)
        network["gen"][gen_id]["pg"] = GENS[i, t]
    end
    nothing
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
    p_diff = (p_after - p_before) / length(SLACK_LOADS)
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
    flows = calc_branch_flow_dc(network)
    update_data!(network, flows)
    nothing
end
