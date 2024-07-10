
const ALGORITHM_DIR = Dict(
    "NBC"   => "nb",
    "KNNC"  => "knn"
)

const FEATURE_NAMES = CSV.read(joinpath([MODULE_FOLDER, "data", "gen_names.csv"]),
    CSV.Tables.matrix, header=false)[:, 1]


function check_python_version()
    sys = pyimport("sys")
    return sys.version_info[1:2] == (3, 7)
end


function run_classifier(algorithm::String, gen::String, features::PyObject) :: Bool
    filename = joinpath([MODULE_FOLDER, "algorithms", ALGORITHM_DIR[algorithm],
        "estimator_$gen.p"])
    estimator = pyimport("pickle").load(pybuiltin("open")(filename, "rb"))
    return estimator.predict(features)[1]
end


function get_features(network::Dict{String, Any}) :: PyObject
    return pyimport("pandas").DataFrame([[network["gen"][id]["pg"] for id in GEN_IDS]],
        columns=FEATURE_NAMES)
end