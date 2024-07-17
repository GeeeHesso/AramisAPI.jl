
function test_valid_network(network)
    @test isa(network, Dict{String, Any})
    for feature in ["name", "branch", "bus", "gen", "load"]
        @test feature in keys(network)
    end
    @test isa(network["name"], String)
    @test isa(network["branch"], Dict{String, Any})
    @test isa(network["bus"], Dict{String, Any})
    @test isa(network["gen"], Dict{String, Any})
    @test isa(network["load"], Dict{String, Any})
end


function test_identical_network_structure(net1, net2)
    @test issetequal(keys(net1["bus"]), keys(net2["bus"]))
    @test issetequal(keys(net1["branch"]), keys(net2["branch"]))
    @test issetequal(keys(net1["gen"]), keys(net2["gen"]))
    @test issetequal(keys(net1["load"]), keys(net2["load"]))
end


function equal_gens(net1, net2; exclude::Vector{String} = String[])
    gens = setdiff(keys(net1["gen"]), exclude)
    all(net1["gen"][id]["pg"] == net2["gen"][id]["pg"] for id in gens)
end


function equal_loads(net1, net2; exclude::Vector{String} = String[])
    loads = setdiff(keys(net1["load"]), exclude)
    all(net1["load"][id]["pd"] == net2["load"][id]["pd"] for id in loads)
end


function equal_flows(net1, net2)
    all(net1["branch"][id]["pt"] == net2["branch"][id]["pt"] for id in keys(net1["branch"]))
end


function test_power_balance(network)
    production = sum(gen["pg"] for gen in values(network["gen"]))
    consumption = sum(load["pd"] for load in values(network["load"]))
    @test abs(production / consumption - 1.0) < 1e-6
end


@testset "Powerflow: data" begin
    test_power_balance(AramisAPI.INITIAL_GRID)
    @test issetequal(keys(AramisAPI.INITIAL_GRID["gen"]), AramisAPI.GEN_IDS)
    @test issetequal(keys(AramisAPI.INITIAL_GRID["load"]), AramisAPI.LOAD_IDS)
    n_gens = length(AramisAPI.INITIAL_GRID["gen"])
    n_loads = length(AramisAPI.INITIAL_GRID["load"])
    n_timesteps = (length(AramisAPI.SEASONS)
        * length(AramisAPI.DAYS) * length(AramisAPI.HOURS))
    @test size(AramisAPI.GENS) == (n_gens, n_timesteps)
    @test size(AramisAPI.LOADS) == (n_loads, n_timesteps)
end


@testset "Powerflow: get timestep" begin
    # first timestep of the year
    datetimes = [
        AramisAPI.DateTime("winter", "weekday", "22-2h"),
        AramisAPI.DateTimeAttack("winter", "weekday", "22-2h", ["918"]),
        AramisAPI.DateTimeAttackAlgo("winter", "weekday", "22-2h", ["918"], ["MLPR"])
    ]
    for datetime in datetimes
        @test AramisAPI.get_timestep(datetime) == 1
    end
    # last timestep of the year
    datetimes = [
        AramisAPI.DateTime("fall", "weekend", "18-22h"),
        AramisAPI.DateTimeAttack("fall", "weekend", "18-22h", ["918"]),
        AramisAPI.DateTimeAttackAlgo("fall", "weekend", "18-22h", ["918"], ["MLPR"]),
    ]
    T = size(AramisAPI.LOADS, 2)
    for datetime in datetimes
        @test AramisAPI.get_timestep(datetime) == T
    end
end


@testset "Powerflow: update_injections" begin
    # first day of the year
    net1 = deepcopy(AramisAPI.INITIAL_GRID)
    AramisAPI.update_injections!(net1, 1)
    test_valid_network(net1)
    # second day of the year
    net2 = deepcopy(AramisAPI.INITIAL_GRID)
    AramisAPI.update_injections!(net2, 2)
    test_valid_network(net2)
    # check that they are distinct
    test_identical_network_structure(net1, net2)
    @test equal_gens(net1, net2) == false
    @test equal_loads(net1, net2) == false
end