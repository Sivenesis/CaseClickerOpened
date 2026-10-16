local socket = require("socket")
local Packet = require("net.packet")
local Connection = require("net.connection")
local JackpotProtocol = {}
JackpotProtocol.callbackTable = {}
JackpotProtocol.connection = Connection.new()
function JackpotProtocol.login()
	local packet = Packet.new()
	packet:addInt8(OutgoingJackpotPacket.login)
	packet:addInt8(NetHub.jackpotVersion)
	packet:addString(Game.others.netId)
	JackpotProtocol.connection:sendPacket(packet)
end
function JackpotProtocol.addItems(items)
	local packet = Packet.new()
	packet:addInt8(OutgoingJackpotPacket.addItems)
	packet:addInt8(#items)
	for _, eqId in ipairs(items) do
		local item = Game.equipment[eqId]
		packet:addInt16(item.id)
		packet:addInt8(item.quality)
		packet:addBool(item.statTrak)
		if item.pattern then
			packet:addInt8(item.pattern)
		else
			packet:addInt8(0)
		end
		packet:addString(item.n or "")
		if item.stickers then
			packet:addString(Stickers.serialize(item.stickers))
		else
			packet:addString("")
		end
	end
	JackpotProtocol.connection:sendPacket(packet)
end
function JackpotProtocol.joinRoom(roomType)
	local packet = Packet.new()
	packet:addInt8(OutgoingJackpotPacket.join)
	packet:addInt8(roomType)
	packet:addInt8(Game.onlineJackpot.avatar)
	packet:addString(Game.onlineJackpot.name)
	JackpotProtocol.connection:sendPacket(packet)
end
function JackpotProtocol.exitRoom(roomId)
	local packet = Packet.new()
	packet:addInt8(OutgoingJackpotPacket.exitRoom)
	packet:addInt32(roomId)
	JackpotProtocol.connection:sendPacket(packet)
end
function JackpotProtocol.onReceive(packetType, data)
	if not JackpotProtocol.callbackTable[packetType] then
		print("Warning: No callback for packet with type " .. packetType)
		return
	end
	data = Packet.parse(packetType, data)
	JackpotProtocol.callbackTable[packetType](unpack(data))
end
function JackpotProtocol.disconnect()
	if not JackpotProtocol.tcpClient then
		return
	end
	JackpotProtocol.connection.onCloseCallback = nil
	JackpotProtocol.connection:onClose()
end
function JackpotProtocol.init(ip, port)
	if JackpotProtocol.tcpClient then
		JackpotProtocol.disconnect()
	end
	JackpotProtocol.tcpClient = socket.connect(ip, port)
	if not JackpotProtocol.tcpClient then
		return false
	end
	JackpotProtocol.connection:init(JackpotProtocol.tcpClient, JackpotProtocol.onReceive)
	return true
end
function JackpotProtocol.registerCallback(packetType, callback)
	JackpotProtocol.callbackTable[packetType] = callback
end
function JackpotProtocol.removeCallback(packetType)
	JackpotProtocol.callbackTable[packetType] = nil
end
function JackpotProtocol.registerOnCloseEvent(callback)
	JackpotProtocol.connection.onCloseCallback = callback
end
return JackpotProtocol
