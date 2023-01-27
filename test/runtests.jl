using JuDOMO
using Test
include("test-sets/schema-tests.jl")

@testset "JuDOMO.jl" begin
    # test whether create_dataset_schema() creates the correct structure on a simple dataset
    @test create_dataset_schema(
        schema_test_mathematicians_dataset,
        "Leonhard Euler Party",
        "Mathematician guest list."
    ) == schema_test_mathematicians
    # test whether types match
    #  (note that mapping here runs multiple tests)
    map(1:length(types)) do type
        @test match_domo_types(types[type]) == expected_types[type]
    end
end
