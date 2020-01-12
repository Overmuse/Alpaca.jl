export AlpacaClock, get_clock

# Structs ----------------------------------------------------------------------------------
"""
    AlpacaClock

## Fields
- `timestamp`  :: String
- `is_open`    :: Bool
- `next_open`  :: DateTime
- `next_close` :: DateTime
"""
struct AlpacaClock
    timestamp  :: String
    is_open    :: Bool
    next_open  :: DateTime
    next_close :: DateTime
end

function AlpacaClock(d::Dict)
    AlpacaClock(
        d["timestamp"],
        d["is_open"],
        parse(DateTime, d["next_open"][1:19]),
        parse(DateTime, d["next_close"][1:19])
    )
end

Base.show(io::IO, c::AlpacaClock) = print(io, c.timestamp)
function Base.show(io::IO, ::MIME"text/plain", c::AlpacaClock)
    println(io, rpad(lpad("Clock", 25), 46))
    println(io, "-"^46)
    for property in propertynames(c)[1:end-1]
        print(io, string(property) * ":")
        println(io, lpad(getproperty(c, property), 45 - length(string(property))))
    end
    print(io, string(propertynames(c)[end]) * ":")
    print(io, lpad(something(getproperty(c, propertynames(c)[end]), "null"), 45 - length(string(propertynames(c)[end]))))
end

# Functions --------------------------------------------------------------------------------

"""
    get_clock()

Returns the market clock, [`AlpacaClock`](@ref).
"""
function get_clock(api::AlpacaBrokerage)
    alpaca_get(api, "/clock") |> AlpacaClock
end
