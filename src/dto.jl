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

const HOURS = Dict(
    "2-6h" => 1,
    "6-10h" => 2,
    "10-14h" => 3,
    "14-18h" => 4,
    "18-22h" => 5,
    "22-2h" => 0
)

const ATTACKABLE_GENS = [
    "173", "915", "918", "923", "924", "927", "931", "932", "933", "934"]

const ALGORITHMS = ["MLPR"]


struct DateTime
    season::String
    day::String
    hour::String
end


struct DateTimeAttack
    season::String
    day::String
    hour::String
    attacked_gens::Vector{String}
end


struct DateTimeAttackAlgo
    season::String
    day::String
    hour::String
    attacked_gens::Vector{String}
    algorithms::Vector{String}
end
