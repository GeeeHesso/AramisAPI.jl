
const GEN_IDS = string.(CSV.read(joinpath([MODULE_FOLDER, "data", "gen_ids.csv"]),
    CSV.Tables.matrix, header=false)[:, 1])
const LOAD_IDS = string.(CSV.read(joinpath([MODULE_FOLDER, "data", "load_ids.csv"]),
    CSV.Tables.matrix, header=false)[:, 1])
const SLACK_LOADS = ["2653", "2655", "2657", "4295", "4788", "4794", "4801", "5024",
    "5069", "5191", "5259", "5266", "5284", "7253", "7325", "7355", "7460"]

const GENS = DataDrop.retrieve_matrix(joinpath([MODULE_FOLDER, "data", "gens.h5"]))
const LOADS = DataDrop.retrieve_matrix(joinpath([MODULE_FOLDER, "data", "loads.h5"]))


function get_timestep(datetime::Union{DateTime, DateTimeAttack, DateTimeAttackAlgo})
    12 * SEASONS[datetime.season] + 6 * DAYS[datetime.day] + (datetime.hour % 24) ÷ HOUR_STEP  + 1
end


function update_injections!(network::Dict{String, Any}, t::Int, scale_factor::Real)
    for (i, load_id) ∈ enumerate(LOAD_IDS)
        network["load"][load_id]["pd"] = LOADS[i, t] * scale_factor / 100.0
    end
    for (i, gen_id) ∈ enumerate(GEN_IDS)
        network["gen"][gen_id]["pg"] = GENS[i, t] * scale_factor / 100.0
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