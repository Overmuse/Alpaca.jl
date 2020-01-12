export AlpacaCalendar, get_calendar

# Structs ----------------------------------------------------------------------------------
struct AlpacaCalendar
    date
    open
    close
end

function AlpacaCalendar(d::Dict)
    AlpacaCalendar(
        d["date"],
        d["open"],
        d["close"]
    )
end

Base.show(io::IO, c::AlpacaCalendar) = print(io, c.date)
function Base.show(io::IO, ::MIME"text/plain", c::AlpacaCalendar)
    println(io, rpad(lpad("Calendar", 14), 20))
    println(io, "-"^20)
    for property in propertynames(c)[1:end-1]
        print(io, string(property) * ":")
        println(io, lpad(getproperty(c, property), 19 - length(string(property))))
    end
    print(io, string(propertynames(c)[end]) * ":")
    print(io, lpad(something(getproperty(c, propertynames(c)[end]), "null"), 19 - length(string(propertynames(c)[end]))))
end
# Functions --------------------------------------------------------------------------------

function get_calendar(api::AlpacaBrokerage; start_date = "", end_date = "")
    params = Dict(:start => string(start_date),
                  :end   => string(end_date))
    AlpacaCalendar.(alpaca_get(api, "/calendar", params))
end
