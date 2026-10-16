local AchievementManager = {}
local unlockAchievement = function(name)
	return Game.unlockAchievement(name)
end
function AchievementManager.init()
	for k, v in pairs(Game.achievements) do
		if Lang.achievements[k] then
			v.name = Lang.achievements[k].name
			v.description = Lang.achievements[k].description
		end
	end
end
function AchievementManager.unlockNewAchievements()
	AchievementManager.onUpgradeBuy()
	if StatisticManager.getStatistic("statTrakFound") >= 1 then
		unlockAchievement("Yeah! StatTrak!")
	end
	if StatisticManager.getStatistic("statTrakFound") >= 5 then
		unlockAchievement("More StatTraks")
	end
	if StatisticManager.getStatistic("statTrakFound") >= 10 then
		unlockAchievement("Even More StatTraks")
	end
	if StatisticManager.getStatistic("statTrakFound") >= 50 then
		unlockAchievement("StatTraker")
	end
	if StatisticManager.getStatistic("statTrakFound") >= 100 then
		unlockAchievement("StatTrak King")
	end
	if StatisticManager.getStatistic("moneyClicks") >= 75000 then
		unlockAchievement("Master Coin Tapper V")
	end
	if StatisticManager.getStatistic("moneyClicks") >= 100000 then
		unlockAchievement("Master Coin Tapper VI")
	end
	if StatisticManager.getStatistic("moneyClicks") >= 250000 then
		unlockAchievement("Elite Coin Tapper I")
	end
	if StatisticManager.getStatistic("moneyClicks") >= 500000 then
		unlockAchievement("Elite Coin Tapper II")
	end
	if StatisticManager.getStatistic("moneyClicks") >= 750000 then
		unlockAchievement("Elite Coin Tapper III")
	end
	if StatisticManager.getStatistic("moneyClicks") >= 1000000 then
		unlockAchievement("Elite Coin Tapper IV")
	end
	local signedContracts = StatisticManager.getStatistic("signedContracts")
	if 1 <= signedContracts then
		unlockAchievement("Gun Deal")
	end
	if 10 <= signedContracts then
		unlockAchievement("Gun Trader")
	end
	if 50 <= signedContracts then
		unlockAchievement("Give me better skins!")
	end
	if 100 <= StatisticManager.getStatistic("upgradesBought") then
		unlockAchievement("100 Upgrades")
	end
	local maximumCombo = StatisticManager.getStatistic("maximumCombo")
	if 1.5 <= maximumCombo then
		unlockAchievement("Combo!")
	end
	if 2.5 <= maximumCombo then
		unlockAchievement("C-combo!")
	end
	if 3.5 <= maximumCombo then
		unlockAchievement("C-c-combo!")
	end
	if 5 <= maximumCombo then
		unlockAchievement("Combo Master")
	end
	if 10 <= maximumCombo then
		unlockAchievement("Combo God")
	end
	if 10 <= #Game.equipment then
		unlockAchievement("10 in Equipment")
	end
	if #Game.equipment >= 25 then
		unlockAchievement("25 in Equipment")
	end
	if 50 <= #Game.equipment then
		unlockAchievement("50 in Equipment")
	end
	if 100 <= #Game.equipment then
		unlockAchievement("100 in Equipment")
	end
	if #Game.equipment >= 250 then
		unlockAchievement("250 in Equipment")
	end
	local soldSkins = StatisticManager.getStatistic("soldSkins")
	if 250 <= soldSkins then
		unlockAchievement("Master Seller II")
	end
	if 500 <= soldSkins then
		unlockAchievement("Master Seller III")
	end
	if 1000 <= soldSkins then
		unlockAchievement("The Trader")
	end
	local searchClicks = StatisticManager.getStatistic("searchClicks")
	if 25000 <= searchClicks then
		unlockAchievement("Master Case Tapper I")
	end
	if 50000 <= searchClicks then
		unlockAchievement("Master Case Tapper II")
	end
	if 75000 <= searchClicks then
		unlockAchievement("Master Case Tapper III")
	end
	if 100000 <= searchClicks then
		unlockAchievement("Master Case Tapper IV")
	end
	if 250000 <= searchClicks then
		unlockAchievement("Elite Case Tapper I")
	end
	if 500000 <= searchClicks then
		unlockAchievement("Elite Case Tapper II")
	end
	if 750000 <= searchClicks then
		unlockAchievement("Elite Case Tapper III")
	end
	if 1000000 <= searchClicks then
		unlockAchievement("Elite Case Tapper IV")
	end
	if StatisticManager.getStatistic("upgradesBought") >= 150 then
		unlockAchievement("150 Upgrades")
	end
	if Game.expRank == 40 then
		unlockAchievement("Global General")
	end
	if 1000 <= Game.money then
		Game.unlockAchievement("Rich Man")
	end
	AchievementManager.onRankReset()
	AchievementManager.onBetPlace()
	AchievementManager.onMissionComplete()
end
function AchievementManager.onCoinClick()
	local value = StatisticManager.getStatistic("moneyClicks")
	if value % 10 ~= 0 then
		return false
	end
	if value == 100 then
		Game.unlockAchievement("Coin Tapper I")
	elseif value == 250 then
		Game.unlockAchievement("Coin Tapper II")
	elseif value == 500 then
		Game.unlockAchievement("Coin Tapper III")
	elseif value == 1000 then
		Game.unlockAchievement("Coin Tapper IV")
	elseif value == 2000 then
		Game.unlockAchievement("Coin Tapper V")
	elseif value == 5000 then
		Game.unlockAchievement("Coin Tapper VI")
	elseif value == 10000 then
		Game.unlockAchievement("Coin Tapper VII")
		Game.unlockUpgrade("Golden Tap Power I")
	elseif value == 15000 then
		Game.unlockAchievement("Coin Tapper VIII")
	elseif value == 20000 then
		Game.unlockAchievement("Master Coin Tapper I")
	elseif value == 30000 then
		Game.unlockAchievement("Master Coin Tapper II")
	elseif value == 40000 then
		Game.unlockAchievement("Master Coin Tapper III")
	elseif value == 50000 then
		Game.unlockAchievement("Master Coin Tapper IV")
		Game.unlockUpgrade("Golden Tap Power II")
	elseif value == 75000 then
		Game.unlockAchievement("Master Coin Tapper V")
	elseif value == 100000 then
		Game.unlockAchievement("Master Coin Tapper VI")
		Game.unlockUpgrade("Golden Tap Power III")
	elseif value == 200000 then
		Game.unlockUpgrade("Golden Tap Power IV")
	elseif value == 250000 then
		Game.unlockAchievement("Elite Coin Tapper I")
	elseif value == 350000 then
		Game.unlockUpgrade("Golden Tap Power V")
	elseif value == 500000 then
		Game.unlockUpgrade("Golden Tap Power VI")
		Game.unlockAchievement("Elite Coin Tapper II")
	elseif value == 750000 then
		Game.unlockAchievement("Elite Coin Tapper III")
	elseif value == 1000000 then
		Game.unlockAchievement("Elite Coin Tapper IV")
	end
end
function AchievementManager.onCaseClick()
	local value = StatisticManager.getStatistic("searchClicks")
	if value % 10 ~= 0 then
		return false
	end
	if value == 100 then
		Game.unlockAchievement("Case Tapper I")
	elseif value == 250 then
		Game.unlockAchievement("Case Tapper II")
	elseif value == 500 then
		Game.unlockAchievement("Case Tapper III")
	elseif value == 1000 then
		Game.unlockAchievement("Case Tapper IV")
	elseif value == 2500 then
		Game.unlockAchievement("Case Tapper V")
	elseif value == 5000 then
		Game.unlockAchievement("Case Tapper VI")
	elseif value == 10000 then
		Game.unlockAchievement("Case Tapper VII")
	elseif value == 15000 then
		Game.unlockAchievement("Case Tapper VIII")
	elseif value == 25000 then
		Game.unlockAchievement("Master Case Tapper I")
	elseif value == 50000 then
		Game.unlockAchievement("Master Case Tapper II")
	elseif value == 75000 then
		Game.unlockAchievement("Master Case Tapper III")
	elseif value == 100000 then
		Game.unlockAchievement("Master Case Tapper IV")
	elseif value == 250000 then
		Game.unlockAchievement("Elite Case Tapper I")
	elseif value == 500000 then
		Game.unlockAchievement("Elite Case Tapper II")
	elseif value == 750000 then
		Game.unlockAchievement("Elite Case Tapper III")
	elseif value == 1000000 then
		Game.unlockAchievement("Elite Case Tapper IV")
	end
end
function AchievementManager.onCombo()
	local value = StatisticManager.getStatistic("maximumCombo")
	if value == 1.5 then
		Game.unlockAchievement("Combo!")
	elseif value == 2.5 then
		Game.unlockAchievement("C-combo!")
	elseif value == 3.5 then
		Game.unlockAchievement("C-c-combo!")
	elseif value == 5 then
		Game.unlockAchievement("Combo Master")
	elseif value == 10 then
		Game.unlockAchievement("Combo God")
	end
end
function AchievementManager.onMoneyGain()
	local value = StatisticManager.getStatistic("totalGainedMoney")
	if 1 <= value then
		Game.unlockAchievement("Fir$t Dollar")
	end
	if 2 <= value then
		Game.unlockAchievement("Second Dollar")
	end
	if 10 <= value then
		Game.unlockAchievement("Ten Dollars")
	end
	if 100 <= value then
		Game.unlockAchievement("Hundred Dollars")
	end
	if 500 <= value then
		Game.unlockAchievement("Five Hundred Dollars")
	end
	if 1000 <= value then
		Game.unlockAchievement("Thousand Dollars")
	end
	if 5000 <= value then
		Game.unlockAchievement("The Money is Mine!")
	end
	if 10000 <= value then
		Game.unlockAchievement("Rockefeller")
	end
end
function AchievementManager.onAchievementUnlock()
	local value = StatisticManager.getStatistic("unlockedAchievements")
	if value == 10 then
		unlockAchievement("Achievement Unlocker")
	elseif value == 30 then
		unlockAchievement("Achievement Mastah")
	elseif value == 60 then
		unlockAchievement("The Unlocker")
	elseif value == 100 then
		unlockAchievement("100 Achievements!")
	elseif value == 150 then
		unlockAchievement("150 Achievements!")
	elseif value == 200 then
		unlockAchievement("200 Achievements!")
	end
end
function AchievementManager.onUpgradeBuy()
	local value = StatisticManager.getStatistic("upgradesBought")
	if 5 <= value then
		unlockAchievement("5 Upgrades")
	end
	if 10 <= value then
		unlockAchievement("10 Upgrades")
	end
	if 25 <= value then
		unlockAchievement("25 Upgrades")
	end
	if 50 <= value then
		unlockAchievement("50 Upgrades")
	end
	if 70 <= value then
		unlockAchievement("70 Upgrades")
	end
	if 100 <= value then
		unlockAchievement("100 Upgrades")
	end
	if 125 <= value then
		unlockAchievement("125 Upgrades")
	end
	if 150 <= value then
		unlockAchievement("150 Upgrades")
	end
	if 175 <= value then
		unlockAchievement("175 Upgrades")
	end
	if 200 <= value then
		unlockAchievement("200 Upgrades")
	end
	if 225 <= value then
		unlockAchievement("225 Upgrades")
	end
	if 250 <= value then
		unlockAchievement("250 Upgrades")
	end
	if 275 <= value then
		unlockAchievement("275 Upgrades")
	end
	if 300 <= value then
		unlockAchievement("300 Upgrades")
	end
end
function AchievementManager.onCriticalTap()
	local value = StatisticManager.getStatistic("criticalTaps")
	if value == 10 then
		Game.unlockUpgrade("Critical Chance I")
		Game.unlockAchievement("Critical Tapper I")
	elseif value == 25 then
		Game.unlockAchievement("Critical Tapper II")
	elseif value == 50 then
		Game.unlockUpgrade("Critical Chance II")
		Game.unlockAchievement("Critical Tapper III")
	elseif value == 100 then
		Game.unlockUpgrade("Critical Chance III")
		Game.unlockAchievement("Critical Tapper IV")
	elseif value == 250 then
		Game.unlockUpgrade("Critical Chance IV")
		Game.unlockAchievement("Critical Tapper V")
	elseif value == 500 then
		Game.unlockUpgrade("Critical Chance V")
		Game.unlockAchievement("Critical Tapper VI")
	elseif value == 1000 then
		Game.unlockUpgrade("Critical Chance VI")
		Game.unlockAchievement("Critical Tapper VII")
	elseif value == 2500 then
		Game.unlockUpgrade("Critical Chance VII")
	elseif value == 5000 then
		Game.unlockUpgrade("Critical Chance VIII")
	end
	if 10000 <= value then
		Game.unlockUpgrade("Critical Chance IX")
	end
	if 15000 <= value then
		Game.unlockUpgrade("Critical Chance X")
	end
	if Game.criticalStreak == 2 then
		Game.unlockAchievement("Two Criticals")
	elseif Game.criticalStreak == 3 then
		Game.unlockAchievement("Three Criticals")
	end
end
function AchievementManager.onBetPlace()
	local placedBets = StatisticManager.getStatistic("placedBets")
	if 10 <= placedBets then
		unlockAchievement("Novice Gambler")
	end
	if 25 <= placedBets then
		unlockAchievement("Advanced Gambler")
	end
	if 100 <= placedBets then
		unlockAchievement("Experienced Gambler")
	end
	if 250 <= placedBets then
		unlockAchievement("Professional Gambler")
	end
end
function AchievementManager.onRankReset()
	local resets = Game.others.expResets
	if 1 <= resets then
		unlockAchievement("Rank Reset")
	end
	if 2 <= resets then
		unlockAchievement("Second Reset")
	end
	if 5 <= resets then
		unlockAchievement("Fifth Reset")
	end
	if 10 <= resets then
		unlockAchievement("Tenth Reset")
	end
end
function AchievementManager.onKnifeFind()
	local value = StatisticManager.getStatistic("knivesFound")
	if value == 1 then
		unlockAchievement("Yay knife!")
	elseif value == 2 then
		unlockAchievement("Second knife!")
	elseif value == 10 then
		unlockAchievement("Knife Master")
	end
end
function AchievementManager.onTradeComplete()
	local value = StatisticManager.getStatistic("tradesCompleted")
	if value == 1 then
		unlockAchievement("Skin Trader I")
	elseif value == 10 then
		unlockAchievement("Skin Trader II")
	elseif value == 25 then
		unlockAchievement("Skin Trader III")
	elseif value == 50 then
		unlockAchievement("Skin Trader IV")
	elseif value == 100 then
		unlockAchievement("Skin Trader V")
	elseif value == 250 then
		unlockAchievement("Skin Trader VI")
	end
end
function AchievementManager.onAdWatch()
	local value = StatisticManager.getStatistic("watchedAds")
	if value == 1 then
		unlockAchievement("First AD")
	elseif value == 10 then
		unlockAchievement("Ten ADs")
	elseif value == 50 then
		unlockAchievement("AD Watcher")
	elseif value == 250 then
		unlockAchievement("AD Master")
	end
end
function AchievementManager.onRouletteWin()
	local value = StatisticManager.getStatistic("roulettesWon")
	if value == 10 then
		unlockAchievement("Roulette Winner I")
	elseif value == 50 then
		unlockAchievement("Roulette Winner II")
	elseif value == 250 then
		unlockAchievement("Roulette Winner III")
	elseif value == 1000 then
		unlockAchievement("Roulette Winner IV")
	elseif value == 2500 then
		unlockAchievement("Roulette Winner V")
	end
end
function AchievementManager.onRouletteLose()
	local value = StatisticManager.getStatistic("roulettesLost")
	if value == 10 then
		unlockAchievement("Roulette Loser I")
	elseif value == 50 then
		unlockAchievement("Roulette Loser II")
	elseif value == 250 then
		unlockAchievement("Roulette Loser III")
	elseif value == 1000 then
		unlockAchievement("Roulette Loser IV")
	elseif value == 2500 then
		unlockAchievement("Roulette Loser V")
	end
end
function AchievementManager.onJackpotEnd()
	local value = StatisticManager.getStatistic("jackpotsPlayed")
	if value == 1 then
		Game.unlockAchievement("First Jackpot")
	elseif value == 25 then
		Game.unlockAchievement("Jackpot Beginner")
	elseif value == 100 then
		Game.unlockAchievement("Jackpot Player")
	elseif value == 500 then
		Game.unlockAchievement("Jackpot Master")
	elseif value == 1000 then
		Game.unlockAchievement("Jackpot King")
	end
end
function AchievementManager.onJackpotWin(winChance)
	if winChance < 40 then
		Game.unlockAchievement("Lucky Hit I")
	end
	if winChance < 20 then
		Game.unlockAchievement("Lucky Hit II")
	end
	if winChance < 10 then
		Game.unlockAchievement("Lucky Hit III")
	end
	if winChance <= 5 then
		Game.unlockAchievement("Lucky Hit IV")
	end
	if winChance <= 2 then
		Game.unlockAchievement("Lucky Hit V")
	end
	local value = StatisticManager.getStatistic("jackpotsWon")
	if value == 1 then
		Game.unlockAchievement("Jackpot Winner I")
	elseif value == 5 then
		Game.unlockAchievement("Jackpot Winner II")
	elseif value == 10 then
		Game.unlockAchievement("Jackpot Winner III")
	elseif value == 25 then
		Game.unlockAchievement("Jackpot Winner IV")
	elseif value == 50 then
		Game.unlockAchievement("Jackpot Winner V")
	elseif value == 100 then
		Game.unlockAchievement("Jackpot Winner VI")
	end
end
function AchievementManager.onJackpotLose(winChance)
	if 960 < winChance then
		Game.unlockAchievement("Bad Luck I")
	end
	if 980 < winChance then
		Game.unlockAchievement("Bad Luck II")
	end
	if 990 < winChance then
		Game.unlockAchievement("Bad Luck III")
	end
	if 995 <= winChance then
		Game.unlockAchievement("Bad Luck IV")
	end
	if 997 <= winChance then
		Game.unlockAchievement("Bad Luck V")
	end
	local value = StatisticManager.getStatistic("jackpotsLost")
	if value == 1 then
		Game.unlockAchievement("Jackpot Loser I")
	elseif value == 10 then
		Game.unlockAchievement("Jackpot Loser II")
	elseif value == 50 then
		Game.unlockAchievement("Jackpot Loser III")
	elseif value == 100 then
		Game.unlockAchievement("Jackpot Loser IV")
	elseif value == 250 then
		Game.unlockAchievement("Jackpot Loser V")
	elseif value == 500 then
		Game.unlockAchievement("Jackpot Loser VI")
	end
end
function AchievementManager.onGlovesFound()
	local glovesFound = StatisticManager.getStatistic("glovesFound")
	if glovesFound == 1 then
		Game.unlockAchievement("Yay! Glove!!")
	elseif glovesFound == 10 then
		Game.unlockAchievement("10 Gloves!")
	elseif glovesFound == 100 then
		Game.unlockAchievement("HUNDRED GLOVES")
	elseif glovesFound == 1000 then
		Game.unlockAchievement("Glove Master")
	end
end
function AchievementManager.onMissionComplete()
	local value = StatisticManager.getStatistic("completedMissions")
	if 100 <= value then
		Game.unlockAchievement("Mission Master")
	end
	if 75 <= value then
		Game.unlockAchievement("75 Missions")
	end
	if 50 <= value then
		Game.unlockAchievement("Mission Maker")
	end
	if 25 <= value then
		Game.unlockAchievement("25 Missions")
	end
	if 10 <= value then
		Game.unlockAchievement("10th mission!")
	end
	if 5 <= value then
		Game.unlockAchievement("Five missions!")
	end
	if 2 <= value then
		Game.unlockAchievement("Next Mission Completed")
	end
	if 1 <= value then
		Game.unlockAchievement("Mission Completed")
	end
end
function AchievementManager.onMoneyAdd(moneyBefore)
	if moneyBefore < 5 and 5 <= Game.money then
		Game.unlockAchievement("Five in the Wallet")
	elseif moneyBefore < 10 and Game.money >= 10 then
		Game.unlockAchievement("Ten in the Wallet")
	elseif moneyBefore < 100 and Game.money >= 100 then
		Game.unlockAchievement("Hundred in the Wallet")
	elseif moneyBefore < 1000 and Game.money >= 1000 then
		Game.unlockAchievement("Rich Man")
	end
end
function AchievementManager.onCaseOpen()
	local value = StatisticManager.getStatistic("openedBoxes")
	if value == 1 then
		Game.unlockAchievement("First Case")
	elseif value == 10 then
		Game.unlockAchievement("Case Opener")
	elseif value == 50 then
		Game.unlockAchievement("Case Addict")
	elseif value == 100 then
		Game.unlockAchievement("Case Mastah")
	end
end
function AchievementManager.onCapsuleOpen()
	local value = StatisticManager.getStatistic("openedCapsules")
	if value == 1 then
		Game.unlockAchievement("First Capsule")
	elseif value == 10 then
		Game.unlockAchievement("Ten Capsules")
	elseif value == 99 then
		Game.unlockAchievement("99 Capsules")
	end
end
function AchievementManager.onSouvenirOpen()
	if StatisticManager.getStatistic("openedSouvenirs") == 1 then
		Game.unlockAchievement("Souvenir Opened!")
	end
end
function AchievementManager.onSouvenirBought()
	local value = StatisticManager.getStatistic("boughtSouvenirs")
	if value == 1 then
		Game.unlockAchievement("First Souvenir!")
	elseif value == 10 then
		Game.unlockAchievement("10 Souvenirs")
	elseif value == 50 then
		Game.unlockAchievement("Souvenir Mastah")
	elseif value == 100 then
		Game.unlockAchievement("Souvenir King")
	elseif value == 250 then
		Game.unlockAchievement("Souvenir God")
	end
end
function AchievementManager.onItemAdd()
	if #Game.equipment == 10 then
		Game.unlockAchievement("10 in Equipment")
	elseif #Game.equipment == 25 then
		Game.unlockAchievement("25 in Equipment")
	elseif #Game.equipment == 50 then
		Game.unlockAchievement("50 in Equipment")
	elseif #Game.equipment == 100 then
		Game.unlockAchievement("100 in Equipment")
	elseif #Game.equipment == 250 then
		Game.unlockAchievement("250 in Equipment")
	end
end
function AchievementManager.onItemSell()
	local value = StatisticManager.getStatistic("soldSkins")
	if value == 10 then
		Game.unlockAchievement("Skin Seller")
	elseif value == 100 then
		Game.unlockAchievement("Master Seller")
	elseif value == 250 then
		Game.unlockAchievement("Master Seller II")
	elseif value == 500 then
		Game.unlockAchievement("Master Seller III")
	elseif value == 1000 then
		Game.unlockAchievement("The Trader")
	end
end
function AchievementManager.onKeyBuy()
	local value = StatisticManager.getStatistic("keysBought")
	if value == 1 then
		Game.unlockAchievement("Magic Key")
	elseif value == 10 then
		Game.unlockAchievement("Ten Keys")
	elseif value == 100 then
		Game.unlockAchievement("Keyholder")
	end
end
function AchievementManager.onStatTrakFound()
	local value = StatisticManager.getStatistic("statTrakFound")
	if value == 1 then
		Game.unlockAchievement("Yeah! StatTrak!")
	elseif value == 5 then
		Game.unlockAchievement("More StatTraks")
	elseif value == 10 then
		Game.unlockAchievement("Even More StatTraks")
	elseif value == 50 then
		Game.unlockAchievement("StatTraker")
	elseif value == 100 then
		Game.unlockAchievement("StatTrak King")
	end
end
function AchievementManager.onCovertItemFound()
	local value = StatisticManager.getStatistic("covertFound")
	if value == 1 then
		Game.unlockAchievement("The Red One")
	elseif value == 10 then
		Game.unlockAchievement("Covert Collector")
	end
end
function AchievementManager.onClassifiedItemFound()
	local value = StatisticManager.getStatistic("classifiedFound")
	if value == 1 then
		Game.unlockAchievement("The Pink One")
	elseif value == 10 then
		Game.unlockAchievement("Classified Collector")
	end
end
function AchievementManager.onBlueInARow()
	local value = StatisticManager.getStatistic("bluesInARow")
	if value == 8 then
		Game.unlockAchievement("Blues in a Row")
	end
end
function AchievementManager.onPurpleInARow()
	local value = StatisticManager.getStatistic("purplesInARow")
	if value == 5 then
		Game.unlockAchievement("Purples in a Row")
	end
end
function AchievementManager.onPinkInARow()
	local value = StatisticManager.getStatistic("pinksInARow")
	if value == 2 then
		Game.unlockAchievement("Pinks in a Row")
	end
end
function AchievementManager.onRedInARow()
	local value = StatisticManager.getStatistic("redsInARow")
	if value == 2 then
		Game.unlockAchievement("Ultra Luck")
	end
end
function AchievementManager.onContractSign()
	local value = StatisticManager.getStatistic("signedContracts")
	if value == 1 then
		Game.unlockAchievement("Gun Deal")
	elseif value == 10 then
		Game.unlockAchievement("Gun Trader")
	elseif value == 50 then
		Game.unlockAchievement("Give me better skins!")
	end
end
function AchievementManager.onExperienceAdd()
	local value = StatisticManager.getStatistic("totalExperience")
	Game.unlockAchievement("First Experience")
	if 10000 <= value then
		Game.unlockAchievement("Moar Exp!")
	end
	if 2500 <= value then
		Game.unlockAchievement("Give me some exp!")
	end
end
function AchievementManager.onCollectionCompleted()
	local collectionsCompleted = StatisticManager.getStatistic("casesCompleted") + StatisticManager.getStatistic("souvenirsCompleted") + StatisticManager.getStatistic("capsulesCompleted")
	if 1 <= collectionsCompleted then
		Game.unlockAchievement("Collection Completed")
	end
	if 5 <= collectionsCompleted then
		Game.unlockAchievement("Completion Master")
	end
	if 10 <= collectionsCompleted then
		Game.unlockAchievement("The Collector")
	end
end
function AchievementManager.onDailyReward()
	local value = StatisticManager.getStatistic("dailyRewards")
	if value == 1 then
		Game.unlockAchievement("Free Item")
	elseif value == 10 then
		Game.unlockAchievement("Five Free Items")
	elseif 30 <= value then
		Game.unlockAchievement("Month of Free Items")
	end
	if 50 <= value then
		Game.unlockAchievement("More Free Items")
	end
end
function AchievementManager.onLogoTap()
	if StatisticManager.getStatistic("logoTaps") == 100 then
		Game.unlockAchievement("Y U DO DIS?!")
	end
end
function AchievementManager.onTapsPerSecondRecord()
	local tapsPerSecond = StatisticManager.getStatistic("maximumTapsPerSecond")
	if tapsPerSecond == 6 then
		Game.unlockAchievement("6 Taps Per Second")
	elseif tapsPerSecond == 7 then
		Game.unlockAchievement("7 Taps Per Second")
	elseif tapsPerSecond == 8 then
		Game.unlockAchievement("8 Taps Per Second")
	elseif tapsPerSecond == 9 then
		Game.unlockAchievement("9 Taps Per Second")
	elseif tapsPerSecond == 10 then
		Game.unlockAchievement("10 Taps Per Second")
	end
end
return AchievementManager
