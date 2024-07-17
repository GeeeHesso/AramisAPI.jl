using AramisAPI
using Test


@testset "AramisAPI.jl" begin

    include("validators_tests.jl")
    include("powerflow_tests.jl")
    include("algorithms_tests.jl")
    include("handlers_tests.jl")

end
