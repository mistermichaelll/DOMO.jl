# function to match Julia's types to Domo's
#  according to Docs, accepted values are STRING, DECIMAL, LONG, DOUBLE, DATE, and DATETIME.
function match_domo_types(type::DataType)
    if type == String # yes, I will expand this eventually...;)
        "STRING"
    elseif type in [Int64, Int32]
        "LONG"
    elseif type in [Float64, Float32]
        "DOUBLE"
    elseif type == Dates.Date
        "DATE"
    elseif type == Dates.DateTime
        "DATETIME"
    end
end

# function to set up the dataset schema from a dataframe in the proper format for pushing
#  the result to Domo.
function create_dataset_schema(df, name, description)
    column_schema = Dict(
        "columns" => map(1:ncol(df)) do column
            Dict(
                "type" => eltype(df[!, column]) |> match_domo_types,
                "name" => names(df)[column]
            )
        end
    )

    schema = Dict(
        "name" => name,
        "description" => description,
        "rows" => nrow(df),
        "schema" => column_schema
    )

    json(schema)
end

## send the schema to Domo.
function push_schema_to_domo(dataset_schema)
    request(
        "POST",
        "https://api.domo.com/v1/datasets",
        [
            "Content-Type" => "application/json",
            "Accept" => "application/json",
            "Authorization" => "bearer " * domo["access_token"]
        ],
        dataset_schema
    )
end
