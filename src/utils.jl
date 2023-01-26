# function which parses the body of an HTTP response into a dictionary object.
function parse_HTTP_response(http_response)
    parse(
        String(http_response.body)
    )
end

function PUT_data(data::String, dataset_id::String, access_token::String)
    response = request(
        "PUT",
        "https://api.domo.com/v1/datasets/" * dataset_id * "/data",
        ["Content-Type" => "text/csv", "Authorization" => "bearer " * access_token],
        data;
        status_exception = false
    )
end
