export start_server
const headers = [
    "Content-Type" => "text/html; charset=utf-8",
    "Access-Control-Allow-Origin" => "https://swissgrid.iigweb.hevs.ch/",
    "Access-Control-Allow-Headers" => "*",
    "Access-Control-Allow-Methods" => "POST, GET, OPTIONS"
]

function start_server(; port::Int64=8080, host::String="0.0.0.0") :: Nothing

    # Return the initial grid to be shown at application startup
    @get "/initial_network" (req::HTTP.Request) -> initial_network()

    # Return the grid with updated datetime
    @post "/real_network" (req::HTTP.Request,
        params::Json{DateTime}) -> real_network(params.payload)

    # Return the grid with updated datetime and on/off attacks on some generators
    @post "/attacked_network" (req::HTTP.Request,
        params::Json{DateTimeAttack}) -> attacked_network(params.payload)

    # Return the result of detection algorithms based on a given grid
    @post "/algorithms" (req::HTTP.Request,
        params::Json{DateTimeAttackAlgo}) -> algorithms(params.payload)

    swagger_schema = YAML.load_file(joinpath([MODULE_FOLDER, "src", "swagger.yml"]))
    mergeschema(swagger_schema)

    serve(port=port, host=host, middleware=[CorsMiddleware], serialize=false)
#    serve(..., access_log=nothing) # to improve performance
#    serveparallel(...)

   function CorsMiddleware(handler)
       return function (req::HTTP.Request)
           if HTTP.method(req) == "OPTIONS"
               return HTTP.Response(200, headers)
           else
               return handler(req) # passes the request to the AuthMiddleware
           end
       end
   end
end


function errorhandler(handle)
    return function(req)
        try
            result = handle(req)
            return HTTP.Response(200, ["content-type" => "application/json; charset=utf-8"],
                body=JSON.json(result))
        catch error
            errorcode = isa(error, ArgumentError) ? 400 : 500
            return HTTP.Response(errorcode, ["content-type" => "text/plain; charset=utf-8"],
                body = hasproperty(error, :msg) ? error.msg : "")
        end
    end
end
