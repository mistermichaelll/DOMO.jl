using DataFrames: DataFrame
using CSV
"""
    match_domo_types(type)

This function helps match types in Julia to those accepted by the Domo API.

This is an internal function used by the package, it may come in handy if you're trying to extend the API.
"""
function match_domo_types(type)
    if type <: AbstractString || type <: Union{AbstractString, Missing} || type <: Bool || type <: Union{Bool, Missing}
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

"""
    dataframe_to_csv

Convert a Julia DataFrame to a CSV string for the API.
"""
function dataframe_to_csv(df::DataFrame)
    io = IOBuffer()
    io_file = CSV.write(io, df; header = false)
    csv_string = String(take!(io_file))
    close(io)
    return csv_string
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
