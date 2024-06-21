# AramisAPI

[![Build Status](https://github.com/GeeeHesso/AramisAPI.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/GeeeHesso/AramisAPI.jl/actions/workflows/CI.yml?query=branch%3Amain)

A Julia API for the Aramis project.

## Quickstart

Install the package by typing the following commands in a Julia REPL:
```julia
using Pkg
Pkg.add("https://github.com/GeeeHesso/AramisAPI.jl")
```

Then load the package with
```julia
using AramisAPI
```

and start the API
```julia
start_server()
```

The default IP is `127.0.0.1` and the default port 8080. After launching the server, the Swagger documentation page is available at http://127.0.0.1:8080/docs.

