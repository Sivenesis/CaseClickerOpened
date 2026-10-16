local packet = {}
local packet_mt = {__index = packet}
local getItem = function(data)
	local item = {}
	item.id = getInt16(data)
	item.quality = getInt8(data)
	item.statTrak = getBool(data)
	item.pattern = getInt8(data)
	local name = getString(data)
	if name and 3 <= #name then
		item.n = name
	end
	if item.pattern == 0 then
		item.pattern = nil
	end
	item.stickers = Stickers.deserialize(getString(data))
	item.player = getInt32(data)
	return item
end
local getPlayer = function(data)
	local player = {}
	player.id = getInt32(data)
	player.name = getString(data)
	player.avatar = getInt8(data)
	return player
end
local function getJackpotRoom(data)
	local room = {
		players = {},
		items = {}
	}
	room.uid = getInt32(data)
	room.type = getInt8(data)
	room.endTime = getInt32(data)
	room.itemLimit = getInt8(data)
	room.itemsPerPlayerLimit = getInt8(data)
	local playerCount = getInt8(data)
	for i = 1, playerCount do
		local player = getPlayer(data)
		room.players[player.id] = player
	end
	local itemCount = getInt8(data)
	for i = 1, itemCount do
		table.insert(room.items, getItem(data))
	end
	return room
end
function getFloat(data)
	local int = 16777216 * data[4] + 65536 * data[3] + 256 * data[2] + data[1]
	for i = 1, 4 do
		table.remove(data, 1)
	end
	return int / 100
end
function getString(data)
	local size = getInt16(data)
	if size == 0 then
		return ""
	end
	local str = ""
	for i = 1, size do
		str = str .. string.char(data[1])
		table.remove(data, 1)
	end
	return str
end
function getInt32(data)
	local int = 16777216 * data[4] + 65536 * data[3] + 256 * data[2] + data[1]
	for i = 1, 4 do
		table.remove(data, 1)
	end
	return int
end
function getInt16(data)
	local int = 256 * data[2] + data[1]
	for i = 1, 2 do
		table.remove(data, 1)
	end
	return int
end
function getBool(data)
	local int = data[1]
	table.remove(data, 1)
	return 0 < int
end
function getInt8(data)
	local int = data[1]
	table.remove(data, 1)
	return int
end
local toInt8 = function(number)
	return string.char(math.floor(number / 1) % 256)
end
local toInt16 = function(number)
	return string.char(math.floor(number / 1) % 256, math.floor(number / 256) % 256)
end
local toInt32 = function(number)
	return string.char(math.floor(number / 1) % 256, math.floor(number / 256) % 256, math.floor(number / 65536) % 256, math.floor(number / 16777216) % 256)
end
function packet.raffleParse(packetType, data)
	local tab = {}
	if packetType == IncomingJackpotPacket.login then
		tab[1] = getBool(data)
		if tab[1] == true then
			tab[2] = getInt16(data)
			tab[3] = getInt16(data)
		else
			tab[2] = getString(data)
		end
	elseif packetType == IncomingJackpotPacket.success then
		tab[1] = getBool(data)
		tab[2] = getString(data)
	elseif packetType == IncomingJackpotPacket.disconnect then
		tab[1] = getString(data)
	elseif packetType == IncomingJackpotPacket.shutdown then
		tab[1] = getBool(data)
	end
	return tab
end
function packet.parse(packetType, data)
	local tab = {}
	if packetType == IncomingJackpotPacket.login then
		tab[1] = getBool(data)
		if tab[1] then
			tab[2] = getInt32(data)
			tab[3] = getInt32(data)
			local tabSize = getInt8(data)
			tab[4] = {}
			for i = 1, tabSize do
				tab[4][i] = {}
				tab[4][i].name = getString(data)
				tab[4][i].minPrice = getFloat(data)
				tab[4][i].maxPrice = getFloat(data)
				tab[4][i].maxTotalPrice = getInt16(data)
			end
		else
			tab[2] = {}
			tab[3] = {}
			tab[4] = {}
			tab[5] = getString(data)
		end
	elseif packetType == IncomingJackpotPacket.join then
		tab[1] = getBool(data)
		if tab[1] then
			tab[2] = ""
			tab[3] = getJackpotRoom(data)
		else
			tab[2] = getString(data)
		end
	elseif packetType == IncomingJackpotPacket.success then
		tab[1] = getBool(data)
		tab[2] = getString(data)
	elseif packetType == IncomingJackpotPacket.itemsAdd then
		tab[1] = getPlayer(data)
		local tabSize = getInt8(data)
		tab[2] = {}
		for i = 1, tabSize do
			tab[2][i] = {}
			tab[2][i].id = getInt16(data)
			tab[2][i].quality = getInt8(data)
			tab[2][i].statTrak = getBool(data)
			tab[2][i].pattern = getInt8(data)
			if tab[2][i].pattern == 0 then
				tab[2][i].pattern = nil
			end
			local name = getString(data)
			if name and 3 <= #name then
				tab[2][i].n = name
			end
			tab[2][i].stickers = Stickers.deserialize(getString(data))
			tab[2][i].player = tab[1].id
		end
	elseif packetType == IncomingJackpotPacket.timeChange then
		tab[1] = getInt32(data)
	elseif packetType == IncomingJackpotPacket.jackpotEnd then
		tab[1] = getInt32(data)
	elseif packetType == IncomingJackpotPacket.disconnect then
		tab[1] = getString(data)
	elseif packetType == IncomingJackpotPacket.newItems then
		tab[1] = {}
		local tabSize = getInt8(data)
		for i = 1, tabSize do
			tab[1][i] = {}
			tab[1][i].id = getInt16(data)
			tab[1][i].quality = getInt8(data)
			tab[1][i].statTrak = getBool(data)
			tab[1][i].pattern = getInt8(data)
			if tab[1][i].pattern == 0 then
				tab[1][i].pattern = nil
			end
			local name = getString(data)
			if name and 3 <= #name then
				tab[1][i].n = name
			end
			tab[1][i].stickers = Stickers.deserialize(getString(data))
			tab[1][i].type = Item.skin
		end
	elseif packetType == IncomingJackpotPacket.shutdown then
		tab[1] = {}
	end
	return tab
end
function packet.new()
	local newPacket = {buffer = ""}
	return setmetatable(newPacket, packet_mt)
end
function packet:onSend()
	local packetSize = #self.buffer
	self.buffer = toInt16(packetSize) .. self.buffer
end
function packet:addInt8(number)
	self.buffer = self.buffer .. toInt8(number)
end
function packet:addBool(number)
	if number and number == true then
		self.buffer = self.buffer .. toInt8(1)
	else
		self.buffer = self.buffer .. toInt8(0)
	end
end
function packet:addInt16(number)
	self.buffer = self.buffer .. toInt16(number)
end
function packet:addInt32(number)
	self.buffer = self.buffer .. toInt32(number)
end
function packet:addString(str)
	self.buffer = self.buffer .. toInt16(#str) .. str
end
return packet
