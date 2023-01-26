using JuDOMO
using Test
using DataFrames
include("test-sets/schema-tests.jl")

@testset "JuDOMO.jl" begin
    ## test whether create_dataset_schema() creates the correct structure on a simple dataset.
    @test create_dataset_schema(
        schema_test_mathematicians_dataset,
        "Leonhard Euler Party",
        "Mathematician guest list."
    ) == schema_test_mathematicians
end
