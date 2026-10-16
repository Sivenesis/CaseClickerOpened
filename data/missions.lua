return {
	{
		image = {
			path = "upgrades/hand.png",
			width = 155,
			height = 185
		},
		skippable = true,
		secondText = "Progress:",
		getEndValue = function()
			if StatisticManager.getStatistic("totalClicks") <= 200 then
				return 100
			elseif StatisticManager.getStatistic("totalClicks") <= 500 then
				return 250
			elseif StatisticManager.getStatistic("totalClicks") <= 1000 then
				return 500
			elseif StatisticManager.getStatistic("totalClicks") <= 3000 then
				return 1000
			elseif StatisticManager.getStatistic("totalClicks") <= 8000 then
				return 2500
			else
				return 3000
			end
		end,
		getValue = function()
			return StatisticManager.getStatistic("totalClicks")
		end,
		getDescription = function(value)
			return "Tap " .. commaValue(value) .. " times!"
		end
	},
	{
		image = {
			path = "missions/case.png",
			width = 250,
			height = 250
		},
		secondText = "Progress:",
		getEndValue = function()
			local value = StatisticManager.getStatistic("openedBoxes")
			if value <= 10 then
				return 5
			elseif value <= 25 then
				return 10
			elseif value <= 50 then
				return 15
			elseif value <= 75 then
				return 20
			elseif value <= 100 then
				return 40
			elseif value <= 250 then
				return 50
			elseif value <= 500 then
				return 60
			elseif value <= 1500 then
				return 75
			else
				return 100
			end
		end,
		getValue = function()
			return StatisticManager.getStatistic("openedBoxes")
		end,
		getDescription = function(value)
			return "Open " .. commaValue(value) .. " cases!"
		end
	},
	{
		image = {
			path = "coin.png",
			width = 250,
			height = 250
		},
		secondText = "Progress:",
		getEndValue = function()
			local total = StatisticManager.getStatistic("totalGainedMoney")
			if total <= 10 then
				return 3
			elseif total <= 40 then
				return 10
			elseif total <= 80 then
				return 12
			elseif total <= 140 then
				return 20
			elseif total <= 250 then
				return 30
			elseif total <= 1000 then
				return 50
			elseif total <= 2500 then
				return 100
			elseif total <= 5000 then
				return 200
			else
				return 350
			end
		end,
		getValue = function()
			return StatisticManager.getStatistic("totalGainedMoney")
		end,
		getDescription = function(value)
			return "Earn $" .. formatPrice(value)
		end,
		formatValueAsPrice = true
	},
	{
		image = {
			path = "souvenirs/cache.png",
			width = 256,
			height = 192
		},
		secondText = "Progress:",
		getEndValue = function()
			local total = StatisticManager.getStatistic("openedSouvenirs")
			if total <= 10 then
				return 3
			elseif total <= 40 then
				return 8
			elseif total <= 80 then
				return 12
			elseif total <= 140 then
				return 20
			elseif total <= 250 then
				return 25
			else
				return 30
			end
		end,
		getValue = function()
			return StatisticManager.getStatistic("openedSouvenirs")
		end,
		getDescription = function(value)
			return "Open " .. commaValue(value) .. " souvenirs"
		end
	},
	{
		image = {
			path = "skins/153.png",
			width = 256,
			height = 192
		},
		secondText = "Progress:",
		getEndValue = function()
			local total = StatisticManager.getStatistic("classifiedFound")
			if total <= 30 then
				return 1
			else
				return 2
			end
		end,
		getValue = function()
			return StatisticManager.getStatistic("classifiedFound")
		end,
		getDescription = function(value)
			return "Find " .. commaValue(value) .. " pink rarity skins"
		end,
		canStart = function()
			return StatisticManager.getStatistic("classifiedFound") >= 25
		end
	},
	{
		image = {
			path = "skins/849.png",
			width = 256,
			height = 192
		},
		secondText = "Progress:",
		getEndValue = function()
			local total = StatisticManager.getStatistic("covertFound")
			if total <= 100 then
				return 1
			else
				return 2
			end
		end,
		getValue = function()
			return StatisticManager.getStatistic("covertFound")
		end,
		getDescription = function(value)
			return "Find " .. commaValue(value) .. " red rarity skins"
		end,
		canStart = function()
			return StatisticManager.getStatistic("covertFound") >= 15
		end
	},
	{
		image = {
			path = "capsules/slid3.png",
			width = 256,
			height = 192
		},
		secondText = "Progress:",
		getEndValue = function()
			if StatisticManager.getStatistic("openedCapsules") <= 10 then
				return 4
			elseif StatisticManager.getStatistic("openedCapsules") <= 40 then
				return 8
			elseif StatisticManager.getStatistic("openedCapsules") <= 80 then
				return 15
			elseif StatisticManager.getStatistic("openedCapsules") <= 120 then
				return 20
			elseif StatisticManager.getStatistic("openedCapsules") <= 160 then
				return 40
			else
				return 50
			end
		end,
		getValue = function()
			return StatisticManager.getStatistic("openedCapsules")
		end,
		getDescription = function(value)
			return "Open " .. commaValue(value) .. " sticker capsules"
		end
	},
	{
		image = {
			path = "upgrades/contract.png",
			width = 256,
			height = 192
		},
		secondText = "Progress:",
		getEndValue = function()
			if StatisticManager.getStatistic("signedContracts") <= 10 then
				return 2
			elseif StatisticManager.getStatistic("signedContracts") <= 20 then
				return 4
			elseif StatisticManager.getStatistic("signedContracts") <= 40 then
				return 6
			elseif StatisticManager.getStatistic("signedContracts") <= 100 then
				return 2
			else
				return 10
			end
		end,
		getValue = function()
			return StatisticManager.getStatistic("signedContracts")
		end,
		getDescription = function(value)
			return "Sign " .. commaValue(value) .. " contracts"
		end,
		canStart = function()
			return StatisticManager.getStatistic("signedContracts") >= 3
		end
	},
	{
		image = {
			path = "missions/trophy.png",
			width = 200,
			height = 200
		},
		secondText = "Progress:",
		getEndValue = function()
			if StatisticManager.getStatistic("unlockedAchievements") <= 50 then
				return 3
			elseif StatisticManager.getStatistic("unlockedAchievements") <= 100 then
				return 2
			else
				return 1
			end
		end,
		getValue = function()
			return StatisticManager.getStatistic("unlockedAchievements")
		end,
		getDescription = function(value)
			local s = ""
			if 1 < value then
				s = "s"
			end
			return "Unlock " .. commaValue(value) .. " achievement" .. s
		end,
		canStart = function()
			return StatisticManager.getStatistic("unlockedAchievements") < tableLength(Game.achievements) * 0.75
		end
	},
	{
		image = {
			path = "upgrades/jackpot.png",
			width = 240,
			height = 240
		},
		secondText = "Progress:",
		getEndValue = function()
			if StatisticManager.getStatistic("jackpotsWon") <= 10 then
				return 1
			elseif StatisticManager.getStatistic("jackpotsWon") <= 25 then
				return 2
			elseif StatisticManager.getStatistic("jackpotsWon") <= 50 then
				return 3
			elseif StatisticManager.getStatistic("jackpotsWon") <= 100 then
				return 4
			elseif StatisticManager.getStatistic("jackpotsWon") <= 250 then
				return 6
			elseif StatisticManager.getStatistic("jackpotsWon") <= 500 then
				return 8
			else
				return 10
			end
		end,
		getValue = function()
			return StatisticManager.getStatistic("jackpotsWon")
		end,
		getDescription = function(value)
			local s = ""
			if 1 < value then
				s = "s"
			end
			return "Win " .. commaValue(value) .. " jackpot" .. s
		end,
		canStart = function()
			return StatisticManager.getStatistic("jackpotsLost") > 3
		end
	},
	{
		image = {
			path = "upgrades/glass.png",
			width = 240,
			height = 240
		},
		secondText = "Progress:",
		getEndValue = function()
			if StatisticManager.getStatistic("casesFound") <= 25 then
				return 5
			elseif StatisticManager.getStatistic("casesFound") <= 75 then
				return 8
			elseif StatisticManager.getStatistic("casesFound") <= 150 then
				return 14
			elseif StatisticManager.getStatistic("casesFound") <= 300 then
				return 20
			else
				return 25
			end
		end,
		getValue = function()
			return StatisticManager.getStatistic("casesFound")
		end,
		getDescription = function(value)
			return "Find " .. commaValue(value) .. " cases"
		end
	},
	{
		image = {
			path = "collections/cobblestone.png",
			width = 256,
			height = 192
		},
		secondText = "Progress:",
		getEndValue = function()
			local total = StatisticManager.getStatistic("openedCollections")
			if total <= 10 then
				return 3
			elseif total <= 40 then
				return 8
			elseif total <= 80 then
				return 12
			elseif total <= 140 then
				return 20
			elseif total <= 250 then
				return 25
			else
				return 30
			end
		end,
		getValue = function()
			return StatisticManager.getStatistic("openedCollections")
		end,
		getDescription = function(value)
			return "Open " .. commaValue(value) .. " collections"
		end
	},
	{
		getImage = function(subId)
			return {
				path = "cases/" .. Game.cases[subId].image,
				width = 241,
				height = 176
			}
		end,
		secondText = "Progress:",
		getSubId = function()
			local cases = ContainerManager.getUnlockedCasesIds()
			return choose(cases)
		end,
		getEndValue = function(subId)
			local value = Game.cases[subId].opened
			if value <= 10 then
				return 4
			elseif value <= 25 then
				return 8
			elseif value <= 50 then
				return 10
			elseif value <= 75 then
				return 15
			elseif value <= 100 then
				return 30
			elseif value <= 250 then
				return 40
			else
				return 50
			end
		end,
		getValue = function(subId)
			return Game.cases[subId].opened
		end,
		getDescription = function(value, subId)
			return "Open " .. commaValue(value) .. "x " .. Game.cases[subId].name
		end
	},
	{
		getImage = function(subId)
			return {
				path = "capsules/" .. Game.capsules[subId].image,
				width = 241,
				height = 176
			}
		end,
		secondText = "Progress:",
		getSubId = function()
			local capsules = ContainerManager.getUnlockedCapsuleIds()
			return choose(capsules)
		end,
		getEndValue = function(subId)
			local value = Game.capsules[subId].opened
			if value <= 10 then
				return 4
			elseif value <= 25 then
				return 8
			elseif value <= 50 then
				return 10
			elseif value <= 75 then
				return 15
			elseif value <= 100 then
				return 30
			elseif value <= 250 then
				return 40
			else
				return 50
			end
		end,
		getValue = function(subId)
			return Game.capsules[subId].opened
		end,
		getDescription = function(value, subId)
			return "Open " .. commaValue(value) .. "x " .. Game.capsules[subId].name
		end
	},
	{
		getImage = function(subId)
			return {
				path = "collections/" .. Game.collections[subId].image,
				width = 241,
				height = 176
			}
		end,
		secondText = "Progress:",
		getSubId = function()
			return choose(ContainerManager.getTopOpenedCollections()).id
		end,
		getEndValue = function(subId)
			local value = Game.collections[subId].opened
			if value <= 10 then
				return 4
			elseif value <= 25 then
				return 8
			elseif value <= 50 then
				return 10
			elseif value <= 75 then
				return 15
			elseif value <= 100 then
				return 30
			elseif value <= 250 then
				return 40
			else
				return 50
			end
		end,
		getValue = function(subId)
			return Game.collections[subId].opened
		end,
		getDescription = function(value, subId)
			return "Open " .. commaValue(value) .. "x " .. Game.collections[subId].name
		end,
		canStart = function()
			return #ContainerManager.getTopOpenedCollections() > 0
		end
	},
	{
		getImage = function(subId)
			local rankId = Game.rank + 1
			if not Game.ranks[Game.rank + 1] then
				rankId = Game.rank
			end
			return {
				path = "ranks/" .. rankId .. ".png",
				width = 185,
				height = 74,
				scale = 0.5
			}
		end,
		noProgressBar = true,
		secondText = "Mission:",
		getEndValue = function()
			return 1
		end,
		getValue = function()
			return Game.rank
		end,
		getDescription = function(value)
			local rankName = "Global Elite"
			if Game.ranks[Game.rank + 1] then
				rankName = Game.ranks[Game.rank + 1].name
			end
			return "Advance to the " .. rankName .. " rank"
		end,
		canStart = function()
			return Game.rank < 18
		end
	},
	{
		image = {
			path = "casino/crash.png",
			width = 250,
			height = 250
		},
		secondText = "Progress:",
		getEndValue = function()
			local total = StatisticManager.getStatistic("crashWon") + StatisticManager.getStatistic("crashLost")
			if total <= 10 then
				return 5
			elseif total <= 25 then
				return 10
			elseif total <= 50 then
				return 20
			elseif total <= 100 then
				return 30
			elseif total <= 250 then
				return 40
			elseif total <= 500 then
				return 50
			elseif total <= 1000 then
				return 60
			else
				return 75
			end
		end,
		getValue = function()
			return StatisticManager.getStatistic("crashWon") + StatisticManager.getStatistic("crashLost")
		end,
		getDescription = function(value)
			return "Play " .. commaValue(value) .. " crash games"
		end,
		canStart = function()
			return StatisticManager.getStatistic("crashWon") > 0
		end
	},
	{
		image = {
			path = "casino/bomb.png",
			width = 250,
			height = 250
		},
		secondText = "Progress:",
		getEndValue = function()
			local total = StatisticManager.getStatistic("minesweepersWon") + StatisticManager.getStatistic("minesweepersLost")
			if total <= 10 then
				return 4
			elseif total <= 25 then
				return 8
			elseif total <= 50 then
				return 10
			elseif total <= 100 then
				return 15
			elseif total <= 250 then
				return 25
			elseif total <= 500 then
				return 30
			else
				return 40
			end
		end,
		getValue = function()
			return StatisticManager.getStatistic("minesweepersWon") + StatisticManager.getStatistic("minesweepersLost")
		end,
		getDescription = function(value)
			return "Play " .. commaValue(value) .. " minesweeper games"
		end,
		canStart = function()
			return StatisticManager.getStatistic("minesweepersWon") > 0
		end
	},
	{
		image = {
			path = "games/scratch_gold.png",
			width = 250,
			height = 250
		},
		secondText = "Progress:",
		getEndValue = function()
			local total = StatisticManager.getStatistic("scratchedScratches")
			if total <= 50 then
				return 5
			elseif total <= 100 then
				return 10
			elseif total <= 200 then
				return 15
			elseif total <= 500 then
				return 25
			elseif total <= 700 then
				return 40
			elseif total <= 1000 then
				return 50
			else
				return 60
			end
		end,
		getValue = function()
			return StatisticManager.getStatistic("scratchedScratches")
		end,
		getDescription = function(value)
			return "Scratch " .. commaValue(value) .. " scratches!"
		end,
		canStart = function()
			return StatisticManager.getStatistic("scratchedScratches") > 20
		end
	},
	{
		image = {
			path = "upgrades/bets.png",
			width = 250,
			height = 250
		},
		secondText = "Progress:",
		getEndValue = function()
			local total = StatisticManager.getStatistic("placedBets")
			if total <= 10 then
				return 3
			elseif total <= 25 then
				return 4
			elseif total <= 50 then
				return 6
			elseif total <= 100 then
				return 8
			elseif total <= 500 then
				return 10
			else
				return 15
			end
		end,
		getValue = function()
			return StatisticManager.getStatistic("placedBets")
		end,
		getDescription = function(value)
			return "Bet " .. commaValue(value) .. " matches!"
		end,
		canStart = function()
			return StatisticManager.getStatistic("placedBets") > 5
		end
	},
	{
		image = {
			path = "gloves/22.png",
			width = 256,
			height = 192
		},
		secondText = "Progress:",
		getEndValue = function()
			local total = StatisticManager.getStatistic("glovesFound")
			if total <= 10 then
				return 1
			elseif total <= 30 then
				return 2
			elseif total <= 50 then
				return 3
			elseif total <= 100 then
				return 4
			else
				return 5
			end
		end,
		getValue = function()
			return StatisticManager.getStatistic("glovesFound")
		end,
		getDescription = function(value)
			local s = ""
			if 1 < value then
				s = "s"
			end
			return "Find " .. commaValue(value) .. " pair" .. s .. " of gloves!"
		end,
		canStart = function()
			return StatisticManager.getStatistic("glovesFound") > 5
		end
	},
	{
		image = {
			path = "skins/233.png",
			width = 360,
			height = 300
		},
		secondText = "Progress:",
		getEndValue = function()
			local total = StatisticManager.getStatistic("knivesFound")
			if total <= 10 then
				return 1
			elseif total <= 30 then
				return 2
			elseif total <= 50 then
				return 3
			elseif total <= 100 then
				return 4
			else
				return 5
			end
		end,
		getValue = function()
			return StatisticManager.getStatistic("knivesFound")
		end,
		getDescription = function(value)
			local nameStr = "knife"
			if 1 < value then
				nameStr = "knives"
			end
			return "Find " .. commaValue(value) .. " " .. nameStr
		end,
		canStart = function()
			return StatisticManager.getStatistic("knivesFound") > 5
		end
	},
	{
		image = {
			path = "upgrades/roulette.png",
			width = 250,
			height = 250
		},
		secondText = "Progress:",
		getEndValue = function()
			local total = StatisticManager.getStatistic("roulettesWon")
			if total <= 10 then
				return 4
			elseif total <= 25 then
				return 8
			elseif total <= 50 then
				return 10
			elseif total <= 100 then
				return 15
			elseif total <= 250 then
				return 25
			elseif total <= 500 then
				return 30
			elseif total <= 2500 then
				return 40
			else
				return 50
			end
		end,
		getValue = function()
			return StatisticManager.getStatistic("roulettesWon")
		end,
		getDescription = function(value)
			return "Win " .. commaValue(value) .. " roulette games"
		end,
		canStart = function()
			return StatisticManager.getStatistic("roulettesWon") > 5
		end
	},
	{
		image = {
			path = "casino/tt.png",
			width = 250,
			height = 250
		},
		secondText = "Progress:",
		getEndValue = function()
			local total = StatisticManager.getStatistic("coinflipsWon")
			if total <= 10 then
				return 5
			elseif total <= 25 then
				return 10
			elseif total <= 50 then
				return 15
			elseif total <= 100 then
				return 20
			elseif total <= 250 then
				return 30
			elseif total <= 500 then
				return 40
			elseif total <= 2500 then
				return 50
			else
				return 75
			end
		end,
		getValue = function()
			return StatisticManager.getStatistic("coinflipsWon")
		end,
		getDescription = function(value)
			return "Win " .. commaValue(value) .. " coinflips!"
		end,
		canStart = function()
			return StatisticManager.getStatistic("coinflipsWon") > 5
		end
	},
	{
		image = {
			path = "missions/daily.png",
			width = 231,
			height = 231
		},
		secondText = "Progress:",
		getEndValue = function()
			local total = StatisticManager.getStatistic("dailyRewards")
			if total <= 10 then
				return 1
			elseif total <= 30 then
				return 2
			elseif total <= 50 then
				return 3
			elseif total <= 80 then
				return 4
			elseif total <= 200 then
				return 5
			elseif total <= 500 then
				return 7
			else
				return 10
			end
		end,
		getValue = function()
			return StatisticManager.getStatistic("dailyRewards")
		end,
		getDescription = function(value)
			local s = ""
			if 1 < value then
				s = "s"
			end
			return "Receive " .. commaValue(value) .. " daily reward" .. s
		end,
		canStart = function()
			return StatisticManager.getStatistic("dailyRewards") >= 10
		end
	},
	{
		image = {
			path = "missions/advert.png",
			width = 192,
			height = 192
		},
		secondText = "Progress:",
		getEndValue = function()
			local total = StatisticManager.getStatistic("watchedAds")
			if total <= 60 then
				return 4
			elseif total <= 100 then
				return 5
			elseif total <= 250 then
				return 8
			elseif total <= 500 then
				return 10
			elseif total <= 750 then
				return 15
			else
				return 20
			end
		end,
		getValue = function()
			return StatisticManager.getStatistic("watchedAds")
		end,
		getDescription = function(value)
			local s = ""
			if 1 < value then
				s = "s"
			end
			return "Watch " .. commaValue(value) .. " adverts!"
		end,
		canStart = function()
			return StatisticManager.getStatistic("watchedAds") >= 40
		end
	}
}
