local json = require("json")
local Bets = {
	betLimit = 25,
	betsToday = 0,
	server = "offline",
	cache = {
		matches = {},
		bets = {}
	},
	bet = {
		items = {},
		selected = 0,
		matchId = 0,
		value = 0
	}
}

local defaultLogos = {
	["Natus Vincere"] = "na'vi",
	["Na'Vi"] = "na'vi",
	["Virtus.pro"] = "vp",
	["VP"] = "vp",
	["MOUZ"] = "mouz",
	["mousesports"] = "mouz",
	["FaZe Clan"] = "faze",
	["Team Liquid"] = "liquid",
	["G2 Esports"] = "g2",
	["SK Gaming"] = "sk",
	["Astralis"] = "astralis",
	["Fnatic"] = "fnatic",
	["Cloud9"] = "cloud9",
	["NiP"] = "nip",
	["EnVyUs"] = "envyus",
	["Titan"] = "titan",
	["Dignitas"] = "dignitas",
	["Renegades"] = "renegades",
	["Gambit"] = "gambit"
}

local TEAMS = {
	{ name = "Astralis", logo = "astralis", tier = 1 },
	{ name = "Natus Vincere", logo = "na'vi", tier = 1 },
	{ name = "Fnatic", logo = "fnatic", tier = 1 },
	{ name = "Cloud9", logo = "cloud9", tier = 2 },
	{ name = "FaZe Clan", logo = "faze", tier = 1 },
	{ name = "NiP", logo = "nip", tier = 2 },
	{ name = "Virtus.pro", logo = "vp", tier = 2 },
	{ name = "Team Liquid", logo = "liquid", tier = 2 },
	{ name = "SK Gaming", logo = "sk", tier = 1 },
	{ name = "EnVyUs", logo = "envyus", tier = 2 },
	{ name = "G2 Esports", logo = "g2", tier = 2 },
	{ name = "Titan", logo = "titan", tier = 2 },
	{ name = "MOUZ", logo = "mouz", tier = 3 },
	{ name = "Dignitas", logo = "dignitas", tier = 3 },
	{ name = "Renegades", logo = "renegades", tier = 3 },
	{ name = "Gambit", logo = "gambit", tier = 2 }
}

local TOURNAMENTS = {
	"ESL Pro League",
	"Major Championship",
	"IEM Katowice",
	"DreamHack Masters",
	"StarLadder StarSeries",
	"ELEAGUE Premier"
}

local function formatTimeRemaining(seconds)
	if seconds <= 0 then
		return "Live"
	end
	local mins = math.floor(seconds / 60)
	if mins < 60 then
		return "in " .. mins .. "m"
	else
		local hours = math.floor(mins / 60)
		local remMins = mins % 60
		return "in " .. hours .. "h " .. remMins .. "m"
	end
end

local function generateMatch(id, offsetMinutes)
	local t1Idx = math.random(1, #TEAMS)
	local t2Idx = math.random(1, #TEAMS)
	while t2Idx == t1Idx do
		t2Idx = math.random(1, #TEAMS)
	end
	local t1 = TEAMS[t1Idx]
	local t2 = TEAMS[t2Idx]

	local baseA = 50 + (t2.tier - t1.tier) * 15 + math.random(-10, 10)
	baseA = math.max(15, math.min(85, baseA))
	local baseB = 100 - baseA

	local totalBets = math.random(3000, 15000)
	local aBets = math.floor(totalBets * (baseA / 100))
	local bBets = totalBets - aBets

	local duration = (offsetMinutes or 15) * 60
	local tournamentName = choose(TOURNAMENTS)
	local timeString = formatTimeRemaining(duration)

	return {
		lounge_id = id,
		a = t1.name,
		b = t2.name,
		alogo = t1.logo,
		blogo = t2.logo,
		abets = aBets,
		bbets = bBets,
		apercent = baseA,
		bpercent = baseB,
		format = math.random(1, 3) == 1 and 1 or 3,
		closed = 0,
		winner = 0,
		date = os.time() + duration,
		endTime = os.time() + duration,
		event = tournamentName,
		tournament = tournamentName,
		timeStr = timeString
	}
end

local function ensureOfflineMatches()
	Game.others.offlineMatches = Game.others.offlineMatches or {}
	local now = os.time()

	-- Keep track of matches that have unresolved player bets
	local activeBetMatchIds = {}
	for _, b in ipairs(Game.others.offlineBets or {}) do
		if b.status == 0 and b.match_id then
			activeBetMatchIds[b.match_id] = true
		end
	end

	-- Update statuses and resolve outcomes for finished matches
	local openMatches = {}
	local finishedMatches = {}
	for i = 1, #Game.others.offlineMatches do
		local m = Game.others.offlineMatches[i]
		m.event = m.event or m.tournament or "Tournament Match"
		m.tournament = m.event

		if m.closed == 0 and now >= (m.endTime or m.date or now) then
			m.closed = 1
			m.closedTime = now
			local roll = math.random(1, 100)
			if roll <= (m.apercent or 50) then
				m.winner = 1
			else
				m.winner = 2
			end
		end

		if m.closed == 0 then
			local remaining = (m.endTime or m.date or (now + 600)) - now
			m.timeStr = formatTimeRemaining(remaining)
			table.insert(openMatches, m)
		else
			m.timeStr = "Finished"
			table.insert(finishedMatches, m)
		end
	end

	-- Prune finished matches (keep active bet matches, plus at most 3 recently finished)
	local prunedFinished = {}
	for _, m in ipairs(finishedMatches) do
		if activeBetMatchIds[m.lounge_id] then
			table.insert(prunedFinished, m)
		elseif #prunedFinished < 3 then
			table.insert(prunedFinished, m)
		end
	end

	-- Always maintain at least 5 upcoming open matches
	Game.others.offlineNextMatchId = Game.others.offlineNextMatchId or 100
	local targetOpenCount = 5
	local needed = targetOpenCount - #openMatches
	if needed > 0 then
		local newOffsets = { 6, 12, 20, 32, 45, 60 }
		for i = 1, needed do
			Game.others.offlineNextMatchId = Game.others.offlineNextMatchId + 1
			local offset = newOffsets[((i - 1) % #newOffsets) + 1] + math.random(1, 4)
			table.insert(openMatches, generateMatch(Game.others.offlineNextMatchId, offset))
		end
	end

	-- Sort open matches by time remaining (nearest first)
	table.sort(openMatches, function(a, b)
		return (a.endTime or 0) < (b.endTime or 0)
	end)

	-- Combine: open matches at top for immediate betting, followed by finished matches
	local combined = {}
	for _, m in ipairs(openMatches) do
		table.insert(combined, m)
	end
	for _, m in ipairs(prunedFinished) do
		table.insert(combined, m)
	end

	Game.others.offlineMatches = combined
	Bets.cache.matches = Game.others.offlineMatches
	Game.save()
end

local function getItemWithPrice(minPrice, maxPrice)
	local item = {}
	local tries = 0
	while tries < 50 do
		tries = tries + 1
		local randomResult = math.random(1, 100)
		if randomResult <= 3 and Game.getRandomKnife then
			item = Game.getRandomKnife(minPrice)
			item.type = Item.skin
			item.quality = math.random(1, 4)
		elseif randomResult <= 8 and Game.getRandomGlove then
			local glove = Game.getRandomGlove()
			item.id = glove.id
			item.type = Item.glove
			item.quality = QualityManager.getRandomQuality(glove)
		elseif randomResult <= 20 and Game.getRandomSticker then
			item.type = Item.sticker
			item.id = Game.getRandomSticker().id
		else
			item.type = Item.skin
			local skin = choose(Game.skins)
			item.id = skin.id
			item.quality = QualityManager and QualityManager.getRandomQuality(skin) or math.random(1, 5)
			item.statTrak = math.random(1, 10) <= 3
		end
		local itemPrice = Game.getItemPrice(item)
		if minPrice <= itemPrice and maxPrice >= itemPrice then
			return item, itemPrice
		end
	end
	-- Fallback
	local skin = choose(Game.skins)
	return { id = skin.id, type = Item.skin, quality = 1, statTrak = false }, Game.getItemPrice({ id = skin.id, quality = 1 })
end

local function getWinnings(betId)
	local bet = Bets.cache.bets[betId]
	if not bet then return {} end
	local items = bet.items or {}
	local value = bet.value or 1
	local worth = 0
	local biggestPrice = 0
	for _, item in ipairs(items) do
		local price = Game.getItemPrice(item)
		worth = worth + price
		if biggestPrice < price then
			biggestPrice = price
		end
	end
	local leftToReturn = worth * value
	if 1 < value then
		biggestPrice = biggestPrice * value
	end
	if biggestPrice < 0.1 then
		biggestPrice = 0.1
	end
	local itemTable = {}
	while 0.1 < leftToReturn and #itemTable < 10 do
		local minimumPrice = math.max(math.min(320, leftToReturn / 4), 0.05)
		local item, price = getItemWithPrice(minimumPrice, math.min(leftToReturn, biggestPrice))
		leftToReturn = leftToReturn - price
		table.insert(itemTable, item)
	end
	return shuffleTable(itemTable)
end

function Bets.loadMatches(callbackFunc)
	ensureOfflineMatches()
	timer.performWithDelay(50, function()
		if callbackFunc then
			callbackFunc(true, {
				bets_today = Bets.betsToday,
				matches = Game.others.offlineMatches
			})
		end
	end)
end

function Bets.loadBets(callbackFunc)
	Game.others.offlineBets = Game.others.offlineBets or {}
	ensureOfflineMatches()

	-- Link match status to bets
	local betList = {}
	for i = 1, #Game.others.offlineBets do
		local b = Game.others.offlineBets[i]
		for m = 1, #Game.others.offlineMatches do
			if Game.others.offlineMatches[m].lounge_id == b.match_id then
				b.match = Game.others.offlineMatches[m]
				break
			end
		end
		table.insert(betList, b)
		Bets.cache.bets[b.id] = b
	end

	timer.performWithDelay(50, function()
		if callbackFunc then
			callbackFunc(true, { bets = betList })
		end
	end)
end

function Bets.placeBet(callbackFunc)
	if #Bets.bet.items == 0 then
		return GUI.showMessageBox(Lang.common.information, Lang.bets.pleaseAddItemsToBet .. ".")
	end
	if Bets.bet.selected == 0 then
		return GUI.showMessageBox(Lang.common.information, Lang.bets.pleaseSelectTeam .. ".")
	end

	table.sort(Bets.bet.items, function(a, b)
		return a < b
	end)
	for i = 1, #Bets.bet.items do
		if Game.equipment[Bets.bet.items[i]] and Game.equipment[Bets.bet.items[i]].locked then
			return GUI.showMessageBox(Lang.common.error, Lang.bets.couldNotPlaceBet .. ".")
		end
	end

	local betItems = {}
	for i = #Bets.bet.items, 1, -1 do
		local it = Game.equipment[Bets.bet.items[i]]
		if it then
			table.insert(betItems, {
				id = it.id,
				item_id = it.id,
				quality = it.quality,
				stattrak = (it.statTrak and 1) or 0,
				statTrak = it.statTrak,
				pattern = it.pattern,
				stickers = it.stickers,
				type = it.type,
				name = it.name
			})
			table.remove(Game.equipment, Bets.bet.items[i])
		end
	end

	Game.others.offlineBets = Game.others.offlineBets or {}
	local betId = #Game.others.offlineBets + 1

	local targetMatch
	for _, m in ipairs(Game.others.offlineMatches or {}) do
		if m.lounge_id == Bets.bet.matchId then
			targetMatch = m
			break
		end
	end

	local newBet = {
		id = betId,
		match_id = Bets.bet.matchId,
		team = Bets.bet.selected,
		value = Bets.bet.value,
		status = 0,
		created = os.time(),
		match = targetMatch,
		items = betItems
	}

	table.insert(Game.others.offlineBets, newBet)
	Bets.cache.bets[betId] = newBet
	Bets.betsToday = Bets.betsToday + 1
	StatisticManager.addStatistic("placedBets")
	Analytics.addEvent("Match Betting:Bet Placed")
	Game.recalculateEquipmentWorth()
	Game.save()

	timer.performWithDelay(50, function()
		if callbackFunc then
			callbackFunc(true, { error = false })
		end
	end)
end

function Bets.getItems(betId, callbackFunc)
	betId = tonumber(betId)
	local bet = Bets.cache.bets[betId]
	if not bet or bet.status > 0 then
		return GUI.showMessageBox(Lang.common.error, Lang.bets.couldNotReceiveItems .. ".")
	end

	local match = bet.match
	if not match or match.closed == 0 then
		return GUI.showMessageBox(Lang.common.information, "Match is still live or in progress.")
	end

	if match.winner == bet.team then
		-- Won bet: return original items + bonus winning items
		for _, item in ipairs(bet.items) do
			Game.addItem(item, false, item.statTrak, false, {
				pattern = item.pattern,
				name = item.name,
				quality = item.quality,
				stickers = item.stickers,
				disableAchievements = true
			})
		end

		local wonItems = getWinnings(betId)
		for _, item in ipairs(wonItems) do
			Game.addItem(item, false, item.statTrak, false, {
				pattern = item.pattern,
				name = item.name,
				quality = item.quality,
				stickers = item.stickers,
				disableAchievements = true
			})
		end

		table.sort(wonItems, function(a, b)
			return Game.getItemPrice(a) > Game.getItemPrice(b)
		end)

		bet.status = 1
		StatisticManager.addStatistic("wonBets")
		Analytics.addEvent("Match Betting:Items Won")
		Game.recalculateEquipmentWorth()
		Game.save()

		timer.performWithDelay(50, function()
			composer.showOverlay("scenes.itemlist", {
				params = {
					firstText = Lang.bets.betWon .. "!",
					secondText = Lang.common.newItems .. ":",
					items = wonItems
				}
			})
			GUI.showInfoBox(Lang.common.expReward, Lang.common.expAwarded:gsub("{1}", "10"), InfoBoxType.experience)
			Game.addExperience(10)
		end)

		if callbackFunc then callbackFunc(true, { won = true, items = bet.items }) end
	elseif match.winner == 3 then
		-- Draw / cancelled: return original items
		for _, item in ipairs(bet.items) do
			Game.addItem(item, false, item.statTrak, false, {
				pattern = item.pattern,
				name = item.name,
				quality = item.quality,
				stickers = item.stickers,
				disableAchievements = true
			})
		end
		bet.status = 1
		Game.recalculateEquipmentWorth()
		Game.save()
		GUI.showMessageBox(Lang.common.success, Lang.bets.itemsReturned .. ".")
		if callbackFunc then callbackFunc(true, { won = false, items = bet.items }) end
	else
		-- Lost bet
		bet.status = 1
		StatisticManager.addStatistic("lostBets")
		Analytics.addEvent("Match Betting:Items Lost")
		Game.save()
		GUI.showMessageBox(Lang.common.information, "The match has ended and your team lost.")
		if callbackFunc then callbackFunc(true, { won = false, items = {} }) end
	end
end

function Bets.createTeamLogo(sceneGroup, teamName)
	if defaultLogos[teamName] then
		teamName = defaultLogos[teamName]
	end
	local path = "images/teams/" .. teamName:lower() .. ".png"
	local logo = display.newImageRect(sceneGroup, path, 150 * Game.guiScale, 150 * Game.guiScale)
	if not logo then
		logo = display.newImageRect(sceneGroup, "images/teams/small/" .. teamName:lower() .. ".png", 150 * Game.guiScale, 125 * Game.guiScale)
	end
	if not logo then
		logo = display.newImageRect(sceneGroup, "images/teams/no-team.png", 150 * Game.guiScale, 150 * Game.guiScale)
	end
	if not logo then
		logo = display.newRect(sceneGroup, 0, 0, 150 * Game.guiScale, 150 * Game.guiScale)
		logo:setFillColor(0.2, 0.2, 0.2, 0)
	end
	return logo
end

return Bets
