export start_server


CORS_HEADERS = [
    "Access-Control-Allow-Origin" => "*",
    "Access-Control-Allow-Headers" => "*",
    "Access-Control-Allow-Methods" => "POST, GET, OPTIONS"
]


function start_server(; port::Int64=8080, host::String="127.0.0.1", frontend_url::String="") :: Nothing

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

    if !isempty(frontend_url)
        CORS_HEADERS = [
            "Access-Control-Allow-Origin" => frontend_url,
            "Access-Control-Allow-Headers" => "*",
            "Access-Control-Allow-Methods" => "POST, GET, OPTIONS"
        ]
    end

    serve(port=port, host=host, middleware=[errorhandler, corsmiddleware], serialize=false)
#    serve(..., access_log=nothing) # to improve performance
#    serveparallel(...)

    nothing
end

function corsmiddleware(handler)
   return function (req::HTTP.Request)
       return HTTP.method(req) == "OPTIONS" ? HTTP.Response(200, CORS_HEADERS) : handler(req)
   end
end

function errorhandler(handler)
    return function(req)
        try
            result = handler(req)
            return HTTP.Response(200, [["content-type" => "application/json; charset=utf-8"]; CORS_HEADERS],
                body=JSON.json(result))
        catch error
            errorcode = isa(error, ArgumentError) ? 400 : 500
            return HTTP.Response(errorcode, [["content-type" => "text/plain; charset=utf-8"]; CORS_HEADERS],
                body = hasproperty(error, :msg) ? error.msg : "")
        end
    end
end
