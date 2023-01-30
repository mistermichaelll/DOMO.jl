using DOMO
using Test
include("test-sets/schema-tests.jl")

@testset "Schemas" begin
    # test whether create_dataset_schema() creates the correct structure on a simple dataset
    @test create_dataset_schema(
        schema_test_mathematicians_dataset,
        "Leonhard Euler Party",
        "Mathematician guest list."
    ) == schema_test_mathematicians
    # test whether schema accounts for nulls
    @test create_dataset_schema(
        null_schema_test_df,
        "The Crows Outside My Apartment",
        "A partial list of friends."
    ) == schema_test_nulls
    # test whether types match
    #  (note that mapping here runs multiple tests)
    map(1:length(types)) do type
        @test match_domo_types(types[type]) == expected_types[type]
    end
    # test whether behavior of csv creator is valid
    @test create_csv_structure(schema_test_mathematicians_dataset) == test_csv_string
end;
