local Packet = require("net.packet")
local connection = {}
connection.__index = connection
function connection.new()
	local self = setmetatable({}, connection)
	self.sendTable = {}
	self.receiveTable = {}
	self.packetSizeTable = {}
	self.closed = false
	return self
end
function connection:send(socket)
	local count = #self.sendTable
	if count == 0 then
		return
	end
	for key, msg in ipairs(self.sendTable) do
		if msg ~= nil then
			socket:send(msg)
		end
		self.sendTable[key] = nil
	end
end
function connection:receive(socket, callback)
	socket:settimeout(0)
	local s, status = socket:receive(1)
	if s ~= nil then
		if self.packetSize == nil then
			if #self.packetSizeTable == 0 then
				self.packetSizeTable[1] = string.byte(s)
			else
				self.packetSizeTable[2] = string.byte(s)
				self.packetSize = getInt16(self.packetSizeTable) - 1
				self.toReceive = self.packetSize
			end
			return
		elseif self.packetType == nil then
			self.packetType = string.byte(s)
			return
		end
		if self.toReceive then
			table.insert(self.receiveTable, string.byte(s))
			self.toReceive = self.toReceive - 1
			if 0 >= self.toReceive then
				callback(self.packetType, self.receiveTable)
				self.toReceive = nil
				self.packetSize = nil
				self.packetType = nil
				self.receiveTable = {}
				self.packetSizeTable = {}
			end
		end
	end
end
function connection:sendPacket(packet)
	if not packet then
		return
	end
	packet:onSend()
	table.insert(self.sendTable, packet.buffer)
end
function connection:isActive()
	return not self.closed
end
function connection:onClose()
	closed = true
	if self.firstTimer then
		timer.cancel(self.firstTimer)
		timer.cancel(self.secondTimer)
		timer.cancel(self.thirdTimer)
	end
	if self.socket then
		local socketNow = self.socket
		timer.performWithDelay(600, function()
			if self.socket and self.socket.shutdown and socketNow == self.socket then
				self.socket:shutdown("both")
			end
		end)
	end
	if self.onCloseCallback then
		self:onCloseCallback()
	end
end
function connection:init(socket, receiveCallback)
	if firstTimer then
		timer.cancel(self.firstTimer)
		timer.cancel(self.secondTimer)
		timer.cancel(self.thirdTimer)
	end
	self.socket = socket
	closed = false
	self.firstTimer = timer.performWithDelay(1, function()
		self:receive(socket, receiveCallback)
	end, 0)
	self.secondTimer = timer.performWithDelay(1, function()
		self:send(socket)
	end, 0)
	self.thirdTimer = timer.performWithDelay(500, function()
		if closed then
			return
		end
		local str1, str2 = socket:receive(0)
		if str2 == "closed" then
			self:onClose()
		end
	end, 0)
end
return connection
