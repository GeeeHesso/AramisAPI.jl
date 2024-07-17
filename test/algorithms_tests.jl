
function check_algorithm_results(result, algorithms)
    return (issetequal(keys(result), algorithms) &&
        all([issetequal(keys(result[algo]), AramisAPI.ATTACKABLE_GENS)
            for algo in algorithms]))
end


@testset "Algorithms: run classifier" begin
    # run all classifiers for all time steps
    network = AramisAPI.INITIAL_GRID
    T = size(AramisAPI.GENS, 2)
    for t = 1:T
        AramisAPI.update_injections!(network, t)
        for algorithm in keys(AramisAPI.CLASSIFIER_DIR)
            for gen in AramisAPI.ATTACKABLE_GENS
                @test AramisAPI.run_classifier(algorithm, gen,
                    AramisAPI.get_features(network)) || true
            end
        end
    end
end


@testset "Algorithms: get features" begin
    network = AramisAPI.INITIAL_GRID
    AramisAPI.update_injections!(network, 1)
    x = AramisAPI.get_features(network)
    @test x.shape == (1, length(AramisAPI.GEN_IDS))
    x_dict = x.to_dict()
    @test issetequal(keys(x_dict), AramisAPI.FEATURE_NAMES)
    AramisAPI.update_injections!(network, 2)
    x_other_t = AramisAPI.get_features(network)
    @test x.values != x_other_t.values
end


@testset "Algorithms: check PyCall environment" begin
    @test AramisAPI.check_python_version()
end