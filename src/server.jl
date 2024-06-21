export start_server


function start_server(; port::Int64=8080, host::String="127.0.0.1") :: Nothing

    # Return the initial grid to be shown at application startup
    @get "/initial_network" function (req::HTTP.Request)
        grid = read(joinpath([MODULE_FOLDER, "networks", "initial_grid.json"]), String)
        response =  html(grid, status=200)
        HTTP.setheader(response, "content-type" => "application/json; charset=utf-8")
        return response
    end

    # Return the grid with updated datetime
    @post "/real_network" function(req::HTTP.Request)
        # validate data
        # handle request
        # response
        grid = read(joinpath([MODULE_FOLDER, "networks", "other_grid.json"]), String)
        response =  html(grid, status=200)
        HTTP.setheader(response, "content-type" => "application/json; charset=utf-8")
        return response
    end

    # Return the grid with updated datetime and on/off attacks on some generators
    @post "/attacked_network" function(req::HTTP.Request)
        # validate data
        # handle request
        # response
        grid = read(joinpath([MODULE_FOLDER, "networks", "other_grid_attacked.json"]), String)
        response =  html(grid, status=200)
        HTTP.setheader(response, "content-type" => "application/json; charset=utf-8")
        return response
    end

    # Return the result of detection algorithms based on a given grid
    @post "/algorithms" function(req::HTTP.Request)
        # validate data
        # handle request
        # response
        result = read(joinpath([MODULE_FOLDER, "networks", "sample_algo_response.json"]), String)
        response =  html(result, status=200)
        HTTP.setheader(response, "content-type" => "application/json; charset=utf-8")
        return response
    end

    swagger_schema = YAML.load_file(joinpath([MODULE_FOLDER, "src", "swagger", "swagger.yml"]))
    setschema(swagger_schema)

    serve(port=port, host=host)
#     serve(port=port, host=host, access_log=nothing) # to improve performance

#    function CorsMiddleware(handler)
#        return function (req::HTTP.Request)
#            if HTTP.method(req) == "OPTIONS"
#                return HTTP.Response(200, headers)
#            else
#                return handler(req) # passes the request to the AuthMiddleware
#            end
#        end
#    end
#
#    serve(port=port, middleware=[CorsMiddleware], host=host)

    nothing
end

