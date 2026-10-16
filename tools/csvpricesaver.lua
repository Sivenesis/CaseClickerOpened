local CSVPriceSaver = {}
local file
local function writePriceLine(itemName, price, quality, statTrak, pattern)
	file:write(itemName .. "," .. price .. "," .. quality .. "," .. statTrak .. "," .. (pattern or "") .. "\n")
end
function CSVPriceSaver.savePrices()
	local location = system.DocumentsDirectory
	local path = system.pathForFile("prices.csv", location)
	file = io.open(path, "w")
	for i = 1, #Game.skins do
		for q = 1, 5 do
			if Game.isQualityAvailable(i, q) then
				writePriceLine(Game.skins[i].name, Game.skins[i].prices.normal[q], QualityNames[q], "-")
			end
		end
		if Game.skins[i].statTrakAvailable or Game.skins[i].souvenirAvailable then
			local st = "StatTrak"
			if Game.skins[i].souvenirAvailable then
				st = "Souvenir"
			end
			for q = 1, 5 do
				if Game.isQualityAvailable(i, q) then
					writePriceLine(Game.skins[i].name, Game.skins[i].prices.statTrak[q], QualityNames[q], st)
				end
			end
		end
		if Game.skins[i].patterns then
			for j, patternId in ipairs(Game.skins[i].patterns) do
				for q = 1, 5 do
					if Game.isQualityAvailable(i, q) then
						writePriceLine(Game.skins[i].name, Game.skins[i].prices.normal[q] * PatternInfo[patternId].priceMultiplier, QualityNames[q], "-", PatternInfo[patternId].name)
					end
				end
				if Game.skins[i].statTrakAvailable then
					for q = 1, 5 do
						if Game.isQualityAvailable(i, q) then
							writePriceLine(Game.skins[i].name, Game.skins[i].prices.statTrak[q] * PatternInfo[patternId].priceMultiplier, QualityNames[q], "StatTrak", PatternInfo[patternId].name)
						end
					end
				end
			end
		end
	end
	if file then
		local contents = json.encode(priceTable)
		file:write(contents)
		io.close(file)
		print("Price files have been saved.")
		return true
	else
		print("Could not save prices.")
		return false
	end
end
return CSVPriceSaver
