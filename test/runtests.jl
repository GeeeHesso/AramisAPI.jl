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


@testset "AramisAPI.jl" begin

    @testset "test_DateTime_validator" begin
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

    @testset "test_DateTimeAttack_validator" begin
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

    @testset "test_DateTimeAttackAlgo_validator" begin
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

    @testset "test_initial_network_handler" begin
        network = AramisAPI.initial_network()
        test_valid_network(network)
    end

    @testset "test_real_network_handler" begin
        param = AramisAPI.DateTime("fall", "weekday", "10-14h")
        network = AramisAPI.real_network(param)
        test_valid_network(network)
        # check that the network structure is the same as the initial netork
        reference_net = AramisAPI.INITIAL_GRID
        test_identical_network_structure(network, reference_net)
        # check difference with initial network
        @test equal_gens(network, reference_net) == false
        @test equal_loads(network, reference_net) == false
        @test equal_flows(network, reference_net) == false
    end

    @testset "test_attacked_network_handler" begin
        attacked_gens = ["918", "931"]
        param = AramisAPI.DateTimeAttack("summer", "weekend", "18-22h", attacked_gens)
        network = AramisAPI.attacked_network(param)
        test_valid_network(network)
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
