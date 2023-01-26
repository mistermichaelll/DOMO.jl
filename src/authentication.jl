import HTTP: response, request
import JSON: parse
import Base64: base64encode
include("utils.jl")

function create_basic_auth_header(client_id::String, client_secret::String)
    ["Authorization" => "Basic " * base64encode(client_id * ":" * client_secret)]
end

function DOMO_auth(client_id::String, client_secret::String)
    if isempty(client_id) | isempty(client_secret)
        error("Don't you need some auth codes or something...?")
    end

    url = "https://api.domo.com/oauth/token?grant_type=client_credentials&scope=data"
    authorization = create_basic_auth_header(client_id, client_secret)

    response = request("GET", url, authorization)

    if response.status != 200
        error("Response had error: " * response.status)
    end

    global domo = parse_HTTP_response(response)

    print("Authentication complete.")
end
