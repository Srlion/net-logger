originalSendToServer = originalSendToServer or net.SendToServer
originalSend = originalSend or net.Send
originalBroadcast = originalBroadcast or net.Broadcast
originalReceive = originalReceive or net.Receive
originalStart = originalStart or net.Start

local current_message_name = "none"
function net.Start(message_name, ...)
    current_message_name = message_name
    return originalStart(message_name, ...)
end

if CLIENT then
    function net.SendToServer()
        local bytes = net.BytesWritten()

        print(string.format("[NetLogger] Sent to server: %s (%d bytes)", current_message_name, bytes))

        return originalSendToServer()
    end
end

if SERVER then
    function net.Send(ply)
        local bytes = net.BytesWritten()
        local target = IsEntity(ply) and ply:Nick() or "Multiple Players"

        print(string.format("[NetLogger] Sent to %s: %s (%d bytes)", target, current_message_name, bytes))

        return originalSend(ply)
    end

    function net.Broadcast()
        local bytes = net.BytesWritten()

        print(string.format("[NetLogger] Broadcast: %s (%d bytes)", current_message_name, bytes))

        return originalBroadcast()
    end
end

function net.Receive(message_name, callback)
    local wrapped_callback
    if callback then
        wrapped_callback = function(bits, ply)
            local sender = SERVER and (IsValid(ply) and ply:Nick() or "Unknown") or "Server"
            local bytes = math.ceil(bits / 8)
            print(string.format("[NetLogger] Received from %s: %s (%d bytes)", sender, message_name, bytes))

            return callback(bits, ply)
        end
    end

    return originalReceive(message_name, wrapped_callback or callback)
end
