#= Serial port communication occurs in a continuous stream of characters. 
To group characters in message units, we employ the special character "<" and ">".
Arduino code recognise "<" and ">" has message begin and close, respectively =#

#this function group integer values in a message for arduino
function send_m(port,what::Int64)
    w = string(what)
    write(port,"<"*w*">")
end

# this function group each entry of a integer vector in a message for arduino
function send_m(port,what::Vector{Int64})
    for x in what
        send_m(port,x)
    end
    sleep(1)
end