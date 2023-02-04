include("schema.jl")

"""
    create_dataset(df; name::String = "", description::String = "")

Create a dataset in Domo from an existing DataFrame object.
"""
function create_dataset(df; name::String = "", description::String = "")
    if !(@isdefined domo)
        error("Please run the DOMO_auth() function to generate an access token.")
    end

    if isempty(name)
        error("Dataset cannot be created without a name.")
    end

    if isempty(description)
        @warn "Dataset will be created without a description."
    end

    access_token = domo["access_token"]

    schema = create_dataset_schema(df, name, description)
    pushed_schema = push_schema_to_domo(schema) |> parse_HTTP_response

    data = create_csv_structure(df)

    response = PUT_data(data, pushed_schema["id"], access_token)

    println("Dataset uploaded to Domo: ID is " * pushed_schema["id"])
end

"""
    replace_dataset(dataset_id::String, df)

Replace an existing dataset in Domo with a new DataFrame object.
"""
function replace_dataset(dataset_id::String, df)
    if !(@isdefined domo)
        error("Please run the DOMO_auth() function to generate an access token.")
    end

    access_token = domo["access_token"]

    data = create_csv_structure(df)

    response = PUT_data(data, dataset_id, access_token)

    if iserror(response)
        error("Dataset update was unsuccessful.")
    end

    println("Dataset update successful.")
end

"""
    list_datasets(dataset_id::String, df)

Returns a list of all datasets in the Domo instance as a DataFrame.
"""
function list_datasets(;limit = 50, name = "", offset = 0, owner_id = "", order_by = "")
    if !(@isdefined domo)
        error("Please run the DOMO_auth() function to generate an access token.")
    end

    if limit > 50
        limit = 50
        @warn "Using a maximum request limit of 50."
    end

    limit_param = "&limit=" * string(ifelse(limit < 1, 50, limit))
    sort_param = ifelse(!isempty(order_by), "&sort=" * order_by, "")

    access_token = domo["access_token"]

    parsed_responses = []
    n_responses = 1

    while n_responses > 0
        offset_param = "&offset=" * string(offset)
        response = request(
            "GET",
            "https://api.domo.com/v1/datasets?" * limit_param * sort_param * offset_param,
            ["Accept" => "application/json", "Authorization" => "bearer " * access_token]
        )

        parsed_response = parse_HTTP_response(response)

        n_responses = length(parsed_response)

        offset += n_responses

        if n_responses > 0
            append!(parsed_responses, parsed_response)
        end
    end

    datetime_format = "yyyy-mm-ddTHH:MM:SSZ"

    cols = [
    "id",
    "name",
    "description",
    "rows",
    "columns",
    "createdAt",
    "updatedAt"
    ]

    dataset_dataframe = map(cols) do id_col
        if id_col in ["createdAt", "dataCurrentAt", "updatedAt"]
            (id_col => [DateTime(ds[id_col], datetime_format) for ds in parsed_responses])
        else
            (id_col => [try ds[id_col] catch KeyError missing end for ds in parsed_responses])
        end
    end |> DataFrame

    return dataset_dataframe
end
