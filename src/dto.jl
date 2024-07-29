const SEASONS = Dict(
    "spring" => 1,
    "summer" => 2,
    "fall" => 3,
    "winter" => 0
)

const DAYS = Dict(
    "weekday" => 0,
    "weekend" => 1
)

const HOUR_STEP = 4

const ATTACKABLE_GENS = [
    "173", "915", "918", "923", "924", "927", "931", "932", "933", "934"]

const ALGORITHMS = ["NBC", "KNNC", "RFC", "SVC", "GBC", "MLPC", "MLPR"]


struct DateTime
    season::String
    day::String
    hour::Int
end


struct DateTimeAttack
    season::String
    day::String
    hour::Int
    attacked_gens::Vector{String}
end


struct DateTimeAttackAlgo
    season::String
    day::String
    hour::Int
    attacked_gens::Vector{String}
    algorithms::Vector{String}
end
