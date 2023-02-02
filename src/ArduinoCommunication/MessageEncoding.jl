function send_m(port,what::Int64)
    w = string(what)
    write(port,"<"*w*">")
end

function send_m(port,what::Vector{Int64})
    for x in what
        send_m(port,x)
    end
    sleep(1)
end