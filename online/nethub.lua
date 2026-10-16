local json = require("json")
local NetHub = {
	version = 57,
	jackpotVersion = 57,
	tradeLimit = 100,
	marketOffersSinceLogin = 0,
	server = "offline",
	cache = {
		trades = {},
		tradeList = nil
	}
}

-- Community Bot Roster
local BOTS = {
	{ name = "CS_Trader_99", avatar = "bot joe.jpg", minMargin = 0.95 },
	{ name = "Karambit_God", avatar = "f4d3.jpg", minMargin = 1.05, prefersKnives = true },
	{ name = "Sticker_Craftsman", avatar = "delicious_doge.jpg", minMargin = 0.92 },
	{ name = "Lowball_Or_Block", avatar = "bad_player.jpg", minMargin = 1.15 },
	{ name = "DragonLoreFan", avatar = "eliteplayer1337.jpg", minMargin = 1.00 },
	{ name = "Gabe_Follower", avatar = "bhaal.jpg", minMargin = 0.90 },
	{ name = "xX_Sniper_Xx", avatar = "777snipe777.jpg", minMargin = 0.95 },
	{ name = "TradeFastMen", avatar = "cykab.jpg", minMargin = 0.95 },
	{ name = "CobblestoneKing", avatar = "anatolij.jpg", minMargin = 1.02 },
	{ name = "Shroud_Fan_420", avatar = "ayy lmao.jpg", minMargin = 0.95 },
	{ name = "CaseHardenedBlue", avatar = "crypton.jpg", minMargin = 1.05 },
	{ name = "Global_Elite_88", avatar = "flamie.jpg", minMargin = 1.00 }
}

local function getBotByName(name)
	if not name then return BOTS[1] end
	for i = 1, #BOTS do
		if BOTS[i].name:lower() == name:lower() then
			return BOTS[i]
		end
	end
	return { name = name, avatar = "bot potato.jpg", minMargin = 0.98 }
end

local function generateBotItem(targetRarity, isKnife)
	if isKnife then
		local knifeIndices = {}
		for i = 1, #Game.skins do
			if Game.skins[i] and Game.skins[i].isKnife then
				table.insert(knifeIndices, i)
			end
		end
		local knife = #knifeIndices > 0 and Game.skins[choose(knifeIndices)] or choose(Game.skins)
		return {
			item_id = knife.id,
			quality = math.random(1, 3),
			stattrak = math.random(1, 5) == 1 and 1 or 0,
			name = knife.name,
			type = Item.skin
		}
	end

	local rarity = targetRarity or math.random(2, 5)
	local candidates = {}
	for i = 1, #Game.skins do
		if Game.skins[i] and Game.skins[i].rarity == rarity then
			table.insert(candidates, Game.skins[i])
		end
	end
	local skin = #candidates > 0 and choose(candidates) or choose(Game.skins)
	local quality = 1
	if QualityManager and QualityManager.getRandomQuality then
		quality = QualityManager.getRandomQuality(skin)
	else
		quality = math.random(1, 5)
	end
	local isStatTrak = math.random(1, 6) == 1
	return {
		item_id = skin.id,
		quality = quality,
		stattrak = isStatTrak and 1 or 0,
		name = skin.name,
		type = Item.skin
	}
end

NetHub.items = {
	{
		name = "Trade with a player",
		shortName = "Trades",
		upgrade = "Trades",
		callback = function()
			composer.gotoScene("scenes.nethub.trades")
			Menu.refreshItems()
		end,
		image = "trades/accepted.png",
		scene = "scenes.nethub.trades"
	},
	{
		name = "Bet on a match",
		shortName = "Match Betting",
		upgrade = "Match Betting",
		buttonText = "Bet!",
		callback = function()
			composer.gotoScene("scenes.nethub.matches")
			Menu.refreshItems()
		end,
		image = "upgrades/bets.png",
		scene = "scenes.nethub.matches"
	},
	{
		name = "Play in a jackpot",
		shortName = "Online Jackpots",
		callback = function()
			composer.gotoScene("scenes.jackpot")
			Menu.refreshItems()
		end,
		image = "upgrades/jackpot.png",
		scene = "scenes.jackpot"
	},
	{
		name = "Play  in a raffle",
		shortName = "Raffles",
		callback = function()
			GUI.showMessageBox(Lang.common.connecting .. "...", Lang.common.pleaseWait, false)
			timer.performWithDelay(200, function()
				local Raffles = require("online.raffles")
				Raffles.connect(function()
					Menu.refreshItems()
				end)
			end)
		end,
		image = "raffle.png",
		scene = "scenes.nethub.raffles"
	},
	{
		name = "Marketplace",
		shortName = "Market",
		callback = function()
			composer.gotoScene("scenes.nethub.marketplace")
			Menu.refreshItems()
		end,
		image = "market.png",
		buttonText = "Enter",
		scene = "scenes.nethub.marketplace"
	},
	{
		name = "Enter a promo code",
		shortName = "Promo Codes",
		buttonText = "Enter code!",
		dontShowInMenu = true,
		callback = function()
			NetHub.enterPromoCode()
		end,
		image = "promocode.png"
	}
}

local function ensureOfflineTrades()
	Game.others.offlineTrades = Game.others.offlineTrades or {}
	if #Game.others.offlineTrades == 0 then
		local initialOffers = {
			{ bot = BOTS[1], rarity = 4, chat = "Looking for a fair 1:1 or slight upgrade. Send offers!" },
			{ bot = BOTS[2], rarity = 5, isKnife = true, chat = "Trading this knife for good skin overpay or another knife." },
			{ bot = BOTS[5], rarity = 5, chat = "Have nice Covert skin, looking for AWP / M4 trades." },
			{ bot = BOTS[8], rarity = 3, chat = "Fast trade men, send anything fair and I accept instant." }
		}
		for i = 1, #initialOffers do
			local offer = initialOffers[i]
			local botItem = generateBotItem(offer.rarity, offer.isKnife)
			local trade = {
				id = i,
				user1 = offer.bot.name,
				user2 = NetHub.getNickname(),
				user1accepted = 0,
				user2accepted = 0,
				user1items = 0,
				user2items = 0,
				state = 0,
				created = os.time() - (i * 3600),
				key = "bot_trade_key_" .. i,
				ownItems = {},
				traderItems = { botItem },
				messages = {
					{
						id = 1,
						text = offer.chat,
						user = 2,
						nick = offer.bot.name,
						timestamp = os.time() - (i * 3600)
					}
				}
			}
			table.insert(Game.others.offlineTrades, trade)
			NetHub.cache.trades[i] = trade
		end
		Game.save()
	else
		for i = 1, #Game.others.offlineTrades do
			local tr = Game.others.offlineTrades[i]
			NetHub.cache.trades[tr.id] = tr
		end
	end
end

function NetHub.getNickname()
	if not Game.others.netNick or Game.others.netNick == "???" or Game.others.netNick == "" then
		Game.others.netNick = "Player"
	end
	return Game.others.netNick
end

function NetHub.isConnected()
	return true
end

function NetHub.register(successFunc)
	ensureOfflineTrades()
	if successFunc then
		timer.performWithDelay(50, function()
			successFunc(true)
		end)
	end
	return true
end

function NetHub.getTradeList(callbackFunc)
	ensureOfflineTrades()
	timer.performWithDelay(50, function()
		if callbackFunc then
			callbackFunc(true, {
				trades_today = #Game.others.offlineTrades,
				trades = Game.others.offlineTrades
			})
		end
	end)
end

function NetHub.createTrade(playerName, callbackFunc)
	if not playerName or playerName == "" or playerName:lower() == NetHub.getNickname():lower() then
		if playerName and playerName:lower() == NetHub.getNickname():lower() then
			return callbackFunc(false, { text = Lang.nethub.cannotTradeWithYourself .. "." })
		end
		return callbackFunc(false, { text = Lang.nethub.enterName .. "." })
	end

	ensureOfflineTrades()
	local botInfo = getBotByName(playerName)
	local tradeId = #Game.others.offlineTrades + 1
	local botItem = generateBotItem(math.random(3, 5), botInfo.prefersKnives)

	local newTrade = {
		id = tradeId,
		user1 = NetHub.getNickname(),
		user2 = botInfo.name,
		user1accepted = 0,
		user2accepted = 0,
		user1items = 0,
		user2items = 0,
		state = 0,
		created = os.time(),
		key = "trade_key_" .. tradeId,
		ownItems = {},
		traderItems = { botItem },
		messages = {
			{
				id = 1,
				text = "Hello! Send me an offer. I am looking for fair value.",
				message = "Hello! Send me an offer. I am looking for fair value.",
				user = 2,
				nick = botInfo.name,
				timestamp = os.time()
			}
		}
	}

	table.insert(Game.others.offlineTrades, newTrade)
	NetHub.cache.trades[tradeId] = newTrade
	Game.save()

	timer.performWithDelay(50, function()
		if callbackFunc then
			callbackFunc(true, { trade = newTrade })
		end
	end)
end

function NetHub.getTradeInfo(tradeId, callbackFunc)
	tradeId = tonumber(tradeId)
	ensureOfflineTrades()
	local tr = NetHub.cache.trades[tradeId]
	timer.performWithDelay(50, function()
		if callbackFunc then
			if tr then
				callbackFunc(true, tr)
			else
				callbackFunc(false, { text = "Trade not found." })
			end
		end
	end)
end

function NetHub.loadTrade(tradeId, loadFromCache)
	tradeId = tonumber(tradeId)
	ensureOfflineTrades()
	local tr = NetHub.cache.trades[tradeId]
	if tr then
		composer.removeScene("scenes.nethub.trade")
		composer.gotoScene("scenes.nethub.trade", { params = tr })
	else
		GUI.showMessageBox(Lang.common.error, Lang.nethub.couldNotLoadTrade .. ".")
	end
end

local function calculateItemsTotal(itemTable)
	local total = 0
	if not itemTable then return 0 end
	for i = 1, #itemTable do
		local it = itemTable[i]
		local price = Game.getItemPrice({
			id = it.item_id or it.id,
			quality = it.quality or 1,
			statTrak = (it.stattrak and it.stattrak > 0) or it.statTrak,
			pattern = it.pattern,
			stickers = it.stickers
		})
		total = total + (price or 0)
	end
	return total
end

function NetHub.addItemsToTrade(tradeId, items, callbackFunc)
	tradeId = tonumber(tradeId)
	local tr = NetHub.cache.trades[tradeId]
	if not tr then
		return callbackFunc(false, { error = true, text = "Trade not found" })
	end

	for _, item in ipairs(items) do
		table.insert(tr.ownItems, {
			item_id = item.id,
			quality = item.quality,
			stattrak = (item.statTrak and 1) or 0,
			name = item.name,
			pattern = item.pattern,
			stickers = item.stickers,
			type = Item.skin
		})
	end

	local botInfo = getBotByName(tr.user2 == NetHub.getNickname() and tr.user1 or tr.user2)
	local playerVal = calculateItemsTotal(tr.ownItems)
	local botVal = calculateItemsTotal(tr.traderItems)
	local requiredMargin = botInfo.minMargin or 0.95

	if botVal > 0 and playerVal >= botVal * requiredMargin then
		tr.user2accepted = 1
		table.insert(tr.messages, {
			id = #tr.messages + 1,
			text = "+rep! That looks like a great offer. I've accepted on my end!",
			user = 2,
			nick = botInfo.name,
			timestamp = os.time()
		})
	else
		tr.user2accepted = 0
		local diff = math.max(0, botVal * requiredMargin - playerVal)
		table.insert(tr.messages, {
			id = #tr.messages + 1,
			text = "Your offer is currently $" .. formatPrice(playerVal) .. " vs my $" .. formatPrice(botVal) .. ". Please add around $" .. formatPrice(diff) .. " more value to balance.",
			user = 2,
			nick = botInfo.name,
			timestamp = os.time()
		})
	end

	Game.save()
	timer.performWithDelay(50, function()
		callbackFunc(true, {
			error = false,
			key = tr.key,
			ownItems = tr.ownItems,
			traderItems = tr.traderItems
		})
	end)
end

function NetHub.removeItemFromTrade(tradeId, tradeItemId, callbackFunc)
	tradeId = tonumber(tradeId)
	local tr = NetHub.cache.trades[tradeId]
	if tr and tr.ownItems and tr.ownItems[tradeItemId] then
		table.remove(tr.ownItems, tradeItemId)
		tr.user2accepted = 0
	end
	Game.save()
	timer.performWithDelay(50, function()
		callbackFunc(true, { error = false, key = tr and tr.key or "" })
	end)
end

function NetHub.acceptTrade(tradeId, tradeKey)
	tradeId = tonumber(tradeId)
	local tr = NetHub.cache.trades[tradeId]
	if not tr then
		return GUI.showMessageBox(Lang.common.error, "Trade not found.")
	end

	if tr.user2accepted ~= 1 then
		return GUI.showMessageBox(Lang.common.error, "The trader has not accepted your offer yet. Please add more value in items.")
	end

	tr.state = 2
	tr.user1accepted = 1
	tr.user2accepted = 1
	tr.user1items = 1
	tr.user2items = 1
	StatisticManager.addStatistic("tradesCompleted")

	local receivedItems = {}
	for i = 1, #tr.traderItems do
		local src = tr.traderItems[i]
		local it = {
			id = src.item_id or src.id,
			item_id = src.item_id or src.id,
			quality = src.quality or 1,
			stattrak = src.stattrak or 0,
			statTrak = (src.stattrak and src.stattrak > 0) or false,
			name = src.name or "",
			n = src.name or "",
			pattern = src.pattern,
			stickers = src.stickers,
			type = Item.skin
		}
		table.insert(receivedItems, it)
		Game.addItem(it, false, it.statTrak, false, {
			pattern = it.pattern,
			name = it.name,
			quality = it.quality,
			stickers = it.stickers,
			disableAchievements = true
		})
	end

	local botInfo = getBotByName(tr.user2 == NetHub.getNickname() and tr.user1 or tr.user2)
	table.insert(tr.messages, {
		id = #tr.messages + 1,
		text = "Trade completed! Thanks for the trade, have fun with the skins! +rep",
		user = 2,
		nick = botInfo.name,
		timestamp = os.time()
	})

	Game.recalculateEquipmentWorth()
	Game.save()
	NetHub.loadTrade(tradeId, true)

	timer.performWithDelay(150, function()
		composer.showOverlay("scenes.itemlist", {
			params = {
				firstText = Lang.nethub.tradeAccepted .. "!",
				secondText = Lang.nethub.newItems .. ":",
				items = receivedItems
			}
		})
	end)
end

function NetHub.getTradeItems(tradeId)
	tradeId = tonumber(tradeId)
	local tr = NetHub.cache.trades[tradeId]
	if not tr then
		return GUI.showMessageBox(Lang.common.error, "Trade not found.")
	end
	NetHub.loadTrade(tradeId, true)
end

function NetHub.cancelTrade(tradeId)
	tradeId = tonumber(tradeId)
	local tr = NetHub.cache.trades[tradeId]
	if not tr then
		return GUI.showMessageBox(Lang.common.error, Lang.nethub.couldNotCancel .. ".")
	end

	tr.state = 1
	tr.user1accepted = 0
	tr.user2accepted = 0

	local returnedItems = {}
	for i = 1, #tr.ownItems do
		local src = tr.ownItems[i]
		local it = {
			id = src.item_id or src.id,
			item_id = src.item_id or src.id,
			quality = src.quality or 1,
			stattrak = src.stattrak or 0,
			statTrak = (src.stattrak and src.stattrak > 0) or false,
			name = src.name,
			pattern = src.pattern,
			stickers = src.stickers,
			type = Item.skin
		}
		table.insert(returnedItems, it)
		Game.addItem(it, false, it.statTrak, false, {
			pattern = it.pattern,
			quality = it.quality,
			stickers = it.stickers,
			name = it.name,
			disableAchievements = true,
			disableMissions = true
		})
	end
	tr.ownItems = {}

	Game.recalculateEquipmentWorth()
	Game.save()
	NetHub.loadTrade(tradeId, true)

	if #returnedItems > 0 then
		timer.performWithDelay(150, function()
			composer.showOverlay("scenes.itemlist", {
				params = {
					firstText = Lang.nethub.tradeCancelled,
					secondText = Lang.nethub.itemsReturned .. ":",
					items = returnedItems
				}
			})
		end)
	end
end

function NetHub.loadMessages(tradeId, callback, allMessages)
	tradeId = tonumber(tradeId)
	local tr = NetHub.cache.trades[tradeId]
	local msgs = tr and tr.messages or {}
	timer.performWithDelay(50, function()
		if callback then
			callback(true, { messages = msgs })
		end
	end)
end

function NetHub.sendMessage(tradeId, message, callback)
	tradeId = tonumber(tradeId)
	local tr = NetHub.cache.trades[tradeId]
	if not tr or not message or #message == 0 then
		if callback then callback(false, "Could not send message.") end
		return
	end

	tr.messages = tr.messages or {}
	table.insert(tr.messages, {
		id = #tr.messages + 1,
		text = message,
		message = message,
		user = 1,
		nick = NetHub.getNickname(),
		timestamp = os.time()
	})

	local botInfo = getBotByName(tr.user2 == NetHub.getNickname() and tr.user1 or tr.user2)
	local lower = message:lower()
	local reply = "Offer looks interesting. Make sure total value is balanced!"
	if lower:find("hello") or lower:find("hi") or lower:find("hey") then
		reply = "Hey! Looking for fair CS trades. Send your offer whenever you're ready."
	elseif lower:find("accept") or lower:find("deal") then
		reply = "Checking prices... if values match, I will accept immediately!"
	elseif lower:find("low") or lower:find("add") then
		reply = "Check market value difference and add matching skins."
	elseif lower:find("knife") then
		reply = "Knives are always welcome. I overpay slightly for clean knives."
	end

	timer.performWithDelay(600, function()
		table.insert(tr.messages, {
			id = #tr.messages + 1,
			text = reply,
			message = reply,
			user = 2,
			nick = botInfo.name,
			timestamp = os.time()
		})
		Game.save()
	end)

	Game.save()
	if callback then callback(true) end
end

function NetHub.init()
	ensureOfflineTrades()
end

function NetHub.reset()
	NetHub.cache = {
		trades = {},
		tradeList = nil
	}
	composer.removeScene("scenes.nethub.trades")
	composer.removeScene("scenes.nethub.nethub")
end

function NetHub.validateName(name)
	if not name or #name < 3 then
		return false, "The name needs to have at least 3 characters."
	end
	if #name > 15 then
		return false, "The name that you have entered is too long."
	end
	return true, ""
end

function NetHub.changeName(name, successCallback)
	local ok, err = NetHub.validateName(name)
	if not ok then
		return GUI.showMessageBox(Lang.common.error, err)
	end
	Game.others.netNick = name
	Game.lastNickChange = os.time()
	Game.save()
	if successCallback then successCallback() end
	GUI.showMessageBox(Lang.common.success, "Your NetHub nick has been successfully changed.")
end

function NetHub.enterPromoCode()
	composer.showOverlay("overlays.textinput", {
		effect = "fade",
		time = 300,
		params = {
			title = "Promo code",
			text = "Enter a promo code:",
			callback = function(text)
				GUI.showMessageBox("Using promo code", "Please wait...", false)
				timer.performWithDelay(200, function()
					NetHub.usePromoCode(text)
				end)
			end,
			buttonText = "Use code",
			validator = {
				minLength = 1,
				maxLength = 20,
				regex = "[A-Za-z0-9-.]+"
			}
		}
	})
end

function NetHub.usePromoCode(code)
	if not code or code == "" then
		return GUI.showMessageBox(Lang.common.error, "Please enter a promo code.")
	end

	code = code:upper():gsub("%s+", "")
	Game.others.redeemedPromoCodes = Game.others.redeemedPromoCodes or {}

	if Game.others.redeemedPromoCodes[code] then
		return GUI.showMessageBox(Lang.common.error, "This promo code has already been used.")
	end

	local promoRewards = {
		COMMUNITY = { type = "money", value = 25000, desc = "$25,000 Cash" },
		HAWKGAMES = { type = "money", value = 10000, desc = "$10,000 Cash" },
		VIBECODE = { type = "money", value = 1000000, desc = "$1,000,000 Cash & Keys", bonusKeys = 20 },
		FREEKNIFE = { type = "knife", desc = "Free Random Knife" },
		FREEGLOVES = { type = "glove", desc = "Free Random Gloves" },
		CASES50 = { type = "cases", value = 50, desc = "50 Random Cases" },
		STATTRAK = { type = "stattrak", value = 10, desc = "10 StatTrak Guarantees" },
		GLOBALELITE = { type = "rank", value = 18, desc = "Rank 18: The Global Elite" },
		DRAGONLORE = { type = "special_skin", desc = "AWP | Dragon Lore (Factory New)" }
	}

	local reward = promoRewards[code]
	if not reward then
		return GUI.showMessageBox(Lang.common.error, "Invalid promo code. Check spelling and try again.")
	end

	Game.others.redeemedPromoCodes[code] = true

	if reward.type == "money" then
		Game.addMoney(reward.value, "Promo Code", code)
		if reward.bonusKeys then
			for i = 1, #Game.keys do
				Game.keys[i].count = (Game.keys[i].count or 0) + reward.bonusKeys
			end
		end
		GUI.showMessageBox("Success", "Code \"" .. code .. "\" redeemed!\nGranted: " .. reward.desc)
	elseif reward.type == "knife" then
		GUI.showMessageBox("Success", "Code \"" .. code .. "\" redeemed! Opening Knife Draw...", false)
		timer.performWithDelay(400, function()
			Game.showKnifeDraw(true)
		end)
	elseif reward.type == "glove" then
		GUI.showMessageBox("Success", "Code \"" .. code .. "\" redeemed! Opening Glove Draw...", false)
		timer.performWithDelay(400, function()
			Game.showGloveDraw(true)
		end)
	elseif reward.type == "cases" then
		for i = 1, reward.value do
			Game.addItem(choose(Game.cases), false)
		end
		Menu.addAlert("Cases")
		GUI.showMessageBox("Success", "Code \"" .. code .. "\" redeemed!\nAdded 50 Random Cases to inventory.")
	elseif reward.type == "stattrak" then
		Game.others.statTrakGuarantees = (Game.others.statTrakGuarantees or 0) + reward.value
		GUI.showMessageBox("Success", "Code \"" .. code .. "\" redeemed!\nAdded 10 StatTrak Guarantees.")
	elseif reward.type == "rank" then
		Game.rank = 18
		for r = 1, 18 do
			for j = 1, #Game.ranks[r].upgrades do
				Game.unlockUpgrade(Game.ranks[r].upgrades[j])
			end
		end
		Menu.showRank()
		GUI.showMessageBox("Success", "Code \"" .. code .. "\" redeemed!\nPromoted to The Global Elite!")
	elseif reward.type == "special_skin" then
		local dl = Game.skins[400] or Game.skins[#Game.skins]
		if dl then
			Game.addItem(dl, false, true, false, Quality.factorynew)
			Menu.addAlert("Equipment")
			GUI.showMessageBox("Success", "Code \"" .. code .. "\" redeemed!\nStatTrak " .. dl.name .. " (FN) added to Equipment!")
		end
	end

	StatisticManager.addStatistic("usedPromoCodes")
	Game.save()
end

return NetHub
