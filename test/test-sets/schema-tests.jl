import JuDOMO: match_domo_types, create_dataset_schema
import JSON: json

## test sets for matching Julia's types to Domo's
types = [Int32, Int64, Float32, Float64, String]
expected_types = ["DOUBLE", "DOUBLE", "DECIMAL", "DECIMAL", "STRING"]

## test sets for schema creation
schema_test_mathematicians = Dict(
    "name" => "Leonhard Euler Party",
    "description" => "Mathematician guest list.",
    "rows" => 3,
    "schema" => Dict(
        "columns" => [ Dict(
            "type" => "STRING",
            "name" => "Friend"
        ), Dict(
            "type" => "STRING",
            "name" => "Attending"
        ) ]
    )
) |> json

schema_test_mathematicians_dataset = DataFrame(
    "Friend" => ["Pythagoras", "Alan Turing", "George Boole"],
    "Attending" => ["TRUE", "TRUE", "FALSE"]
)
