local LuaFileSystem = require("lfs")
Game = {
	rank = 1,
	keyCost = 2.5,
	lastScene = "scenes.main",
	settings = {
		enableAnimations = true,
		enableSounds = true,
		confirmItemSelling = false,
		menuIcons = true,
		equipmentScrollbar = true,
		lowEnergyMode = false
	},
	version = "2.1.8a",
	testMode = false,
	netHub = true,
	googlePlayBanishment = false,
	gameServices = false,
	microPayments = true,
	cheatLock = false,
	openLock = false,
	betSystem = true,
	qrScanner = false,
	beta = false,
	betaFunction = function()
	end,
	betaUpgrades = {},
	screenMode = false,
	screenModeFunction = function()
	end,
	lastSave = os.time() - 5,
	itemLock = false,
	achievementChange = true,
	guiScale = 1,
	tabletModeScale = 0.8
}
if isIOS() then
	Game.gameServices = true
end
if Game.googlePlayBanishment and isAndroid() then
	Game.gameServices = false
	Game.microPayments = false
end
require("data.skins")
require("data.cases")
require("data.keys")
require("data.gloves")
require("data.collections")
require("data.souvenirs")
require("data.upgrades")
require("data.achievements")
require("data.ranks")
require("data.expranks")
require("data.stickers")
require("data.capsules")
require("data.shopitems")
require("data.otheritems")
Game.sounds = {
	itemReveal = audio.loadStream("sounds/itemreveal.wav"),
	click = audio.loadStream("sounds/click.wav"),
	menuClick = audio.loadStream("sounds/menuclick.wav"),
	caseOpen = audio.loadStream("sounds/caseopen.wav"),
	scrollSounds = {
		audio.loadStream("sounds/scroll.wav"),
		audio.loadStream("sounds/scroll.wav"),
		audio.loadStream("sounds/scroll.wav"),
		audio.loadStream("sounds/scroll.wav"),
		audio.loadStream("sounds/scroll.wav"),
		audio.loadStream("sounds/scroll.wav"),
		audio.loadStream("sounds/scroll.wav"),
		audio.loadStream("sounds/scroll.wav"),
		audio.loadStream("sounds/scroll.wav"),
		audio.loadStream("sounds/scroll.wav"),
		audio.loadStream("sounds/scroll.wav"),
		audio.loadStream("sounds/scroll.wav")
	}
}
function Game.loadDefaults()
	Game.rank = 1
	Game.expRank = 1
	Game.experience = 0
	Game.money = 25
	Game.showingOverlay = false
	Game.explosions = false
	Game.clickMoneyGain = 0.01
	Game.clickSearchGain = 1
	Game.moneyPerSecond = 0
	Game.searchBarLimit = 100
	Game.searchProgress = 0
	Game.searchPerSecond = 0
	Game.criticalStreak = 0
	Game.criticalHitChance = 1
	Game.others = {
		netId = "0",
		statTrakGuarantees = 0,
		statTrakGuarantee = false,
		statTrakChance = 6,
		knifeChance = 3,
		lastAdWatch = os.time(),
		lastCaseAdWatch = 0,
		lastMoneyAdWatch = 0,
		lastTapPowerAdWatch = 0,
		tapPowerTime = os.time(),
		tapPowerBonusMultiplier = 1,
		lastMissionSkipAdWatch = 0,
		saveTime = os.time(),
		offlineIncomeTime = 1200,
		expRankRewardsAvailable = 0,
		tapsToCombo = 15,
		lastDailyRewardd = 0,
		lastDailyRewardd2 = 0,
		dailyRewardAdWatched = false,
		leftDailyRewardAwarded = false,
		rightDailyRewardAwarded = false,
		comboLimit = true,
		mpsBought = false,
		lastRandomSkin = os.time(),
		lastRandomKey = 0,
		jackpotsUnlocked = false,
		nethubUnlocked = false,
		paidBonusCooldowns = {},
		criticalHitChance = 1,
		onceAction1 = false,
		onceAction2 = false,
		onceAction3 = false,
		onceAction4 = false,
		lt = 0,
		userInitiate = true,
		lastMoneyRecordSent = 0,
		lastSkinWorthSent = 0,
		lastOpenedBoxesSent = 0,
		lastEquipmentCountSent = 0,
		expResets = 0,
		netNick = "???",
		noKnifeAds = false,
		defaultEquipmentCategory = 1,
		lastMarketOffer = {},
		uLD = 0,
		uN = 0,
		uS = os.time()
	}
	Game.equipmentCategories = {
		{name = "Default"},
		{name = "Locked", locked = true}
	}
	Game.jackpot = {
		id = 1,
		status = 0,
		mode = 1,
		type = 3,
		playerItems = {},
		otherItems = {},
		otherItemsCount = 0,
		botCount = math.random(3, 9),
		expensiveItems = 0
	}
	Game.onlineJackpot = {
		name = "Player" .. math.random(1, 10000),
		avatar = math.random(1, #Jackpot.botNames)
	}
	Game.roulette = {
		balance = 0,
		betAmount = 0,
		coinflipBetAmount = 0,
		ticketsToPlay = 0,
		depositedItems = {},
		lastNumbers = {}
	}
	Game.minesweeper = {
		started = false,
		lost = false,
		won = false,
		betAmount = 0,
		variant = 1,
		roundProfit = 0,
		map = {},
		shownMap = {}
	}
	Game.crash = {betAmount = 0}
	Game.raffles = {
		lastDay = 0,
		items = {}
	}
	Game.lastDailies = {}
	Game.settings = {
		enableAnimations = true,
		enableSounds = true,
		confirmItemSelling = false,
		speedUpDrawAnimations = false,
		tabletMode = false,
		showQualityInEquipment = false,
		qrCodes = false,
		equipmentScrollbar = true,
		menuIcons = true,
		stackEquipmentItems = true,
		equipmentCategories = false,
		lowEnergyMode = false
	}
	if Game.settings.tabletMode then
		Game.guiScale = Game.tabletModeScale
	end
	Game.unlockables = {
		cases = {
			Case.breakout,
			Case.phoenix
		}
	}
	for _, upgrade in pairs(Game.upgrades) do
		upgrade.bought = false
		upgrade.unlocked = upgrade.defaultUnlocked
	end
	for i = 1, #Game.cases do
		Game.cases[i].count = 0
		Game.cases[i].unlocked = false
		Game.cases[i].completed = false
		Game.cases[i].opened = 0
		Game.cases[i].profit = 0
	end
	Game.cases[Case.breakout].unlocked = true
	Game.cases[Case.phoenix].unlocked = true
	for i = 1, #Game.capsules do
		Game.capsules[i].count = 0
		Game.capsules[i].completed = false
		Game.capsules[i].opened = 0
		Game.capsules[i].profit = 0
	end
	for i = 1, #Game.collections do
		Game.collections[i].count = 0
		Game.collections[i].completed = false
		Game.collections[i].opened = 0
		Game.collections[i].profit = 0
	end
	for i = 1, #Game.souvenirs do
		Game.souvenirs[i].count = 0
		Game.souvenirs[i].completed = false
		Game.souvenirs[i].opened = 0
		Game.souvenirs[i].profit = 0
	end
	for _, achievement in pairs(Game.achievements) do
		achievement.unlocked = false
		achievement.rewarded = false
	end
	for i = 1, #Game.keys do
		Game.keys[i].count = 0
	end
	Game.equipment = {}
	MissionManager.refreshMissions()
	StatisticManager.reset()
	if Game.testMode then
		Game.rank = 18
		Game.money = 750
		Game.unlockables.contracts = true
	end
	if Game.beta then
		Game.betaFunction()
	end
	Menu.lockItem("Jackpot")
	Menu.refreshItems()
	Game.unlockUpgrade("Roulette")
end
function Game.load(options)
	local options = options or {}
	local loadTable = {}
	if options.data then
		loadTable = options.data
	else
		local files = {
			"cs.dat",
			"cs_1.dat",
			"cs_2.dat",
			"cs_3.dat",
			"c_1.dat",
			"c_2.dat",
			"c_3.dat",
			"c_4.dat",
			"c_5.dat",
			"c_6.dat",
			"c_7.dat"
		}
		local lastMod = 0
		local lastModFile
		for i = 1, #files do
			local lastModification = LuaFileSystem.attributes(system.pathForFile(files[i], system.DocumentsDirectory), "modification")
			if lastModification and lastMod < lastModification then
				lastMod = lastModification
				lastModFile = files[i]
			end
		end
		local checkNumber = LoadSave.loadCheckFile()
		if 0 < checkNumber then
			lastModFile = "c_" .. checkNumber .. ".dat"
		end
		if not lastModFile then
			return false
		end
		loadTable = LoadSave.loadTable(lastModFile, system.DocumentsDirectory)
		if not loadTable then
			os.remove(system.pathForFile(lastModFile, system.DocumentsDirectory))
			Game.load()
			return false
		end
	end
	Game.rank = loadTable.rank
	if loadTable.rank > #Game.ranks then
		Game.rank = #Game.ranks
	end
	Game.money = loadTable.money
	if 0 > Game.money then
		Game.money = 0
	end
	Game.searchProgress = loadTable.searchProgress
	Game.saveVersion = loadTable.version
	if loadTable.moneyPerSecond then
		Game.moneyPerSecond = loadTable.moneyPerSecond
	else
		Game.moneyPerSecond = 0.01
	end
	if loadTable.expRank then
		Game.expRank = loadTable.expRank
	end
	if loadTable.experience then
		Game.experience = loadTable.experience
	end
	if loadTable.equipmentCategories then
		Game.equipmentCategories = loadTable.equipmentCategories
	end
	if loadTable.lastDailies then
		Game.lastDailies = loadTable.lastDailies
	end
	if loadTable.missions then
		MissionManager.load(loadTable)
	end
	EquipmentManager.load(loadTable)
	if loadTable.unlockables then
		for key, unlockable in pairs(loadTable.unlockables) do
			Game.unlockables[key] = loadTable.unlockables[key]
		end
	end
	StatisticManager.load(loadTable)
	for key, upgrade in pairs(loadTable.upgrades) do
		if Game.upgrades[key] then
			Game.upgrades[key].unlocked = upgrade.unlocked
			Game.upgrades[key].bought = upgrade.bought
		end
	end
	Game.settings.enableSounds = loadTable.settings.enableSounds
	Game.settings.enableAnimations = loadTable.settings.enableAnimations
	Game.settings.confirmItemSelling = loadTable.settings.confirmItemSelling
	Game.settings.lowEnergyMode = loadTable.settings.lowEnergyMode
	if loadTable.settings.tabletMode then
		Game.settings.tabletMode = loadTable.settings.tabletMode
	end
	if loadTable.settings.stackEquipmentItems then
		Game.settings.stackEquipmentItems = loadTable.settings.stackEquipmentItems
	end
	if loadTable.settings.equipmentCategories then
		Game.settings.equipmentCategories = loadTable.settings.equipmentCategories
	end
	if loadTable.settings.speedUpDrawAnimations then
		Game.settings.speedUpDrawAnimations = loadTable.settings.speedUpDrawAnimations
	end
	if loadTable.settings.enableSounds == true then
		audio.setVolume(1)
	else
		audio.setVolume(0)
	end
	if loadTable.settings.showQualityInEquipment then
		Game.settings.showQualityInEquipment = loadTable.settings.showQualityInEquipment
	end
	if type(loadTable.settings.equipmentScrollbar) ~= "nil" then
		Game.settings.equipmentScrollbar = loadTable.settings.equipmentScrollbar
	end
	if type(loadTable.settings.menuIcons) ~= "nil" then
		Game.settings.menuIcons = loadTable.settings.menuIcons
	end
	local secError = false
	if loadTable.lastAction and tonumber(loadTable.lastAction / 3.5) ~= tonumber(loadTable.statistics.openedBoxes) then
		secError = true
	end
	if loadTable.lastAction2 and loadTable.jackpot.playerItems and tonumber(loadTable.lastAction2 / 5.5) ~= tonumber(#loadTable.jackpot.playerItems + #loadTable.equipment) then
		secError = true
	end
	if loadTable.bluesFound then
		local sum = 0
		for _, item in ipairs(loadTable.equipment) do
			sum = sum + item.id
			if item.quality then
				sum = sum + item.quality
			end
		end
		if loadTable.bluesFound ~= sum then
			secError = true
		end
	end
	if not secError and loadTable.jackpot then
		for key, value in pairs(loadTable.jackpot) do
			Game.jackpot[key] = loadTable.jackpot[key]
		end
	end
	if loadTable.onlineJackpot then
		for key, value in pairs(loadTable.onlineJackpot) do
			Game.onlineJackpot[key] = loadTable.onlineJackpot[key]
		end
	end
	if loadTable.roulette then
		for key, value in pairs(loadTable.roulette) do
			Game.roulette[key] = loadTable.roulette[key]
		end
		if loadTable.bTime and (loadTable.roulette.balance + loadTable.roulette.betAmount) * 2 ~= loadTable.bTime then
			Game.roulette.balance = 0
		end
		if loadTable.cTime and (loadTable.roulette.balance + loadTable.roulette.coinflipBetAmount) * 3 ~= loadTable.cTime then
			Game.roulette.coinflipBetAmount = 0
		end
	end
	if loadTable.minesweeper then
		for key, value in pairs(loadTable.minesweeper) do
			Game.minesweeper[key] = loadTable.minesweeper[key]
		end
		if loadTable.dTime and (loadTable.roulette.balance + loadTable.minesweeper.betAmount) * 5 ~= loadTable.dTime then
			Game.minesweeper.betAmount = 0
		end
	end
	if loadTable.crash then
		for key, value in pairs(loadTable.crash) do
			Game.crash[key] = loadTable.crash[key]
		end
		if loadTable.dTime and (loadTable.roulette.balance + loadTable.crash.betAmount) * 4 ~= loadTable.eTime then
			Game.crash.betAmount = 0
		end
	end
	if loadTable.raffles then
		for key, value in pairs(loadTable.raffles) do
			Game.raffles[key] = loadTable.raffles[key]
		end
	end
	for i = 1, #loadTable.cases do
		Game.cases[i].count = loadTable.cases[i].count
		Game.cases[i].unlocked = loadTable.cases[i].unlocked
		if loadTable.cases[i].completed then
			Game.cases[i].completed = loadTable.cases[i].completed
		end
		if loadTable.cases[i].opened then
			Game.cases[i].opened = loadTable.cases[i].opened
		end
		if loadTable.cases[i].profit then
			Game.cases[i].profit = loadTable.cases[i].profit
		end
	end
	if loadTable.capsules then
		for i = 1, #loadTable.capsules do
			Game.capsules[i].count = loadTable.capsules[i].count
			Game.capsules[i].unlocked = loadTable.capsules[i].unlocked
			if loadTable.capsules[i].completed then
				Game.capsules[i].completed = loadTable.capsules[i].completed
			end
			if loadTable.capsules[i].opened then
				Game.capsules[i].opened = loadTable.capsules[i].opened
			end
			if loadTable.capsules[i].profit then
				Game.capsules[i].profit = loadTable.capsules[i].profit
			end
		end
	end
	for i = 1, #loadTable.keys do
		Game.keys[i].count = loadTable.keys[i].count
	end
	for key, achievement in pairs(loadTable.achievements) do
		Game.achievements[key].unlocked = achievement.unlocked
		if achievement.rewarded then
			Game.achievements[key].rewarded = achievement.rewarded
		end
	end
	for i = 1, Game.rank do
		for j = 1, #Game.ranks[i].upgrades do
			Game.unlockUpgrade(Game.ranks[i].upgrades[j])
		end
	end
	local actualRank = Game.expRank
	if 0 < Game.others.expResets then
		actualRank = #Game.expRanks
	end
	for i = 1, actualRank do
		for j = 1, #Game.expRanks[i].upgrades do
			Game.unlockUpgrade(Game.expRanks[i].upgrades[j])
		end
	end
	if loadTable.souvenirs then
		print("Loading...")
		if not loadTable.collections then
			for i = 1, #loadTable.souvenirs do
				local collectionId = Game.souvenirs[i].collection
				Game.collections[collectionId].count = loadTable.souvenirs[i].count
				if 0 > Game.collections[collectionId].count then
					Game.collections[collectionId].count = 0
				end
				if loadTable.souvenirs[i].completed then
					Game.collections[collectionId].completed = loadTable.souvenirs[i].completed
				end
				if loadTable.souvenirs[i].opened then
					Game.collections[collectionId].opened = loadTable.souvenirs[i].opened
				end
				if loadTable.souvenirs[i].profit then
					Game.collections[collectionId].profit = loadTable.souvenirs[i].profit
				end
			end
			print("Souvenirs to collections")
		else
			print("Souvenirs to souvenirs")
			for i = 1, #loadTable.souvenirs do
				Game.souvenirs[i].count = loadTable.souvenirs[i].count
				if 0 > Game.souvenirs[i].count then
					Game.souvenirs[i].count = 0
				end
				if loadTable.souvenirs[i].completed then
					Game.souvenirs[i].completed = loadTable.souvenirs[i].completed
				end
				if loadTable.souvenirs[i].opened then
					Game.souvenirs[i].opened = loadTable.souvenirs[i].opened
				end
				if loadTable.souvenirs[i].profit then
					Game.souvenirs[i].profit = loadTable.souvenirs[i].profit
				end
			end
			if loadTable.collections then
				for i = 1, #loadTable.collections do
					Game.collections[i].count = loadTable.collections[i].count
					Game.collections[i].completed = loadTable.collections[i].completed
					Game.collections[i].opened = loadTable.collections[i].opened
					Game.collections[i].profit = loadTable.collections[i].profit
					if 0 > Game.collections[i].count then
						Game.collections[i].count = 0
					end
				end
			end
		end
	end
	if not secError then
		Game.equipment = loadTable.equipment
		for i = 1, #Game.equipment do
			if Game.equipment[i].tmpLock then
				Game.equipment[i].tmpLock = nil
			end
		end
	end
	for key, value in pairs(loadTable.others) do
		Game.others[key] = value
	end
	if loadTable.shopItems then
		for key, item in pairs(loadTable.shopItems) do
			Game.shopItems[key].bought = loadTable.shopItems[key].bought
		end
	end
	if Game.microPayments then
		MicroPayments.load(loadTable)
	end
	if not loadTable.missions then
		MissionManager.reset()
	end
	Game.cases[Case.breakout].unlocked = true
	Game.cases[Case.phoenix].unlocked = true
	addNewAchievements()
	Upgrades.unlockNewUpgrades()
end
function addNewAchievements()
	AchievementManager.unlockNewAchievements()
	Game.checkForCompletedCollections()
	for i = 1, #Game.cases do
		if Game.cases[i].unlocked then
			StatisticManager.addStatistic("unlockedCases")
		end
	end
end

function Game.getBonusCooldownMinutes()
	if Game.bonusCooldownMinutes then
		return Game.bonusCooldownMinutes
	end
	local path = system.pathForFile("bonuses_config.json", system.ResourceDirectory)
	if path then
		local f = io.open(path, "r")
		if f then
			local content = f:read("*a")
			f:close()
			if content and #content > 0 then
				local json = require("json")
				local data = json.decode(content)
				if data and data.cooldown_minutes ~= nil then
					Game.bonusCooldownMinutes = tonumber(data.cooldown_minutes) or 60
					return Game.bonusCooldownMinutes
				end
			end
		end
	end
	Game.bonusCooldownMinutes = 60
	return 60
end

function Game.setBonusCooldownMinutes(mins)
	mins = math.max(0, tonumber(mins) or 0)
	Game.bonusCooldownMinutes = mins
	local path = system.pathForFile("bonuses_config.json", system.ResourceDirectory)
	if path then
		local f = io.open(path, "w")
		if f then
			local json = require("json")
			local data = {
				cooldown_minutes = mins,
				description = "Cooldown in minutes for repeatable paid bonuses (default: 60). Set to 0 for instant claims."
			}
			f:write(json.prettify(data))
			f:close()
		end
	end
end

function Game.getBonusCooldownRemaining(productId)
	if Game.testMode then
		return 0
	end
	local cdMinutes = Game.getBonusCooldownMinutes()
	if cdMinutes <= 0 then
		return 0
	end
	local cdSeconds = cdMinutes * 60
	Game.others.paidBonusCooldowns = Game.others.paidBonusCooldowns or {}
	local lastClaim = Game.others.paidBonusCooldowns[productId] or 0
	local elapsed = os.time() - lastClaim
	if elapsed < cdSeconds then
		return cdSeconds - elapsed
	end
	return 0
end

function Game.recordBonusClaim(productId)
	Game.others.paidBonusCooldowns = Game.others.paidBonusCooldowns or {}
	Game.others.paidBonusCooldowns[productId] = os.time()
	Game.save()
end

function Game.resetAllBonusCooldowns()
	Game.others.paidBonusCooldowns = {}
	Game.save()
end
local lastSaveSlot = 1
function Game.save(autoSave, params)
	local params = params or {}
	if autoSave and autoSave == true and os.time() - Game.lastSave < 60 then
		return
	end
	Game.lastSave = os.time()
	local saveTable = {
		upgrades = {},
		cases = {},
		keys = {},
		achievements = {},
		settings = {},
		souvenirs = {},
		capsules = {},
		collections = {},
		shopItems = {}
	}
	print("Saving...")
	Game.others.saveTime = os.time()
	Game.others.lastItem = os.time()
	saveTable.settings.enableSounds = Game.settings.enableSounds
	saveTable.settings.enableAnimations = Game.settings.enableAnimations
	saveTable.settings.confirmItemSelling = Game.settings.confirmItemSelling
	saveTable.settings.stackEquipmentItems = Game.settings.stackEquipmentItems
	saveTable.settings.equipmentCategories = Game.settings.equipmentCategories
	saveTable.settings.speedUpDrawAnimations = Game.settings.speedUpDrawAnimations
	saveTable.settings.tabletMode = Game.settings.tabletMode
	saveTable.settings.showQualityInEquipment = Game.settings.showQualityInEquipment
	saveTable.settings.equipmentScrollbar = Game.settings.equipmentScrollbar
	saveTable.settings.menuIcons = Game.settings.menuIcons
	saveTable.settings.lowEnergyMode = Game.settings.lowEnergyMode
	saveTable.rank = Game.rank
	saveTable.money = Game.money
	saveTable.expRank = Game.expRank
	saveTable.experience = Game.experience
	saveTable.moneyPerSecond = Game.moneyPerSecond
	saveTable.searchProgress = Game.searchProgress
	saveTable.version = Game.version
	StatisticManager.save(saveTable)
	saveTable.unlockables = Game.unlockables
	MissionManager.save(saveTable)
	saveTable.lastDailies = Game.lastDailies
	saveTable.equipmentCategories = Game.equipmentCategories
	saveTable.jackpot = Game.jackpot
	saveTable.onlineJackpot = Game.onlineJackpot
	saveTable.roulette = Game.roulette
	saveTable.minesweeper = Game.minesweeper
	saveTable.crash = Game.crash
	saveTable.raffles = Game.raffles
	saveTable.lastAction2 = (#Game.jackpot.playerItems + #Game.equipment) * 5.5
	saveTable.lastAction = StatisticManager.getStatistic("openedBoxes") * 3.5
	saveTable.bTime = (Game.roulette.balance + Game.roulette.betAmount) * 2
	saveTable.cTime = (Game.roulette.balance + Game.roulette.coinflipBetAmount) * 3
	saveTable.dTime = (Game.roulette.balance + Game.minesweeper.betAmount) * 5
	saveTable.eTime = (Game.roulette.balance + Game.crash.betAmount) * 4
	local sum = 0
	for _, item in ipairs(Game.equipment) do
		sum = sum + item.id
		if item.quality then
			sum = sum + item.quality
		end
	end
	saveTable.bluesFound = sum
	for key, upgrade in pairs(Game.upgrades) do
		saveTable.upgrades[key] = {}
		saveTable.upgrades[key].unlocked = upgrade.unlocked
		saveTable.upgrades[key].bought = upgrade.bought
	end
	for i = 1, #Game.cases do
		saveTable.cases[i] = {}
		saveTable.cases[i].count = Game.cases[i].count
		saveTable.cases[i].opened = Game.cases[i].opened
		saveTable.cases[i].unlocked = Game.cases[i].unlocked
		saveTable.cases[i].completed = Game.cases[i].completed
		saveTable.cases[i].profit = Game.cases[i].profit
	end
	for i = 1, #Game.capsules do
		saveTable.capsules[i] = {}
		saveTable.capsules[i].count = Game.capsules[i].count
		saveTable.capsules[i].unlocked = Game.capsules[i].unlocked
		saveTable.capsules[i].completed = Game.capsules[i].completed
		saveTable.capsules[i].opened = Game.capsules[i].opened
		saveTable.capsules[i].profit = Game.capsules[i].profit
	end
	for i = 1, #Game.souvenirs do
		saveTable.souvenirs[i] = {}
		saveTable.souvenirs[i].count = Game.souvenirs[i].count
		saveTable.souvenirs[i].completed = Game.souvenirs[i].completed
		saveTable.souvenirs[i].opened = Game.souvenirs[i].opened
		saveTable.souvenirs[i].profit = Game.souvenirs[i].profit
	end
	for i = 1, #Game.collections do
		saveTable.collections[i] = {}
		saveTable.collections[i].count = Game.collections[i].count
		saveTable.collections[i].completed = Game.collections[i].completed
		saveTable.collections[i].opened = Game.collections[i].opened
		saveTable.collections[i].profit = Game.collections[i].profit
	end
	for i = 1, #Game.keys do
		saveTable.keys[i] = {}
		saveTable.keys[i].count = Game.keys[i].count
	end
	for key, achievement in pairs(Game.achievements) do
		if achievement.unlocked or achievement.rewarded then
			saveTable.achievements[key] = {}
			saveTable.achievements[key].unlocked = achievement.unlocked
			saveTable.achievements[key].rewarded = achievement.rewarded
		end
	end
	for i = 1, #Game.shopItems do
		saveTable.shopItems[i] = {}
		saveTable.shopItems[i].bought = Game.shopItems[i].bought
	end
	EquipmentManager.save(saveTable)
	saveTable.equipment = Game.equipment
	saveTable.others = Game.others
	if Game.microPayments then
		MicroPayments.save(saveTable)
	end
	local actualNetId
	if params.cloudSave then
		saveTable.others.jackpotRand = os.time()
		Game.others.jackpotRand = os.time()
		actualNetId = saveTable.others.netId
		saveTable.others.netId = "0"
		print("Saving with other NetID")
	end
	lastSaveSlot = lastSaveSlot + 1
	if 7 < lastSaveSlot then
		lastSaveSlot = 1
	end
	LoadSave.saveCheckFile(lastSaveSlot)
	local saveFileName = params.filename or "c_" .. lastSaveSlot .. ".dat"
	LoadSave.saveTable(saveTable, saveFileName, system.DocumentsDirectory)
	if params.cloudSave then
		Game.others.netId = actualNetId
	end
end
function Game.gainMoney()
	local moneyBefore = Game.money
	Game.addMoney(Game.moneyPerSecond, "Main", "Money Per Second")
	if composer.getSceneName("current") == "scenes.main" and createFallingCoin then
		local coinCount = math.min(math.floor(Game.moneyPerSecond * 100), 18)
		for i = 1, coinCount do
			if 4 <= coinCount and i >= coinCount / 3 then
				local delay = 333
				if i >= coinCount / 3 * 2 then
					delay = 666
				end
				timer.performWithDelay(delay, function()
					if composer.getSceneName("current") == "scenes.main" and createFallingCoin then
						createFallingCoin(FallingCoin.perSecond)
					end
				end)
			else
				createFallingCoin(FallingCoin.perSecond)
			end
		end
		if moneyBefore * 100 % 1 > Game.money * 100 % 1 then
			createFallingCoin(FallingCoin.perSecond)
		end
	end
	Menu.updateBalanceText()
	local searchBefore = Game.searchProgress
	Game.searchProgress = Game.searchProgress + Game.searchPerSecond
	if Game.searchProgress > Game.searchBarLimit then
		Game.searchProgress = Game.searchBarLimit
		return
	end
	if composer.getSceneName("current") == "scenes.main" and createFallingCase then
		for i = 1, math.floor(Game.searchPerSecond) do
			createFallingCase()
		end
		if searchBefore * 100 % 1 > Game.searchProgress * 100 % 1 then
			createFallingCase()
		end
	end
end
function Game.unlockUpgrade(name)
	if Game.upgrades[name].unlocked == false then
		Game.upgrades[name].unlocked = true
		GUI.showInfoBox("Upgrade unlocked:", name)
		Menu.addAlert("Upgrades")
	end
end
function Game.buyUpgrade(upgradeId, freeUpgrade)
	if Game.upgrades[upgradeId].bought then
		return
	end
	local req = Game.upgrades[upgradeId].requirements
	if not freeUpgrade then
		Game.removeMoney(req.cost, "Upgrade", Lang.upgrades[upgradeId].name)
	end
	StatisticManager.addStatistic("upgradesBought")
	Game.upgrades[upgradeId].bought = true
	GUI.showInfoBox("Upgrade bought:", Lang.upgrades[upgradeId].name)
	Analytics.addEvent("Upgrade Bought:" .. Lang.upgrades[upgradeId].name)
	if Game.upgrades[upgradeId].onBuy then
		Game.upgrades[upgradeId].onBuy()
	end
	if Game.upgrades[upgradeId].searchBarLimitAdd then
		Game.searchBarLimit = Game.searchBarLimit + Game.upgrades[upgradeId].searchBarLimitAdd
	end
	if Game.upgrades[upgradeId].clickSearchGain then
		Game.clickSearchGain = Game.clickSearchGain + Game.upgrades[upgradeId].clickSearchGain
	end
	if Game.upgrades[upgradeId].clickMoneyGain then
		Game.clickMoneyGain = Game.clickMoneyGain + Game.upgrades[upgradeId].clickMoneyGain
	end
	if Game.upgrades[upgradeId].searchPerSecond then
		Game.searchPerSecond = Game.searchPerSecond + Game.upgrades[upgradeId].searchPerSecond
	end
	if Game.upgrades[upgradeId].moneyPerSecond then
		Game.moneyPerSecond = Game.moneyPerSecond + Game.upgrades[upgradeId].moneyPerSecond
	end
	if Game.upgrades[upgradeId].criticalHitChance then
		Game.criticalHitChance = Game.criticalHitChance + Game.upgrades[upgradeId].criticalHitChance
	end
	if Game.upgrades[upgradeId].unlockUpgrades then
		for _, name in ipairs(Game.upgrades[upgradeId].unlockUpgrades) do
			Game.unlockUpgrade(name)
		end
	end
	AchievementManager.onUpgradeBuy()
end
function Game.isUpgradeUnlocked(name)
	return Game.upgrades[name].unlocked
end
function Game.isUpgradeBought(name)
	if not Game.upgrades[name] then
		print("[ERROR - Game.isUpgradeBought] Upgrade " .. (name or "[unknown]") .. " not found!")
		return false
	end
	return Game.upgrades[name].bought
end
function Game.isCapsuleUnlocked(capsuleId)
	local capsule = Game.capsules[capsuleId]
	if not capsule.unlockingUpgrade then
		return true
	end
	return Game.isUpgradeBought(capsule.unlockingUpgrade)
end
function Game.recalculateEquipmentWorth()
	StatisticManager.setStatistic("skinsWorth", 0)
	for i = 1, #Game.equipment do
		if Game.equipment[i].type == Item.skin then
			StatisticManager.addStatistic("skinsWorth", Game.getPrice(Game.equipment[i]))
		end
	end
end
function Game.getItemPrice(item)
	if item.type == Item.sticker then
		return Game.stickers[item.id].price
	elseif item.type == Item.other then
		return Game.otherItems[item.id].price
	elseif item.type == Item.case then
		return Game.cases[item.id].price
	elseif item.type == Item.key then
		return Game.keys[item.id].price or 2.5
	elseif item.type == Item.glove then
		return Game.gloves[item.id].prices[item.quality]
	end
	local price = 0
	if item.statTrak and (Game.skins[item.id].statTrakAvailable or Game.skins[item.id].souvenirAvailable) then
		price = Game.skins[item.id].prices.statTrak[item.quality]
	else
		price = Game.skins[item.id].prices.normal[item.quality]
	end
	if item.pattern and 0 < item.pattern then
		local patternId = Game.skins[item.id].patterns[item.pattern]
		price = price * PatternInfo[patternId].priceMultiplier
		price = math.ceil(price * 100) / 100
	end
	if item.stickers and #item.stickers > 0 and not Game.isKnife(item.id) then
		for i = 1, math.min(#item.stickers, 4) do
			price = price + formatPrice(Game.stickers[item.stickers[i]].price * 0.2)
		end
	end
	return price
end
function Game.getItemName(item)
	if item.type == Item.sticker then
		return Game.stickers[item.id].name
	elseif item.type == Item.glove then
		return Game.gloves[item.id].name
	elseif item.type == Item.other then
		return Game.otherItems[item.id].name
	end
	return Game.skins[item.id].name
end
function Game.getItemQuality(item)
	if item.type == Item.sticker then
		return Quality.battlescarred
	end
	return item.quality
end
function Game.getPrice(eqEntry)
	local price = 0
	if eqEntry.type == Item.sticker then
		return Game.stickers[eqEntry.id].price
	elseif eqEntry.type == Item.glove then
		return Game.gloves[eqEntry.id].prices[eqEntry.quality]
	elseif eqEntry.type == Item.other then
		return Game.otherItems[eqEntry.id].price
	end
	if eqEntry.statTrak and (Game.skins[eqEntry.id].statTrakAvailable or Game.skins[eqEntry.id].souvenirAvailable) then
		price = Game.skins[eqEntry.id].prices.statTrak[eqEntry.quality]
	else
		price = Game.skins[eqEntry.id].prices.normal[eqEntry.quality]
	end
	if eqEntry.pattern then
		local patternId = Game.skins[eqEntry.id].patterns[eqEntry.pattern]
		price = price * PatternInfo[patternId].priceMultiplier
	end
	if eqEntry.stickers and 0 < #eqEntry.stickers and not Game.isKnife(eqEntry.id) then
		for i = 1, math.min(#eqEntry.stickers, 4) do
			price = price + formatPrice(Game.stickers[eqEntry.stickers[i]].price * 0.2)
		end
	end
	return price
end
function Game.setTapPower(multiplier, seconds)
	Game.others.tapPowerTime = os.time() + seconds
	Game.others.tapPowerBonusMultiplier = multiplier
	timer.performWithDelay(seconds * 1000, function()
		Game.others.tapPowerTime = 0
	end)
end
function Game.getTapPowerMultiplier()
	if os.time() > Game.others.tapPowerTime then
		return 1
	end
	return Game.others.tapPowerBonusMultiplier
end
function Game.internalSellCase(caseId)
	local case = Game.cases[caseId]
	Game.cases[caseId].count = Game.cases[caseId].count - 1
	Game.addMoney(case.sellPrice, "Case", Game.cases[caseId].name)
	StatisticManager.addStatistic("soldCases")
end
function Game.sellCase(caseId, event)
	if Game.cases[caseId].count <= 0 then
		return
	end
	if Game.settings.confirmItemSelling then
		composer.showOverlay("overlays.sellconfirmation", {
			effect = "fade",
			time = 300,
			isModal = true,
			params = {
				item = Game.cases[caseId]
			}
		})
		return
	end
	Game.internalSellCase(caseId)
	if event then
		GUI.showAnimatedText(nil, "+$" .. formatPrice(Game.cases[caseId].sellPrice), event.x * (math.random(95, 105) / 100), event.y * (math.random(95, 100) / 100))
	end
end
function Game.internalSellCapsule(capsuleId)
	local capsule = Game.capsules[capsuleId]
	Game.capsules[capsuleId].count = Game.capsules[capsuleId].count - 1
	Game.addMoney(capsule.sellPrice, "Capsule", Game.capsules[capsuleId].name)
end
function Game.sellCapsule(capsuleId, event)
	if Game.capsules[capsuleId].count <= 0 then
		return
	end
	if Game.settings.confirmItemSelling then
		composer.showOverlay("overlays.sellconfirmation", {
			effect = "fade",
			time = 300,
			isModal = true,
			params = {
				item = Game.capsules[capsuleId]
			}
		})
		return
	end
	Game.internalSellCapsule(capsuleId)
	if event then
		GUI.showAnimatedText(nil, "+$" .. formatPrice(Game.capsules[capsuleId].sellPrice), event.x * (math.random(95, 105) / 100), event.y * (math.random(95, 100) / 100))
	end
end
function Game.internalSellCollection(collectionId)
	Game.collections[collectionId].count = Game.collections[collectionId].count - 1
	Game.addMoney(Game.collections[collectionId].sellPrice, "Collection", Game.collections[collectionId].name)
end
function Game.sellCollection(collectionId, event)
	if Game.collections[collectionId].count <= 0 then
		return
	end
	if Game.settings.confirmItemSelling then
		composer.showOverlay("overlays.sellconfirmation", {
			effect = "fade",
			time = 300,
			isModal = true,
			params = {
				item = Game.collections[collectionId]
			}
		})
		return
	end
	Game.internalSellCollection(collectionId)
	if event then
		GUI.showAnimatedText(nil, "+$" .. formatPrice(Game.collections[collectionId].sellPrice), event.x * (math.random(95, 105) / 100), event.y * (math.random(95, 100) / 100))
	end
end
function Game.internalSellSouvenir(souvenirId)
	local souvenir = Game.souvenirs[souvenirId]
	Game.souvenirs[souvenirId].count = Game.souvenirs[souvenirId].count - 1
	Game.addMoney(souvenir.sellPrice, "Souvenir", Game.souvenirs[souvenirId].name)
end
function Game.sellSouvenir(souvenirId, event)
	if Game.souvenirs[souvenirId].count <= 0 then
		return
	end
	if Game.settings.confirmItemSelling then
		composer.showOverlay("overlays.sellconfirmation", {
			effect = "fade",
			time = 300,
			isModal = true,
			params = {
				item = Game.souvenirs[souvenirId]
			}
		})
		return
	end
	Game.internalSellSouvenir(souvenirId)
	if event then
		GUI.showAnimatedText(nil, "+$" .. formatPrice(Game.souvenirs[souvenirId].sellPrice), event.x * (math.random(95, 105) / 100), event.y * (math.random(95, 100) / 100))
	end
end
function Game.internalSellSkin(eqEntry, entryId)
	local itemPrice = Game.getPrice(eqEntry)
	StatisticManager.addStatistic("soldItems")
	StatisticManager.addStatistic("soldSkins")
	StatisticManager.addStatistic("skinsWorth", -itemPrice)
	Game.addMoney(itemPrice, "Skin", "sell")
	table.remove(Game.equipment, entryId)
	if 25 <= itemPrice then
		Game.unlockAchievement("Valuable Skin")
	end
end
function Game.internalSellSticker(eqEntry, entryId)
	local itemPrice = Game.getPrice(eqEntry)
	Game.addMoney(itemPrice, "Sticker", Game.stickers[eqEntry.id].name)
	StatisticManager.addStatistic("soldItems")
	StatisticManager.addStatistic("skinsWorth", -itemPrice)
	table.remove(Game.equipment, entryId)
end
function Game.sellEquipmentItem(eqEntry, entryId, event, force, sellCallback)
	local itemPrice = Game.getPrice(eqEntry)
	if Game.settings.confirmItemSelling and not force then
		composer.showOverlay("overlays.sellconfirmation", {
			effect = "fade",
			time = 300,
			isModal = true,
			params = {
				item = eqEntry,
				entryId = entryId,
				callback = sellCallback
			}
		})
		return itemPrice
	end
	if eqEntry.type == Item.skin then
		Game.internalSellSkin(eqEntry, entryId)
	else
		Game.internalSellSticker(eqEntry, entryId)
	end
	if event then
		GUI.showAnimatedText(nil, "+$" .. formatPrice(itemPrice), event.x, event.y * 0.97)
	end
	return itemPrice
end
function Game.onKeyBuy()
	StatisticManager.addStatistic("keysBought")
	StatisticManager.addStatistic("itemsBought")
end
function Game.isKnife(id)
	return Game.skins[id].isKnife or false
end
function Game.unlockCase(caseId)
	if Game.cases[caseId].unlocked then
		return false
	end
	StatisticManager.addStatistic("unlockedCases")
	Game.cases[caseId].unlocked = true
end
function Game.addItem(item, showOverlay, statTrak, save, options)
	if Game.itemLock == true then
		return
	end
	options = options or {}
	if type(showOverlay) == "nil" then
		showOverlay = true
	end
	if type(options.highlight) == "nil" then
		options.highlight = true
	end
	if type(statTrak) == "nil" then
		statTrak = false
	end
	if type(save) == "nil" then
		save = true
	end
	if options.disableAchievements then
		Game.disableAchievements = true
	end
	local quality, pattern
	local itemPrice = 0
	local itemPosition = 0
	if item.type == Item.case then
		Game.cases[item.id].count = Game.cases[item.id].count + 1
	elseif item.type == Item.key then
		Game.keys[item.id].count = Game.keys[item.id].count + 1
	elseif item.type == Item.collection then
		Game.collections[item.id].count = Game.collections[item.id].count + 1
	elseif item.type == Item.souvenir then
		Game.souvenirs[item.id].count = Game.souvenirs[item.id].count + 1
	elseif item.type == Item.capsule then
		Game.capsules[item.id].count = Game.capsules[item.id].count + 1
	elseif item.type == Item.skin then
		if options.quality then
			quality = tonumber(options.quality)
		else
			quality = QualityManager.getRandomQuality(item)
		end
		if options.pattern then
			pattern = options.pattern
		end
		local itemTable = {
			type = Item.skin,
			id = item.id,
			quality = quality,
			hl = options.highlight
		}
		if statTrak and Game.skins[item.id].statTrakAvailable then
			if not options.disableMissions then
				StatisticManager.addStatistic("statTrakFound")
			end
			itemTable.statTrak = true
			statTrak = true
		end
		if statTrak and Game.skins[item.id].souvenirAvailable then
			itemTable.statTrak = true
			statTrak = true
		end
		if options.name then
			itemTable.n = options.name
		end
		if options.stickers then
			itemTable.stickers = options.stickers
		end
		if Game.isKnife(item.id) then
			if not options.disableMissions then
				StatisticManager.addStatistic("knivesFound")
			end
			if Game.skins[item.id].patterns then
				if pattern then
					itemTable.pattern = pattern
				else
					pattern = Game.getSkinRandomPattern(itemTable)
					itemTable.pattern = pattern
				end
			end
		end
		local rarity = Game.skins[item.id].rarity
		if rarity == Rarity.red and not options.disableMissions then
			StatisticManager.addStatistic("covertFound")
		elseif rarity == Rarity.pink and not options.disableMissions then
			StatisticManager.addStatistic("classifiedFound")
		elseif rarity == Rarity.purple and not options.disableMissions then
			StatisticManager.addStatistic("restrictedFound")
		elseif rarity == Rarity.blue and not options.disableMissions then
			StatisticManager.addStatistic("milspecFound")
		end
		if rarity == Rarity.blue then
			StatisticManager.addStatistic("bluesInARow")
		else
			StatisticManager.setStatistic("bluesInARow", 0)
		end
		if rarity == Rarity.purple then
			StatisticManager.addStatistic("purplesInARow")
		else
			StatisticManager.setStatistic("purplesInARow", 0)
		end
		if rarity == Rarity.pink then
			StatisticManager.addStatistic("pinksInARow")
		else
			StatisticManager.setStatistic("pinksInARow", 0)
		end
		if rarity == Rarity.red then
			StatisticManager.addStatistic("redsInARow")
		else
			StatisticManager.setStatistic("redsInARow", 0)
		end
		itemPosition = EquipmentManager.queryItemPosition(itemTable)
		table.insert(Game.equipment, itemPosition, itemTable)
		itemPrice = Game.getPrice(itemTable)
		StatisticManager.addStatistic("skinsWorth", itemPrice)
		Menu.addAlert("Equipment")
	elseif item.type == Item.sticker then
		local itemTable = {
			type = Item.sticker,
			id = item.id,
			hl = options.highlight
		}
		itemPosition = EquipmentManager.queryItemPosition(itemTable)
		table.insert(Game.equipment, itemPosition, itemTable)
		StatisticManager.addStatistic("stickersFound")
		itemPrice = Game.getPrice(itemTable)
		StatisticManager.addStatistic("skinsWorth", itemPrice)
		if Game.stickers[item.id].rarity == Rarity.pink then
			Game.unlockAchievement("Exotic Sticker")
		end
		Menu.addAlert("Equipment")
	elseif item.type == Item.glove then
		statTrak = false
		if options.quality then
			quality = tonumber(options.quality)
		else
			quality = QualityManager.getRandomQuality(item)
		end
		local itemTable = {
			type = Item.glove,
			id = item.id,
			quality = quality,
			hl = options.highlight
		}
		itemPosition = EquipmentManager.queryItemPosition(itemTable)
		table.insert(Game.equipment, itemPosition, itemTable)
		itemPrice = Game.getPrice(itemTable)
		StatisticManager.addStatistic("skinsWorth", itemPrice)
		StatisticManager.addStatistic("glovesFound")
		Menu.addAlert("Equipment")
	elseif item.type == Item.other then
		local itemTable = {
			type = Item.other,
			id = item.id,
			hl = true
		}
		table.insert(Game.equipment, 1, itemTable)
	end
	if options.changeProfit then
		if options.case then
			Game.cases[options.case.id].profit = Game.cases[options.case.id].profit + itemPrice
		elseif options.souvenir then
			Game.souvenirs[options.souvenir.id].profit = Game.souvenirs[options.souvenir.id].profit + itemPrice
		elseif options.collection then
			Game.collections[options.collection.id].profit = Game.collections[options.collection.id].profit + itemPrice
		elseif options.capsule then
			Game.capsules[options.capsule.id].profit = Game.capsules[options.capsule.id].profit + itemPrice
		end
	end
	if save then
		Game.save()
	end
	AchievementManager.onItemAdd()
	if options.disableAchievements then
		Game.disableAchievements = false
	end
	if showOverlay == true then
		if options.drawType and (options.drawType == Item.skin or options.drawType == Item.collection) and composer.getSceneName("current") == "scenes.draw" then
			composer.gotoScene("scenes.main")
		end
		local overlayOptions = {
			isModal = true,
			effect = "slideDown",
			time = 200,
			params = {
				titleText = "New item!",
				item = item,
				statTrak = statTrak,
				quality = quality,
				newItem = true,
				pattern = pattern,
				customName = options.name,
				itemPosition = itemPosition
			}
		}
		if not options.overlayDelay then
			audio.play(Game.sounds.itemReveal, {
				channel = audio.findFreeChannel()
			})
			composer.showOverlay("overlays.itemoverlay", overlayOptions)
		else
			timer.performWithDelay(options.overlayDelay, function()
				audio.play(Game.sounds.itemReveal, {
					channel = audio.findFreeChannel()
				})
				composer.showOverlay("overlays.itemoverlay", overlayOptions)
			end)
		end
	end
end
function Game.getSkinRandomPattern(item)
	if item.type ~= Item.skin or not Game.skins[item.id].patterns then
		return nil
	end
	while true do
		local selectedPattern = math.random(1, #Game.skins[item.id].patterns)
		local patternId = Game.skins[item.id].patterns[selectedPattern]
		local patternInfo = PatternInfo[patternId]
		if math.random(1, 100) <= patternInfo.chance then
			return selectedPattern
		end
	end
end
function Game.addMoney(amount, itemType, itemName, missionReward)
	local moneyBefore = Game.money
	Game.money = Game.money + amount
	if Game.money > StatisticManager.getStatistic("moneyRecord") then
		StatisticManager.setStatistic("moneyRecord", Game.money)
	end
	if not missionReward then
		StatisticManager.addStatistic("totalGainedMoney", amount)
	end
	Menu.updateBalanceText()
	Analytics.addResource({
		currency = "Money",
		amount = amount,
		itemType = itemType,
		itemId = itemName
	})
	AchievementManager.onMoneyAdd(moneyBefore)
end
function Game.removeMoney(amount, itemType, itemName)
	Game.money = Game.money - amount
	Analytics.removeResource({
		currency = "Money",
		amount = amount,
		itemType = itemType,
		itemId = itemName
	})
	Menu.updateBalanceText()
end
function Game.getRandomGlove()
	return choose(Game.gloves)
end
function Game.getRandomKnife(minPrice)
	local knifeTable = {}
	local minPrice = minPrice or 0
	for i = 1, #Game.skins do
		if Game.skins[i] and Game.skins[i].isKnife then
			table.insert(knifeTable, i)
		end
	end
	if #knifeTable == 0 then
		return choose(Game.skins)
	end
	for try = 1, 50 do
		local knife = Game.skins[choose(knifeTable)]
		local quality = Quality.fieldtested
		if knife.disabledQualities and knife.disabledQualities[Quality.fieldtested] then
			quality = Quality.factorynew
		end
		local price = Game.getItemPrice({
			id = knife.id,
			quality = quality
		}) or 0
		if minPrice <= price then
			return knife
		end
	end
	return Game.skins[choose(knifeTable)]
end
function Game.getRandomSkinByRarity(rarity)
	local item
	while true do
		local item = choose(Game.skins)
		local allowed = true
		if item.percentChance and math.random(1, 100) > item.percentChance then
			allowed = false
		end
		if item.rarity == rarity and allowed then
			return item
		end
	end
end
function Game.getRandomSticker()
	while true do
		local allowed = true
		local sticker = choose(Game.stickers)
		if sticker.percentChance and math.random(1, 100) > sticker.percentChance then
			allowed = false
		end
		if allowed then
			return sticker
		end
	end
end
function Game.getRandomCaseItemId(case, options)
	local options = options or {}
	local item
	local additionalKnifeChance = 0
	if options.dailyDraw then
		additionalKnifeChance = 3
	end
	while true do
		if math.random(1, 1220) <= Game.knifeChance + additionalKnifeChance then
			if case.gloves then
				return case.gloves
			end
			if case.knifes == Knife.huntsman then
				return -2
			elseif case.knifes == Knife.falchion then
				return -3
			elseif case.knifes == Knife.butterfly then
				return -4
			elseif case.knifes == Knife.shadow then
				return -5
			elseif case.knifes == Knife.bowie then
				return -6
			else
				return -1
			end
		end
		item = Game.skins[choose(case.skins)]
		if math.random(1, 1000) <= RarityChances[item.rarity] * #case.skins * 2.904 then
			return item.id
		end
	end
	return nil
end
function Game.getRandomCapsuleItemId(capsule)
	local item
	while true do
		item = Game.stickers[choose(capsule.stickers)]
		if math.random(1, 1000) <= RarityChances[item.rarity] * #capsule.stickers * 2.904 then
			return item.id
		end
	end
	return nil
end
function Game.getCollectionRandomItemId(collection)
	local item
	while true do
		item = Game.skins[choose(collection.skins)]
		if math.random(1, 1000) <= RarityChances[item.rarity] * #collection.skins * 2.904 then
			return item.id
		end
	end
	return nil
end
function Game.getRandomCaseId(allCases)
	local case
	while true do
		case = choose(Game.cases)
		if (case.unlocked == true or allCases) and math.random(1, 100) <= case.chance then
			case = case.id
			break
		end
	end
	return case
end
function Game.unlockAchievement(name)
	if Game.disableAchievements or Game.achievements[name].unlocked == true then
		return false
	end
	GameServices.unlockAchievement(name)
	Game.achievementChange = true
	Game.achievements[name].unlocked = true
	GUI.showInfoBox("Achievement unlocked:", name)
	StatisticManager.addStatistic("unlockedAchievements")
	Analytics.addEvent("Achievement:" .. name)
	Menu.addAlert("Achievements")
	return true
end
function Game.isAchievementUnlocked(name)
	return Game.achievements[name].unlocked
end
function Game.showKnifeDraw(paidBonus)
	local options = {
		effect = "fade",
		time = 100,
		params = {
			drawType = Item.knife,
			paidBonus = paidBonus
		}
	}
	Game.lastDrawParams = {
		drawType = Item.knife,
		paidBonus = paidBonus
	}
	Game.lastScene = composer.getSceneName("current")
	composer.gotoScene("scenes.draw", options)
end
function Game.showGloveDraw(paidBonus)
	local options = {
		effect = "fade",
		time = 100,
		params = {
			drawType = Item.glove,
			paidBonus = paidBonus
		}
	}
	Game.lastDrawParams = {
		drawType = Item.glove,
		paidBonus = paidBonus
	}
	Game.lastScene = composer.getSceneName("current")
	composer.gotoScene("scenes.draw", options)
end
function Game.showCaseDraw(allCases)
	local case = Game.getRandomCaseId(allCases)
	Game.addItem(Game.cases[case], true)
end
function Game.showCollectionDraw(collectionId, quickDraw)
	if quickDraw then
		local skin = Game.skins[Game.getCollectionRandomItemId(Game.collections[collectionId])]
		Game.addItem(skin, true, false, true)
		return true
	end
	local options = {
		effect = "fade",
		time = 100,
		params = {
			drawType = Item.collection,
			collection = Game.collections[collectionId],
			changeProfit = true
		}
	}
	Game.lastDrawParams = {
		drawType = Item.collection,
		collection = Game.collections[collectionId],
		changeProfit = true
	}
	Game.lastScene = composer.getSceneName("current")
	composer.gotoScene("scenes.draw", options)
end
function Game.showSouvenirDraw(souvenirId)
	local options = {
		effect = "fade",
		time = 100,
		params = {
			drawType = Item.souvenir,
			collection = Game.collections[Game.souvenirs[souvenirId].collection],
			changeProfit = true
		}
	}
	Game.lastDrawParams = {
		drawType = Item.souvenir,
		collection = Game.collections[Game.souvenirs[souvenirId].collection],
		changeProfit = true
	}
	Game.lastScene = composer.getSceneName("current")
	composer.gotoScene("scenes.draw", options)
end
function Game.showKeyDraw(caseKeysOnly)
	local options = {
		effect = "fade",
		time = 100,
		params = {
			drawType = Item.key,
			caseKeysOnly = caseKeysOnly
		}
	}
	Game.lastScene = composer.getSceneName("current")
	composer.gotoScene("scenes.draw", options)
end
function Game.showDailyDraw(boxId)
	local params = {
		dailyDraw = true,
		boxId = boxId,
		drawType = Item.custom
	}
	local items = {}
	for i = 1, 6 do
		local item = EquipmentManager.getItemWithPrice(0.5 + StatisticManager.getStatistic("dailyRewards") / 6, 5 + StatisticManager.getStatistic("dailyRewards") * 2)
		table.insert(items, item)
	end
	params.items = items
	local options = {
		effect = "fade",
		time = 100,
		params = params
	}
	Game.lastScene = composer.getSceneName("current")
	composer.gotoScene("scenes.draw", options)
end
function Game.showCaseInfo(caseId)
	local options = {
		params = {
			case = Game.cases[caseId]
		}
	}
	if composer.getSceneName("current") ~= "scenes.caseinfo" then
		Game.lastScene = composer.getSceneName("current")
	end
	composer.gotoScene("scenes.caseinfo", options)
end
function Game.showCapsuleInfo(capsuleId)
	local options = {
		params = {
			case = Game.capsules[capsuleId]
		}
	}
	if composer.getSceneName("current") ~= "scenes.caseinfo" then
		Game.lastScene = composer.getSceneName("current")
	end
	composer.gotoScene("scenes.caseinfo", options)
end
function Game.showSouvenirInfo(souvenirId)
	local souvenir = Game.souvenirs[souvenirId]
	local case = Game.collections[souvenir.collection]
	case.rarity = Rarity.red
	local options = {
		params = {case = case, info = souvenir}
	}
	if composer.getSceneName("current") ~= "scenes.caseinfo" then
		Game.lastScene = composer.getSceneName("current")
	end
	composer.gotoScene("scenes.caseinfo", options)
end
function Game.showCollectionInfo(collectionId)
	local case = Game.collections[collectionId]
	case.rarity = Rarity.red
	local options = {
		params = {case = case}
	}
	if composer.getSceneName("current") ~= "scenes.caseinfo" then
		Game.lastScene = composer.getSceneName("current")
	end
	composer.gotoScene("scenes.caseinfo", options)
end
function Game.showPriceInfo(item)
	local options = {
		isModal = true,
		effect = "slideDown",
		time = 200,
		params = {item = item}
	}
	composer.showOverlay("overlays.itempriceinfo", options)
end
function Game.showItemInfo(item)
	local options = {
		isModal = true,
		effect = "slideDown",
		time = 200,
		params = {
			item = item,
			statTrak = item.statTrak,
			quality = item.quality,
			pattern = item.pattern,
			stickers = item.stickers
		}
	}
	audio.play(Game.sounds.itemReveal, {
		channel = audio.findFreeChannel()
	})
	composer.showOverlay("overlays.itemoverlay", options)
end
function Game.showEquipmentItemInfo(equipmentId, options)
	local item
	local options = options or {}
	if Game.equipment[equipmentId].type == Item.skin then
		item = Game.skins[Game.equipment[equipmentId].id]
	elseif Game.equipment[equipmentId].type == Item.sticker then
		item = Game.stickers[Game.equipment[equipmentId].id]
	elseif Game.equipment[equipmentId].type == Item.glove then
		item = Game.gloves[Game.equipment[equipmentId].id]
	elseif Game.equipment[equipmentId].type == Item.other then
		item = Game.otherItems[Game.equipment[equipmentId].id]
	end
	options.item = item
	options.statTrak = Game.equipment[equipmentId].statTrak
	options.quality = Game.equipment[equipmentId].quality
	options.pattern = Game.equipment[equipmentId].pattern
	options.stickers = Game.equipment[equipmentId].stickers
	options.locked = Game.equipment[equipmentId].locked
	options.item.n = Game.equipment[equipmentId].n
	local options = {
		isModal = true,
		effect = "slideDown",
		time = 200,
		params = options
	}
	audio.play(Game.sounds.itemReveal, {
		channel = audio.findFreeChannel()
	})
	composer.showOverlay("overlays.itemoverlay", options)
end
function Game.openCase(caseId)
	Game.lastScene = composer.getSceneName("current")
	Game.cases[caseId].opened = Game.cases[caseId].opened + 1
	Game.cases[caseId].count = Game.cases[caseId].count - 1
	Game.keys[Game.cases[caseId].keyId].count = Game.keys[Game.cases[caseId].keyId].count - 1
	Game.cases[caseId].profit = Game.cases[caseId].profit - Game.cases[caseId].price - Game.keyCost
	Analytics.addEvent("Case Open:" .. Game.cases[caseId].name)
	Game.lastDrawParams = {
		drawType = Item.skin,
		caseId = caseId or 2,
		changeProfit = true,
		newItem = true
	}
	composer.gotoScene("scenes.draw", {
		effect = "fade",
		time = 100,
		params = {
			drawType = Item.skin,
			caseId = caseId,
			changeProfit = true,
			newItem = true
		}
	})
	StatisticManager.addStatistic("openedBoxes")
end
function Game.getStatTrak()
	if math.random(1, 100) <= Game.others.statTrakChance or Game.others.statTrakGuarantees > 0 then
		return true
	end
	return false
end
function Game.signContract(equipmentIdList)
	local nameList = {}
	for i = 1, #equipmentIdList do
		table.insert(nameList, Game.skins[Game.equipment[equipmentIdList[i]].id].name)
	end
	local contractRarity = Game.skins[Game.equipment[equipmentIdList[1]].id].rarity + 1
	local statTrak = false
	if Game.equipment[equipmentIdList[1]].statTrak then
		statTrak = true
	end
	local qualityChances = {
		[Quality.battlescarred] = 0,
		[Quality.wellworn] = 0,
		[Quality.fieldtested] = 0,
		[Quality.minimalwear] = 0,
		[Quality.factorynew] = 0
	}
	local itemList = {}
	for i = 1, #equipmentIdList do
		local equipmentSkin = Game.equipment[equipmentIdList[i]]
		local skin = Game.skins[equipmentSkin.id]
		if equipmentSkin.quality == Quality.battlescarred then
			qualityChances[Quality.battlescarred] = qualityChances[Quality.battlescarred] + 50
			qualityChances[Quality.wellworn] = qualityChances[Quality.wellworn] + 20
			qualityChances[Quality.fieldtested] = qualityChances[Quality.fieldtested] + 30
		elseif equipmentSkin.quality == Quality.wellworn then
			qualityChances[Quality.battlescarred] = qualityChances[Quality.battlescarred] + 30
			qualityChances[Quality.wellworn] = qualityChances[Quality.wellworn] + 50
			qualityChances[Quality.fieldtested] = qualityChances[Quality.fieldtested] + 20
		elseif equipmentSkin.quality == Quality.fieldtested then
			qualityChances[Quality.fieldtested] = qualityChances[Quality.fieldtested] + 75
			qualityChances[Quality.minimalwear] = qualityChances[Quality.minimalwear] + 25
		elseif equipmentSkin.quality == Quality.minimalwear then
			qualityChances[Quality.fieldtested] = qualityChances[Quality.fieldtested] + 25
			qualityChances[Quality.minimalwear] = qualityChances[Quality.minimalwear] + 50
			qualityChances[Quality.factorynew] = qualityChances[Quality.factorynew] + 25
		elseif equipmentSkin.quality == Quality.factorynew then
			qualityChances[Quality.minimalwear] = qualityChances[Quality.minimalwear] + 45
			qualityChances[Quality.factorynew] = qualityChances[Quality.factorynew] + 55
		end
		for _, case in ipairs(Game.cases) do
			local isPresent = false
			for _, caseSkinId in ipairs(case.skins) do
				if skin.id == caseSkinId then
					isPresent = true
				end
			end
			if isPresent then
				for _, caseSkinId in ipairs(case.skins) do
					if Game.skins[caseSkinId].rarity == contractRarity then
						table.insert(itemList, caseSkinId)
					end
				end
				if case.contractSkins then
					for _, caseSkinId in ipairs(case.contractSkins) do
						if Game.skins[caseSkinId].rarity == contractRarity then
							table.insert(itemList, caseSkinId)
						end
					end
				end
			end
		end
		for _, collection in pairs(Game.collections) do
			local isPresent = false
			for _, skinId in ipairs(collection.skins) do
				if skin.id == skinId then
					isPresent = true
				end
			end
			if isPresent then
				for _, skinId in ipairs(collection.skins) do
					if Game.skins[skinId].rarity == contractRarity then
						table.insert(itemList, skinId)
					end
				end
			end
		end
	end
	if Game.testMode then
		print("Possible contract outcome:")
		for _, i in ipairs(itemList) do
			print(" > " .. Game.skins[i].name)
		end
	end
	if #itemList == 0 then
		return false
	end
	table.sort(equipmentIdList)
	for i = #equipmentIdList, 1, -1 do
		table.remove(Game.equipment, equipmentIdList[i])
	end
	StatisticManager.addStatistic("signedContracts")
	local rand = math.random(1, 1000)
	local outputQuality = Quality.wellworn
	local sum = 0
	for i = 1, #qualityChances do
		sum = sum + qualityChances[i]
		if rand <= sum then
			outputQuality = i
			break
		end
	end
	local skinToAdd = Game.skins[choose(itemList)]
	skinToAdd.n = nil
	local disabledQualities = {}
	if skinToAdd.disabledQualities then
		for i = 1, #skinToAdd.disabledQualities do
			disabledQualities[skinToAdd.disabledQualities[i]] = true
		end
	end
	local goodQuality = true
	if disabledQualities[outputQuality] and outputQuality ~= 5 then
		goodQuality = false
		for i = outputQuality + 1, 5 do
			if not disabledQualities[i] then
				goodQuality = true
				outputQuality = i
				break
			end
		end
	end
	if not goodQuality and outputQuality ~= 1 then
		for i = outputQuality - 1, 1, -1 do
			if not disabledQualities[i] then
				goodQuality = true
				outputQuality = i
				break
			end
		end
	end
	local options = {
		effect = "fade",
		time = 100,
		params = {
			names = nameList,
			toAdd = skinToAdd,
			quality = outputQuality,
			statTrak = statTrak
		}
	}
	Game.lastScene = composer.getSceneName("current")
	composer.gotoScene("scenes.contract", options)
	Analytics.addEvent("Contract Sign")
end
function Game.addExperience(value)
	Game.experience = Game.experience + value
	local experienceToAdvance = Game.expRanks[Game.expRank].expForAdvance
	if experienceToAdvance <= Game.experience and Game.expRank < 40 then
		Game.expRank = Game.expRank + 1
		Game.experience = 0
		Game.others.expRankRewardsAvailable = Game.others.expRankRewardsAvailable + 1
		Analytics.setProgress("Start", "Private Rank", Game.others.expResets, Game.expRanks[Game.expRank].name)
		for i = 1, #Game.expRanks[Game.expRank].upgrades do
			Game.unlockUpgrade(Game.expRanks[Game.expRank].upgrades[i])
		end
		Menu.addAlert("Missions")
		GUI.showInfoBox("Rank up!", "Great!", InfoBoxType.rank)
		if Game.expRank == 40 then
			Game.unlockAchievement("Global General")
		end
	end
	StatisticManager.addStatistic("totalExperience", value)
end
function Game.openCapsule(capsuleId)
	Game.capsules[capsuleId].count = Game.capsules[capsuleId].count - 1
	Game.capsules[capsuleId].opened = Game.capsules[capsuleId].opened + 1
	Game.capsules[capsuleId].profit = Game.capsules[capsuleId].profit - Game.capsules[capsuleId].price
	if Game.capsules[capsuleId].keyId then
		Game.keys[Game.capsules[capsuleId].keyId].count = Game.keys[Game.capsules[capsuleId].keyId].count - 1
		Game.capsules[capsuleId].profit = Game.capsules[capsuleId].profit - Game.keys[Game.capsules[capsuleId].keyId].price
	end
	local options = {
		effect = "fade",
		time = 100,
		params = {
			drawType = Item.sticker,
			capsuleId = capsuleId,
			changeProfit = true
		}
	}
	Game.lastDrawParams = {
		drawType = Item.sticker,
		capsuleId = capsuleId,
		changeProfit = true
	}
	Game.lastScene = composer.getSceneName("current")
	composer.gotoScene("scenes.draw", options)
	StatisticManager.addStatistic("openedCapsules")
	Analytics.addEvent("Capsule Open:" .. Game.capsules[capsuleId].name)
end
function Game.openCollection(collectionId)
	Game.collections[collectionId].opened = Game.collections[collectionId].opened + 1
	Game.collections[collectionId].count = Game.collections[collectionId].count - 1
	Game.collections[collectionId].profit = Game.collections[collectionId].profit - Game.collections[collectionId].price
	Game.showCollectionDraw(collectionId)
	StatisticManager.addStatistic("openedCollections")
	Analytics.addEvent("Collection Open:" .. Game.collections[collectionId].name)
end
function Game.openSouvenir(souvenirId)
	Game.souvenirs[souvenirId].opened = Game.souvenirs[souvenirId].opened + 1
	Game.souvenirs[souvenirId].count = Game.souvenirs[souvenirId].count - 1
	Game.souvenirs[souvenirId].profit = Game.souvenirs[souvenirId].profit - Game.souvenirs[souvenirId].price
	Game.showSouvenirDraw(Game.souvenirs[souvenirId].id)
	StatisticManager.addStatistic("openedSouvenirs")
	Analytics.addEvent("Souvenir Open:" .. Game.souvenirs[souvenirId].name)
end
function Game.buyKey(keyId, amount)
	local key = Game.keys[keyId]
	local buyAmount = amount or 1
	local buyPrice = buyAmount * 2.5
	if buyPrice > Game.money then
		return
	end
	Game.removeMoney(buyPrice, "Key", buyAmount .. "x " .. key.name)
	for i = 1, buyAmount do
		Game.addItem(Game.keys[key.id], false, false, false)
	end
end
function Game.buyCase(caseId, amount)
	local case = Game.cases[caseId]
	local buyAmount = amount or 1
	local buyPrice = buyAmount * case.price
	if buyPrice > Game.money then
		return
	end
	Game.removeMoney(buyPrice, "Case", buyAmount .. "x " .. case.name)
	for i = 1, buyAmount do
		Game.addItem(Game.cases[case.id], false, false, false)
	end
end
function Game.buyCapsule(capsuleId, amount)
	local buyAmount = amount or 1
	local buyPrice = buyAmount * Game.capsules[capsuleId].price
	if buyPrice > Game.money then
		return
	end
	Game.capsules[capsuleId].count = Game.capsules[capsuleId].count + buyAmount
	Game.removeMoney(buyPrice, "Capsule", buyAmount .. "x " .. Game.capsules[capsuleId].name)
	StatisticManager.addStatistic("boughtCapsules", buyAmount)
end
function Game.buySouvenir(souvenirId, amount)
	local buyAmount = amount or 1
	local buyPrice = buyAmount * Game.souvenirs[souvenirId].price
	if buyPrice > Game.money then
		return
	end
	Game.souvenirs[souvenirId].count = Game.souvenirs[souvenirId].count + buyAmount
	Game.removeMoney(buyPrice, "Souvenir", buyAmount .. "x " .. Game.souvenirs[souvenirId].name)
	StatisticManager.addStatistic("boughtSouvenirs", buyAmount)
end
function Game.buyCollection(collectionId, amount)
	local buyAmount = amount or 1
	local buyPrice = buyAmount * Game.collections[collectionId].price
	local collection = Game.collections[collectionId]
	if buyPrice > Game.money then
		return
	end
	StatisticManager.addStatistic("boughtCollections", buyAmount)
	Game.collections[collectionId].count = Game.collections[collectionId].count + buyAmount
	Game.removeMoney(buyPrice, "Collection", buyAmount .. "x " .. Game.collections[collectionId].name)
end
function Game.onDailyReward()
	StatisticManager.addStatistic("dailyRewards")
end
function Game.getItemRarity(item)
	if item.type == Item.skin then
		return Game.skins[item.id].rarity
	else
		return Game.stickers[item.id].rarity
	end
end
function Game.getSouvenirByCollectionId(collectionId)
	for i = 1, #Game.souvenirs do
		if Game.souvenirs[i].collection == collectionId then
			return Game.souvenirs[i]
		end
	end
	return nil
end
function Game.completeCollection(item)
	if item.completed then
		return
	end
	if item.type == Item.case then
		StatisticManager.addStatistic("casesCompleted")
		Game.cases[item.id].completed = true
	elseif item.type == Item.souvenir then
		StatisticManager.addStatistic("souvenirsCompleted")
		Game.souvenirs[item.id].completed = true
		item = Game.souvenirs[item.id]
	elseif item.type == Item.collection then
		StatisticManager.addStatistic("collectionsCompleted")
		Game.collections[item.id].completed = true
		item = Game.collections[item.id]
	elseif item.type == Item.capsule then
		StatisticManager.addStatistic("capsulesCompleted")
		Game.capsules[item.id].completed = true
	end
	for i = 1, 50 do
		Game.addItem(item, false, false, false)
	end
	Game.checkForCompletedCollections()
	GUI.showInfoBox("Exp reward", "1000 exp awarded", InfoBoxType.experience)
	Game.addExperience(1000)
	Game.save()
	GUI.showInfoBox("Completion reward:", "50x " .. item.name, InfoBoxType.coin)
end
function Game.isItemOwned(item)
	if item.type == Item.sticker then
		for i = 1, #Game.equipment do
			if Game.equipment[i].id == item.id and Game.equipment[i].type == Item.sticker then
				return true
			end
		end
	elseif item.type == Item.skin then
		for i = 1, #Game.equipment do
			if Game.equipment[i].id == item.id and Game.equipment[i].type == Item.skin then
				if not item.statTrak then
					return true
				end
				if item.statTrak and Game.equipment[i].statTrak then
					return true
				end
			end
		end
	elseif item.type == Item.glove then
		for i = 1, #Game.equipment do
			if Game.equipment[i].id == item.id and Game.equipment[i].type == Item.glove then
				return true
			end
		end
	end
	return false
end
function Game.checkForCompletedCollections()
	AchievementManager.onCollectionCompleted()
end
function Game.addCriticalTap()
	StatisticManager.addStatistic("criticalTaps")
	Game.criticalStreak = Game.criticalStreak + 1
end
function Game.performOnceAction(actionId, action)
	if not Game.others["onceAction" .. actionId] then
		Game.others["onceAction" .. actionId] = true
		action()
	end
end
function Game.showKnifeAd()
	if Game.others.noKnifeAds then
		return
	end
	composer.showOverlay("overlays.knifead")
end
function Game.isQualityAvailable(skinId, quality)
	if not Game.skins[skinId].disabledQualities then
		return true
	end
	for _, disabledQuality in ipairs(Game.skins[skinId].disabledQualities) do
		if disabledQuality == quality then
			return false
		end
	end
	return true
end
function Game.getMissingKeys()
	local keys = {}
	for _, case in ipairs(Game.cases) do
		local caseCount = case.count
		local key = Game.keys[case.keyId]
		local keyCount = key.count
		local missingKeys = math.max(0, caseCount - keyCount)
		for i = 1, missingKeys do
			table.insert(keys, key.id)
		end
	end
	return keys
end
function Game.getItemPatternId(item)
	return Game.skins[item.id].patterns[item.pattern]
end
function Game.getItemPatternInfo(item)
	local patternId = Game.skins[item.id].patterns[item.pattern]
	return PatternInfo[patternId]
end
function Game.checkForItemNewImage(id, pattern)
	if 784 <= id or pattern then
		return true
	end
	return false
end
