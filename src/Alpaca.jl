module Alpaca

using UUIDs: UUID
using Dates: DateTime, unix2datetime
using TradingBase:
    AbstractAccount,
    AbstractBrokerage,
    AbstractOrder,
    AbstractOrderDuration,
    AbstractPosition,
    OrderIntent,
    MarketOrder,
    LimitOrder,
    StopLimitOrder,
    StopOrder,
    DAY,
    GTC,
    OPG,
    CLS,
    IOC,
    FOK,
    limit_price,
    stop_price

import TradingBase:
    get_account,
    get_equity,
    get_order,
    get_orders,
    get_position,
    get_positions,
    submit_order,
    cancel_order,
    cancel_orders,
    close_position,
    close_positions
import HTTP, JSON

export get_credentials

const PAPER_URL = "https://paper-api.alpaca.markets/v2"
const LIVE_URL = "https://api.alpaca.markets/v2"
const DATA_URL = "https://data.alpaca.markets/v1"

struct AlpacaBrokerage <: AbstractBrokerage
    id
    key
    url
end

function Base.show(io::IO, b::AlpacaBrokerage)
    print(io, "AlpacaBrokerage($(b.id), $(b.key[1:10])" * "*"^30 * ", $(b.url))")
end

alpaca_url(api) = api.url

function get_credentials(;live = false)
    if live
        return AlpacaBrokerage(
            ENV["APCA-LIVE-KEY-ID"],
            ENV["APCA-LIVE-SECRET-KEY"],
            LIVE_URL
        )
    else
        return AlpacaBrokerage(
            ENV["APCA-PAPER-KEY-ID"],
            ENV["APCA-PAPER-SECRET-KEY"],
            PAPER_URL
            )
    end
end

function alpaca_headers(x::AlpacaBrokerage)
    Dict(
        "APCA-API-KEY-ID" => x.id,
        "APCA-API-SECRET-KEY" => x.key
    )
end

function alpaca_get(api::AlpacaBrokerage, endpoint::String, params = Dict(), body = "")
    headers = alpaca_headers(api)
    sleep(0.3) # 200 requests / minute limit
    result = HTTP.get(alpaca_url(api) * endpoint, headers, JSON.json(body), query = params)
    !HTTP.iserror(result) && JSON.parse(String(result.body))
end

function alpaca_post(api::AlpacaBrokerage, endpoint::String, body)
    headers = alpaca_headers(api)
    sleep(0.3) # 200 requests / minute limit
    result = HTTP.post(alpaca_url(api) * endpoint, headers, JSON.json(body))
    !HTTP.iserror(result) && JSON.parse(String(result.body))
end

function alpaca_delete(api::AlpacaBrokerage, endpoint::String)
    headers = alpaca_headers(api)
    sleep(0.3) # 200 requests / minute limit
    result = HTTP.delete(alpaca_url(api) * endpoint, headers)
    !HTTP.iserror(result) && return
end

function alpaca_market_get(api::AlpacaBrokerage, endpoint::String, params = Dict(), body = "")
    headers = alpaca_headers(api)
    sleep(0.3) # 200 requests / minute limit
    result = HTTP.get(DATA_URL * endpoint, headers, JSON.json(body), query = params)
    !HTTP.iserror(result) && JSON.parse(String(result.body))
end

function alpaca_date_to_datetime(x::String)
    y, m, d, h, mi, s, ms = map(y -> parse(Int, x[y]), [1:4, 6:7, 9:10, 12:13, 12:13, 18:19, 21:23])
    DateTime(y, m, d, h, mi, s, ms)
end

function alpaca_date_to_datetime(x::Nothing)
    nothing
end

include("clock.jl")
include("calendar.jl")
include("asset.jl")
include("order.jl")
include("account.jl")
include("position.jl")
include("bars.jl")
end
