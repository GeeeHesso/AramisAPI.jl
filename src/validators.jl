import Oxygen: validate


function is_valid_hour(h::Int) :: Bool
    return h >= 0 && h <= 24 && h % 4 == 0
end


function validate(req::DateTime)
    (req.season in keys(SEASONS) && req.day in keys(DAYS) && is_valid_hour(req.hour)
        && req.scale_factor > 0)
end


function validate(req::DateTimeAttack)
    (
        all([gen in ATTACKABLE_GENS for gen in req.attacked_gens]) &&
        validate(DateTime(req.season, req.day, req.hour, req.scale_factor))
    )
end


function validate(req::DateTimeAttackAlgo)
    (
        all([algo in ALGORITHMS for algo in req.algorithms]) &&
        validate(DateTimeAttack(req.season, req.day, req.hour, req.scale_factor, req.attacked_gens))
    )
end