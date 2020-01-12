# Alpaca.jl 🦙

`Alpaca.jl` is an unofficial SDK for the online brokerage [Alpaca](https://alpaca.markets/).

## Getting started
`Alpaca.jl` sources credentials for all API calls from `ENV`. You can set your credentials
by adding the following to lines to your `~/.julia/config/startup.jl`:
```
ENV["APCA-API-KEY-ID"] = "YOUR_API_KEY"
ENV["APCA-API-SECRET-KEY"] = "YOUR_SECRET_KEY"
```

The above will allow you full functionality for your paper-trading account. Once you're
ready to use `Alpaca.jl` for live trading, you can set your live-trading keys using:
```
ENV["APCA-LIVE-API-KEY-ID"] = "YOUR_LIVE_API_KEY"
ENV["APCA-LIVE-API-SECRET-KEY"] = "YOUR_LIVE_SECRET_KEY"
```
and calling the `Alpaca.jl` functions with the key-word parameter `live = true`
