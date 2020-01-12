export AlpacaOrder, get_order, get_orders, submit_order, cancel_order, cancel_orders

# Structs ----------------------------------------------------------------------------------

struct AlpacaOrder <: AbstractOrder
    id
    client_order_id
    created_at
    updated_at
    submitted_at
    filled_at
    expired_at
    canceled_at
    failed_at
    asset_id
    symbol
    asset_class
    qty
    filled_qty
    type
    side
    time_in_force
    limit_price
    stop_price
    filled_avg_price
    status
    extended_hours
end

function AlpacaOrder(d::Dict)
    AlpacaOrder(
        UUID(d["id"]),
        d["client_order_id"],
        alpaca_date_to_datetime(d["created_at"]),
        alpaca_date_to_datetime(d["updated_at"]),
        alpaca_date_to_datetime(d["submitted_at"]),
        alpaca_date_to_datetime(d["filled_at"]),
        alpaca_date_to_datetime(d["expired_at"]),
        alpaca_date_to_datetime(d["canceled_at"]),
        alpaca_date_to_datetime(d["failed_at"]),
        UUID(d["asset_id"]),
        d["symbol"],
        d["asset_class"],
        parse(Int, d["qty"]),
        parse(Int, d["filled_qty"]),
        d["type"],
        d["side"],
        d["time_in_force"],
        d["limit_price"],
        d["stop_price"],
        d["filled_avg_price"],
        d["status"],
        d["extended_hours"]
    )
end

function status_color(status)
    mapping = Dict(
        "new" => :blue,
        "filled" => :green,
        "partially_filled" => :light_cyan,
        "done_for_day" => :light_cyan,
        "canceled" => :yellow,
        "expired" => :red
    )
    if status in keys(mapping)
        return mapping[status]
    else
        return :default
    end
end

function Base.show(io::IO, o::AlpacaOrder)
    color = get(io, :color, false)
    if color
        status = o.status
        printstyled(io, "Order: $(o.id)", color = status_color(status))
    else
        print(io, "Order: $(o.id)")
    end
end

function Base.show(io::IO, ::MIME"text/plain", o::AlpacaOrder)
    println(io, rpad(lpad("Order", 29), 53))
    println(io, "-"^53)
    for property in propertynames(o)[1:end-1]
        print(io, string(property) * ":")
        println(io, lpad(something(getproperty(o, property), "null"), 52 - length(string(property))))
    end
    print(io, string(propertynames(o)[end]) * ":")
    print(io, lpad(something(getproperty(o, propertynames(o)[end]), "null"), 52 - length(string(propertynames(o)[end]))))
end

# Functions --------------------------------------------------------------------------------

function get_order(api::AlpacaBrokerage, id::UUID; live = false)
    AlpacaOrder(alpaca_get(api, "/orders/" * string(id), Dict(), live = live))
end

function get_order(api::AlpacaBrokerage, client_order_id::String; live = false)
    AlpacaOrder(alpaca_get(api, "/orders:by_client_order_id", Dict(:client_order_id => client_order_id), live = live))
end

function get_orders(api::AlpacaBrokerage; status = "open", limit = 50, after = "", until = "", direction = "desc", live = false)
    params = Dict(:status => status,
                  :limit => limit,
                  :after => after,
                  :until => until,
                  :direction => direction)
    AlpacaOrder.(alpaca_get(api, "/orders", params, live = live))
end

JSON.lower(::DAY) = "day"
JSON.lower(::GTC) = "gtc"
JSON.lower(::OPG) = "opg"
JSON.lower(::CLS) = "cls"
JSON.lower(::IOC) = "ioc"
JSON.lower(::FOK) = "fok"
JSON.lower(::MarketOrder) = "market"

function submit_order(api::AlpacaBrokerage, ticker, quantity::Integer, type; time_in_force::AbstractOrderDuration = DAY(), extended_hours = false, client_order_id = nothing, live = false)
    side = quantity >= 0 ? "buy" : "sell"
    body = Dict(:symbol => ticker,
                :qty => abs(quantity),
                :side => side,
                :type => type,
                :time_in_force => time_in_force,
                :limit_price => limit_price(type),
                :stop_price => stop_price(type),
                :extended_hours => extended_hours,
                :client_order_id => client_order_id)
    alpaca_post(api, "/orders", body, live = live) |> AlpacaOrder
end

function cancel_order(api::AlpacaBrokerage, id::UUID; live = false)
    alpaca_delete(api, "/orders/" * string(id), live = live)
end

function cancel_orders(api::AlpacaBrokerage; live = false)
    alpaca_delete(api, "/orders", live = live)
end
