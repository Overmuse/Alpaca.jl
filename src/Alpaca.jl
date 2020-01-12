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
    get_order,
    get_orders,
    get_positions,
    submit_order,
    cancel_order,
    cancel_orders
import HTTP, JSON

const PAPER_URL = "https://paper-api.alpaca.markets/v2"
const LIVE_URL = "https://api.alpaca.markets/v2"
const DATA_URL = "https://data.alpaca.markets/v1"

struct AlpacaBrokerage <: AbstractBrokerage
    id
    key
end

function Base.show(io::IO, b::AlpacaBrokerage)
    print(io, "AlpacaBrokerage($(b.id), $(b.key[1:10])" * "*"^30 * ")")
end

function alpaca_url(;live::Bool = false)
    if live
        LIVE_URL
    else
        PAPER_URL
    end
end

function alpaca_headers(x::AlpacaBrokerage)
    Dict(
        "APCA-API-KEY-ID" => x.id,
        "APCA-API-SECRET-KEY" => x.key
    )
end

# function alpaca_headers(;live::Bool = false)
#     if live
#         b = AlpacaBrokerage(
#             ENV["APCA-LIVE-API-KEY-ID"],
#             ENV["APCA-LIVE-API-SECRET-KEY"]
#         )
#     else
#         b = AlpacaBrokerage(
#             ENV["APCA-API-KEY-ID"],
#             ENV["APCA-API-SECRET-KEY"]
#         )
#     end
#     alpaca_headers(b)
# end

function alpaca_get(api::AlpacaBrokerage, endpoint::String, params = Dict(), body = ""; live::Bool = false)
    url = alpaca_url(live = live)
    headers = alpaca_headers(api)
    sleep(0.3) # 200 requests / minute limit
    result = HTTP.get(url * endpoint, headers, JSON.json(body), query = params)
    !HTTP.iserror(result) && JSON.parse(String(result.body))
end

function alpaca_post(api::AlpacaBrokerage, endpoint::String, body; live::Bool = false)
    url = alpaca_url(live = live)
    headers = alpaca_headers(api)
    sleep(0.3) # 200 requests / minute limit
    result = HTTP.post(url * endpoint, headers, JSON.json(body))
    !HTTP.iserror(result) && JSON.parse(String(result.body))
end

function alpaca_delete(api::AlpacaBrokerage, endpoint::String; live::Bool = false)
    url = alpaca_url(live = live)
    headers = alpaca_headers(api)
    sleep(0.3) # 200 requests / minute limit
    result = HTTP.delete(url * endpoint, headers)
    !HTTP.iserror(result) && return
end

function alpaca_market_get(api::AlpacaBrokerage, endpoint::String, params = Dict(), body = "")
    url = DATA_URL
    headers = alpaca_headers(api)
    sleep(0.3) # 200 requests / minute limit
    result = HTTP.get(url * endpoint, headers, JSON.json(body), query = params)
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
