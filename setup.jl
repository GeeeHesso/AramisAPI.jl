
# add packages
import Pkg
Pkg.add(["JSON", "PyCall"])

# create conda virtual environment
println("Creating conda environment 'aramis-api'...")
using JSON
conda_json = JSON.parse(
    read(`conda create -yn aramis-api python=3.6 pandas scikit-learn --json`, String))
@assert conda_json["success"]
println("Environment created at ", conda_json["prefix"])

# build PyCall
ENV["PYTHON"] = joinpath([conda_json["prefix"], "bin", "python3.6"])
Pkg.build("PyCall")

# check that PyCall is using the correct Python version
using PyCall
sys = pyimport("sys")
println("Using Python ", sys.version)
