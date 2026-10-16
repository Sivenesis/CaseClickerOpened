PriceTester = {}
local priceFile
function PriceTester.testCapsules(generatePriceFile)
	local capsulesToTest = 20000
	if generatePriceFile then
		priceFile = io.open(system.pathForFile("capsuleprices.lua", system.DocumentsDirectory), "w")
		priceFile:write("return {\n")
	end
	for i = 1, #Game.capsules do
		if not Game.capsules[i] then
			break
		end
		local capsule = Game.capsules[i]
		local str = "Name: " .. capsule.name .. " | "
		local profit = 0
		local totalStickersPrice = 0
		for i = 1, capsulesToTest do
			profit = profit - capsule.price
			if capsule.keyId then
				profit = profit - 1
			end
			local stickerPrice = Game.stickers[Game.getRandomCapsuleItemId(capsule)].price
			profit = profit + stickerPrice
			totalStickersPrice = totalStickersPrice + stickerPrice
		end
		str = str .. "profit: " .. math.round(profit)
		if generatePriceFile then
			local roundFactor = 10
			local averagePrice = totalStickersPrice / capsulesToTest
			if averagePrice <= 5 then
				averagePrice = averagePrice + 0.1
			end
			if 100 < averagePrice then
				roundFactor = 0.1
			end
			local recommendedPrice = math.ceil(averagePrice * roundFactor) / roundFactor
			print("Recommended price: " .. recommendedPrice)
			priceFile:write("\t[" .. i .. "] = " .. recommendedPrice .. ",\n")
		end
		print(str)
		if capsule.price < capsule.sellPrice then
			print("======================================")
			print("===== SELL PRICE IS TOO LOW! =========")
			print("======================================")
		end
	end
	if generatePriceFile then
		priceFile:write("}")
		io.close(priceFile)
	end
end
function PriceTester.testSouvenirs()
	for i = 1, #Game.souvenirs do
		if Game.souvenirs[i].price then
			local souvenir = Game.souvenirs[i]
			local str = "Name: "
			for i = 1, 25 - #souvenir.name do
				str = str .. " "
			end
			str = str .. souvenir.name
			local profit = 0
			str = str .. " | "
			for i = 1, 90000 do
				profit = profit - souvenir.price
				local item = Game.skins[Game.getCollectionRandomItemId(Game.collections[souvenir.collection])]
				item.statTrak = true
				item.quality = QualityManager.getRandomQuality(item)
				local itemPrice = Game.getItemPrice(item)
				profit = profit + itemPrice
			end
			str = str .. "profit: " .. math.round(profit)
			print(str)
			if souvenir.price < souvenir.sellPrice then
				print("======================================")
				print("===== SELL PRICE IS TOO LOW! =========")
				print("======================================")
			end
			if 0 < profit then
				print("======================================")
				print("===== PROFIT IS TOO HIGH! ============")
				print("======================================")
			end
		end
	end
end
function PriceTester.testCollections(generatePriceFile)
	local collectionsToTest = 40000
	if generatePriceFile then
		priceFile = io.open(system.pathForFile("collectionprices.lua", system.DocumentsDirectory), "w")
		priceFile:write("return {\n")
	end
	for i = 1, #Game.collections do
		local collection = Game.collections[i]
		local str = "Name: "
		for i = 1, 25 - #collection.name do
			str = str .. " "
		end
		str = str .. collection.name
		local profit = 0
		local totalItemPrice = 0
		str = str .. " | "
		for i = 1, collectionsToTest do
			profit = profit - collection.price
			local item = Game.skins[Game.getCollectionRandomItemId(Game.collections[collection.id])]
			item.statTrak = false
			item.quality = QualityManager.getRandomQuality(item)
			local itemPrice = Game.getItemPrice(item)
			profit = profit + itemPrice
			totalItemPrice = totalItemPrice + itemPrice
		end
		str = str .. "profit: " .. math.round(profit)
		if generatePriceFile then
			local roundFactor = 10
			local averagePrice = totalItemPrice / collectionsToTest
			if averagePrice <= 5 then
				averagePrice = averagePrice + 0.1
			end
			if 100 < averagePrice then
				roundFactor = 0.1
			end
			local recommendedPrice = math.ceil(averagePrice * roundFactor) / roundFactor
			print("Recommended price: " .. recommendedPrice)
			priceFile:write("\t[" .. i .. "] = " .. recommendedPrice .. ",\n")
		end
		print(str)
		if collection.price < collection.sellPrice then
			print("======================================")
			print("===== SELL PRICE IS TOO LOW! =========")
			print("======================================")
		end
		if 5000 < profit then
			print("======================================")
			print("===== PROFIT IS TOO HIGH! ============")
			print("======================================")
		end
	end
	if generatePriceFile then
		priceFile:write("}")
		io.close(priceFile)
	end
end
return PriceTester
