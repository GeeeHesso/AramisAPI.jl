
@testset "Handlers: initial_network" begin
    network = AramisAPI.initial_network()
    test_valid_network(network)
end


@testset "Handlers: real_network" begin
    param = AramisAPI.DateTime("fall", "weekday", 12, 100)
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
    param = AramisAPI.DateTimeAttack("summer", "weekend", 20, 100, attacked_gens)
    network = AramisAPI.attacked_network(param)
    test_valid_network(network)
    test_power_balance(network)
    # check that the network structure is the same as without attacks
    reference_param = AramisAPI.DateTime(param.season, param.day, param.hour, param.scale_factor)
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


@testset "Handlers: algorithms" begin
    attacked_gens = ["927", "915", "933"]
    algorithms = ["NBC", "KNNC", "RFC", "SVC", "GBC", "MLPC", "MLPR"]
    param = AramisAPI.DateTimeAttackAlgo("spring", "weekend", 16, 100,
        attacked_gens, algorithms)
    @test check_algorithm_results(AramisAPI.algorithms(param),
        algorithms)
end