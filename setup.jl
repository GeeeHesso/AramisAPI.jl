const PACKAGE_PATH = joinpath([@__DIR__])
const ENV_PATH = joinpath([PACKAGE_PATH, "conda"])

ENV["PYTHON"] = joinpath([ENV_PATH, "bin", "python3.7"])

import Pkg
Pkg.activate(PACKAGE_PATH)
Pkg.build("PyCall")

using PyCall
sys = pyimport("sys")
println("Using Python ", sys.version)
