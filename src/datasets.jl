include("schema.jl")

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

function list_datasets(;limit = 50, name = "", offset = 0, owner_id = "", order_by = "")
    if !(@isdefined domo)
        error("Please run the DOMO_auth() function to generate an access token.")
    end

    if limit > 50
        limit = 50
        @warn "Using a maximum request limit of 50."
    end

    if !isempty(order_by) && !(order_by in ["name", "lastTouched", "lastUpdated", "cardCount", "cardViewCount"])
        error("Invalid order_by parameter '$order_by', valid options are: 'name', 'lastTouched', 'lastUpdated', 'cardCount', 'cardViewCount'")
    end

    limit_param = "&limit=" * string(ifelse(limit < 1, 50, limit))

    name_param = ifelse(!isempty(name), "&nameLike=" * name, "")

    owner_id_param = ifelse(!isempty(owner_id), "&ownerID=" * owner_id, "")

    order_by_param = ifelse(!isempty(order_by), "&orderBy=" * order_by, "")

    offset_param = "&offset=" * string(offset)

    url = "https://api.domo.com/v1/datasets?"

    access_token = domo["access_token"]

    response = request(
        "GET",
        url * limit_param * order_by_param * name_param * offset_param,
        ["Accept" => "application/json", "Authorization" => "bearer " * access_token]
    )

    parsed_response = parse_HTTP_response(response)

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
            (id_col => [DateTime(ds[id_col], datetime_format) for ds in parsed_response])
        else
            (id_col => [try ds[id_col] catch KeyError missing end for ds in parsed_response])
        end
    end |> DataFrame

    return dataset_dataframe
end
