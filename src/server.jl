export start_server


function start_server(; port::Int64=8080, host::String="127.0.0.1") :: Nothing

    # returns the inital grid to be shown at application startup
    @get "/initial_network" function (req::HTTP.Request)
        # return  html(initial_grid, status=200, headers=json_header)
        response =  html(initial_grid, status=200)
        HTTP.setheader(response, "content-type" => "application/json; charset=utf-8")
        return response
    end

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

    serve(port=port, host=host, access_log=nothing)

    nothing
end

