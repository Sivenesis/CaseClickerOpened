local composer = require("composer")
local TextSlider = require("gui.textslider")
local ProgressBar = require("gui.progressbar")
local scene = composer.newScene()
local tableView
Statistic = {
	main = 1,
	progress = 2,
	tapping = 3,
	skinsnstickers = 4,
	jackpots = 5,
	casino = 6,
	bets = 7,
	others = 8,
	online = 9
}
local sliderTexts = Lang.statistics.tabNames
local actualOption = Statistic.main
local statisticTexts = {}
local progressBars = {}
local completableSouvenirs = 0
for i = 1, #Game.souvenirs do
	if Game.souvenirs[i].price then
		completableSouvenirs = completableSouvenirs + 1
	end
end
local getStatisticValue = function(tab)
	if tab.id then
		return nil
	end
	if tab.text then
		return tab.text
	end
	local text = tab.value
	if tab.prefix then
		text = tab.prefix .. text
	end
	if tab.suffix then
		text = text .. tab.suffix
	end
	return text
end
local function updateStatistics()
	if composer.getSceneName("current") ~= "scenes.statistics" then
		return
	end
	timer.performWithDelay(250, updateStatistics)
	local tab = {}
	if actualOption == Statistic.main then
		tab = {
			{
				name = Lang.statistics.moneypersecond,
				value = Game.moneyPerSecond,
				prefix = "$",
				color = {
					rgb(255, 255, 0)
				}
			},
			{
				name = Lang.statistics.actualMoney,
				value = formatPrice(Game.money),
				prefix = "$",
				color = {
					rgb(255, 255, 0)
				}
			},
			{
				name = Lang.statistics.moneyRecord,
				value = formatPrice(StatisticManager.getStatistic("moneyRecord")),
				prefix = "$",
				color = {
					rgb(255, 255, 0)
				}
			},
			{
				name = Lang.statistics.totalGainedMoney,
				value = formatPrice(StatisticManager.getStatistic("totalGainedMoney")),
				prefix = "$",
				color = {
					rgb(255, 255, 0)
				}
			},
			{
				name = Lang.statistics.searchPerSecond,
				value = Game.searchPerSecond,
				suffix = "%"
			},
			{
				name = Lang.statistics.totalExperienceGained,
				value = StatisticManager.getStatistic("totalExperience")
			},
			{
				name = Lang.statistics.offlineIncomeTime,
				value = math.ceil(Game.others.offlineIncomeTime / 60),
				suffix = " minutes"
			},
			{
				name = Lang.statistics.boughtCollections,
				value = commaValue(StatisticManager.getStatistic("boughtCollections"))
			},
			{
				name = Lang.statistics.openedCollections,
				value = commaValue(StatisticManager.getStatistic("openedCollections"))
			},
			{
				name = Lang.statistics.boughtSouvenirs,
				value = commaValue(StatisticManager.getStatistic("boughtSouvenirs"))
			},
			{
				name = Lang.statistics.openedSouvenirs,
				value = commaValue(StatisticManager.getStatistic("openedSouvenirs"))
			},
			{
				name = Lang.statistics.boughtCapsules,
				value = commaValue(StatisticManager.getStatistic("boughtCapsules"))
			},
			{
				name = Lang.statistics.openedCapsules,
				value = commaValue(StatisticManager.getStatistic("openedCapsules"))
			},
			{
				name = Lang.statistics.completedMissions,
				value = StatisticManager.getStatistic("completedMissions")
			},
			{
				name = Lang.statistics.openedCases,
				value = StatisticManager.getStatistic("openedBoxes")
			},
			{
				name = Lang.statistics.soldCases,
				value = commaValue(StatisticManager.getStatistic("soldCases"))
			},
			{
				name = Lang.statistics.soldItems,
				value = commaValue(StatisticManager.getStatistic("soldItems"))
			},
			{
				name = Lang.statistics.boughtItems,
				value = commaValue(StatisticManager.getStatistic("itemsBought"))
			},
			{
				name = Lang.statistics.boughtKeys,
				value = commaValue(StatisticManager.getStatistic("keysBought"))
			},
			{
				name = Lang.statistics.dailyRewardsFound,
				value = StatisticManager.getStatistic("dailyRewards")
			},
			{
				name = Lang.statistics.signedContracts,
				value = commaValue(StatisticManager.getStatistic("signedContracts"))
			},
			{
				name = Lang.statistics.privateRankResets,
				value = Game.others.expResets
			}
		}
	elseif actualOption == Statistic.tapping then
		tab = {
			{
				name = Lang.statistics.totalTaps,
				value = commaValue(StatisticManager.getStatistic("totalClicks"))
			},
			{
				name = Lang.statistics.moneyTaps,
				value = commaValue(StatisticManager.getStatistic("moneyClicks"))
			},
			{
				name = Lang.statistics.caseSearchTaps,
				value = commaValue(StatisticManager.getStatistic("searchClicks"))
			},
			{
				name = Lang.statistics.casesFound,
				value = commaValue(StatisticManager.getStatistic("casesFound"))
			},
			{
				name = Lang.statistics.moneyPerTap,
				value = Game.clickMoneyGain,
				prefix = "$",
				color = {
					rgb(255, 255, 0)
				}
			},
			{
				name = Lang.statistics.searchPerTap,
				value = Game.clickSearchGain,
				suffix = "%"
			},
			{
				name = Lang.statistics.criticalTapChance,
				value = Game.criticalHitChance,
				suffix = "%"
			},
			{
				name = Lang.statistics.criticalTaps,
				value = StatisticManager.getStatistic("criticalTaps")
			},
			{
				name = Lang.statistics.comboRecord,
				prefix = "x",
				value = formatPrice(StatisticManager.getStatistic("maximumCombo"))
			},
			{
				name = Lang.statistics.tapsPerSecondRecord,
				value = StatisticManager.getStatistic("maximumTapsPerSecond")
			}
		}
	elseif actualOption == Statistic.skinsnstickers then
		tab = {
			{
				name = Lang.statistics.equipmentWorth,
				value = formatPrice(StatisticManager.getStatistic("skinsWorth")),
				prefix = "$",
				color = {
					rgb(255, 255, 0)
				}
			},
			{
				name = Lang.statistics.itemCount,
				value = #Game.equipment
			},
			{
				name = Lang.statistics.averageItemPrice,
				value = formatPrice(StatisticManager.getStatistic("skinsWorth") / math.max(1, #Game.equipment)),
				prefix = "$",
				color = {
					rgb(255, 255, 0)
				}
			},
			{
				name = Lang.statistics.soldSkins,
				value = StatisticManager.getStatistic("soldSkins")
			},
			{
				name = Lang.statistics.covertSkinsFound,
				value = StatisticManager.getStatistic("covertFound")
			},
			{
				name = Lang.statistics.classifiedSkinsFound,
				value = StatisticManager.getStatistic("classifiedFound")
			},
			{
				name = Lang.statistics.restrictedSkinsFound,
				value = StatisticManager.getStatistic("restrictedFound")
			},
			{
				name = Lang.statistics.milSpecSkinsFound,
				value = StatisticManager.getStatistic("milspecFound")
			},
			{
				name = Lang.statistics.statTrakSkinsFound,
				value = StatisticManager.getStatistic("statTrakFound")
			},
			{
				name = Lang.statistics.knivesFound,
				value = StatisticManager.getStatistic("knivesFound")
			},
			{
				name = "Gloves found",
				value = StatisticManager.getStatistic("glovesFound")
			}
		}
	elseif actualOption == Statistic.jackpots then
		tab = {
			{
				name = Lang.statistics.jackpotsPlayed,
				value = StatisticManager.getStatistic("jackpotsPlayed")
			},
			{
				name = Lang.statistics.jackpotsWon,
				value = StatisticManager.getStatistic("jackpotsWon")
			},
			{
				name = Lang.statistics.jackpotsLost,
				value = StatisticManager.getStatistic("jackpotsLost")
			},
			{
				name = Lang.statistics.moneyWonInJackpots,
				value = formatPrice(StatisticManager.getStatistic("moneyWonInJackpots")),
				prefix = "$",
				color = {
					rgb(255, 255, 0)
				}
			},
			{
				name = Lang.statistics.moneyLostInJackpots,
				value = formatPrice(StatisticManager.getStatistic("moneyLostInJackpots")),
				prefix = "$",
				color = {
					rgb(255, 255, 0)
				}
			},
			{
				name = Lang.statistics.onlineJackpotsPlayed,
				value = StatisticManager.getStatistic("onlineJackpotsPlayed")
			},
			{
				name = Lang.statistics.onlineJackpotsWon,
				value = StatisticManager.getStatistic("onlineJackpotsWon")
			},
			{
				name = Lang.statistics.onlineJackpotsLost,
				value = StatisticManager.getStatistic("onlineJackpotsLost")
			},
			{
				name = Lang.statistics.moneyWonInJackpots,
				value = formatPrice(StatisticManager.getStatistic("moneyWonInOnlineJackpots")),
				prefix = "$",
				color = {
					rgb(255, 255, 0)
				}
			},
			{
				name = Lang.statistics.moneyLostInJackpots,
				value = formatPrice(StatisticManager.getStatistic("moneyLostInOnlineJackpots")),
				prefix = "$",
				color = {
					rgb(255, 255, 0)
				}
			}
		}
	elseif actualOption == Statistic.casino then
		tab = {
			{
				name = Lang.statistics.roulettesWon,
				value = StatisticManager.getStatistic("roulettesWon")
			},
			{
				name = Lang.statistics.roulettesLost,
				value = StatisticManager.getStatistic("roulettesLost")
			},
			{
				name = Lang.statistics.ticketsWonInRoulette,
				value = commaValue(StatisticManager.getStatistic("ticketsWonInRoulette")),
				color = {
					rgb(255, 255, 0)
				}
			},
			{
				name = Lang.statistics.ticketsLostInRoulette,
				value = commaValue(StatisticManager.getStatistic("ticketsLostInRoulette")),
				color = {
					rgb(255, 255, 0)
				}
			},
			{
				name = Lang.statistics.coinflipsWon,
				value = StatisticManager.getStatistic("coinflipsWon")
			},
			{
				name = Lang.statistics.coinflipsLost,
				value = StatisticManager.getStatistic("coinflipsLost")
			},
			{
				name = Lang.statistics.ticketsWonInCoinflip,
				value = commaValue(StatisticManager.getStatistic("ticketsWonInCoinflip")),
				color = {
					rgb(255, 255, 0)
				}
			},
			{
				name = Lang.statistics.ticketsLostInCoinflip,
				value = commaValue(StatisticManager.getStatistic("ticketsLostInCoinflip")),
				color = {
					rgb(255, 255, 0)
				}
			},
			{
				name = "Mineswepers won",
				value = StatisticManager.getStatistic("minesweepersWon")
			},
			{
				name = "Mineswepers lost",
				value = StatisticManager.getStatistic("minesweepersLost")
			},
			{
				name = "Minesweeper profit",
				value = commaValue(StatisticManager.getStatistic("minesweeperProfit")):gsub("-", "@"),
				suffix = " tickets",
				color = {
					rgb(255, 255, 0)
				}
			},
			{
				name = "Scratched scratches",
				value = StatisticManager.getStatistic("scratchedScratches")
			},
			{
				name = "Crash won",
				value = StatisticManager.getStatistic("crashWon")
			},
			{
				name = "Crash lost",
				value = StatisticManager.getStatistic("crashLost")
			},
			{
				name = "Crash profit",
				value = commaValue(StatisticManager.getStatistic("crashProfit")):gsub("-", "@"),
				suffix = " tickets",
				color = {
					rgb(255, 255, 0)
				}
			}
		}
	elseif actualOption == Statistic.bets then
		tab = {
			{
				name = Lang.statistics.placedBets,
				value = StatisticManager.getStatistic("placedBets")
			},
			{
				name = Lang.statistics.betsWon,
				value = StatisticManager.getStatistic("wonBets")
			},
			{
				name = Lang.statistics.bestLost,
				value = StatisticManager.getStatistic("lostBets")
			},
			{
				name = Lang.statistics.winLoseRation,
				value = formatPrice(StatisticManager.getStatistic("wonBets") / math.max(1, StatisticManager.getStatistic("lostBets")))
			}
		}
	elseif actualOption == Statistic.others then
		tab = {
			{
				name = Lang.statistics.watchedAds,
				value = StatisticManager.getStatistic("watchedAds")
			},
			{
				name = Lang.statistics.logoTaps,
				value = StatisticManager.getStatistic("logoTaps")
			},
			{
				name = Lang.statistics.acceptedTrades,
				value = StatisticManager.getStatistic("tradesCompleted")
			},
			{
				name = "Used promo codes",
				value = StatisticManager.getStatistic("usedPromoCodes")
			}
		}
	elseif actualOption == Statistic.progress then
		tab = {
			{
				name = Lang.statistics.rank,
				percent = math.min(#Game.ranks, Game.rank) / #Game.ranks * 100,
				text = Game.ranks[Game.rank].name,
				color = Color.mainText
			},
			{
				name = Lang.statistics.privateRank,
				percent = Game.expRank / #Game.expRanks * 100,
				text = Lang.privateRanks[Game.expRank],
				color = Color.mainText
			},
			{
				name = Lang.statistics.unlockedCases,
				percent = StatisticManager.getStatistic("unlockedCases") / #Game.cases * 100,
				text = StatisticManager.getStatistic("unlockedCases") .. " / " .. #Game.cases
			},
			{
				name = Lang.statistics.unlockedAchievements,
				percent = StatisticManager.getStatistic("unlockedAchievements") / tableLength(Game.achievements) * 100,
				text = StatisticManager.getStatistic("unlockedAchievements") .. " / " .. tableLength(Game.achievements)
			},
			{
				name = Lang.statistics.boughtUpgrades,
				percent = StatisticManager.getStatistic("upgradesBought") / tableLength(Game.upgrades) * 100,
				text = StatisticManager.getStatistic("upgradesBought") .. " / " .. tableLength(Game.upgrades)
			},
			{
				name = Lang.statistics.completedCapsules,
				percent = StatisticManager.getStatistic("capsulesCompleted") / #Game.capsules * 100,
				text = StatisticManager.getStatistic("capsulesCompleted") .. " / " .. #Game.capsules
			},
			{
				name = Lang.statistics.completedCollections,
				percent = StatisticManager.getStatistic("collectionsCompleted") / #Game.collections * 100,
				text = StatisticManager.getStatistic("collectionsCompleted") .. " / " .. #Game.collections
			},
			{
				name = Lang.statistics.completedSouvenirs,
				percent = StatisticManager.getStatistic("souvenirsCompleted") / completableSouvenirs * 100,
				text = StatisticManager.getStatistic("souvenirsCompleted") .. " / " .. completableSouvenirs
			},
			{
				name = Lang.statistics.completedCases,
				percent = StatisticManager.getStatistic("casesCompleted") / #Game.cases * 100,
				text = StatisticManager.getStatistic("casesCompleted") .. " / " .. #Game.cases
			}
		}
	elseif actualOption == Statistic.online then
		statisticTexts = {}
		progressBars = {}
		tableView:deleteAllRows()
		tab = {
			{leaderboards = true}
		}
	end
	if 0 < #statisticTexts or 0 < #progressBars then
		if 0 < #statisticTexts then
			for i = 1, #tab do
				if statisticTexts[i] then
					statisticTexts[i].text = getStatisticValue(tab[i])
				end
				if progressBars[i] then
					progressBars[i]:setProgress(tab[i].percent)
					progressBars[i]:setText(math.floor(tab[i].percent * 100) / 100 .. "%")
				end
			end
		end
		return
	end
	for i = 1, #tab do
		local height = 140
		if tab[i].percent or tab[i].leaderboards then
			height = 250
		end
		tableView:insertRow({
			params = {
				i = i,
				data = tab[i]
			},
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = height * Game.guiScale
		})
	end
end
local function refreshStatisticsList()
	if actualOption == Statistic.online then
		return
	end
	statisticTexts = {}
	progressBars = {}
	tableView:deleteAllRows()
	updateStatistics()
end
local function onRowRender(event)
	local row = event.row
	local i = row.params.i
	local data = row.params.data
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
	if data.leaderboards then
		local buttonText = Lang.statistics.googlePlayLeaderboards
		if isIOS() then
			buttonText = Lang.statistics.gameCenterLeaderboards
		end
		GUI.createButton(row, 30, 20, row.width - 60, row.height - 20, buttonText, ButtonType.blue, function()
			GameServices.showLeaderboards()
			return true
		end, 60)
		return
	end
	local fontSize = 60
	if 20 <= data.name:len() then
		fontSize = 52
	end
	fontSize = fontSize * Game.guiScale
	local firstTextText = data.name
	if not data.id then
		firstTextText = firstTextText .. ":"
	end
	local firstText = display.newText({
		parent = row,
		x = 30,
		y = 54,
		text = firstTextText,
		font = Font.counterstrike,
		fontSize = fontSize
	})
	firstText.anchorY = 0
	FontOffset.setOffset(firstText)
	if not data.percent then
		GUI.drawVerticalLine(row, row.x + row.width * 0.55, row.x, row.height)
	end
	if data.percent then
		progressBars[i] = ProgressBar.create(row, row.width / 2, 130 * Game.guiScale, row.width - 60, 65, ProgressBarType.default)
		progressBars[i]:setProgress(data.percent)
		progressBars[i]:setText(math.floor(data.percent * 100) / 100 .. "%")
	end
	local text = getStatisticValue(data)
	if text then
		local textX = row.x + row.width * 0.57
		local textAnchorX = 0
		if data.percent then
			textX = row.width - 20
			textAnchorX = 1
		end
		statisticTexts[i] = display.newText({
			parent = row,
			x = textX,
			y = 54,
			text = text,
			font = Font.counterstrike,
			fontSize = fontSize
		})
		statisticTexts[i].anchorY = 0
		statisticTexts[i].anchorX = textAnchorX
		statisticTexts[i]:setFillColor(rgb(146, 176, 210))
		if data.color then
			statisticTexts[i]:setFillColor(unpack(data.color))
		end
		FontOffset.setOffset(statisticTexts[i])
	end
end
function scene:create(event)
	local sceneGroup = self.view
	local sliderTexts = Lang.statistics.tabNames
	if GameServices.loggedIn then
		table.insert(sliderTexts, Lang.statistics.leaderboards)
	end
	local box = GUI.drawMainBox(sceneGroup, Lang.statistics.yourStatistics)
	local slider = TextSlider.create(sceneGroup, box.x, box.y, box.width, 110 * Game.guiScale, sliderTexts, function(text, textId)
		actualOption = textId
		refreshStatisticsList()
	end)
	tableView = widget.newTableView({
		left = box.x,
		top = box.y + 110 * Game.guiScale,
		width = box.width,
		height = box.height - 110 * Game.guiScale,
		isBounceEnabled = true,
		backgroundColor = Color.row,
		onRowRender = onRowRender,
		friction = 0.976,
		maxVelocity = 3
	})
	sceneGroup:insert(tableView)
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
		GameServices.sendHighscores()
		updateStatistics()
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
