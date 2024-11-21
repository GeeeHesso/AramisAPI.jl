
function check_algorithm_results(result, algorithms)
    return (issetequal(keys(result), algorithms) &&
        all([issetequal(keys(result[algo]), AramisAPI.ATTACKABLE_GENS)
            for algo in algorithms]))
end


@testset "Algorithms: run classifier" begin
    # run all classifiers for all time steps
    network = AramisAPI.INITIAL_GRID
    T = size(AramisAPI.GENS, 2)
    for t = 1:4 # MEMORY OVERFLOW IF 1:T, WHY?
        AramisAPI.update_injections!(network, t, 100)
        features = AramisAPI.get_features(network)
        for algorithm in keys(AramisAPI.CLASSIFIER_DIR)
            for gen in AramisAPI.ATTACKABLE_GENS
                @test AramisAPI.run_classifier(algorithm, gen, features) || true
            end
        end
    end
end


@testset "Algorithms: run regressor" begin
    # run all regressors for all time steps
    network = AramisAPI.INITIAL_GRID
    T = size(AramisAPI.GENS, 2)
    for t = 1:4 # MEMORY OVERFLOW IF 1:T, WHY?
        AramisAPI.update_injections!(network, t, 100)
        features = AramisAPI.get_features(network)
        for algorithm in keys(AramisAPI.REGRESSOR_DIR)
            for gen in AramisAPI.ATTACKABLE_GENS
                @test AramisAPI.run_regressor(algorithm, gen, features, t) || true
            end
        end
    end
end


@testset "Algorithms: get features" begin
    network = AramisAPI.INITIAL_GRID
    AramisAPI.update_injections!(network, 1, 100)
    x = AramisAPI.get_features(network)
    @test x.shape == (1, length(AramisAPI.GEN_IDS))
    x_dict = x.to_dict()
    @test issetequal(keys(x_dict), AramisAPI.FEATURE_NAMES)
    AramisAPI.update_injections!(network, 2, 100)
    x_other_t = AramisAPI.get_features(network)
    @test x.values != x_other_t.values
end


@testset "Algorithms: get history" begin
    x = AramisAPI.get_history("923", 1)
    @test x.size == 4
    x_other_t = AramisAPI.get_history("923", 2)
    @test x.values != x_other_t.values
    x_other_gen = AramisAPI.get_history("934", 1)
    @test x.values != x_other_gen.values
end


@testset "Algorithms: check PyCall environment" begin
    @test AramisAPI.check_python_version()
end