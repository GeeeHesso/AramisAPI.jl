const SEASONS = Dict(
    "spring" => 1,
    "summer" => 2,
    "fall" => 3,
    "winter" => 4
)

const DAYS = Dict(
    "weekday" => 1,
    "weekend" => 2
)

const HOURS = Dict(
    "2-6h" => 1,
    "6-10h" => 2,
    "10-14h" => 3,
    "14-18h" => 4,
    "18-24h" => 5,
    "22-2h" => 6
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
