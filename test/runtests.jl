using AramisAPI
using Test

@testset "AramisAPI.jl" begin

    @testset "test_global_variables" begin
        @test isa(AramisAPI.initial_grid, String)
        @test length(AramisAPI.initial_grid) > 0
    end


end
