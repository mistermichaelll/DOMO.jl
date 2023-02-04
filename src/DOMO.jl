module DOMO
include("authentication.jl")
include("datasets.jl")
include("utils.jl")

import HTTP: request, iserror
import JSON: parse, json
import Base64: base64encode
import DataFrames: nrow, ncol, rownumber, eachrow, eachcol
using Dates

export DOMO_auth
export create_dataset
export replace_dataset
export list_datasets

end
