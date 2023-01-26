# function to match Julia's types to Domo's
function match_domo_types(type::DataType)
    if type == String # yes, I will expand this eventually...;)
        "STRING"
    end
end

# function to set up the dataset schema from a dataframe in the proper format for pushing
#  the result to Domo.
function create_dataset_schema(df::DataFrame, name, description)
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
