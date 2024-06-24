using AramisAPI
using Test

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

end
