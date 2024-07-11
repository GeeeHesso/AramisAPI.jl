# AramisAPI

[![Build Status](https://github.com/GeeeHesso/AramisAPI.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/GeeeHesso/AramisAPI.jl/actions/workflows/CI.yml?query=branch%3Amain)

A Julia API for the Aramis project.

## Installation

The machine learning algorithms running in the background require Python version 3.7 with the `pandas` and `scikit-learn` packages,
called from Julia through the `PyCall` package.

Since Python 3.7 is presumably not the default version on your machine,
you have to tell PyCall where to find it. In a Julia REPL, run
```julia
import Pkg
Pkg.add("PyCall")

ENV["PYTHON"] = "<path to your python3.7 executable>"
Pkg.build("PyCall")
```

Alternatively, you can set up a virtual environment using Anaconda
([Miniconda installation link](https://docs.anaconda.com/miniconda/miniconda-install/)).
To do so, download the script [setup.jl](./setup.jl) and run it in the Julia REPL with
```julia
include("setup.jl")
```
or directly in the command line as
```bash
julia setup.jl
```

If successful, the installation script should output something like `Using Python 3.7.12 ...`.

Once this is done, the Julia package *AramisAPI.jl* can be installed with
```julia
using Pkg
Pkg.add("https://github.com/GeeeHesso/AramisAPI.jl")
```

### Usage

Load the package and start the API with
```julia
using AramisAPI
start_server()
```

The default IP is `127.0.0.1` and the default port 8080. After launching the server, the Swagger documentation page is available at http://127.0.0.1:8080/docs.

