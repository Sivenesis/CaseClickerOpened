local composer = require("composer")
local scene = composer.newScene()
local leftBox, rightBox, statisticsBox
local itemBoxes = {}
local buttons = {}
local priceText, countText
local getMinimumPrice = function()
	return 0.5 + StatisticManager.getStatistic("dailyRewards") / 6
end
local getMaximumPrice = function()
	return 5 + StatisticManager.getStatistic("dailyRewards") * 2
end
local function updateTexts()
	priceText.text = "$" .. formatPrice(getMinimumPrice()) .. " @ $" .. formatPrice(getMaximumPrice())
	countText.text = StatisticManager.getStatistic("dailyRewards") .. " rewards!"
end
local function updateItemBoxes()
	local sceneGroup = scene.view
	if leftBox then
		leftBox:removeSelf()
	end
	if rightBox then
		rightBox:removeSelf()
	end
	if Game.lastDailies[1] and Game.lastDailies[1].day == tonumber(os.date("%d")) then
		leftBox = GUI.createItemBox(sceneGroup, Game.lastDailies[1], buttons[1].x, buttons[1].y, Game.lastDailies[1].statTrak, 1, {
			dontUseGUIScale = true,
			showQuality = true,
			quality = Game.lastDailies[1].quality,
			pattern = Game.lastDailies[1].pattern
		})
	else
		leftBox = GUI.createItemBox(sceneGroup, {
			type = Item.unknown
		}, buttons[1].x, buttons[1].y, false, 1, {center = true, dontUseGUIScale = true})
	end
	if Game.lastDailies[2] and Game.lastDailies[2].day == tonumber(os.date("%d")) then
		rightBox = GUI.createItemBox(sceneGroup, Game.lastDailies[2], buttons[2].x, buttons[2].y, Game.lastDailies[2].statTrak, 1, {
			dontUseGUIScale = true,
			showQuality = true,
			quality = Game.lastDailies[2].quality,
			pattern = Game.lastDailies[2].pattern
		})
	else
		rightBox = GUI.createItemBox(sceneGroup, {
			type = Item.unknown
		}, buttons[2].x, buttons[2].y, false, 1, {center = true, dontUseGUIScale = true})
	end
	leftBox.x = buttons[1].x + buttons[1].width / 2 - 175
	leftBox.y = buttons[1].y - 350 - 20
	rightBox.x = buttons[2].x + buttons[2].width / 2 - 175
	rightBox.y = buttons[2].y - 350 - 20
end
local function updateButtons()
	local sceneGroup = scene.view
	if tonumber(os.date("%d")) == Game.others.lastDailyRewardd and Game.others.leftDailyRewardAwarded then
		buttons[1]:setText("No rewards available")
		buttons[1]:setType(ButtonType.red)
	elseif not Game.others.dailyRewardAdWatched then
		if ADS.isAvailable() then
			buttons[1]:setText("Watch AD!")
			buttons[1]:setType(ButtonType.purple)
		else
			buttons[1]:setText("No ADs available")
			buttons[1]:setType(ButtonType.red)
		end
	else
		buttons[1]:setText("Get reward!")
		buttons[1]:setType(ButtonType.green)
	end
	if tonumber(os.date("%d")) == Game.others.lastDailyRewardd2 and Game.others.rightDailyRewardAwarded then
		buttons[2]:setText("No rewards available")
		buttons[2]:setType(ButtonType.red)
	elseif not Game.others.dailyRewardAdWatched then
		if ADS.isAvailable() then
			buttons[2]:setText("Watch AD!")
			buttons[2]:setType(ButtonType.purple)
		else
			buttons[2]:setText("No ADs available")
			buttons[2]:setType(ButtonType.red)
		end
	else
		buttons[2]:setText("Get reward!")
		buttons[2]:setType(ButtonType.green)
	end
end
function scene:create(event)
	local sceneGroup = self.view
	local rewardBoxWidth = (display.safeActualContentWidth - display.safeActualContentWidth * 0.25 - 20) / 2
	local firstRewardBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.25 + 10, 10, rewardBoxWidth - 5, display.safeActualContentHeight * 0.55, "Reward #1", true)
	local secondRewardBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.25 + 10 + rewardBoxWidth + 5, 10, rewardBoxWidth - 5, display.safeActualContentHeight * 0.55, "Reward #2", true)
	local buttonWidth = firstRewardBox.width * 0.7
	local buttonY = firstRewardBox.y + firstRewardBox.height * 0.75
	buttons[1] = Button.create(sceneGroup, firstRewardBox.x + firstRewardBox.width * 0.5 - buttonWidth / 2, buttonY, buttonWidth, 80, "", ButtonType.red, function()
		if buttons[1]:getType() == ButtonType.green then
			Game.others.dailyRewardAdWatched = false
			Game.others.leftDailyRewardAwarded = true
			Game.others.lastDailyRewardd = tonumber(os.date("%d"))
			Game.showDailyDraw(1)
			Game.onDailyReward()
		elseif buttons[1]:getType() == ButtonType.purple then
			if not ADS.isAvailable() then
				return updateButtons()
			end
			ADS.showAd(function()
				Game.others.dailyRewardAdWatched = true
				Game.others.leftDailyRewardAwarded = false
				updateButtons()
				updateItemBoxes()
				updateTexts()
			end)
		end
		updateButtons()
		updateItemBoxes()
	end, {fontSize = 40, blockTime = 1000})
	buttons[2] = Button.create(sceneGroup, secondRewardBox.x + secondRewardBox.width * 0.5 - buttonWidth / 2, buttonY, buttonWidth, 80, "", ButtonType.red, function()
		if buttons[2]:getType() == ButtonType.green then
			Game.others.dailyRewardAdWatched = false
			Game.others.rightDailyRewardAwarded = true
			Game.others.lastDailyRewardd2 = tonumber(os.date("%d"))
			Game.showDailyDraw(2)
			Game.onDailyReward()
		elseif buttons[2]:getType() == ButtonType.purple then
			if not ADS.isAvailable() then
				return updateButtons()
			end
			ADS.showAd(function()
				Game.others.dailyRewardAdWatched = true
				Game.others.rightDailyRewardAwarded = false
				updateButtons()
				updateItemBoxes()
				updateTexts()
			end)
		end
		updateButtons()
		updateItemBoxes()
	end, {fontSize = 40, blockTime = 1000})
	local boxY = 10 + display.safeActualContentHeight * 0.55 + 10
	local boxHeight = display.safeActualContentHeight - boxY - 10
	statisticsBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.25 + 10, boxY, display.safeActualContentWidth - display.safeActualContentWidth * 0.25 - 20, boxHeight, "Statistics")
	local firstText = PonyFont.newText({
		parent = sceneGroup,
		x = getCenterX(statisticsBox),
		y = statisticsBox.y + 120,
		text = "Daily rewards received:",
		font = BitmapFont.counterstrike,
		fontSize = 62,
		align = "center"
	})
	firstText.anchorX = 0.5
	firstText.anchorY = 0.5
	countText = PonyFont.newText({
		parent = sceneGroup,
		x = getCenterX(statisticsBox),
		y = firstText.y + 60,
		text = "",
		font = BitmapFont.counterstrike,
		fontSize = 72,
		align = "center"
	})
	countText.anchorX = 0.5
	countText.anchorY = 0.5
	countText:setFillColor(unpack(Color.gold))
	local thirdText = PonyFont.newText({
		parent = sceneGroup,
		x = getCenterX(statisticsBox),
		y = countText.y + 130,
		text = "Next daily reward price:",
		font = BitmapFont.counterstrike,
		fontSize = 62,
		align = "center"
	})
	thirdText.anchorX = 0.5
	thirdText.anchorY = 0.5
	thirdText:addEventListener("tap", function()
		Game.unlockAchievement("Secret VIII")
	end)
	priceText = PonyFont.newText({
		parent = sceneGroup,
		x = getCenterX(statisticsBox),
		y = thirdText.y + 60,
		text = "",
		font = BitmapFont.counterstrike,
		fontSize = 72,
		align = "center"
	})
	priceText.anchorX = 0.5
	priceText.anchorY = 0.5
	priceText:setFillColor(unpack(Color.gold))
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
		updateItemBoxes()
		updateButtons()
		updateTexts()
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
