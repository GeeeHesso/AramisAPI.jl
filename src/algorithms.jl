
const CLASSIFIER_DIR = Dict(
    "NBC"   => "nb",
    "KNNC"  => "knn",
    "RFC"   => "rf",
    "SVC"   => "svc",
    "GBC"   => "gbc",
    "MLPC"  => "mlpc"
)

const FEATURE_NAMES = CSV.read(joinpath([MODULE_FOLDER, "data", "gen_names.csv"]),
    CSV.Tables.matrix, header=false)[:, 1]


function check_python_version()
    sys = pyimport("sys")
    return sys.version_info[1:2] == (3, 7)
end


function run_classifier(algorithm::String, gen::String, features::PyObject) :: Bool
    filename = joinpath([MODULE_FOLDER, "algorithms", CLASSIFIER_DIR[algorithm],
        "estimator_$gen.p"])
    estimator = pickle.load(pybuiltin("open")(filename, "rb"))
    if algorithm == "MLPC"
        filename = joinpath([MODULE_FOLDER, "algorithms", CLASSIFIER_DIR[algorithm],
            "scaler_$gen.p"])
        scaler = pickle.load(pybuiltin("open")(filename, "rb"))
        features = scaler.transform(features)
    end
    return estimator.predict(features)[1]
end


function get_features(network::Dict{String, Any}) :: PyObject
    return pandas.DataFrame([[network["gen"][id]["pg"] for id in GEN_IDS]],
        columns=FEATURE_NAMES).multiply(100.)
end