function replace_dataset(dataset_id::String, df::DataFrame)
    if !(@isdefined domo)
        error("Please run the DOMO_auth() function.")
    end

    access_token = domo["access_token"]

    io = IOBuffer()

    write(io, df; newline = "\n", writeheader = false)

    data = String(io.data)

    response = request(
        "PUT",
        "https://api.domo.com/v1/datasets/" * dataset_id * "/data",
        ["Content-Type" => "text/csv", "Authorization" => "bearer " * access_token],
        data;
        status_exception = false
    )

    if iserror(response)
        error("Dataset update was unsuccessful.")
    end

    println("Dataset update successful.")

end
