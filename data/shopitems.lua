Game.shopItems = {
	Bonuses = {
		{
			name = Lang.shopItems["Free Random Case"].name,
			description = Lang.shopItems["Free Random Case"].description,
			image = {
				path = "cases/unknown.png",
				width = 180.75,
				height = 132
			},
			buttonText = Lang.shop.watchAd,
			canBeBought = function()
				if os.time() - Game.others.lastCaseAdWatch < 600 then
					return false
				end
				return ADS.isAvailable(true)
			end,
			onBuy = function()
				if not ADS.isAvailable() then
					return false
				end
				ADS.showAd(function()
					Game.showCaseDraw(true)
					GUI.showInfoBox(Lang.shop.adWatched .. ".", Lang.shopItems["Free Random Case"].awardMessage .. "!", InfoBoxType.chest)
				end)
				Game.others.lastCaseAdWatch = os.time()
			end,
			getButtonText = function()
				if not ADS.isAvailable(true) then
					return Lang.shop.noAds
				end
				if os.time() - Game.others.lastCaseAdWatch < 600 then
					local minutesLeft = math.ceil((600 - (os.time() - Game.others.lastCaseAdWatch)) / 60)
					return minutesLeft .. " " .. Lang.shop.minutes
				end
				return Lang.shop.watchAd
			end
		},
		{
			name = Lang.shopItems["Free Money"].name,
			getDescription = function()
				return Lang.shopItems["Free Money"].description:gsub("{1}", 5 + math.floor((Game.rank - 1) * 1.5))
			end,
			image = {
				path = "coin.png",
				width = 147.95000000000002,
				height = 147.4
			},
			buttonText = Lang.shop.watchAd,
			canBeBought = function()
				if os.time() - Game.others.lastMoneyAdWatch < 600 then
					return false
				end
				return ADS.isAvailable(true)
			end,
			onBuy = function()
				ADS.showAd()
				timer.performWithDelay(1500, function()
					local money = 5 + math.floor((Game.rank - 1) * 1.5)
					Game.addMoney(money, "Other", "AD Watch")
					GUI.showInfoBox(Lang.shop.adWatched .. ".", Lang.shopItems["Free Money"].awardMessage:gsub("{1}", formatPrice(money)) .. "!", InfoBoxType.chest)
				end)
				Game.others.lastMoneyAdWatch = os.time()
				Game.others.lastNormalAdWatch = os.time() + 3600
			end,
			getButtonText = function()
				if not ADS.isAvailable(true) then
					return Lang.shop.noAds
				end
				if os.time() - Game.others.lastMoneyAdWatch < 600 then
					local minutesLeft = math.ceil((600 - (os.time() - Game.others.lastMoneyAdWatch)) / 60)
					return minutesLeft .. " " .. Lang.shop.minutes
				end
				return Lang.shop.watchAd
			end
		},
		{
			name = Lang.shopItems["Skip Mission"].name,
			description = "Skips random mission",
			image = {
				path = "mission.png",
				width = 210.75,
				height = 135
			},
			buttonText = Lang.shop.watchAd,
			canBeBought = function()
				if os.time() - Game.others.lastMissionSkipAdWatch < 600 then
					return false
				end
				return ADS.isAvailable(true)
			end,
			onBuy = function()
				if not ADS.isAvailable() then
					return false
				end
				ADS.showAd(function()
					MissionManager.skipRandomMission()
					Menu.addAlert("Missions")
					GUI.showInfoBox(Lang.shop.adWatched .. ".", Lang.shopItems["Skip Mission"].awardMessage .. ".", InfoBoxType.chest)
				end)
				Game.others.lastMissionSkipAdWatch = os.time()
			end,
			getButtonText = function()
				if not ADS.isAvailable(true) then
					return Lang.shop.noAds
				end
				if os.time() - Game.others.lastMissionSkipAdWatch < 600 then
					local minutesLeft = math.ceil((600 - (os.time() - Game.others.lastMissionSkipAdWatch)) / 60)
					return minutesLeft .. " " .. Lang.shop.minutes
				end
				return Lang.shop.watchAd
			end
		},
		{
			name = Lang.shopItems["Tap Power"].name,
			description = Lang.shopItems["Tap Power"].description,
			image = {
				path = "upgrades/hand.png",
				width = 131.75,
				height = 157.25
			},
			buttonText = Lang.shop.watchAd,
			canBeBought = function()
				if os.time() - Game.others.lastTapPowerAdWatch < 600 then
					return false
				end
				return ADS.isAvailable(true)
			end,
			onBuy = function()
				if not ADS.isAvailable() then
					return false
				end
				ADS.showAd(function()
					Game.setTapPower(2, 180)
					GUI.showInfoBox(Lang.shop.adWatched .. ".", Lang.shopItems["Tap Power"].awardMessage .. ".", InfoBoxType.chest)
				end)
				Game.others.lastTapPowerAdWatch = os.time()
			end,
			getButtonText = function()
				if not ADS.isAvailable(true) then
					return Lang.shop.noAds
				end
				if os.time() - Game.others.lastTapPowerAdWatch < 600 then
					local minutesLeft = math.ceil((600 - (os.time() - Game.others.lastTapPowerAdWatch)) / 60)
					return minutesLeft .. " " .. Lang.shop.minutes
				end
				return Lang.shop.watchAd
			end
		},
		{
			name = Lang.shopItems["StatTrak Guarantee"].name,
			getDescription = function()
				return Lang.shopItems["StatTrak Guarantee"].description .. " " .. Game.others.statTrakGuarantees
			end,
			holdBuy = true,
			image = {
				path = "stattrak.png",
				width = 160,
				height = 160
			},
			getButtonText = function(buyMultiplier)
				return "$" .. formatPrice(15 * buyMultiplier)
			end,
			multipleBuy = true,
			canBeBought = function(buyMultiplier)
				if Game.money >= 15 * buyMultiplier then
					return true
				else
					return false
				end
			end,
			onBuy = function(event, buyId)
				Game.removeMoney(15, "Shop", "StatTrak Guarantee")
				Game.unlockAchievement("StatTrak Guaranteed")
				Game.others.statTrakGuarantees = Game.others.statTrakGuarantees + 1
				if buyId == 1 then
					GUI.showAnimatedText(nil, Lang.shop.bought .. "!", event.x * (math.random(95, 105) / 100), event.y * (math.random(95, 100) / 100))
				end
			end
		},
		{
			name = Lang.shopItems["Skip Mission"].name,
			description = "Skips random mission",
			image = {
				path = "mission.png",
				width = 210.75,
				height = 135
			},
			buttonText = "$10.00",
			multipleBuy = false,
			canBeBought = function()
				if Game.money >= 10 then
					return true
				else
					return false
				end
			end,
			onBuy = function()
				Game.removeMoney(10, "Shop", "Mission Skip")
				MissionManager.skipRandomMission()
				Menu.addAlert("Missions")
				GUI.showInfoBox(Lang.shop.itemBought .. ".", Lang.shopItems["Skip Mission"].awardMessage .. ".", InfoBoxType.chest)
			end
		},
		{
			name = Lang.shopItems["Weapon Name Tag"].name,
			description = Lang.shopItems["Weapon Name Tag"].description,
			image = {
				path = "otheritems/nametag.png",
				width = 178.5,
				height = 72
			},
			buttonText = "$50.00",
			multipleBuy = false,
			canBeBought = function()
				if Game.money >= 50 and #Game.equipment > 0 then
					return true
				else
					return false
				end
			end,
			onBuy = function()
				composer.gotoScene("scenes.itemselection", {
					params = {
						type = ItemSelection.nameTag
					}
				})
			end
		}
	},
	Cases = {
		{
			name = Lang.shopItems["Random Case"].name,
			description = Lang.shopItems["Random Case"].description,
			image = {
				path = "cases/unknown.png",
				width = 180.75,
				height = 132
			},
			getButtonText = function(buyMultiplier)
				return "$" .. formatPrice(4 * buyMultiplier)
			end,
			holdBuy = false,
			multipleBuy = true,
			canBeBought = function(buyMultiplier)
				if Game.money >= 4 * buyMultiplier then
					return true
				else
					return false
				end
			end,
			onBuy = function(event, buyId)
				Game.removeMoney(4, "Case", "Random")
				Game.showCaseDraw(true)
			end,
			onMultipleBuy = function(event, buyAmount)
				Game.removeMoney(buyAmount * 4, "Case", "Random")
				local stackedCases = {}
				for i = 1, buyAmount do
					local case = Game.cases[Game.getRandomCaseId(true)]
					Game.addItem(case, false, false, false)
					if stackedCases[case.id] then
						stackedCases[case.id] = stackedCases[case.id] + 1
					else
						stackedCases[case.id] = 1
					end
				end
				local casesToShow = {}
				for caseId, count in pairs(stackedCases) do
					table.insert(casesToShow, {
						id = caseId,
						type = Item.case,
						count = count
					})
				end
				composer.showOverlay("scenes.itemlist", {
					params = {
						firstText = "Item bought!",
						secondText = "New cases:",
						items = casesToShow,
						okButtonCallback = function()
							composer.hideOverlay()
						end
					}
				})
				Game.save()
			end
		}
	},
	Keys = {
		{
			name = Lang.shopItems["Free Key"].name,
			description = Lang.shopItems["Free Key"].description,
			image = {
				path = "keys/unknown.png",
				width = 155.25,
				height = 133.5
			},
			buttonText = Lang.shop.get .. "!",
			multipleBuy = false,
			canBeBought = function()
				if os.time() - Game.others.lastRandomKey < 1800 then
					return false
				end
				return true
			end,
			onBuy = function()
				Game.addItem(choose(Game.keys))
				Game.others.lastRandomKey = os.time()
			end,
			getButtonText = function()
				if os.time() - Game.others.lastRandomKey < 1800 then
					local minutesLeft = math.ceil((1800 - (os.time() - Game.others.lastRandomKey)) / 60)
					return minutesLeft .. " " .. Lang.shop.minutes
				end
				return Lang.shop.get .. "!"
			end
		},
		{
			name = Lang.shopItems["Random Case Key"].name,
			description = Lang.shopItems["Random Case Key"].description,
			image = {
				path = "keys/unknown.png",
				width = 155.25,
				height = 133.5
			},
			getButtonText = function(buyMultiplier)
				return "$" .. formatPrice(1.8 * buyMultiplier)
			end,
			multipleBuy = true,
			holdBuy = false,
			canBeBought = function(buyMultiplier)
				if Game.money >= 1.8 * buyMultiplier then
					return true
				else
					return false
				end
			end,
			onBuy = function()
				Game.removeMoney(1.8, "Key", "Random")
				Game.addItem(choose(Game.keys))
			end,
			onMultipleBuy = function(event, buyAmount)
				Game.removeMoney(buyAmount * 1.8, "Key", "Random")
				local stackedKeys = {}
				for i = 1, buyAmount do
					local key = choose(Game.keys)
					Game.addItem(key, false, false, false)
					if stackedKeys[key.id] then
						stackedKeys[key.id] = stackedKeys[key.id] + 1
					else
						stackedKeys[key.id] = 1
					end
				end
				local keysToShow = {}
				for keyId, count in pairs(stackedKeys) do
					table.insert(keysToShow, {
						id = keyId,
						type = Item.key,
						count = count
					})
				end
				composer.showOverlay("scenes.itemlist", {
					params = {
						firstText = "Item bought!",
						secondText = "New keys:",
						items = keysToShow,
						okButtonCallback = function()
							composer.hideOverlay()
						end
					}
				})
				Game.save()
			end
		},
		{
			name = Lang.shopItems["Missing Keys"].name,
			description = Lang.shopItems["Missing Keys"].description,
			image = {
				path = "keys/unknown.png",
				width = 155.25,
				height = 133.5
			},
			getButtonText = function()
				return "$" .. #Game.getMissingKeys() * 2.5
			end,
			multipleBuy = false,
			holdBuy = false,
			canBeBought = function()
				local missingKeys = #Game.getMissingKeys()
				if missingKeys == 0 then
					return false
				end
				if Game.money >= missingKeys * 2.5 then
					return true
				else
					return false
				end
			end,
			onBuy = function()
				local keys = Game.getMissingKeys()
				Game.removeMoney(#keys * 2.5, "Key", "Missing Keys")
				local stackedKeys = {}
				for i = 1, #keys do
					Game.onKeyBuy()
					local key = Game.keys[keys[i]]
					Game.addItem(key, false, false, false)
					if not stackedKeys[key.id] then
						stackedKeys[key.id] = 0
					end
					stackedKeys[key.id] = stackedKeys[key.id] + 1
				end
				local keysToShow = {}
				for keyId, count in pairs(stackedKeys) do
					table.insert(keysToShow, {
						id = keyId,
						type = Item.key,
						count = count
					})
				end
				stackedKeys = nil
				composer.showOverlay("scenes.itemlist", {
					params = {
						firstText = "Item bought!",
						secondText = "New keys:",
						items = keysToShow,
						okButtonCallback = function()
							composer.hideOverlay()
						end
					}
				})
				Game.save()
			end
		}
	},
	Collections = {},
	Souvenirs = {},
	Capsules = {},
	Autographs = {},
	["Paid Bonuses"] = {
		{
			id = "randomknife",
			name = Lang.shopItems["Random Knife"].name,
			description = Lang.shopItems["Random Knife"].description,
			image = {
				path = "knifes/all.png",
				width = 217.6,
				height = 168.29999999999998
			},
			buttonText = "Claim!",
			canBeBought = function()
				return Game.getBonusCooldownRemaining("randomknife") == 0
			end,
			getButtonText = function()
				local rem = Game.getBonusCooldownRemaining("randomknife")
				if rem > 0 then
					local m = math.floor(rem / 60)
					local s = rem % 60
					if m > 0 then
						return string.format("%dm %ds", m, s)
					else
						return string.format("%ds", s)
					end
				end
				return "Claim!"
			end,
			onBuy = function()
				if Game.getBonusCooldownRemaining("randomknife") == 0 or Game.testMode then
					Game.recordBonusClaim("randomknife")
					GUI.showInfoBox("Bonus Claimed:", "Random Knife", InfoBoxType.coin)
					Game.showKnifeDraw(true)
				end
			end
		},
		{
			id = "randomgloves",
			name = Lang.shopItems["Random Gloves"].name,
			description = Lang.shopItems["Random Gloves"].description,
			image = {
				path = "gloves/shopgloves.png",
				width = 204.8,
				height = 153.60000000000002
			},
			buttonText = "Claim!",
			canBeBought = function()
				return Game.getBonusCooldownRemaining("randomgloves") == 0
			end,
			getButtonText = function()
				local rem = Game.getBonusCooldownRemaining("randomgloves")
				if rem > 0 then
					local m = math.floor(rem / 60)
					local s = rem % 60
					if m > 0 then
						return string.format("%dm %ds", m, s)
					else
						return string.format("%ds", s)
					end
				end
				return "Claim!"
			end,
			onBuy = function()
				if Game.getBonusCooldownRemaining("randomgloves") == 0 or Game.testMode then
					Game.recordBonusClaim("randomgloves")
					GUI.showInfoBox("Bonus Claimed:", "Random Gloves", InfoBoxType.coin)
					Game.showGloveDraw(true)
				end
			end
		},
		{
			id = "100bonus",
			name = Lang.shopItems["Money Bonus"].name,
			description = Lang.shopItems["Money Bonus"].description:gsub("{1}", "500"),
			image = {
				path = "coin.png",
				width = 147.95000000000002,
				height = 147.4
			},
			buttonText = "Claim!",
			canBeBought = function()
				return Game.getBonusCooldownRemaining("100bonus") == 0
			end,
			getButtonText = function()
				local rem = Game.getBonusCooldownRemaining("100bonus")
				if rem > 0 then
					local m = math.floor(rem / 60)
					local s = rem % 60
					if m > 0 then
						return string.format("%dm %ds", m, s)
					else
						return string.format("%ds", s)
					end
				end
				return "Claim!"
			end,
			onBuy = function()
				if Game.getBonusCooldownRemaining("100bonus") == 0 or Game.testMode then
					Game.recordBonusClaim("100bonus")
					Game.addMoney(500, "Bonus", "Money Bonus")
					GUI.showInfoBox("Bonus Claimed:", "+$500 Cash", InfoBoxType.coin)
				end
			end
		},
		{
			id = "50randomcases",
			name = Lang.shopItems["50 Random Cases"].name,
			description = Lang.shopItems["50 Random Cases"].description,
			image = {
				path = "clickcase.png",
				width = 207.75,
				height = 159
			},
			buttonText = "Claim!",
			canBeBought = function()
				return Game.getBonusCooldownRemaining("50randomcases") == 0
			end,
			getButtonText = function()
				local rem = Game.getBonusCooldownRemaining("50randomcases")
				if rem > 0 then
					local m = math.floor(rem / 60)
					local s = rem % 60
					if m > 0 then
						return string.format("%dm %ds", m, s)
					else
						return string.format("%ds", s)
					end
				end
				return "Claim!"
			end,
			onBuy = function()
				if Game.getBonusCooldownRemaining("50randomcases") == 0 or Game.testMode then
					Game.recordBonusClaim("50randomcases")
					GUI.showInfoBox("Bonus Claimed:", "50 Random Cases", InfoBoxType.coin)
					for i = 1, 50 do
						Game.addItem(choose(Game.cases), false)
					end
					Menu.addAlert("Cases")
				end
			end
		},
		{
			id = "nethub",
			name = Lang.shopItems.NetHub.name,
			description = Lang.shopItems.NetHub.description,
			image = {
				path = "upgrades/bets.png",
				width = 187.5,
				height = 187.5
			},
			buttonText = "Unlock",
			canBeBought = function()
				return not (Game.isUpgradeBought("Trades") and Game.isUpgradeBought("Match Betting"))
			end,
			getButtonText = function()
				if Game.isUpgradeBought("Trades") and Game.isUpgradeBought("Match Betting") then
					return "Unlocked"
				end
				return "Unlock"
			end,
			onBuy = function()
				if not (Game.isUpgradeBought("Trades") and Game.isUpgradeBought("Match Betting")) or Game.testMode then
					GUI.showInfoBox("Unlocked:", "NetHub Online Features", InfoBoxType.coin)
					Game.buyUpgrade("Trades", true)
					Game.buyUpgrade("Match Betting", true)
					Game.others.nethubUnlocked = true
					Game.save()
				end
			end
		},
		{
			id = "jackpots",
			name = Lang.shopItems.Jackpots.name,
			description = Lang.shopItems.Jackpots.description,
			image = {
				path = "upgrades/jackpot.png",
				width = 180,
				height = 180
			},
			buttonText = "Unlock",
			canBeBought = function()
				return not Game.others.jackpotsUnlocked
			end,
			getButtonText = function()
				if Game.others.jackpotsUnlocked or Game.isUpgradeBought("Jackpot") then
					return "Unlocked"
				end
				return "Unlock"
			end,
			onBuy = function()
				if not Game.others.jackpotsUnlocked or Game.testMode then
					GUI.showInfoBox("Unlocked:", "Jackpot Mode", InfoBoxType.coin)
					Game.buyUpgrade("Jackpot", true)
					Game.others.jackpotsUnlocked = true
					Game.save()
				end
			end
		},
		{
			id = "mps",
			name = Lang.shopItems["More Money per Second"].name,
			description = Lang.shopItems["More Money per Second"].description,
			image = {
				path = "upgrades/orangecrystal.png",
				width = 175,
				height = 120.39999999999999
			},
			buttonText = "Claim!",
			canBeBought = function()
				if Game.moneyPerSecond >= 0.9 then
					return false
				end
				return Game.getBonusCooldownRemaining("mps") == 0
			end,
			getButtonText = function()
				if Game.moneyPerSecond >= 0.9 then
					return "Maxed"
				end
				local rem = Game.getBonusCooldownRemaining("mps")
				if rem > 0 then
					local m = math.floor(rem / 60)
					local s = rem % 60
					if m > 0 then
						return string.format("%dm %ds", m, s)
					else
						return string.format("%ds", s)
					end
				end
				return "Claim!"
			end,
			onBuy = function()
				if (Game.getBonusCooldownRemaining("mps") == 0 or Game.testMode) and Game.moneyPerSecond < 0.9 then
					Game.recordBonusClaim("mps")
					GUI.showInfoBox("Bonus Claimed:", "+$0.025/sec Income", InfoBoxType.coin)
					Game.moneyPerSecond = Game.moneyPerSecond + 0.025
					Game.others.mpsBought = true
					Game.save()
				end
			end
		}
	}
}
