include("utils.jl")

function create_basic_auth_header(client_id::String, client_secret::String)
    ["Authorization" => "Basic " * base64encode(client_id * ":" * client_secret)]
end

function DOMO_auth(client_id::String, client_secret::String)
     # this likely would never happen since providing nothing will throw a method error...
     #  and I doubt someone would pass an empty string here...but you never know.
    if isempty(client_id) | isempty(client_secret)
        error("Missing client keys - if you don't have them, create them here: https://developer.domo.com/new-client")
    end

    url = "https://api.domo.com/oauth/token?grant_type=client_credentials&scope=data"
    authorization = create_basic_auth_header(client_id, client_secret)

    response = request("GET", url, authorization; status_exception = false)

    if iserror(response)
        error("Response had error: " * string(response.status))
    end

    global domo = parse_HTTP_response(response)

    print("Authentication complete.")
end
