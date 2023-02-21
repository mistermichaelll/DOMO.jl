"""
    match_domo_types(type)

This function helps match types in Julia to those accepted by the Domo API.

This is an internal function used by the package, it may come in handy if you're trying to extend the API.
"""
function match_domo_types(type)
    if type <: AbstractString || type <: Union{AbstractString, Missing} || type <: Bool || type == Union{Bool, Missing}
        "STRING"
    elseif type <: Integer || type <: Union{Integer, Missing}
        "LONG"
    elseif type <: AbstractFloat || type <: Union{AbstractFloat, Missing}
        "DOUBLE"
    elseif type <: Dates.Date || type <: Union{Dates.Date, Missing}
        "DATE"
    elseif type <: Dates.DateTime || type <: Union{Dates.DateTime, Missing}
        "DATETIME"
    end
end

"""
    create_dataset_schema(df, name, description)

Creates a dataset schema for a given DataFrame. This is an internal function, but may be useful if you are extending the Domo API in Julia.
"""
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

    return JSON3.write(schema)
end

function create_csv_string(row, col_num)
    csv_string = string(ifelse(ismissing(row[col_num]), "", row[col_num]))

    if occursin(",", csv_string)
        csv_string = "\"" * csv_string * "\""
    end

    return csv_string
end

"""
    create_csv_structure(df)

This function creates a CSV, in the form of a single string, from a DataFrame to send to Domo.
"""
function create_csv_structure(df)
    csv_data = ""

    for row in eachrow(df), col_num in 1:ncol(df)
        if col_num < ncol(df) && rownumber(row) < nrow(df)
            csv_data = csv_data * create_csv_string(row, col_num) * ","
        elseif col_num == ncol(df) && rownumber(row) < nrow(df)
            csv_data = csv_data * create_csv_string(row, col_num) * "\n"
        elseif col_num < ncol(df) && rownumber(row) == nrow(df)
            csv_data = csv_data * create_csv_string(row, col_num) * ","
        elseif col_num == ncol(df) && rownumber(row) == nrow(df)
            csv_data = csv_data * create_csv_string(row, col_num) * "\n"
        end
    end

    return csv_data
end

function push_schema_to_domo(dataset_schema)
    response = request(
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
