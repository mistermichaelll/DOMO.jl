# DOMO.jl
DOMO.jl is a Julia interface to the Domo API.

The long-term vision is to create a package which mimics the functionality of the (seemingly-abandoned) DomoR package in Julia.

# Getting Started
## Installation

Install the package from GitHub via `Pkg`.

```julia
julia> ]
pkg> add "https://github.com/mistermichaelll/DOMO.jl"
```

## Using the Package

You will need a `client_id` and a `client_secret` from the Domo Developer Portal.

You can get up and running with an access token by using the `DOMO_auth()` function. This function sets a global variable called `domo` accessible by the package's internal functions.

```julia
using DOMO

DOMO_auth(client_id, client_secret)
#> Authentication complete.
```

## What can I do with the package?
Right now, not a ton... 😅 but you can create and replace datasets straight from Julia, as well as get a `DataFrame` containing a list of all datasets in your Domo instance.

```julia
using CSV
using DataFrames
using DOMO

url = "https://gist.githubusercontent.com/seankross/a412dfbd88b3db70b74b/raw/5f23f993cd87c283ce766e7ac6b329ee7cc2e1d1/mtcars.csv"
mtcars = CSV.read(download(url), DataFrame)

DOMO_auth(client_id, client_secret)
#> Authentication complete.

create_dataset(
    mtcars;
    name = "Julia | mtcars",
    description = "uploading the mtcars dataset from Julia.
)
#> Dataset uploaded to Domo: ID is some-string-of-numbers.
```


[![Build Status](https://github.com/mistermichaelll/DOMO.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mistermichaelll/DOMO.jl/actions/workflows/CI.yml?query=branch%3Amain)
