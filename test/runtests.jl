using JuDOMO
using Test
using DataFrames
import JuDOMO: match_domo_types, create_dataset_schema
import JSON: json

test_schema = Dict(
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

test_dataset = DataFrame(
    "Friend" => ["Pythagoras", "Alan Turing", "George Boole"],
    "Attending" => ["TRUE", "TRUE", "FALSE"]
)

@testset "JuDOMO.jl" begin
    ## test whether create_dataset_schema() creates the correct structure on a simple dataset.
    @test create_dataset_schema(test_dataset, "Leonhard Euler Party", "Mathematician guest list.") == test_schema
end
