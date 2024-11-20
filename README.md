# AramisAPI

[![Build Status](https://github.com/GeeeHesso/AramisAPI.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/GeeeHesso/AramisAPI.jl/actions/workflows/CI.yml?query=branch%3Amain)

A Julia API for the Aramis project.

## Installation

The machine learning algorithms running in the background require Python version 3.6 with the `pandas` and `scikit-learn` packages,
called from Julia through the `PyCall` package.

Since Python 3.6 is presumably not the default version on your machine,
you have to tell PyCall where to find it. In a Julia REPL, run
```julia
import Pkg
Pkg.add("PyCall")

ENV["PYTHON"] = "<path to your python3.6 executable>"
Pkg.build("PyCall")
```

You can verify which version of Python is being used by PyCall with the commands 
```julia
using PyCall
sys = pyimport("sys")
sys.version
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

If successful, the installation script should output something like `Using Python 3.6.15 ...`.

Once this is done, the Julia package *AramisAPI.jl* can be installed with
```julia
using Pkg
Pkg.add(url="https://github.com/GeeeHesso/AramisAPI.jl")
```

The installation can be tested with
```julia
using Pkg
Pkg.test("AramisAPI")
```

## Usage

Load the package and start the API with
```julia
using AramisAPI
start_server()
```

The default IP is `127.0.0.1` and the default port 8080. After launching the server, the Swagger documentation page is available at http://127.0.0.1:8080/docs.

## Docker container

The [Docker file](./Dockerfile) provided with the package can be used to build a container.
Download the file and run
```bash
docker build -t aramis-api <path-to-the-docker-file>
```
The image created in this way is about 2.7 GB. To run the container, use
```bash
docker run -p 8080:8080 --restart=unless-stopped aramis-api
```
The API is then available at http://0.0.0.0:8080/docs.