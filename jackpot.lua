local Jackpot = {}
local started = false
local itemCallback
Jackpot.difficulties = {
	[1] = {
		name = Lang.jackpot.difficulties.verylow,
		minPrice = 0.5,
		maxPrice = 15
	},
	[2] = {
		name = Lang.jackpot.difficulties.low,
		minPrice = 2.5,
		maxPrice = 50
	},
	[3] = {
		name = Lang.jackpot.difficulties.normal,
		minPrice = 10,
		maxPrice = 150
	},
	[4] = {
		name = Lang.jackpot.difficulties.high,
		minPrice = 10,
		maxPrice = 300
	},
	[5] = {
		name = Lang.jackpot.difficulties.veryhigh,
		minPrice = 20,
		maxPrice = 500
	},
	[6] = {
		name = Lang.jackpot.difficulties.extreme,
		minPrice = 40,
		maxPrice = 5000
	}
}
local function work()
	if Jackpot.getItemCount() >= 50 then
		started = false
		Game.jackpot.status = 1
		Menu.addAlert("Jackpot")
		if itemCallback then
			itemCallback()
		end
		return
	end
	local minPrice = Jackpot.difficulties[Game.jackpot.type].minPrice
	local maxPrice = Jackpot.difficulties[Game.jackpot.type].maxPrice
	if Game.jackpot.expensiveItems >= 2 then
		maxPrice = 1000
	end
	if math.random(1, 6) == 1 or Game.testMode then
		while true do
			local item = {}
			local randomResult = math.random(1, 100)
			if randomResult <= 1 and Game.jackpot.mode == 1 then
				local glove = choose(Game.gloves)
				item.type = Item.glove
				item.id = glove.id
				item.quality = QualityManager.getRandomQuality(glove)
			elseif Game.jackpot.mode == 3 or Game.jackpot.mode == 1 and randomResult <= 20 then
				item.type = Item.sticker
				item.id = Game.getRandomSticker().id
			else
				item.type = Item.skin
				local rarity
				local rand = math.random(1, 1000)
				if rand < 700 then
					rarity = Rarity.blue
				elseif rand < 860 then
					rarity = Rarity.purple
				elseif rand < 950 then
					rarity = Rarity.pink
				else
					rarity = Rarity.red
				end
				local skin = Game.getRandomSkinByRarity(rarity)
				item.id = skin.id
				item.quality = QualityManager.getRandomQuality(skin)
				if 3 >= math.random(1, 10) and (Game.skins[item.id].statTrakAvailable or Game.skins[item.id].souvenirAvailable) then
					item.statTrak = true
				else
					item.statTrak = false
				end
			end
			local itemPrice = Game.getItemPrice(item)
			if maxPrice > itemPrice and minPrice < itemPrice then
				table.insert(Game.jackpot.otherItems[Jackpot.getRandomBot()], item)
				Game.jackpot.otherItemsCount = Game.jackpot.otherItemsCount + 1
				if 1000 <= itemPrice then
					Game.jackpot.expensiveItems = Game.jackpot.expensiveItems + 1
				end
				if itemCallback then
					itemCallback(item)
				end
				break
			end
		end
	end
	if Jackpot.isStarted() then
		local delay = 200
		if Game.testMode then
			delay = 1
		end
		timer.performWithDelay(delay, work)
	end
end
Jackpot.botNames = {
	"CzajaX",
	"Thug_Life",
	"Crypton",
	"GenZee",
	"Szyroty",
	"yoreciv",
	"CyKab",
	"doze",
	"ElitePlayer1337",
	"enough",
	"Fallosh",
	"Jimbo TV",
	"Mr. Bones",
	"powah",
	"U WOT M8",
	"geT RekT",
	"GeT_RiGhT",
	"Perlo",
	"Cheerio",
	"Crazy-banana",
	"Ventura",
	"Delicious_doge",
	"duK",
	"Rezland",
	"paszaBiceps g2a",
	"soloQPlayer",
	"XxN00BSLAYERxX",
	"SnackS",
	"reKoN21",
	"SAGA",
	"wo0t",
	"LokeHansen",
	"flamie",
	"rise'n'shine",
	"SOBIESKI",
	"kappa",
	"RotaRy CSGOLounge",
	"HAL 9000",
	"BriaN1996",
	"GabeN",
	"Anatolij",
	"Raves",
	"Hot2Doge",
	"WhiteTooth",
	"KorwinKing",
	"iamjasskid",
	"loban_9",
	"krazy__",
	"Yolo Swaggins",
	"Jackpot Steve",
	"TheSuspect",
	"zhivoff-dA",
	"GimmeAllSkins",
	"f4d3",
	"Bot Potato",
	"JackKINGpot",
	"Gentleman",
	"M.a.g.n.u.s",
	"SoapTurtle",
	"GMX",
	"Mayhem",
	"Janczar",
	"kqly",
	"777snipe777",
	"BOT Joe",
	"Saddy",
	"I_HAVE_VAC",
	"Dayan",
	"izak",
	"PsYcHo",
	"IsAmUxPompa",
	"Phantoml0rd",
	"Frimpy",
	"summit",
	"Wigwam",
	"olofmeister",
	"visu",
	"DOBRYAK",
	"FREESTYLER",
	"ALIVE-AGAIN3",
	"F34R_0F_D4Rk",
	"MRL.",
	"OTUM",
	"ProudBoy22",
	"Social Guy",
	"t0MASY 'kac",
	"Yoakim",
	"Zeddsc",
	"Zirael",
	"El Sock",
	"Na'vigator",
	"PollyX2",
	"poof poof",
	"ravvvvvv",
	"WITEK",
	"Ayy LMAO",
	"Bat Dude",
	"bhaal",
	"Cawlin1D",
	"I'm QT",
	"ImmaOrange",
	"TheKing",
	"Krosis",
	"MARIO",
	"pokey",
	"Ptown-",
	"s3ns",
	"Vaulx",
	"WATman",
	"zadookthx",
	"DerApache",
	"bad_player",
	"Brain Damage",
	"Trucker101",
	"JDM.Power"
}
local function chooseBotName()
	while true do
		local name = choose(Jackpot.botNames)
		local playerName = "You"
		if GameServices and GameServices.loggedIn then
			playerName = GameServices.getPlayerName()
		end
		if playerName ~= name then
			return name
		end
	end
end
function Jackpot.getRandomBot()
	local botList = {}
	for bot, items in pairs(Game.jackpot.otherItems) do
		table.insert(botList, bot)
	end
	if #botList < Game.jackpot.botCount then
		for i = 1, Game.jackpot.botCount - #botList do
			local name = chooseBotName(Jackpot.botNames)
			if not Game.jackpot.otherItems[name] then
				Game.jackpot.otherItems[name] = {}
				table.insert(botList, name)
			end
		end
	end
	for bot, items in pairs(Game.jackpot.otherItems) do
		if #items == 0 then
			return bot
		end
	end
	return choose(botList)
end
function Jackpot.getStatus()
	return Game.jackpot.status
end
function Jackpot.getWinChance(botName)
	if Game.testMode and not botName then
		return 100
	end
	local playerItemsWorth = 0
	local botItemsWorth = 0
	for _, item in ipairs(Game.jackpot.playerItems) do
		playerItemsWorth = playerItemsWorth + Game.getItemPrice(item)
	end
	local totalWorth = playerItemsWorth
	for bot, items in pairs(Game.jackpot.otherItems) do
		for _, item in ipairs(items) do
			local itemPrice = Game.getItemPrice(item)
			totalWorth = totalWorth + itemPrice
			if botName and bot == botName then
				botItemsWorth = botItemsWorth + itemPrice
			end
		end
	end
	if totalWorth == 0 then
		return 0
	end
	if not botName then
		return playerItemsWorth / totalWorth
	else
		return botItemsWorth / totalWorth
	end
end
function Jackpot.new()
	Game.jackpot.id = Game.jackpot.id + 1
	Game.jackpot.playerItems = {}
	Game.jackpot.otherItems = {}
	Game.jackpot.status = 0
	Game.jackpot.otherItemsCount = 0
	Game.jackpot.expensiveItems = 0
	Game.jackpot.botCount = math.random(3, 9)
	if math.random(1, 500) == 1 then
		Game.jackpot.botCount = 1
		Game.jackpot.otherItems = {
			motar2k15 = {}
		}
	end
end
function Jackpot.getItems()
	local items = {}
	for _, item in ipairs(Game.jackpot.playerItems) do
		table.insert(items, item)
	end
	for _, itemList in pairs(Game.jackpot.otherItems) do
		for a, item in pairs(itemList) do
			table.insert(items, item)
		end
	end
	return items
end
function Jackpot.postDraw(win, winChance)
	AchievementManager.onJackpotEnd()
	if win then
		AchievementManager.onJackpotWin(winChance)
	else
		AchievementManager.onJackpotLose(winChance)
	end
	Game.save()
end
function Jackpot.check()
	if Game.jackpot.status == 2 or Game.jackpot.status == 3 then
		return
	end
	local winChance = Jackpot.getWinChance() * 1000
	if Game.others.jackpotRand then
		math.randomseed(Game.others.jackpotRand)
		Game.others.jackpotRand = nil
	end
	local win = winChance >= math.random(1, 1000)
	Game.lastScene = composer.getSceneName("current")
	Game.lastDrawParams = {
		jackpotDraw = true,
		win = win,
		postDrawCallback = function()
			Jackpot.postDraw(win, winChance)
		end
	}
	composer.gotoScene("scenes.draw", {
		effect = "fade",
		time = 0,
		params = {
			jackpotDraw = true,
			win = win,
			postDrawCallback = function()
				Jackpot.postDraw(win, winChance)
			end
		}
	})
	StatisticManager.addStatistic("jackpotsPlayed")
	if win then
		Game.jackpot.status = 2
		StatisticManager.addStatistic("jackpotsWon")
		Analytics.addEvent("Jackpot:Won")
	else
		Game.jackpot.status = 3
		StatisticManager.addStatistic("jackpotsLost")
		Analytics.addEvent("Jackpot:Lost")
	end
	Game.recalculateEquipmentWorth()
	Game.save()
	function Jackpot.okButtonCallback()
		composer.gotoScene("scenes.jackpot")
		if win then
			for _, items in pairs(Game.jackpot.otherItems) do
				for _, item in ipairs(items) do
					Game.addItem(item, false, item.statTrak, false, {
						quality = item.quality,
						disableAchievements = true,
						disableMissions = true
					})
					StatisticManager.addStatistic("moneyWonInJackpots", Game.getItemPrice(item))
				end
			end
			for i = 1, #Game.jackpot.playerItems do
				Game.addItem(Game.jackpot.playerItems[i], false, Game.jackpot.playerItems[i].statTrak, false, {
					pattern = Game.jackpot.playerItems[i].pattern,
					name = Game.jackpot.playerItems[i].n,
					stickers = Game.jackpot.playerItems[i].stickers,
					quality = Game.jackpot.playerItems[i].quality,
					highlight = false,
					disableAchievements = true,
					disableMissions = true
				})
			end
			Game.itemLock = true
			timer.performWithDelay(250, function()
				Game.itemLock = false
			end, 2)
			local itemList = {}
			for _, items in pairs(Game.jackpot.otherItems) do
				for _, item in ipairs(items) do
					table.insert(itemList, item)
					if item.id == Skin.M4A4_howl and item.type == Item.skin then
						Game.unlockAchievement("The Howl is Mine!")
					end
				end
			end
			table.sort(itemList, function(a, b)
				return Game.getItemPrice(a) > Game.getItemPrice(b)
			end)
			composer.showOverlay("scenes.itemlist", {
				params = {
					firstText = "Jackpot won!",
					secondText = "New items:",
					items = itemList
				}
			})
			GUI.showInfoBox("Exp reward", "10 exp awarded", InfoBoxType.experience)
			Game.addExperience(10)
		else
			for _, item in ipairs(Game.jackpot.playerItems) do
				StatisticManager.addStatistic("moneyLostInJackpots", Game.getItemPrice(item))
			end
		end
	end
end
function Jackpot.getItemCount()
	return #Game.jackpot.playerItems + Game.jackpot.otherItemsCount
end
function Jackpot.addItems(eqIds)
	table.sort(eqIds, function(a, b)
		return b < a
	end)
	for i = 1, #eqIds do
		table.insert(Game.jackpot.playerItems, Game.equipment[eqIds[i]])
		table.remove(Game.equipment, eqIds[i])
	end
	Game.save()
end
function Jackpot.isStarted()
	return started
end
function Jackpot.start(itemAddCallback)
	started = true
	itemCallback = itemAddCallback
	timer.performWithDelay(400, work)
end
function Jackpot.stop()
	started = false
end
return Jackpot
