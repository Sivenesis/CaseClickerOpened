local StatisticManager = {
	statistics = {
		totalGainedMoney = 0,
		totalClicks = 0,
		searchClicks = 0,
		moneyClicks = 0,
		knivesFound = 0,
		soldCases = 0,
		signedContracts = 0,
		unlockedAchievements = 0,
		openedBoxes = 0,
		itemsBought = 0,
		soldItems = 0,
		soldSkins = 0,
		keysBought = 0,
		upgradesBought = 0,
		watchedAds = 0,
		skinsWorth = 0,
		covertFound = 0,
		classifiedFound = 0,
		restrictedFound = 0,
		milspecFound = 0,
		statTrakFound = 0,
		unlockedCases = 0,
		totalExperience = 0,
		completedMissions = 0,
		openedSouvenirs = 0,
		boughtSouvenirs = 0,
		openedCollections = 0,
		boughtCollections = 0,
		dailyRewards = 0,
		maximumCombo = 1,
		boughtCapsules = 0,
		openedCapsules = 0,
		stickersFound = 0,
		bluesInARow = 0,
		purplesInARow = 0,
		pinksInARow = 0,
		redsInARow = 0,
		capsulesCompleted = 0,
		souvenirsCompleted = 0,
		casesCompleted = 0,
		collectionsCompleted = 0,
		jackpotsPlayed = 0,
		jackpotsWon = 0,
		jackpotsLost = 0,
		logoTaps = 0,
		criticalTaps = 0,
		moneyWonInJackpots = 0,
		moneyLostInJackpots = 0,
		tradesCompleted = 0,
		maximumTapsPerSecond = 0,
		moneyRecord = 0,
		placedBets = 0,
		wonBets = 0,
		lostBets = 0,
		casesFound = 0,
		onlineJackpotsPlayed = 0,
		onlineJackpotsWon = 0,
		onlineJackpotsLost = 0,
		moneyWonInOnlineJackpots = 0,
		moneyLostInOnlineJackpots = 0,
		roulettesWon = 0,
		roulettesLost = 0,
		ticketsWonInRoulette = 0,
		ticketsLostInRoulette = 0,
		coinflipsWon = 0,
		coinflipsLost = 0,
		ticketsWonInCoinflip = 0,
		ticketsLostInCoinflip = 0,
		glovesFound = 0,
		minesweepersWon = 0,
		minesweepersLost = 0,
		ticketsWonInMinesweeper = 0,
		ticketsLostInMinesweeper = 0,
		minesweepersWon = 0,
		minesweepersLost = 0,
		minesweeperProfit = 0,
		crashWon = 0,
		crashLost = 0,
		crashProfit = 0,
		usedPromoCodes = 0,
		scratchedScratches = 0,
		successfulUpgrades = 0,
		failedUpgrades = 0
	}
}
local missionCompletionStats = {
	covertFound = true,
	classifiedFound = true,
	totalClicks = true,
	totalGainedMoney = true,
	openedBoxes = true,
	signedContracts = true,
	completedMissions = true,
	openedCapsules = true,
	openedSouvenirs = true,
	minesweepersWon = true,
	casesFound = true,
	minesweepersLost = true,
	crashWon = true,
	jackpotsLost = true,
	jackpotsWon = true,
	openedCollections = true,
	crashLost = true,
	unlockedAchievements = true,
	scratchedScratches = true,
	placedBets = true,
	glovesFound = true,
	knivesFound = true,
	roulettesWon = true,
	coinflipsWon = true,
	dailyRewards = true,
	watchedAds = true
}
function StatisticManager.addStatistic(statistic, value)
	if not StatisticManager.statistics[statistic] then
		return GUI.showMessageBox("Error", "\"" .. statistic .. "\"" .. " not found!")
	end
	local value = value or 1
	StatisticManager.statistics[statistic] = StatisticManager.statistics[statistic] + value
	if missionCompletionStats[statistic] then
		MissionManager.checkMissionsForCompletion()
	end
	if statistic == "covertFound" then
		AchievementManager.onCovertItemFound()
	elseif statistic == "searchClicks" then
		AchievementManager.onCaseClick()
	elseif statistic == "moneyClicks" then
		AchievementManager.onCoinClick()
	elseif statistic == "classifiedFound" then
		AchievementManager.onClassifiedItemFound()
	elseif statistic == "totalGainedMoney" then
		AchievementManager.onMoneyGain()
	elseif statistic == "bluesInARow" then
		AchievementManager.onBlueInARow()
	elseif statistic == "purplesInARow" then
		AchievementManager.onPurpleInARow()
	elseif statistic == "pinksInARow" then
		AchievementManager.onPinkInARow()
	elseif statistic == "redsInARow" then
		AchievementManager.onRedInARow()
	elseif statistic == "glovesFound" then
		AchievementManager.onGlovesFound()
	elseif statistic == "unlockedAchievements" then
		AchievementManager.onAchievementUnlock()
	elseif statistic == "openedBoxes" then
		AchievementManager.onCaseOpen()
	elseif statistic == "signedContracts" then
		AchievementManager.onContractSign()
	elseif statistic == "totalExperience" then
		AchievementManager.onExperienceAdd()
	elseif statistic == "openedCapsules" then
		AchievementManager.onCapsuleOpen()
	elseif statistic == "openedSouvenirs" then
		AchievementManager.onSouvenirOpen()
	elseif statistic == "completedMissions" then
		AchievementManager.onMissionComplete()
	elseif statistic == "boughtSouvenirs" then
		AchievementManager.onSouvenirBought()
	elseif statistic == "dailyRewards" then
		AchievementManager.onDailyReward()
	elseif statistic == "criticalTaps" then
		AchievementManager.onCriticalTap()
	elseif statistic == "soldItems" then
		AchievementManager.onItemSell()
	elseif statistic == "keysBought" then
		AchievementManager.onKeyBuy()
	elseif statistic == "statTrakFound" then
		AchievementManager.onStatTrakFound()
	elseif statistic == "knivesFound" then
		AchievementManager.onKnifeFind()
	elseif statistic == "tradesCompleted" then
		AchievementManager.onTradeComplete()
	elseif statistic == "watchedAds" then
		AchievementManager.onAdWatch()
	elseif statistic == "roulettesWon" then
		AchievementManager.onRouletteWin()
	elseif statistic == "roulettesLost" then
		AchievementManager.onRouletteLose()
	elseif statistic == "logoTaps" then
		AchievementManager.onLogoTap()
	elseif statistic == "placedBets" then
		AchievementManager.onBetPlace()
	end
end
function StatisticManager.getStatistic(name)
	return StatisticManager.statistics[name] or 0
end
function StatisticManager.setStatistic(statistic, value)
	StatisticManager.statistics[statistic] = value
	if statistic == "maximumTapsPerSecond" then
		AchievementManager.onTapsPerSecondRecord()
	elseif statistic == "maximumCombo" then
		AchievementManager.onCombo()
	end
end
function StatisticManager.load(loadTable)
	for key, statistic in pairs(loadTable.statistics) do
		StatisticManager.statistics[key] = loadTable.statistics[key]
	end
	StatisticManager.statistics.unlockedCases = 0
end
function StatisticManager.save(saveTable)
	saveTable.statistics = StatisticManager.statistics
end
function StatisticManager.reset()
	for statistic, _ in pairs(StatisticManager.statistics) do
		StatisticManager.statistics[statistic] = 0
	end
end
return StatisticManager
