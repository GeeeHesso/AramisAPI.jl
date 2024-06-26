using AramisAPI
using Test


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


@testset "AramisAPI.jl" begin

    @testset "Validator: DateTime" begin
        # test all valid parameters
        for season in ["spring", "summer", "fall", "winter"]
            for day in ["weekday", "weekend"]
                for time in ["22-2h", "2-6h", "6-10h", "10-14h", "14-18h", "18-22h"]
                    @test AramisAPI.validate(AramisAPI.DateTime(season, day, time))
                    nothing
                end
            end
        end
        # check failure with erroneous parameters
        for param in [
                ["not-a-season", "weekday", "14-18h"],
                ["winter", "not-a-weekday", "14-18h"],
                ["winter", "weekday", "not-a-time"]
            ]
            param = AramisAPI.DateTime(param[1], param[2], param[3])
            @test AramisAPI.validate(param) == false
        end
    end

    @testset "Validator: DateTimeAttack" begin
        # test valid parameters
        param = AramisAPI.DateTimeAttack("spring", "weekend", "22-2h", ["918", "932"])
        @test AramisAPI.validate(param)
        # test success with empty list of generators
        param = AramisAPI.DateTimeAttack("spring", "weekend", "22-2h", [])
        @test AramisAPI.validate(param)
        # check failure with invalid generator
        param = AramisAPI.DateTimeAttack("spring", "weekend", "22-2h", ["918", "111", "932"])
        @test AramisAPI.validate(param) == false
        # check failure with invalid date-time
        param = AramisAPI.DateTimeAttack("x", "weekend", "22-2h", ["918", "932"])
        @test AramisAPI.validate(param) == false
        param = AramisAPI.DateTimeAttack("spring", "x", "22-2h", ["918", "932"])
        @test AramisAPI.validate(param) == false
        param = AramisAPI.DateTimeAttack("spring", "weekend", "x", ["918", "932"])
        @test AramisAPI.validate(param) == false
    end

    @testset "Validator: DateTimeAttackAlgo" begin
        # test valid parameters
        param = AramisAPI.DateTimeAttackAlgo("spring", "weekend", "22-2h", ["918", "932"], ["MLPR"])
        @test AramisAPI.validate(param)
        # test success with empty list of algorithms
        param = AramisAPI.DateTimeAttackAlgo("spring", "weekend", "22-2h", ["918", "932"], [])
        @test AramisAPI.validate(param)
        # check failure with invalid algorithm
        param = AramisAPI.DateTimeAttackAlgo("spring", "weekend", "22-2h", ["918", "932"], ["random"])
        @test AramisAPI.validate(param) == false
        # check failure with invalid date-time
        param = AramisAPI.DateTimeAttackAlgo("x", "weekend", "22-2h", ["918", "932"], ["MLPR"])
        @test AramisAPI.validate(param) == false
        param = AramisAPI.DateTimeAttackAlgo("spring", "x", "22-2h", ["918", "932"], ["MLPR"])
        @test AramisAPI.validate(param) == false
        param = AramisAPI.DateTimeAttackAlgo("spring", "weekend", "x", ["918", "932"], ["MLPR"])
        @test AramisAPI.validate(param) == false
    end

    @testset "Handlers: data" begin
        test_power_balance(AramisAPI.INITIAL_GRID)
        n_gens = length(AramisAPI.INITIAL_GRID["gen"])
        n_loads = length(AramisAPI.INITIAL_GRID["load"])
        n_timesteps = (length(AramisAPI.SEASONS)
            * length(AramisAPI.DAYS) * length(AramisAPI.HOURS))
        @test size(AramisAPI.GENS) == (n_gens, n_timesteps)
        @test size(AramisAPI.LOADS) == (n_loads, n_timesteps)
    end

    @testset "Handlers: update_injections" begin
        # first day of the year
        net1 = deepcopy(AramisAPI.INITIAL_GRID)
        AramisAPI.update_injections!(net1, AramisAPI.DateTime("winter", "weekday", "22-2h"))
        test_valid_network(net1)
        # last day of the year
        net2 = deepcopy(AramisAPI.INITIAL_GRID)
        AramisAPI.update_injections!(net2, AramisAPI.DateTime("fall", "weekend", "18-22h"))
        test_valid_network(net2)
        # check that they are distinct
        test_identical_network_structure(net1, net2)
        @test equal_gens(net1, net2) == false
        @test equal_loads(net1, net2) == false
    end

    @testset "Handlers: initial_network" begin
        network = AramisAPI.initial_network()
        test_valid_network(network)
    end

    @testset "Handlers: real_network" begin
        param = AramisAPI.DateTime("fall", "weekday", "10-14h")
        network = AramisAPI.real_network(param)
        test_valid_network(network)
        test_power_balance(network)
        # check that the network structure is the same as the initial netork
        reference_net = AramisAPI.INITIAL_GRID
        test_identical_network_structure(network, reference_net)
        # check difference with initial network
        @test equal_gens(network, reference_net) == false
        @test equal_loads(network, reference_net) == false
        @test equal_flows(network, reference_net) == false
    end

    @testset "Handlers: attacked_network" begin
        attacked_gens = ["918", "931"]
        param = AramisAPI.DateTimeAttack("summer", "weekend", "18-22h", attacked_gens)
        network = AramisAPI.attacked_network(param)
        test_valid_network(network)
        test_power_balance(network)
        # check that the network structure is the same as without attacks
        reference_param = AramisAPI.DateTime(param.season, param.day, param.hour)
        reference_net = AramisAPI.real_network(reference_param)
        test_identical_network_structure(network, reference_net)
        # check difference with initial network
        @test equal_gens(network, reference_net; exclude = attacked_gens)
        for id in attacked_gens
            @test network["gen"][id]["pg"] != reference_net["gen"][id]["pg"]
        end
        @test equal_loads(network, reference_net; exclude = AramisAPI.SLACK_LOADS)
        @test equal_flows(network, reference_net) == false
    end

end
