
const CLASSIFIER_DIR = Dict(
    "NBC"   => "nb",
    "KNNC"  => "knn",
    "RFC"   => "rf",
    "SVC"   => "svc",
    "GBC"   => "gbc",
    "MLPC"  => "mlpc"
)
const REGRESSOR_DIR = Dict(
    "MLPR"  => "mlpr"
)
const FEATURE_NAMES = CSV.read(joinpath([MODULE_FOLDER, "data", "gen_names.csv"]),
    CSV.Tables.matrix, header=false)[:, 1]
const GEN_HIST = DataDrop.retrieve_matrix(joinpath([MODULE_FOLDER, "data", "gen_hist.h5"]))


function check_python_version()
    sys = pyimport("sys")
    return sys.version_info[1:2] == (3, 6)
end


function run_algorithm(algorithm::String, gen::String, features::PyObject, t::Int) :: Bool
    return algorithm in keys(CLASSIFIER_DIR) ?
        run_classifier(algorithm, gen, features) :
        run_regressor(algorithm, gen, features, t)
end


function run_classifier(algorithm::String, gen::String, features::PyObject) :: Bool
    dir = joinpath([MODULE_FOLDER, "algorithms", CLASSIFIER_DIR[algorithm]])
    estimator = pickle.load(pybuiltin("open")(joinpath([dir, "estimator_$gen.p"]), "rb"))
    if algorithm == "MLPC"
        scaler = pickle.load(pybuiltin("open")(joinpath([dir, "scaler_$gen.p"]), "rb"))
        features = scaler.transform(features)
    end
    return estimator.predict(features)[1]
end


function run_regressor(algorithm::String, gen::String, features::PyObject, t::Int) :: Bool
    # load regressor and scaler
    dir = joinpath([MODULE_FOLDER, "algorithms", REGRESSOR_DIR[algorithm]])
    estimator = pickle.load(pybuiltin("open")(joinpath([dir, "estimator_$gen.p"]), "rb"))
    scaler_x = pickle.load(pybuiltin("open")(joinpath([dir, "scaler_x_$gen.p"]), "rb"))
    scaler_y = pickle.load(pybuiltin("open")(joinpath([dir, "scaler_y_$gen.p"]), "rb"))

    # load threshold value
    threshold_df = pickle.load(pybuiltin("open")(joinpath([dir, "threshold_$gen.p"]), "rb"))
    threshold = threshold_df."best_threshold".get(0)

    # identify generator name
    label_id = findfirst(x -> string(x) == gen, GEN_IDS)
    label_name = FEATURE_NAMES[label_id]

    # prepare label and features
    features_series = features.T.squeeze()
    y = features_series.get(label_name)
    x_context = features_series.drop(index=label_name)
    x_context = x_context.rename(index=Dict(name => "$(name)_t" for name in x_context.index))
    x_hist = get_history(gen, t)
    x = pandas.concat([x_context, x_hist]).to_frame().T

    # perform regression
    x_scaled = scaler_x.transform(x)
    y_scaled = pandas.DataFrame([estimator.predict(x_scaled)])
    y_pred = scaler_y.inverse_transform(y_scaled)[1]

    return abs(y - y_pred) > threshold
end


function get_features(network::Dict{String, Any}) :: PyObject
    return pandas.DataFrame([[network["gen"][id]["pg"] for id in GEN_IDS]],
        columns=FEATURE_NAMES).multiply(100.)
end


function get_history(gen::String, t::Int) :: PyObject
    id = findfirst(==(gen), ATTACKABLE_GENS)
    return pandas.Series([GEN_HIST[id, time] for time = 4*t-3:4*t],
        index=["y_t-4", "y_t-3", "y_t-2", "y_t-1"],
        name=FEATURE_NAMES[id]).multiply(100.)
end