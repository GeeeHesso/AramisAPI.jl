export start_server


function start_server(; port::Int64=8080, host::String="127.0.0.1") :: Nothing

    # Return the initial grid to be shown at application startup
    @get "/initial_network" function (req::HTTP.Request)
        return read(joinpath([MODULE_FOLDER, "networks", "initial_grid.json"]), String)
    end

    # Return the grid with updated datetime
    @post "/real_network" function(req::HTTP.Request, params::Json{DateTime})
        return read(joinpath([MODULE_FOLDER, "networks", "other_grid.json"]), String)
    end

    # Return the grid with updated datetime and on/off attacks on some generators
    @post "/attacked_network" function(req::HTTP.Request, params::Json{DateTimeAttack})
        return read(joinpath([MODULE_FOLDER, "networks", "other_grid_attacked.json"]), String)
    end

    # Return the result of detection algorithms based on a given grid
    @post "/algorithms" function(req::HTTP.Request, params::Json{DateTimeAttackAlgo})
        return read(joinpath([MODULE_FOLDER, "networks", "sample_algo_response.json"]), String)
    end

    function errorhandler(handle)
        return function(req)
            try
                result = handle(req)
                return HTTP.Response(200, ["content-type" => "application/json; charset=utf-8"],
                    body=result)
                return response
            catch error
                if isa(error, ArgumentError)
                    return HTTP.Response(400, ["content-type" => "text/plain; charset=utf-8"],
                        body=error.msg)
                else
                    return HTTP.Response(500, ["content-type" => "text/plain; charset=utf-8"],
                        body=error.msg)
                end
            end
        end
    end

    swagger_schema = YAML.load_file(joinpath([MODULE_FOLDER, "src", "swagger", "swagger.yml"]))
    mergeschema(swagger_schema)

    serve(port=port, host=host, middleware=[errorhandler], serialize=false)
#    serve(port=port, host=host, middleware=[errorhandler], serialize=false, access_log=nothing) # to improve performance

#    function CorsMiddleware(handler)
#        return function (req::HTTP.Request)
#            if HTTP.method(req) == "OPTIONS"
#                return HTTP.Response(200, headers)
#            else
#                return handler(req) # passes the request to the AuthMiddleware
#            end
#        end
#    end

    nothing
end

