StashSaver = {}
local network = require("network")
local luaStickerFile, luaSkinFile, luaGloveFile
local gloveCount = 0
local skinCount = 0
local stickerCount = 0
local totalStickerCount = 0
local euroToDollar = 1.22965
StashId = {
	AWP_dragonlore = 422,
	AWP_medusa = 613,
	AK47_fireserpent = 114,
	AWP_dragonlore = 422,
	M4A4_howl = 355,
	BAYONET_bluesteel = 303,
	BAYONET_casehardened = 305,
	M9_crimsonweb = 319,
	KARAMBIT_night = 335,
	BAYONET_crimsonweb = 306,
	BAYONET_marblefade = 537,
	BAYONET_night = 309,
	BAYONET_ultraviolet = 540,
	FLIP_crimsonweb = 293,
	GUT_crimsonweb = 280,
	KARAMBIT_borealforest = 330,
	AK47_vulcan = 354,
	AUG_akihabaraaccept = 629,
	KARAMBIT_fade = 333,
	KARAMBIT_ultraviolet = 552,
	AK47_wastelandrebel = 495,
	M9_ultraviolet = 546,
	M9_slaughter = 325,
	KARAMBIT_tigertooth = 550,
	KARAMBIT_marblefade = 549,
	M9_marblefade = 543,
	M9_tigertooth = 544,
	KARAMBIT_doppler = 548,
	BAYONET_fade = 307,
	FALCHION_crimsonweb = 634,
	KARAMBIT_crimsonweb = 332,
	BUTTERFLY_crimsonweb = 456,
	HUNTSMAN_crimsonweb = 376,
	R8_amberfade = 689,
	KARAMBIT_gammadoppler = 782,
	KARAMBIT_lore = 772,
	GUT_rustcoat = 527,
	HUNTSMAN_stained = 383,
	KARAMBIT_damascussteel = 547
}
local glovePriceTable = {}
local priceTable = {
	[StashId.GUT_rustcoat] = {
		normal = {
			[1] = 249.09,
			[2] = 207.58,
			[3] = 172.98,
			[4] = 144.15,
			[5] = 45.5
		},
		statTrak = {
			[1] = 1736.69,
			[2] = 1447.24,
			[3] = 1206.04,
			[4] = 411.24,
			[5] = 68.54
		}
	},
	[StashId.KARAMBIT_damascussteel] = {
		normal = {
			[Quality.factorynew] = 274.64,
			[Quality.minimalwear] = 247.82,
			[Quality.fieldtested] = 223.23,
			[Quality.wellworn] = 217.5,
			[Quality.battlescarred] = 176.41
		},
		statTrak = {
			[Quality.factorynew] = 382.59,
			[Quality.minimalwear] = 342.53,
			[Quality.fieldtested] = 293.36,
			[Quality.wellworn] = 267.91,
			[Quality.battlescarred] = 239.94
		}
	},
	[StashId.HUNTSMAN_stained] = {
		normal = {
			[Quality.factorynew] = 102.01,
			[Quality.minimalwear] = 65.82,
			[Quality.fieldtested] = 59.23,
			[Quality.wellworn] = 55.91,
			[Quality.battlescarred] = 51.98
		},
		statTrak = {
			[Quality.factorynew] = 148.59,
			[Quality.minimalwear] = 115.53,
			[Quality.fieldtested] = 90.2,
			[Quality.wellworn] = 85.91,
			[Quality.battlescarred] = 74.94
		}
	},
	[StashId.KARAMBIT_lore] = {
		normal = {
			[1] = 1754.47,
			[2] = 1341.41,
			[3] = 929.38,
			[4] = 743.5,
			[5] = 594.8
		},
		statTrak = {
			[1] = 3320.99,
			[2] = 2688.82,
			[3] = 1780.66,
			[4] = 1464.53,
			[5] = 951.62
		}
	},
	[StashId.KARAMBIT_gammadoppler] = {
		normal = {
			[1] = 1032.65,
			[2] = 826.12,
			[3] = 660.9,
			[4] = 528.72,
			[5] = 422.97
		},
		statTrak = {
			[1] = 2368.29,
			[2] = 1791.43,
			[3] = 2313.14,
			[4] = 1850.51,
			[5] = 1480.41
		}
	},
	[StashId.AWP_dragonlore] = {
		statTrak = {
			[Quality.factorynew] = 2758.23,
			[Quality.minimalwear] = 2132.53,
			[Quality.fieldtested] = 1405.46,
			[Quality.wellworn] = 994.82,
			[Quality.battlescarred] = 520.09
		}
	},
	[StashId.AWP_medusa] = {
		normal = {
			[Quality.factorynew] = 1375.22,
			[Quality.minimalwear] = 489.42,
			[Quality.fieldtested] = 397.02,
			[Quality.wellworn] = 360.77,
			[Quality.battlescarred] = 308.98
		}
	},
	[StashId.AK47_fireserpent] = {
		statTrak = {
			[Quality.factorynew] = 1452.33,
			[Quality.minimalwear] = 1016.53,
			[Quality.fieldtested] = 827.5,
			[Quality.wellworn] = 504.91,
			[Quality.battlescarred] = 317.53
		}
	},
	[StashId.M4A4_howl] = {
		normal = {
			[Quality.factorynew] = 1320.63,
			[Quality.minimalwear] = 1197.2,
			[Quality.fieldtested] = 923.84,
			[Quality.wellworn] = 648.33
		},
		statTrak = {
			[Quality.factorynew] = 3864.75,
			[Quality.minimalwear] = 2320.82,
			[Quality.fieldtested] = 1618.23,
			[Quality.wellworn] = 1463.01
		}
	},
	[StashId.BAYONET_bluesteel] = {
		statTrak = {
			[Quality.factorynew] = 1007.52
		}
	},
	[StashId.BAYONET_casehardened] = {
		statTrak = {
			[Quality.factorynew] = 671.84
		}
	},
	[StashId.M9_crimsonweb] = {
		normal = {
			[Quality.factorynew] = 827.33,
			[Quality.minimalwear] = 582.32
		},
		statTrak = {
			[Quality.factorynew] = 1683.22,
			[Quality.minimalwear] = 1153.82
		}
	},
	[StashId.KARAMBIT_night] = {
		normal = {
			[Quality.factorynew] = 1282.53
		},
		statTrak = {
			[Quality.factorynew] = 1527.88,
			[Quality.minimalwear] = 945.27
		}
	},
	[StashId.BAYONET_crimsonweb] = {
		normal = {
			[Quality.factorynew] = 827.4
		},
		statTrak = {
			[Quality.factorynew] = 1239.76,
			[Quality.minimalwear] = 481.02
		}
	},
	[StashId.BAYONET_marblefade] = {
		normal = {
			[Quality.factorynew] = 398.18,
			[Quality.minimalwear] = 362.32
		},
		statTrak = {
			[Quality.factorynew] = 521.92,
			[Quality.minimalwear] = 381.55
		}
	},
	[StashId.BAYONET_night] = {
		normal = {
			[Quality.factorynew] = 673.59
		},
		statTrak = {
			[Quality.factorynew] = 2371.29
		}
	},
	[StashId.BAYONET_ultraviolet] = {
		normal = {
			[Quality.factorynew] = 712.72
		},
		statTrak = {
			[Quality.factorynew] = 1230.22
		}
	},
	[StashId.FLIP_crimsonweb] = {
		normal = {
			[Quality.factorynew] = 1102.66
		},
		statTrak = {
			[Quality.factorynew] = 1835.99
		}
	},
	[StashId.GUT_crimsonweb] = {
		normal = {
			[Quality.factorynew] = 472.09
		},
		statTrak = {
			[Quality.factorynew] = 692
		}
	},
	[StashId.KARAMBIT_borealforest] = {
		statTrak = {
			[Quality.factorynew] = 486.1
		}
	},
	[StashId.AK47_vulcan] = {
		statTrak = {
			[Quality.factorynew] = 393.75
		}
	},
	[StashId.AUG_akihabaraaccept] = {
		normal = {
			[Quality.factorynew] = 643.82
		}
	},
	[StashId.KARAMBIT_fade] = {
		normal = {
			[Quality.factorynew] = 611.81,
			[Quality.minimalwear] = 463.44
		},
		statTrak = {
			[Quality.factorynew] = 877.5,
			[Quality.minimalwear] = 592.44
		}
	},
	[StashId.KARAMBIT_ultraviolet] = {
		normal = {
			[Quality.factorynew] = 562.48
		},
		statTrak = {
			[Quality.factorynew] = 927.36,
			[Quality.minimalwear] = 453.3
		}
	},
	[StashId.AK47_wastelandrebel] = {
		statTrak = {
			[Quality.factorynew] = 477.39
		}
	},
	[StashId.M9_ultraviolet] = {
		normal = {
			[Quality.factorynew] = 632.33
		},
		statTrak = {
			[Quality.factorynew] = 972.38
		}
	},
	[StashId.M9_slaughter] = {
		normal = {
			[Quality.factorynew] = 415.23,
			[Quality.minimalwear] = 258.12
		},
		statTrak = {
			[Quality.factorynew] = 677,
			[Quality.minimalwear] = 459.06
		}
	},
	[StashId.KARAMBIT_tigertooth] = {
		normal = {
			[Quality.factorynew] = 498.28,
			[Quality.minimalwear] = 421.34
		},
		statTrak = {
			[Quality.factorynew] = 701.93,
			[Quality.minimalwear] = 482.88
		}
	},
	[StashId.KARAMBIT_marblefade] = {
		normal = {
			[Quality.factorynew] = 763.12,
			[Quality.minimalwear] = 555.55
		},
		statTrak = {
			[Quality.factorynew] = 1157.84,
			[Quality.minimalwear] = 652.12
		}
	},
	[StashId.M9_marblefade] = {
		normal = {
			[Quality.factorynew] = 517.47,
			[Quality.minimalwear] = 478.59
		},
		statTrak = {
			[Quality.factorynew] = 1105.27,
			[Quality.minimalwear] = 683.1
		}
	},
	[StashId.M9_tigertooth] = {
		normal = {
			[Quality.factorynew] = 416.97,
			[Quality.minimalwear] = 343.75
		},
		statTrak = {
			[Quality.factorynew] = 611.11,
			[Quality.minimalwear] = 736.49
		}
	},
	[StashId.BAYONET_fade] = {
		normal = {
			[Quality.factorynew] = 198.07,
			[Quality.minimalwear] = 211.84
		},
		statTrak = {
			[Quality.factorynew] = 395.22,
			[Quality.minimalwear] = 760.05
		}
	},
	[StashId.HUNTSMAN_crimsonweb] = {
		normal = {
			[Quality.factorynew] = 648.43,
			[Quality.minimalwear] = 173.11
		},
		statTrak = {
			[Quality.factorynew] = 1338.12,
			[Quality.minimalwear] = 315.05
		}
	},
	[StashId.BUTTERFLY_crimsonweb] = {
		normal = {
			[Quality.factorynew] = 795.21
		},
		statTrak = {
			[Quality.factorynew] = 1498.88,
			[Quality.minimalwear] = 419.95
		}
	},
	[StashId.KARAMBIT_crimsonweb] = {
		normal = {
			[Quality.factorynew] = 1532.7,
			[Quality.minimalwear] = 370.52
		},
		statTrak = {
			[Quality.factorynew] = 2542.08,
			[Quality.minimalwear] = 752.22
		}
	},
	[StashId.FALCHION_crimsonweb] = {
		normal = {
			[Quality.factorynew] = 529.99
		},
		statTrak = {
			[Quality.factorynew] = 1258.08
		}
	},
	[StashId.R8_amberfade] = {
		statTrak = {
			[Quality.factorynew] = 684.08,
			[Quality.minimalwear] = 495.33
		}
	}
}
local fillupPrices = function(list)
	if tableLength == 5 then
		return list
	end
	while true do
		for i = 1, 5 do
			if not list[i] and list[i + 1] then
				list[i] = list[i + 1] * 1.2
			elseif not list[i] and list[i - 1] then
				list[i] = list[i - 1] * 0.8
			end
		end
		if tableLength(list) == 5 then
			return list
		end
	end
end
local fixPrices = function(list, name)
	for i = 5, 2, -1 do
		if list[i - 1] >= 100 and list[i - 1] / list[i] >= 6 then
			list[i - 1] = list[i] * math.random(550, 600) / 100
		end
	end
	return list
end
local fixPrices2 = function(list)
	for i = 5, 2, -1 do
		if 2 <= list[i] / list[i - 1] then
			list[i - 1] = list[i - 1] * math.random(170, 220) / 100
		end
	end
	for i = 1, 4 do
		if list[i + 1] / list[i] > 1.75 then
			list[i + 1] = list[i] * math.random(125, 150) / 100
		end
	end
	return list
end
local fillupPrices2 = function(tableToFill, filledTable, multiplier)
	for i = 1, 5 do
		tableToFill[i] = filledTable[i] * multiplier
	end
	return tableToFill
end
function convertPrices(list)
	for i = 1, 5 do
		if #list[i] == 0 then
			list[i] = nil
		elseif list[i][1] <= 10 then
			list[i] = list[i][1]
		else
			local sum = 0
			for _, price in ipairs(list[i]) do
				sum = sum + price
			end
			list[i] = sum / #list[i]
		end
	end
	return list
end
local function networkStickerListener(event)
	if event.isError then
		print("Network error!")
		return
	end
	print("Saving sticker #" .. stickerCount .. "...")
	local ss, se = event.response:find("<title>")
	event.response = event.response:sub(se + 1)
	local ss2, se2
	ss2, se2 = event.response:find(" Sticker")
	if not ss2 then
		local ss, se = event.response:find("Redirecting to ")
		event.response = event.response:sub(se, event.response:find("</title>") - 1)
		network.request(event.response:gsub(" ", ""), "GET", networkStickerListener)
		return false
	end
	stickerCount = stickerCount + 1
	local name = event.response:sub(1, ss2 - 1):gsub("&#039;", "'"):gsub("&amp;", "&")
	ss, se = event.response:find("quality color-")
	event.response = event.response:sub(se + 3)
	ss2, se2 = event.response:find("\">")
	local rarity = event.response:sub(1, ss2 - 1)
	if rarity == "milspec" then
		rarity = Rarity.blue
	elseif rarity == "covert" then
		rarity = Rarity.red
	elseif rarity == "classified" then
		rarity = Rarity.pink
	elseif rarity == "restricted" then
		rarity = Rarity.purple
	elseif rarity == "industrial" then
		rarity = Rarity.lightblue
	elseif rarity == "contraband" then
		rarity = Rarity.red
	else
		rarity = Rarity.gray
	end
	local price = 2
	local prices = {}
	while true do
		ss, se = event.response:find("justified")
		if not ss then
			break
		end
		if 3 <= #prices then
			break
		end
		local tmpResponse = event.response:sub(se + 40, se + 500)
		local ss2, se2 = tmpResponse:find("btn-group btn-group-justified")
		local tmpString = event.response:sub(ss, ss2)
		local euroPos = tmpString:find("&euro;")
		euroPos = euroPos or tmpString:find("\226\130\172")
		if euroPos then
			local numberString = tmpString:sub(euroPos - 8, euroPos - 1):gsub("\"", ""):gsub("t", ""):gsub(",--", ""):gsub("<", ""):gsub(">", ""):gsub("p", "")
			local priceString = ""
			local allowedChars = {
				["1"] = "1",
				["2"] = "2",
				["3"] = "3",
				["4"] = "4",
				["5"] = "5",
				["6"] = "6",
				["7"] = "7",
				["8"] = "8",
				["9"] = "9",
				["0"] = "0",
				[","] = "."
			}
			for i = 1, numberString:len() do
				if allowedChars[numberString:sub(i, i)] then
					priceString = priceString .. allowedChars[numberString:sub(i, i)]
				end
			end
			local tmpPrice = math.round(tonumber(priceString) * euroToDollar * 100) / 100
			if 0 < tmpPrice then
				table.insert(prices, tmpPrice)
			end
		end
		if euroPos then
			event.response = event.response:sub(euroPos + 10)
		else
			break
		end
	end
	local sum = 0
	local highestPrice = 0
	for i = 1, #prices do
		sum = sum + prices[i]
		if highestPrice < prices[i] then
			highestPrice = prices[i]
		end
	end
	if 0 < sum then
		price = sum / #prices
	end
	if highestPrice <= 10 then
		price = highestPrice
	end
	if sum == 0 or price == 0 then
		price = 5
		print(name)
	end
	price = math.round(price * 100) / 100
	local id = event.url:sub(-5)
	id = id:sub(1, id:len() - 1):gsub("/", ""):gsub("r", ""):gsub("e", "")
	if not euroPos then
		if id == "58" then
			price = 3827.23
		elseif id == "48" then
			price = 3273.88
		elseif id == "61" then
			price = 472.23
		elseif id == "62" then
			price = 559.02
		elseif id == "42" then
			price = 420
		elseif id == "64" then
			price = 1533.23
		elseif id == "45" then
			price = 1075.31
		end
	end
	luaStickerFile:write("\t[" .. id .. [[
] = {
		id = ]] .. id .. [[
,
		name = "]] .. name .. [[
",
		price = ]] .. price .. [[
,
		rarity = ]] .. rarity .. [[

	},
]])
	if stickerCount >= totalStickerCount then
		luaStickerFile:write([[

}]])
		luaStickerFile:close()
	end
end
local function networkSkinListener(event)
	if event.isError then
		print("Network error!")
		return
	end
	skinCount = skinCount + 1
	local ss, se
	ss, se = event.response:find("Souvenir Available")
	souvenirAvailable = false
	if ss then
		souvenirAvailable = true
	end
	ss, se = event.response:find("StatTrak Available")
	statTrakAvailable = false
	if ss then
		statTrakAvailable = true
	end
	local isKnife = false
	ss, se = event.response:find("Covert Knife")
	if ss then
		isKnife = true
	end
	ss, se = event.response:find("<title>")
	event.response = event.response:sub(se + 1)
	local ss2, se2
	ss2, se2 = event.response:find(" - CS:GO")
	if not ss2 then
		return false
	end
	local name = event.response:sub(1, ss2 - 3):gsub("&#039;", "'"):gsub("&amp;", "&")
	ss, se = event.response:find("quality color-")
	event.response = event.response:sub(se + 3)
	ss2, se2 = event.response:find("\">")
	local rarity = event.response:sub(1, ss2 - 1)
	if rarity == "milspec" then
		rarity = Rarity.blue
	elseif rarity == "covert" then
		rarity = Rarity.red
	elseif rarity == "classified" then
		rarity = Rarity.pink
	elseif rarity == "restricted" then
		rarity = Rarity.purple
	elseif rarity == "industrial" then
		rarity = Rarity.lightblue
	else
		rarity = Rarity.gray
	end
	local prices = {
		normal = {
			{},
			{},
			{},
			{},
			{}
		},
		statTrak = {
			{},
			{},
			{},
			{},
			{}
		}
	}
	local minI = 1
	if not statTrakAvailable and not souvenirAvailable then
		minI = 6
	end
	ss, se = event.response:find("<tbody>")
	ss2, se2 = event.response:find("</tbody>")
	event.response = event.response:sub(ss, se2)
	local qualityStrings = {
		["Factory New"] = 1,
		["Minimal Wear"] = 2,
		Field = 3,
		Well = 4,
		Battle = 5
	}
	while true do
		if not event.response:find("<tr") then
			break
		end
		local trow = event.response:sub(event.response:find("<tr"), event.response:find("</tr>")):gsub("sort=\"[0-9]+\"", ""):gsub("sort=[0-9]+>", "")
		local qualityString = trow:sub(trow:find("<td class"), trow:find("</td>"))
		local st = (qualityString:find("StatTrak") or qualityString:find("Souvenir")) ~= nil
		local quality = 1
		for str, number in pairs(qualityStrings) do
			if qualityString:find(str) then
				quality = number
				break
			end
		end
		while true do
			ss, se = trow:find("\226\130\172")
			if not ss then
				break
			end
			local price = trow:sub(ss - 10, ss - 1)
			price = price:gsub("l", ""):gsub("o", ""):gsub("w", ""):gsub("\"", ""):gsub(">", ""):gsub("--", "0")
			trow = trow:sub(se)
			local priceString = ""
			local allowedChars = {
				["1"] = "1",
				["2"] = "2",
				["3"] = "3",
				["4"] = "4",
				["5"] = "5",
				["6"] = "6",
				["7"] = "7",
				["8"] = "8",
				["9"] = "9",
				["0"] = "0",
				[","] = "."
			}
			for i = 1, price:len() do
				if allowedChars[price:sub(i, i)] and i % 2 == 0 then
					priceString = priceString .. allowedChars[price:sub(i, i)]
				end
			end
			if st then
				table.insert(prices.statTrak[quality], tonumber(priceString) * euroToDollar)
			else
				table.insert(prices.normal[quality], tonumber(priceString) * euroToDollar)
			end
		end
		ss, se = event.response:find("</tr>")
		event.response = event.response:sub(se)
	end
	prices.normal = convertPrices(prices.normal)
	prices.statTrak = convertPrices(prices.statTrak)
	local id = event.url:sub(-4)
	id = id:sub(1, id:len() - 1):gsub("/", ""):gsub("n", "")
	if id == "355" then
		rarity = Rarity.red
	end
	local defaultPrices = {
		[Rarity.gray] = {normal = 0.03, statTrak = 0.08},
		[Rarity.lightblue] = {normal = 0.05, statTrak = 0.1},
		[Rarity.blue] = {normal = 0.06, statTrak = 0.13},
		[Rarity.purple] = {normal = 0.25, statTrak = 0.45},
		[Rarity.pink] = {normal = 2, statTrak = 4.5},
		[Rarity.red] = {normal = 10, statTrak = 20},
		[Rarity.gold] = {normal = 82, statTrak = 140}
	}
	local noFix = false
	if priceTable[tonumber(id)] then
		noFix = true
		if priceTable[tonumber(id)].normal then
			for i = 1, 5 do
				if priceTable[tonumber(id)].normal[i] then
					prices.normal[i] = priceTable[tonumber(id)].normal[i]
				end
			end
		end
		if priceTable[tonumber(id)].statTrak then
			for i = 1, 5 do
				if priceTable[tonumber(id)].statTrak[i] then
					prices.statTrak[i] = priceTable[tonumber(id)].statTrak[i]
				end
			end
		end
	end
	if tableLength(prices.normal) == 0 and tableLength(prices.statTrak) == 0 then
		if isKnife then
			prices.normal[Quality.battlescarred] = defaultPrices[Rarity.gold].normal
			prices.statTrak[Quality.battlescarred] = defaultPrices[Rarity.gold].statTrak
		else
			prices.normal[Quality.battlescarred] = defaultPrices[rarity].normal
			prices.statTrak[Quality.battlescarred] = defaultPrices[rarity].statTrak
		end
	end
	if 0 < tableLength(prices.normal) and 5 > tableLength(prices.normal) then
		prices.normal = fillupPrices(prices.normal)
	end
	if 0 < tableLength(prices.statTrak) and #prices.statTrak < 5 then
		prices.statTrak = fillupPrices(prices.statTrak)
	end
	if tableLength(prices.statTrak) == 0 and tableLength(prices.normal) == 5 then
		prices.statTrak = fillupPrices2(prices.statTrak, prices.normal, math.random(132, 137) / 100)
	end
	if tableLength(prices.statTrak) == 5 and tableLength(prices.normal) == 0 then
		prices.normal = fillupPrices2(prices.normal, prices.statTrak, 0.65)
	end
	prices.normal = fillupPrices(prices.normal)
	prices.statTrak = fillupPrices(prices.statTrak)
	if not noFix then
		prices.normal = fixPrices(prices.normal, name)
		prices.statTrak = fixPrices(prices.statTrak, name)
	end
	prices.normal = fixPrices2(prices.normal)
	prices.statTrak = fixPrices2(prices.statTrak)
	for i = 1, 5 do
		prices.normal[i] = math.round(prices.normal[i] * 100) / 100
		prices.statTrak[i] = math.round(prices.statTrak[i] * 100) / 100
		if prices.normal[i] > 3000 then
			print("Normal price too high: " .. name .. " | " .. prices.normal[i])
		end
		if prices.statTrak[i] > 3000 then
			print("StatTrak price too high: " .. name .. " | " .. prices.statTrak[i])
		end
	end
	if tableLength(prices.normal) ~= 5 or tableLength(prices.statTrak) ~= 5 then
		print(id .. " | Prices need fillup!")
	end
	local luaPriceString = [[
prices = {
			normal = {
]]
	for i, price in pairs(prices.normal) do
		luaPriceString = luaPriceString .. "\t\t\t\t[" .. i .. "] = " .. price .. ",\n"
	end
	luaPriceString = luaPriceString .. [[
			},
			statTrak = {
]]
	for i, price in pairs(prices.statTrak) do
		luaPriceString = luaPriceString .. "\t\t\t\t[" .. i .. "] = " .. price .. ",\n"
	end
	luaPriceString = luaPriceString .. [[
			}
		}]]
	local luaStr = "\t[" .. id .. [[
] = {
		id = ]] .. id .. [[
,
		name = "]] .. name .. [[
",
		]] .. luaPriceString .. [[
,
		rarity = ]] .. rarity
	if not souvenirAvailable then
		local statTrakString = "false"
		if statTrakAvailable then
			statTrakString = "true"
		end
		luaStr = luaStr .. [[
,
		statTrakAvailable = ]] .. statTrakString
	end
	if souvenirAvailable then
		luaStr = luaStr .. [[
,
		souvenirAvailable = true]]
	end
	if isKnife then
		luaStr = luaStr .. [[
,
		isKnife = true]]
	end
	luaStr = luaStr .. [[

	},
]]
	luaSkinFile:write(luaStr)
	if skinCount >= #Game.skins then
		luaSkinFile:write([[

}]])
		luaSkinFile:close()
	end
end
local function networkGloveListener(event)
	if event.isError then
		print("Network error!")
		return
	end
	gloveCount = gloveCount + 1
	local ss, se
	ss, se = event.response:find("<title>")
	event.response = event.response:sub(se + 1)
	local ss2, se2
	ss2, se2 = event.response:find(" - CS:GO")
	local name = event.response:sub(1, ss2 - 3):gsub("&#039;", "'"):gsub("&amp;", "&")
	ss, se = event.response:find("quality color-")
	event.response = event.response:sub(se + 3)
	ss2, se2 = event.response:find("\">")
	local rarity = event.response:sub(1, ss2 - 1)
	if rarity == "milspec" then
		rarity = Rarity.blue
	elseif rarity == "covert" then
		rarity = Rarity.red
	elseif rarity == "classified" then
		rarity = Rarity.pink
	elseif rarity == "restricted" then
		rarity = Rarity.purple
	elseif rarity == "industrial" then
		rarity = Rarity.lightblue
	else
		rarity = Rarity.gray
	end
	local prices = {
		{},
		{},
		{},
		{},
		{}
	}
	ss, se = event.response:find("<tbody>")
	ss2, se2 = event.response:find("</tbody>")
	event.response = event.response:sub(ss, se2)
	local qualityStrings = {
		["Factory New"] = 1,
		["Minimal Wear"] = 2,
		Field = 3,
		Well = 4,
		Battle = 5
	}
	while true do
		if not event.response:find("<tr") then
			break
		end
		local trow = event.response:sub(event.response:find("<tr"), event.response:find("</tr>"))
		local qualityString = trow:sub(trow:find("<td class"), trow:find("</td>"))
		local quality = 1
		for str, number in pairs(qualityStrings) do
			if qualityString:find(str) then
				quality = number
				break
			end
		end
		while true do
			ss, se = trow:find("\226\130\172")
			if not ss then
				break
			end
			local price = trow:sub(ss - 10, ss - 1)
			price = price:gsub("l", ""):gsub("o", ""):gsub("w", ""):gsub("\"", ""):gsub(">", ""):gsub("--", "0")
			trow = trow:sub(se)
			local priceString = ""
			local allowedChars = {
				["1"] = "1",
				["2"] = "2",
				["3"] = "3",
				["4"] = "4",
				["5"] = "5",
				["6"] = "6",
				["7"] = "7",
				["8"] = "8",
				["9"] = "9",
				["0"] = "0",
				[","] = "."
			}
			for i = 1, price:len() do
				if allowedChars[price:sub(i, i)] and i % 2 == 0 then
					priceString = priceString .. allowedChars[price:sub(i, i)]
				end
			end
			table.insert(prices[quality], tonumber(priceString) * euroToDollar)
		end
		ss, se = event.response:find("</tr>")
		event.response = event.response:sub(se)
	end
	prices = convertPrices(prices)
	local id = event.url:sub(-4)
	id = id:sub(1, id:len() - 1):gsub("/", ""):gsub("n", ""):gsub("e", "")
	if id == "355" then
		rarity = Rarity.red
	end
	local defaultPrices = {
		[Rarity.gray] = 0.03,
		[Rarity.lightblue] = 0.05,
		[Rarity.blue] = 0.06,
		[Rarity.purple] = 0.25,
		[Rarity.pink] = 2,
		[Rarity.red] = 120,
		[Rarity.gold] = 120
	}
	local noFix = false
	if glovePriceTable[tonumber(id)] then
		noFix = true
		for i = 1, 5 do
			if glovePriceTable[tonumber(id)][i] then
				prices[i] = glovePriceTable[tonumber(id)][i]
			end
		end
	end
	if tableLength(prices) == 0 then
		prices[Quality.battlescarred] = defaultPrices[rarity]
	end
	prices = fillupPrices(prices)
	if not noFix then
		prices = fixPrices(prices, name)
	end
	for i = 1, 5 do
		prices[i] = math.round(prices[i] * 100) / 100
		if 3000 < prices[i] then
			print("Gloves price too high: " .. name .. " | " .. prices[i])
		end
	end
	if tableLength(prices) ~= 5 then
		print(id .. " | Prices need fillup!")
	end
	local luaPriceString = "prices = {\n"
	for i, price in pairs(prices) do
		luaPriceString = luaPriceString .. "\t\t\t[" .. i .. "] = " .. price .. ",\n"
	end
	luaPriceString = luaPriceString .. "\t\t}"
	local luaStr = "\t[" .. id .. [[
] = {
		id = ]] .. id .. [[
,
		name = "]] .. name .. [[
",
		]] .. luaPriceString .. [[
,
		rarity = ]] .. rarity
	luaStr = luaStr .. [[

	},
]]
	luaGloveFile:write(luaStr)
	if gloveCount >= #Game.gloves then
		luaGloveFile:write([[

}]])
		luaGloveFile:close()
	end
end
function StashSaver.start(options)
	if options.scrapGloves then
		print("Scrapping gloves started...")
		local luaPath = system.pathForFile("glovedata.lua", system.DocumentsDirectory)
		luaGloveFile = io.open(luaPath, "w")
		luaGloveFile:write("return {\n")
		print("Saving to: " .. luaPath)
		local i = 1
		for _, skin in ipairs(Game.gloves) do
			print("Scrapping glove " .. i .. " of " .. #Game.gloves)
			local URL = "http://csgostash.com/glove/" .. skin.stashId .. "/"
			network.request(URL, "GET", networkGloveListener, {localId = i})
			sleep(80)
			i = i + 1
		end
	end
	network.request("http://csgostash.com/skin/668/", "GET", function()
	end)
	sleep(100)
	if options.scrapSkins then
		print("Scrapping skins started...")
		local luaPath = system.pathForFile("skindata.lua", system.DocumentsDirectory)
		luaSkinFile = io.open(luaPath, "w")
		luaSkinFile:write("return {\n")
		print("Saving to: " .. luaPath)
		local i = 1
		for _, skin in ipairs(Game.skins) do
			if i % 10 == 0 then
				print("Scrapping skin " .. i .. " of " .. #Game.skins)
			end
			local URL = "http://csgostash.com/skin/" .. skin.stashId .. "/"
			network.request(URL, "GET", networkSkinListener, {localId = i})
			sleep(95)
			i = i + 1
		end
	end
	if options.scrapStickers then
		print("Scrapping stickers started...")
		luaPath = system.pathForFile("stickerdata.lua", system.DocumentsDirectory)
		luaStickerFile = io.open(luaPath, "w")
		luaStickerFile:write("return {\n")
		print("Saving to: " .. luaPath)
		local i = 1
		for _, sticker in ipairs(Game.stickers) do
			if sticker.stashId then
				totalStickerCount = totalStickerCount + 1
				print("Scrapping sticker " .. i .. " of " .. #Game.stickers)
				local URL = "http://csgostash.com/sticker/" .. sticker.stashId .. "/"
				network.request(URL, "GET", networkStickerListener, {localId = i})
				sleep(95)
				i = i + 1
			end
		end
	end
end
return StashSaver
