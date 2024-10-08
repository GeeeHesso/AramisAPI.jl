@testset "Validator: DateTime" begin
    # test all valid parameters
    for season in ["spring", "summer", "fall", "winter"]
        for day in ["weekday", "weekend"]
            for time in [0, 4, 8, 12, 16, 20, 24] # midnight can be input as either 0 or 24
                for scale_factor in [100, 120]
                    @test AramisAPI.validate(AramisAPI.DateTime(season, day, time, scale_factor))
                end
            end
        end
    end
    # check failure with erroneous parameters
    for param in [
            ["not-a-season", "weekday", 16, 100],
            ["winter", "not-a-weekday", 16, 100],
            ["winter", "weekday", 17, 100],
            ["winter", "weekday", 16, -10]
        ]
        param = AramisAPI.DateTime(param[1], param[2], param[3], param[4])
        @test AramisAPI.validate(param) == false
    end
end


@testset "Validator: DateTimeAttack" begin
    # test valid parameters
    param = AramisAPI.DateTimeAttack("spring", "weekend", 0, 100, ["918", "932"])
    @test AramisAPI.validate(param)
    # test success with empty list of generators
    param = AramisAPI.DateTimeAttack("spring", "weekend", 0, 100, [])
    @test AramisAPI.validate(param)
    # check failure with invalid generator
    param = AramisAPI.DateTimeAttack("spring", "weekend", 0, 100, ["918", "111", "932"])
    @test AramisAPI.validate(param) == false
    # check failure with invalid date-time
    param = AramisAPI.DateTimeAttack("x", "weekend", 0, 100, ["918", "932"])
    @test AramisAPI.validate(param) == false
    param = AramisAPI.DateTimeAttack("spring", "x", 0, 100, ["918", "932"])
    @test AramisAPI.validate(param) == false
    param = AramisAPI.DateTimeAttack("spring", "weekend", -1, 100, ["918", "932"])
    @test AramisAPI.validate(param) == false
    param = AramisAPI.DateTimeAttack("spring", "weekend", 0, -1, ["918", "932"])
    @test AramisAPI.validate(param) == false
end


@testset "Validator: DateTimeAttackAlgo" begin
    # test valid parameters
    param = AramisAPI.DateTimeAttackAlgo("spring", "weekend", 0, 100, ["918", "932"], ["MLPC"])
    @test AramisAPI.validate(param)
    # test success with empty list of algorithms
    param = AramisAPI.DateTimeAttackAlgo("spring", "weekend", 0, 100, ["918", "932"], [])
    @test AramisAPI.validate(param)
    # check failure with invalid algorithm
    param = AramisAPI.DateTimeAttackAlgo("spring", "weekend", 0, 100, ["918", "932"], ["random"])
    @test AramisAPI.validate(param) == false
    # check failure with invalid date-time
    param = AramisAPI.DateTimeAttackAlgo("x", "weekend", 0, 100, ["918", "932"], ["MLPC"])
    @test AramisAPI.validate(param) == false
    param = AramisAPI.DateTimeAttackAlgo("spring", "x", 0, 100, ["918", "932"], ["MLPC"])
    @test AramisAPI.validate(param) == false
    param = AramisAPI.DateTimeAttackAlgo("spring", "weekend", 33, 100, ["918", "932"], ["MLPC"])
    @test AramisAPI.validate(param) == false
    param = AramisAPI.DateTimeAttackAlgo("spring", "weekend", 0, 0, ["918", "932"], ["MLPC"])
    @test AramisAPI.validate(param) == false
end