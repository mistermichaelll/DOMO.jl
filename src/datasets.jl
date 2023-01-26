include("schema.jl")

function create_dataset(df; name::String = "", description::String = "")
    if !(@isdefined domo)
        error("Please run the DOMO_auth() function to generate an access token.")
    end

    if isempty(name)
        @error "Dataset cannot be created without a name."
    end

    if isempty(description)
        @warn "Dataset will be created without a description."
    end

    access_token = domo["access_token"]

    schema = create_dataset_schema(df, name, description)
    pushed_schema = push_schema_to_domo(schema) |> parse_HTTP_response

    io = IOBuffer()
    write(io, df; newline = "\n", writeheader = false)
    data = String(io.data)

    data_response = PUT_data(data, pushed_schema["id"], access_token)

    println("Dataset uploaded to Domo: ID is" * pushed_schema["id"])
end

function replace_dataset(dataset_id::String, df)
    if !(@isdefined domo)
        error("Please run the DOMO_auth() function to generate an access token.")
    end

    access_token = domo["access_token"]

    io = IOBuffer()
    write(io, df; newline = "\n", writeheader = false, append = false)
    data = String(io.data)

    response = PUT_data(data, dataset_id, access_token)

    if iserror(response)
        error("Dataset update was unsuccessful.")
    end

    println("Dataset update successful.")
end
