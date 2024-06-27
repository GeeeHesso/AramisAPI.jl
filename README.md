# AramisAPI

[![Build Status](https://github.com/GeeeHesso/AramisAPI.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/GeeeHesso/AramisAPI.jl/actions/workflows/CI.yml?query=branch%3Amain)

A Julia API for the Aramis project.

## Quickstart

Install the package by typing the following commands in a Julia REPL:
```julia
using Pkg
Pkg.add("https://github.com/GeeeHesso/AramisAPI.jl")
```

Then load the package and start the API with
```julia
using AramisAPI
start_server()
```

The default IP is `127.0.0.1` and the default port 8080. After launching the server, the Swagger documentation page is available at http://127.0.0.1:8080/docs.

## Setting up the Python virtual environment

The machine learning algorithms requires a specific Python virtual environment that can be set up with Anaconda ([Miniconda installation link](https://docs.anaconda.com/miniconda/miniconda-install/)) as follows:

```bash
cd <path-to-repo>/AramisAPI.jl
conda env create -f environment.yml -p conda
```

Once the installation is complete, run the following script to set up PyCall:

```bash
julia setup.jl
```
