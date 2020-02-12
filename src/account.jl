export AlpacaAccount, get_account, get_account_configurations, get_equity
# Structs ----------------------------------------------------------------------------------
struct AlpacaAccount{T <: AbstractFloat} <: AbstractAccount
    id                      :: UUID
    status                  :: String
    currency                :: String
    cash                    :: T
    portfolio_value         :: T
    pattern_day_trader      :: Bool
    trade_suspended_by_user :: Bool
    trading_blocked         :: Bool
    transfers_blocked       :: Bool
    account_blocked         :: Bool
    created_at              :: DateTime
    shorting_enabled        :: Bool
    long_market_value       :: T
    short_market_value      :: T
    equity                  :: T
    last_equity             :: T
    multiplier              :: T
    buying_power            :: T
    initial_margin          :: T
    maintenance_margin      :: T
    sma                     :: T
    daytrade_count          :: Int
    last_maintenance_margin :: T
    daytrading_buying_power :: T
    regt_buying_power       :: T
end

function AlpacaAccount(d::Dict)
    f(x) = parse(Float64, x)
    AlpacaAccount(
        UUID(d["id"]),
        d["status"],
        d["currency"],
        d["cash"] |> f,
        d["portfolio_value"] |> f,
        d["pattern_day_trader"],
        d["trade_suspended_by_user"],
        d["trading_blocked"],
        d["transfers_blocked"],
        d["account_blocked"],
        parse(DateTime, d["created_at"][1:19]),
        d["shorting_enabled"],
        d["long_market_value"] |> f,
        d["short_market_value"] |> f,
        d["equity"] |> f,
        d["last_equity"] |> f,
        d["multiplier"] |> f,
        d["buying_power"] |> f,
        d["initial_margin"] |> f,
        d["maintenance_margin"] |> f,
        d["sma"] |> f,
        d["daytrade_count"],
        d["last_maintenance_margin"] |> f,
        d["daytrading_buying_power"] |> f,
        d["regt_buying_power"] |> f
    )
end

Base.show(io::IO, a::AlpacaAccount) = print(io, "Account: $(a.id)")

function Base.show(io::IO, ::MIME"text/plain", a::AlpacaAccount)
    println(io, rpad(lpad("Account", 23), 40))
    println(io, "-"^40)
    for property in propertynames(a)[1:end-1]
        print(io, string(property) * ":")
        println(io, lpad(getproperty(a, property), 39 - length(string(property))))
    end
    print(io, string(propertynames(a)[end]) * ":")
    print(io, lpad(something(getproperty(a, propertynames(a)[end]), "null"), 39 - length(string(propertynames(a)[end]))))
end

# Functions --------------------------------------------------------------------------------

function get_account(api::AlpacaBrokerage)
    alpaca_get(api, "/account") |> AlpacaAccount
end

function get_account_configurations(api::AlpacaBrokerage)
    alpaca_get(api, "/account/configurations")
end

function get_equity(api::AlpacaBrokerage)
    get_account(api).equity
end
