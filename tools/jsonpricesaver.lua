local JSONPriceSaver = {}
function JSONPriceSaver.savePrices()
	local location = system.DocumentsDirectory
	local path = system.pathForFile("prices.json", location)
	local path2 = system.pathForFile("validation.json", location)
	local priceTable = {}
	local validationTable = {}
	for i = 1, #Game.skins do
		priceTable[i] = {}
		priceTable[i][1] = Game.skins[i].prices.normal
		priceTable[i][2] = Game.skins[i].prices.statTrak
		if Game.skins[i].patterns then
			priceTable[i][3] = {}
			for j, patternId in ipairs(Game.skins[i].patterns) do
				priceTable[i][3][j] = PatternInfo[patternId].priceMultiplier
			end
		end
		validationTable[i] = {}
		validationTable[i].disabledQualities = Game.skins[i].disabledQualities
		validationTable[i].statTrakAvailable = Game.skins[i].statTrakAvailable
		validationTable[i].souvenirAvailable = Game.skins[i].souvenirAvailable
		validationTable[i].patternAvailable = Game.skins[i].patterns ~= nil
	end
	local file = io.open(path, "w")
	local file2 = io.open(path2, "w")
	if file and file2 then
		local contents = json.encode(priceTable)
		local contents2 = json.encode(validationTable)
		file:write(contents)
		file2:write(contents2)
		io.close(file)
		io.close(file2)
		print("Price files have been saved.")
		return true
	else
		print("Could not save prices.")
		return false
	end
end
return JSONPriceSaver
