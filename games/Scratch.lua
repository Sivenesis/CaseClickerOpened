local Scratch = {}
Scratch.__index = Scratch
function Scratch:getSkinsToAddList()
	local item = {}
	while true do
		item = EquipmentManager.getItemWithPrice(self.ticketPrice * 0.3, self.ticketPrice * 1.55)
		if not self.usedSkins[EquipmentManager.itemToString(item, true)] then
			self.usedSkins[EquipmentManager.itemToString(item, true)] = true
			break
		end
	end
	local count = 1
	local randomResult = math.random(1, 100)
	if not self.tripleSkinsAdded and self.winningScratch then
		count = 3
		self.tripleSkinsAdded = true
	elseif randomResult < 60 and self.emptyFields >= 2 then
		count = 2
	end
	return {count = count, item = item}
end
function Scratch:scratchField(fieldId)
	if self.scratchedFields[fieldId] or self.finished then
		return false
	end
	self.scratchedFields[fieldId] = true
	self.scratchCallback()
	local sameItemFields = {fieldId}
	for i = 1, #self.fields do
		if self.scratchedFields[i] then
			if i ~= fieldId and EquipmentManager.shallowCompareItems(self.fields[i], self.fields[fieldId]) then
				table.insert(sameItemFields, i)
			end
			if #sameItemFields == 3 then
				self.finished = true
				for j = 1, #self.endCallbacks do
					self.endCallbacks[j](true, self.fields[fieldId], sameItemFields)
				end
				StatisticManager.addStatistic("scratchedScratches")
			end
		end
	end
	if not self.finished and tableLength(self.scratchedFields) == 9 then
		self.finished = true
		for i = 1, #self.endCallbacks do
			self.endCallbacks[i](false)
		end
		StatisticManager.addStatistic("scratchedScratches")
	end
	return true
end
function Scratch:generate()
	self.fields = {}
	self.usedSkins = {}
	self.endCallbacks = {}
	self.scratchedFields = {}
	self.finished = false
	self.tripleSkinsAdded = false
	self.emptyFields = 9
	self.winningScratch = false
	if math.random(1, 100) <= 70 then
		self.winningScratch = true
		Analytics.addEvent("Scratch:" .. self.ticketPrice .. ":win")
	else
		Analytics.addEvent("Scratch:" .. self.ticketPrice .. ":lose")
	end
	while self.emptyFields > 0 do
		local items = self:getSkinsToAddList()
		for i = 1, items.count do
			table.insert(self.fields, items.item)
		end
		self.emptyFields = self.emptyFields - items.count
	end
	self.fields = shuffleTable(self.fields)
end
function Scratch:addEndCallback(callback)
	table.insert(self.endCallbacks, callback)
end
function Scratch.create(scratchType, ticketPrice, endCallback, scratchCallback)
	local newScratch = {}
	setmetatable(newScratch, Scratch)
	newScratch.type = scratchType
	newScratch.ticketPrice = ticketPrice
	newScratch.scratchCallback = scratchCallback
	newScratch:generate()
	newScratch:addEndCallback(endCallback)
	return newScratch
end
return Scratch
