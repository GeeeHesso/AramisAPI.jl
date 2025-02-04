
const ALGORITHM_DIR = Dict(
    "NBC"   => "nb",
    "KNNC"  => "knn",
    "RFC"   => "rf",
    "SVC"   => "svc",
    "GBC"   => "gbc",
    "MLPC"  => "mlpc",
    "MLPR"  => "mlpr"
)

const SCALERS = ["MLPC", "MLPR"]
const REGRESSORS = ["MLPR"]

const FEATURE_NAMES = CSV.read(joinpath([MODULE_FOLDER, "data", "gen_names.csv"]),
    CSV.Tables.matrix, header=false)[:, 1]
const GEN_HIST = DataDrop.retrieve_matrix(joinpath([MODULE_FOLDER, "data", "gen_hist.h5"]))


function check_python_version()
    sys = pyimport("sys")
    return sys.version_info[1:2] == (3, 6)
end


function run_algorithm(algorithm::String, gen::String, features::PyObject, t::Int) :: Bool

    # load model
    dir = joinpath([MODULE_FOLDER, "algorithms", ALGORITHM_DIR[algorithm]])
    estimator = pickle.load(pybuiltin("open")(joinpath([dir, "estimator_$gen.p"]), "rb"))

    # identify generator name
    label_id = findfirst(x -> string(x) == gen, GEN_IDS)
    label_name = FEATURE_NAMES[label_id]

    # prepare label and features
    x_context = features.T.squeeze()
    if algorithm in REGRESSORS
        y = x_context.get(label_name)
        x_context = x_context.drop(index=label_name)
    end
    x_context = x_context.rename(index=Dict(name => "$(name)_t" for name in x_context.index))
    x_hist = get_history(gen, t)
    x = pandas.concat([x_context, x_hist]).to_frame().T

    # scale inputs
    if algorithm in SCALERS
        scaler_x = pickle.load(pybuiltin("open")(joinpath([dir, "scaler_x_$gen.p"]), "rb"))
        x = scaler_x.transform(x)
    end

    # inference
    y_pred = estimator.predict(x)

    if algorithm in REGRESSORS
        # load threshold value
        threshold_df = pickle.load(pybuiltin("open")(joinpath([dir, "threshold_$gen.p"]), "rb"))
        threshold = threshold_df."best_threshold".get(0)

        # scale prediction
        if algorithm in SCALERS
            scaler_y = pickle.load(pybuiltin("open")(joinpath([dir, "scaler_y_$gen.p"]), "rb"))
            y_pred = scaler_y.inverse_transform(pandas.DataFrame([y_pred]))
        end

        return abs(y - y_pred[1]) > threshold
    end

    return y_pred[1]
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