export AlpacaBar, get_bars

struct AlpacaBar{F<:AbstractFloat, I<:Integer}
    t :: I
    o :: F
    h :: F
    l :: F
    c :: F
    v :: I
end

function AlpacaBar(d::Dict)
    AlpacaBar(
        d["t"],
        d["o"] |> float,
        d["h"] |> float,
        d["l"] |> float,
        d["c"] |> float,
        d["v"]
    )
end

Base.show(io::IO, a::AlpacaBar) = print(io, a.c)

function Base.show(io::IO, ::MIME"text/plain", b::AlpacaBar)
    println(io, rpad(lpad("Bar", 22), 40))
    println(io, "-"^40)
    print(io, "Time:"); println(io, lpad(string(b.t) * " (" * string(unix2datetime(b.t)) * ")", 35))
    print(io, "Open:"); println(io, lpad(b.o, 35))
    print(io, "High:"); println(io, lpad(b.h, 35))
    print(io, "Low:"); println(io, lpad(b.l, 36))
    print(io, "Close:"); println(io, lpad(b.c, 34))
    print(io, "Volume:"); print(io, lpad(b.v, 33))
end

function get_bars(api::AlpacaBrokerage, symbols::AbstractVector{<:AbstractString}, timeframe; limit = 100, start_time = nothing, end_time = nothing, after = nothing, until = nothing)
    params = Dict(:symbols => join(symbols, ','),
                  :limit   => limit)
    for param in [start_time, end_time, after, until]
        !isnothing(param) && merge!(params, param)
    end
    result = alpaca_market_get(api, "/bars/$timeframe", params)
    Dict(k => AlpacaBar.(v) for (k, v) in result)
end
