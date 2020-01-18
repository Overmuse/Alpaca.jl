export AlpacaPosition, get_positions, get_position, close_positions, close_position

struct AlpacaPosition <: AbstractPosition
    asset_id
    symbol
    exchange
    asset_class
    avg_entry_price
    qty
    side
    market_value
    cost_basis
    unrealized_pl
    unrealized_plpc
    unrealized_intraday_pl
    unrealized_intraday_plpc
    current_price
    lastday_price
    change_today
end

function AlpacaPosition(d::Dict)
    AlpacaPosition(
        UUID(d["asset_id"]),
        d["symbol"],
        d["exchange"],
        d["asset_class"],
        d["avg_entry_price"],
        d["qty"],
        d["side"],
        d["market_value"],
        d["cost_basis"],
        d["unrealized_pl"],
        d["unrealized_plpc"],
        d["unrealized_intraday_pl"],
        d["unrealized_intraday_plpc"],
        d["current_price"],
        d["lastday_price"],
        d["change_today"]
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
