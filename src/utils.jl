# function which parses the body of an HTTP response into a dictionary object.
function parse_HTTP_response(http_response::Response)
    parse(
        String(http_response.body)
    )
end
