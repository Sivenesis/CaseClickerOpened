local GameInit = {}
local loadSkinData = function()
	local skinData = require("data.skindata")
	for i = 1, #Game.skins do
		if not skinData[Game.skins[i].stashId] then
			print("Skin with stash id #" .. Game.skins[i].stashId .. " not found!")
			return false
		end
		Game.skins[i].name = skinData[Game.skins[i].stashId].name
		Game.skins[i].rarity = skinData[Game.skins[i].stashId].rarity
		Game.skins[i].prices = skinData[Game.skins[i].stashId].prices
		Game.skins[i].isKnife = skinData[Game.skins[i].stashId].isKnife
		Game.skins[i].statTrakAvailable = skinData[Game.skins[i].stashId].statTrakAvailable
		Game.skins[i].souvenirAvailable = skinData[Game.skins[i].stashId].souvenirAvailable
	end
end
local loadGloveData = function()
	local gloveData = require("data.glovedata")
	for i = 1, #Game.gloves do
		Game.gloves[i].name = gloveData[Game.gloves[i].stashId].name
		Game.gloves[i].rarity = gloveData[Game.gloves[i].stashId].rarity
		Game.gloves[i].prices = gloveData[Game.gloves[i].stashId].prices
	end
end
local loadStickerData = function()
	local stickerData = require("data.stickerdata")
	for i = 1, #Game.stickers do
		if Game.stickers[i].stashId then
			if not stickerData[Game.stickers[i].stashId] then
				print(Game.stickers[i].stashId .. " not found!")
			end
			if not Game.stickers[i].name then
				Game.stickers[i].name = stickerData[Game.stickers[i].stashId].name
			end
			if not Game.stickers[i].rarity then
				Game.stickers[i].rarity = stickerData[Game.stickers[i].stashId].rarity
			end
			if not Game.stickers[i].price then
				Game.stickers[i].price = stickerData[Game.stickers[i].stashId].price
			end
		end
	end
end
local initRankUpgrades = function()
	for i = 2, #Game.ranks do
		local unlocked = false
		if i == Game.rank + 1 then
			unlocked = true
		end
		Lang.upgrades[Game.ranks[i].name] = {}
		Lang.upgrades[Game.ranks[i].name].name = Game.ranks[i].name
		Lang.upgrades[Game.ranks[i].name].description = ("Upgrades your rank to " .. Game.ranks[i].name .. ".\r\nUnlocks new upgrades."):gsub("IIII", "IV")
		Game.upgrades[Game.ranks[i].name] = {
			image = {
				name = "ranks/" .. i .. ".png",
				width = 149.79999999999998,
				height = 60.199999999999996
			},
			requirements = {
				cost = Game.ranks[i].cost,
				openedBoxes = Game.ranks[i].openedCases
			},
			type = Upgrade.unlockable,
			isRank = true,
			unlocked = unlocked,
			onBuy = function()
				Game.rank = Game.rank + 1
				for i = 1, #Game.ranks[Game.rank].upgrades do
					Game.unlockUpgrade(Game.ranks[Game.rank].upgrades[i])
				end
				if Game.ranks[Game.rank].name == "Gold Nova I" then
					Game.unlockAchievement("Out of Silver")
				elseif Game.ranks[Game.rank].name == "Master Guardian I" then
					Game.unlockAchievement("Out of Gold")
				elseif Game.ranks[Game.rank].name == "Legendary Eagle" then
					Game.unlockAchievement("The Eagle")
				elseif Game.ranks[Game.rank].name == "The Global Elite" then
					Game.unlockAchievement("GLOBAL ELITE")
				end
				Menu.showRank()
				MissionManager.checkMissionsForCompletion()
				Analytics.setProgress("Start", "Rank", Game.ranks[Game.rank].name)
				if Game.rank < #Game.ranks then
					Game.unlockUpgrade(Game.ranks[Game.rank + 1].name)
				end
			end
		}
	end
end
local initItems = function()
	for i = 1, #Game.cases do
		Game.cases[i].type = Item.case
		Game.cases[i].sellPrice = math.round(Game.cases[i].price / 4 * 100) / 100
	end
	for i = 1, #Game.souvenirs do
		Game.souvenirs[i].type = Item.souvenir
		Game.souvenirs[i].count = 0
		if Game.souvenirs[i].price then
			Game.souvenirs[i].sellPrice = math.round(Game.souvenirs[i].price / 2 * 100) / 100
		end
	end
	local capsulePrices = require("data.capsuleprices")
	for i = 1, #Game.capsules do
		Game.capsules[i].type = Item.capsule
		Game.capsules[i].count = 0
		Game.capsules[i].price = capsulePrices[i] or 50
		Game.capsules[i].sellPrice = math.round(Game.capsules[i].price / 2 * 100) / 100
	end
	for _, upgrade in pairs(Game.upgrades) do
		upgrade.defaultUnlocked = upgrade.unlocked
	end
	for i = 1, #Game.keys do
		Game.keys[i].type = Item.key
		Game.keys[i].rarity = Rarity.pink
	end
	for i = 1, #Game.skins do
		Game.skins[i].type = Item.skin
		Game.skins[i].id = i
	end
	for i = 1, #Game.gloves do
		Game.gloves[i].type = Item.glove
		Game.gloves[i].id = i
	end
	for i = 1, #Game.stickers do
		Game.stickers[i].type = Item.sticker
		Game.stickers[i].id = i
	end
	local collectionPrices = require("data.collectionprices")
	for i = 1, #Game.collections do
		Game.collections[i].type = Item.collection
		Game.collections[i].price = collectionPrices[i] or 50
		Game.collections[i].sellPrice = math.round(Game.collections[i].price / 2 * 100) / 100
	end
end
local initShopSouvenirs = function()
	local tmp = {}
	for _, souvenir in ipairs(Game.souvenirs) do
		if souvenir.price then
			table.insert(tmp, souvenir)
		end
	end
	table.sort(tmp, function(a, b)
		return a.price < b.price
	end)
	for _, souvenir in ipairs(tmp) do
		local entry = {
			name = souvenir.name:gsub(" Collection", ""),
			holdBuy = true,
			getDescription = function()
				return "Count: " .. Game.souvenirs[souvenir.id].count
			end,
			image = {
				path = "souvenirs/" .. souvenir.image,
				width = 179.2,
				height = 138.6
			},
			imageCallback = function(event)
				Game.showSouvenirInfo(souvenir.id)
				return true
			end,
			getButtonText = function(buyMultiplier)
				return "$" .. formatPrice(souvenir.price * buyMultiplier)
			end,
			multipleBuy = true,
			canBeBought = function(buyMultiplier)
				if Game.money >= souvenir.price * buyMultiplier then
					return true
				else
					return false
				end
			end,
			onBuy = function(event, buyId)
				Game.buySouvenir(souvenir.id)
				GUI.showAnimatedText(nil, "Bought!", event.x * (math.random(95, 105) / 100), event.y * (math.random(95, 100) / 100))
			end,
			onMultipleBuy = function(event, buyAmount)
				Game.buySouvenir(souvenir.id, buyAmount)
				GUI.showAnimatedText(nil, "Bought!", event.x * (math.random(95, 105) / 100), event.y * (math.random(95, 100) / 100))
			end
		}
		table.insert(Game.shopItems.Souvenirs, entry)
	end
end
local initShopCollections = function()
	local tmp = {}
	for _, collection in ipairs(Game.collections) do
		table.insert(tmp, collection)
	end
	table.sort(tmp, function(a, b)
		return a.price < b.price
	end)
	for _, collection in ipairs(tmp) do
		local entry = {
			name = collection.name:gsub(" Collection", ""),
			holdBuy = true,
			getDescription = function()
				return "Count: " .. collection.count
			end,
			image = {
				path = "collections/" .. collection.image,
				width = 179.2,
				height = 138.6
			},
			imageCallback = function(event)
				Game.showCollectionInfo(collection.id)
				return true
			end,
			getButtonText = function(buyMultiplier)
				return "$" .. formatPrice(collection.price * buyMultiplier)
			end,
			multipleBuy = true,
			canBeBought = function(buyMultiplier)
				if Game.money >= collection.price * buyMultiplier then
					return true
				else
					return false
				end
			end,
			onBuy = function(event, buyId)
				Game.buyCollection(collection.id)
				GUI.showAnimatedText(nil, "Bought!", event.x * (math.random(95, 105) / 100), event.y * (math.random(95, 100) / 100))
			end,
			onMultipleBuy = function(event, buyAmount)
				Game.buyCollection(collection.id, buyAmount)
				GUI.showAnimatedText(nil, "Bought!", event.x * (math.random(95, 105) / 100), event.y * (math.random(95, 100) / 100))
			end
		}
		table.insert(Game.shopItems.Collections, entry)
	end
end
local initShopCapsules = function()
	local tmp = {}
	for _, capsule in ipairs(Game.capsules) do
		table.insert(tmp, capsule)
	end
	table.sort(tmp, function(a, b)
		return a.price < b.price
	end)
	for _, capsule in ipairs(tmp) do
		local entry = {
			name = capsule.name,
			subName = capsule.subName,
			getDescription = function()
				return "Count: " .. Game.capsules[capsule.id].count
			end,
			image = {
				path = "capsules/" .. capsule.image,
				width = 179.2,
				height = 134.39999999999998
			},
			imageCallback = function(event)
				Game.showCapsuleInfo(capsule.id)
				return true
			end,
			holdBuy = true,
			getButtonText = function(buyMultiplier)
				return "$" .. formatPrice(capsule.price * buyMultiplier)
			end,
			multipleBuy = true,
			canBeBought = function(buyMultiplier)
				if Game.money >= capsule.price * buyMultiplier then
					return true
				else
					return false
				end
			end,
			onBuy = function(event, buyId)
				Game.buyCapsule(capsule.id)
				GUI.showAnimatedText(nil, "Bought!", event.x * (math.random(95, 105) / 100), event.y * (math.random(95, 100) / 100))
			end,
			onMultipleBuy = function(event, buyAmount)
				Game.buyCapsule(capsule.id, buyAmount)
				GUI.showAnimatedText(nil, "Bought!", event.x * (math.random(95, 105) / 100), event.y * (math.random(95, 100) / 100))
			end,
			isUnlocked = function()
				if capsule.unlockingUpgrade then
					if Game.isUpgradeBought(capsule.unlockingUpgrade) then
						return true
					else
						return false
					end
				end
				return true
			end
		}
		if capsule.hasAutographs then
			table.insert(Game.shopItems.Autographs, entry)
		else
			table.insert(Game.shopItems.Capsules, entry)
		end
	end
end
local initShopKeys = function()
	for _, key in ipairs(Game.keys) do
		local price = 2.5
		if key.price then
			price = key.price
		end
		local entry = {
			name = key.name,
			getDescription = function()
				return "Count: " .. Game.keys[key.id].count
			end,
			holdBuy = true,
			image = {
				path = "keys/" .. key.image,
				width = 155.25,
				height = 133.5
			},
			getButtonText = function(buyMultiplier)
				return "$" .. formatPrice(price * buyMultiplier)
			end,
			multipleBuy = true,
			canBeBought = function(buyMultiplier)
				if Game.money >= price * buyMultiplier then
					return true
				else
					return false
				end
			end,
			onBuy = function(event, buyId)
				Game.buyKey(key.id)
				GUI.showAnimatedText(nil, "Bought!", event.x * (math.random(95, 105) / 100), event.y * (math.random(95, 100) / 100))
				Game.onKeyBuy()
			end,
			onMultipleBuy = function(event, buyAmount)
				Game.buyKey(key.id, buyAmount)
				GUI.showAnimatedText(nil, "Bought!", event.x * (math.random(95, 105) / 100), event.y * (math.random(95, 100) / 100))
			end
		}
		table.insert(Game.shopItems.Keys, entry)
	end
end
local initShopCases = function()
	local tmp = {}
	for _, case in ipairs(Game.cases) do
		table.insert(tmp, case)
	end
	table.sort(tmp, function(a, b)
		return a.price < b.price
	end)
	for _, case in ipairs(tmp) do
		local entry = {
			name = case.name,
			holdBuy = true,
			getDescription = function()
				return "Count: " .. Game.cases[case.id].count
			end,
			image = {
				path = "cases/" .. case.image,
				width = 180.75,
				height = 132
			},
			imageCallback = function(event)
				Game.showCaseInfo(case.id)
				return true
			end,
			getButtonText = function(buyMultiplier)
				return "$" .. formatPrice(case.price * buyMultiplier)
			end,
			multipleBuy = true,
			canBeBought = function(buyMultiplier)
				if Game.money >= case.price * buyMultiplier then
					return true
				else
					return false
				end
			end,
			onBuy = function(event, buyId)
				Game.buyCase(case.id)
				GUI.showAnimatedText(nil, "Bought!", event.x * (math.random(95, 105) / 100), event.y * (math.random(95, 100) / 100))
			end,
			onMultipleBuy = function(event, buyAmount)
				Game.buyCase(case.id, buyAmount)
				GUI.showAnimatedText(nil, "Bought!", event.x * (math.random(95, 105) / 100), event.y * (math.random(95, 100) / 100))
			end,
			isUnlocked = function()
				if case.unlockingUpgrade then
					if Game.isUpgradeBought(case.unlockingUpgrade) then
						return true
					else
						return false
					end
				end
				return true
			end
		}
		table.insert(Game.shopItems.Cases, entry)
	end
end
local fixEquipmentItemsQualities = function()
	for _, item in ipairs(Game.equipment) do
		if item.type == Item.skin then
			local disabledQualities = Game.skins[item.id].disabledQualities
			if disabledQualities then
				local enabledQualities = {
					[1] = 1,
					[2] = 2,
					[3] = 3,
					[4] = 4,
					[5] = 5
				}
				for _, quality in ipairs(disabledQualities) do
					enabledQualities[quality] = nil
				end
				if not enabledQualities[item.quality] then
					local newQuality = Quality.battlescarred
					for i = 1, 5 do
						if enabledQualities[i] then
							newQuality = i
							break
						end
					end
					item.quality = newQuality
				end
			end
		end
	end
end
local function initShopItems()
	initShopCollections()
	initShopSouvenirs()
	initShopCapsules()
	initShopKeys()
	initShopCases()
end
function GameInit.postLoadInit()
	Game.knifeChance = 3
	if Game.isUpgradeBought("More Knives I") then
		Game.knifeChance = Game.knifeChance + 1
	end
	if Game.isUpgradeBought("More Knives II") then
		Game.knifeChance = Game.knifeChance + 1
	end
	if Game.isUpgradeBought("More Knives III") then
		Game.knifeChance = Game.knifeChance + 1
	end
	if Game.others.statTrakGuarantee then
		Game.others.statTrakGuarantee = false
		Game.others.statTrakGuarantees = Game.others.statTrakGuarantees + 1
	end
	fixEquipmentItemsQualities()
	for _, upgrade in pairs(Game.upgrades) do
		if upgrade.bought then
			if upgrade.clickSearchGain then
				Game.clickSearchGain = Game.clickSearchGain + upgrade.clickSearchGain
			end
			if upgrade.searchBarLimitAdd then
				Game.searchBarLimit = Game.searchBarLimit + upgrade.searchBarLimitAdd
			end
			if upgrade.clickMoneyGain then
				Game.clickMoneyGain = Game.clickMoneyGain + upgrade.clickMoneyGain
			end
			if upgrade.searchPerSecond then
				Game.searchPerSecond = Game.searchPerSecond + upgrade.searchPerSecond
			end
			if upgrade.criticalHitChance then
				Game.criticalHitChance = Game.criticalHitChance + upgrade.criticalHitChance
			end
			if upgrade.unlockUpgrades then
				for _, name in ipairs(upgrade.unlockUpgrades) do
					Game.unlockUpgrade(name)
				end
			end
		end
	end
	if not Game.jackpot.expensiveItems then
		Game.jackpot.expensiveItems = 0
	end
	Game.performOnceAction(5, function()
		if isTablet() then
			Game.settings.tabletMode = true
		end
	end)
	if Game.settings.tabletMode then
		Game.guiScale = Game.tabletModeScale
		Menu.refreshItems()
	end
end
function GameInit.init()
	loadSkinData()
	loadGloveData()
	loadStickerData()
	initRankUpgrades()
	initItems()
	initShopItems()
	AchievementManager.init()
	RandomSkins.init()
	Game.unlockUpgrade("Match Betting")
end
return GameInit
