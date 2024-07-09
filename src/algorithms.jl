
const ALGORITHM_DIR = Dict(
    "NBC"   => "nb",
    "KNNC"  => "knn"
)


function check_python_version()
    sys = pyimport("sys")
    return sys.version_info[1:2] == (3, 7)
end


function run_classifier(algorithm::String, gen::String, x::AbstractVector{<:Real}) :: Bool
    filename = joinpath([MODULE_FOLDER, "algorithms", ALGORITHM_DIR[algorithm],
        "estimator_$gen.p"])
    estimator = pyimport("pickle").load(pybuiltin("open")(filename, "rb"))
    return estimator.predict(reshape(x, (1, :)))[1]
end