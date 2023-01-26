module JuDOMO
include("authentication.jl")
include("datasets.jl")
include("utils.jl")

import HTTP: request, iserror
import JSON: parse, json
import Base64: base64encode
import DataFrames: DataFrame, nrow, ncol
import CSV: write

export DOMO_auth
export create_dataset
export replace_dataset

end
