export AlpacaPosition, get_positions, get_position, close_positions, close_position

struct AlpacaPosition <: AbstractPosition
    asset_id::UUID
    symbol::String
    exchange::String
    asset_class::String
    avg_entry_price::Float64
    quantity::Int
    side::String
    market_value::Float64
    cost_basis::Float64
    unrealized_pl::Float64
    unrealized_plpc::Float64
    unrealized_intraday_pl::Float64
    unrealized_intraday_plpc::Float64
    current_price::Float64
    lastday_price::Float64
    change_today::Float64
end

function AlpacaPosition(d::Dict)
    AlpacaPosition(
        UUID(d["asset_id"]),
        d["symbol"],
        d["exchange"],
        d["asset_class"],
        parse(Float64, d["avg_entry_price"]),
        parse(Int, d["qty"]),
        d["side"],
        parse(Float64, d["market_value"]),
        parse(Float64, d["cost_basis"]),
        parse(Float64, d["unrealized_pl"]),
        parse(Float64, d["unrealized_plpc"]),
        parse(Float64, d["unrealized_intraday_pl"]),
        parse(Float64, d["unrealized_intraday_plpc"]),
        parse(Float64, d["current_price"]),
        parse(Float64, d["lastday_price"]),
        parse(Float64, d["change_today"])
    )
end

Base.show(io::IO, p::AlpacaPosition) = print(io, "Position: $(p.symbol)")

function Base.show(io::IO, ::MIME"text/plain", p::AlpacaPosition)
    println(io, rpad(lpad("Position", 26), 46))
    println(io, "-"^46)
    for property in propertynames(p)[1:end-1]
        print(io, string(property) * ":")
        println(io, lpad(something(getproperty(p, property), "null"), 45 - length(string(property))))
    end
    print(io, string(propertynames(p)[end]) * ":")
    print(io, lpad(something(getproperty(p, propertynames(p)[end]), "null"), 45 - length(string(propertynames(p)[end]))))
end

function get_positions(api::AlpacaBrokerage)
    positions = AlpacaPosition.(alpaca_get(api, "/positions"))
end

function get_position(api::AlpacaBrokerage, ticker)
    positions = AlpacaPosition(alpaca_get(api, "/positions/$ticker"))
end

function close_positions(api::AlpacaBrokerage)
    positions = alpaca_delete(api, "/positions")
end

function close_position(api::AlpacaBrokerage, ticker)
    positions = alpaca_delete(api, "/positions/$ticker")
end
