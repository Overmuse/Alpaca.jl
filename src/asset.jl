export AlpacaAsset, get_assets, get_asset

# Structs ----------------------------------------------------------------------------------
struct AlpacaAsset
    id             :: UUID
    class          :: String
    exchange       :: String
    symbol         :: String
    status         :: String
    tradable       :: Bool
    marginable     :: Bool
    shortable      :: Bool
    easy_to_borrow :: Bool
end

function AlpacaAsset(d::Dict)
    AlpacaAsset(
        UUID(d["id"]),
        d["class"],
        d["exchange"],
        d["symbol"],
        d["status"],
        d["tradable"],
        d["marginable"],
        d["shortable"],
        d["easy_to_borrow"]
    )
end

Base.show(io::IO, a::AlpacaAsset) = print(io, a.symbol)

function Base.show(io::IO, ::MIME"text/plain", a::AlpacaAsset)
    println(io, rpad(lpad("Asset", 22), 40))
    println(io, "-"^40)
    for property in propertynames(a)[1:end-1]
        print(io, string(property) * ":")
        println(io, lpad(getproperty(a, property), 39 - length(string(property))))
    end
    print(io, string(propertynames(a)[end]) * ":")
    print(io, lpad(something(getproperty(a, propertynames(a)[end]), "null"), 39 - length(string(propertynames(a)[end]))))
end

# Functions --------------------------------------------------------------------------------

function get_assets(api::AlpacaBrokerage; status = nothing, asset_class = "us_equity")
    params = Dict(:asset_class => asset_class)
    if !isnothing(status)
        merge!(params, Dict(:status => status))
    end
    AlpacaAsset.(alpaca_get(api::AlpacaBrokerage, "/assets", params))
end

function get_asset(api::AlpacaBrokerage, symbol::String)
    AlpacaAsset(alpaca_get(api, "/assets/$symbol"))
end

function get_asset(api::AlpacaBrokerage, id::UUID)
    AlpacaAsset(alpaca_get(api, "/assets/" * string(id)))
end
