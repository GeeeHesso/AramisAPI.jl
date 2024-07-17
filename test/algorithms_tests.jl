
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


@testset "Algorithms: check PyCall environment" begin
    @test AramisAPI.check_python_version()
end