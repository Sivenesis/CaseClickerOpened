local widget = require("widget")
local TextSlider = require("gui.textslider")
local scene = composer.newScene()
local box, mainGroup, optionsGroup, playerItemsText, winChanceText, startButton, addItemsButton, stopButton, viewItemsButton, checkButton, newJackpotButton, itemCountText, worthText, jackpotNumberText, statusText, circle, gearWheel, priceRangeText, jackpotOverlay
local jackpotImages = {}
local animation = {started = false, phase = 0}
local jackpotModeTexts = Lang.jackpot.modetexts
local difficultySlider
local actualModeText = jackpotModeTexts[Game.jackpot.mode]
local actualText = Jackpot.difficulties[Game.jackpot.type].name
local function updateSettingsTexts()
	local difficulty = Jackpot.difficulties[Game.jackpot.type]
	local maxPrice = "$" .. formatPrice(difficulty.maxPrice)
	if difficulty.maxPrice > 2500 then
		maxPrice = Lang.jackpot.maximum
	end
	priceRangeText.text = Lang.jackpot.pricerange .. ": $" .. formatPrice(difficulty.minPrice) .. " " .. Lang.jackpot.to .. " " .. maxPrice
end
local function fadeOutGearwheel()
	transition.fadeOut(gearWheel, {time = 500})
end
local function fadeInGearWheel()
	transition.fadeIn(gearWheel, {time = 500})
end
local function updateImages()
	for i = 0, 50 do
		if jackpotImages[i] then
			jackpotImages[i].alpha = 0
		end
	end
	local itemCount = Jackpot.getItemCount()
	if 50 < itemCount then
		itemCount = 50
	end
	if not jackpotImages[itemCount] then
		jackpotImages[itemCount] = display.newImageRect(mainGroup, "images/jackpot/jackpot_" .. itemCount .. ".png", 640, 640)
		jackpotImages[itemCount].alpha = 0
		jackpotImages[itemCount].anchorX = 0.5
		jackpotImages[itemCount].anchorY = 0.5
		jackpotImages[itemCount].x = getCenterX(box)
		jackpotImages[itemCount].y = circle.y + circle.height / 2
	end
	jackpotImages[itemCount].alpha = 1
	if not jackpotOverlay or not jackpotOverlay.toFront then
		jackpotOverlay = display.newImageRect(mainGroup, "images/jackpot/overlay.png", 640, 640)
		jackpotOverlay.anchorX = 0.5
		jackpotOverlay.anchorY = 0.5
		jackpotOverlay.x = getCenterX(box)
		jackpotOverlay.y = circle.y + circle.height / 2
	end
	jackpotOverlay:toFront()
end
local function updateButtons()
	startButton.alpha = 0
	addItemsButton.alpha = 0
	stopButton.alpha = 0
	checkButton.alpha = 0
	newJackpotButton.alpha = 0
	viewItemsButton.alpha = 0
	if Jackpot.getStatus() > 1 then
		newJackpotButton.alpha = 1
	elseif Jackpot.getStatus() == 1 then
		checkButton.alpha = 1
	elseif Jackpot.isStarted() then
		stopButton.alpha = 1
	else
		startButton.alpha = 1
		addItemsButton.alpha = 1
		viewItemsButton.alpha = 1
	end
end
local function updatePlayerTexts()
	local itemCount = #Game.jackpot.playerItems
	local worth = 0
	for _, item in ipairs(Game.jackpot.playerItems) do
		worth = worth + Game.getItemPrice(item)
	end
	local totalWorth = worth
	for _, item in ipairs(Game.jackpot.otherItems) do
		totalWorth = totalWorth + Game.getItemPrice(item)
	end
	local s = ""
	if 1 < itemCount then
		s = "s"
	end
	playerItemsText.text = itemCount .. " item" .. s .. " worth $" .. formatPrice(worth)
	winChanceText.text = math.floor(Jackpot.getWinChance() * 10000) / 100 .. "% win chance"
end
local function updateJackpotTexts(disableEffects)
	jackpotNumberText.text = "Jackpot #" .. Game.jackpot.id
	local itemCount = Jackpot.getItemCount()
	itemCountText.text = itemCount .. " / 50"
	local worth = 0
	for _, item in ipairs(Game.jackpot.playerItems) do
		worth = worth + Game.getItemPrice(item)
	end
	for _, items in pairs(Game.jackpot.otherItems) do
		for _, item in ipairs(items) do
			worth = worth + Game.getItemPrice(item)
		end
	end
	worthText.text = Lang.jackpot.total .. ": $" .. formatPrice(worth)
	local status = ""
	if Jackpot.getStatus() == 2 then
		status = "won"
		statusText:setFillColor(0, 1, 0)
	elseif Jackpot.getStatus() == 3 then
		status = "lost"
		statusText:setFillColor(unpack(Color.lightText))
	end
	if status == "" then
		if not disableEffects then
			statusText.alpha = 1
			transition.fadeOut(statusText, {time = 500})
			timer.performWithDelay(500, function()
				statusText.text = status
			end)
		else
			statusText.alpha = 0
			statusText.text = status
		end
	else
		statusText.text = status
		if not disableEffects then
			statusText.alpha = 0
			transition.fadeIn(statusText, {time = 500})
		else
			statusText.alpha = 1
		end
	end
end
function itemAddCallback(item)
	if composer.getSceneName("current") ~= "scenes.jackpot" then
		return
	end
	fadeOutGearwheel()
	updatePlayerTexts()
	updateJackpotTexts()
	updateButtons()
	if not item then
		return
	end
	local price = Game.getItemPrice(item)
	GUI.showAnimatedText(nil, "$" .. formatPrice(price), jackpotNumberText.x, jackpotNumberText.y)
	updateImages()
end
function onEnterFrame(event)
	if not animation.started then
		return
	end
end
function scene:create(event)
	local sceneGroup = self.view
	mainGroup = display.newGroup()
	sceneGroup:insert(mainGroup)
	box = GUI.drawMainBox(mainGroup, Lang.menu.jackpot, true)
	circle = display.newCircle(mainGroup, getCenterX(box), box.y + 90, 275)
	circle.anchorX = 0.5
	circle.anchorY = 0
	circle:setFillColor(rgb(42, 58, 79))
	local fontSize = 63
	if Game.jackpot.id >= 1000 then
		fontSize = 58
	end
	jackpotNumberText = display.newText({
		parent = mainGroup,
		x = getCenterX(box),
		y = circle.y + circle.height / 2 - 85,
		text = "",
		font = Font.counterstrike,
		fontSize = fontSize,
		align = "center"
	})
	jackpotNumberText.anchorX = 0.5
	jackpotNumberText:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(jackpotNumberText)
	itemCountText = display.newText({
		parent = mainGroup,
		x = getCenterX(box),
		y = jackpotNumberText.y + jackpotNumberText.height + 15,
		text = "",
		font = Font.counterstrike,
		fontSize = 72,
		align = "center"
	})
	itemCountText.anchorX = 0.5
	FontOffset.setOffset(itemCountText)
	worthText = display.newText({
		parent = mainGroup,
		x = getCenterX(box),
		y = itemCountText.y + itemCountText.height + 10,
		text = "",
		font = Font.counterstrike,
		fontSize = 53,
		align = "center"
	})
	worthText.anchorX = 0.5
	FontOffset.setOffset(worthText)
	statusText = display.newText({
		parent = mainGroup,
		x = getCenterX(box),
		y = worthText.y + worthText.height + 7,
		text = "",
		font = Font.counterstrike,
		fontSize = 73,
		align = "center"
	})
	statusText.anchorX = 0.5
	FontOffset.setOffset(statusText)
	gearWheel = display.newImageRect(mainGroup, "images/gearwheel2.png", 84, 84)
	gearWheel.x = getCenterX(box)
	gearWheel.y = circle.y + circle.height - 90
	gearWheel.anchorX = 0.5
	gearWheel.anchorY = 0.5
	gearWheel:addEventListener("tap", function()
		if gearWheel.alpha < 1 then
			return
		end
		mainGroup.alpha = 0
		optionsGroup.alpha = 1
	end)
	local yourItems = display.newText({
		parent = mainGroup,
		x = getCenterX(box),
		y = circle.y + circle.height + 80,
		text = Lang.jackpot.youritems .. ":",
		font = Font.counterstrike,
		fontSize = 72,
		align = "center"
	})
	yourItems.anchorX = 0.5
	yourItems:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(yourItems)
	playerItemsText = display.newText({
		parent = mainGroup,
		x = getCenterX(box),
		y = yourItems.y + yourItems.height + 20,
		text = "",
		font = Font.counterstrike,
		fontSize = 62,
		align = "center"
	})
	playerItemsText.anchorX = 0.5
	playerItemsText:setFillColor(unpack(Color.white))
	FontOffset.setOffset(playerItemsText)
	winChanceText = display.newText({
		parent = mainGroup,
		x = getCenterX(box),
		y = playerItemsText.y + playerItemsText.height + 20,
		text = "",
		font = Font.counterstrike,
		fontSize = 52,
		align = "center"
	})
	winChanceText.anchorX = 0.5
	winChanceText:setFillColor(unpack(Color.white))
	FontOffset.setOffset(winChanceText)
	local smallButtonWidth = box.width * 0.35 - 5
	addItemsButton = GUI.createButton(mainGroup, box.x + box.width * 0.5 - smallButtonWidth - 5, winChanceText.y + winChanceText.height + 40, smallButtonWidth, 100, Lang.jackpot.additems, ButtonType.default, function()
		composer.gotoScene("scenes.itemselection", {
			params = {
				type = ItemSelection.jackpot
			}
		})
	end, 60)
	viewItemsButton = GUI.createButton(mainGroup, box.x + box.width * 0.5 + 5, winChanceText.y + winChanceText.height + 40, smallButtonWidth, 100, Lang.jackpot.itemlist, ButtonType.default, function()
		local itemList = Jackpot.getItems()
		composer.showOverlay("scenes.jackpotitemlist")
	end, 60)
	startButton = GUI.createButton(mainGroup, box.x + box.width * 0.5 - box.width * 0.35, winChanceText.y + winChanceText.height + 150, box.width * 0.7, 100, Lang.jackpot.startjackpot .. "!", ButtonType.purple, function()
		Jackpot.start(itemAddCallback)
		updateButtons()
	end, 60, {blockTime = 500})
	stopButton = GUI.createButton(mainGroup, box.x + box.width * 0.5 - box.width * 0.35, winChanceText.y + winChanceText.height + 40, box.width * 0.7, 210, Lang.jackpot.stopjackpot, ButtonType.purple, function()
		if Jackpot.getItemCount() >= 49 then
			return
		end
		Jackpot.stop()
		updateButtons()
	end, 60, {blockTime = 500})
	stopButton.alpha = 0
	checkButton = GUI.createButton(mainGroup, box.x + box.width * 0.5 - box.width * 0.35, winChanceText.y + winChanceText.height + 40, box.width * 0.7, 210, Lang.jackpot.check, ButtonType.pink, function()
		checkButton.alpha = 0
		Jackpot.check()
	end, 90, {blockTime = 800})
	checkButton.alpha = 0
	newJackpotButton = GUI.createButton(mainGroup, box.x + box.width * 0.5 - box.width * 0.35, winChanceText.y + winChanceText.height + 40, box.width * 0.7, 210, Lang.jackpot.newjackpot, ButtonType.purple, function()
		Jackpot.new()
		updatePlayerTexts()
		updateJackpotTexts()
		updateImages()
		updateButtons()
	end, 60)
	newJackpotButton.alpha = 0
	optionsGroup = display.newGroup()
	optionsGroup.alpha = 0
	sceneGroup:insert(optionsGroup)
	local optionsBox = GUI.drawMainBox(optionsGroup, Lang.jackpot.jackpotsettings, true)
	local lastY = optionsBox.y + optionsBox.height / 2 - 400
	local jackpotSettingsText = display.newText({
		parent = optionsGroup,
		x = getCenterX(optionsBox),
		y = lastY,
		width = optionsBox.width,
		text = Lang.jackpot.jackpotsettings,
		font = Font.counterstrike,
		fontSize = 92,
		align = "center"
	})
	jackpotSettingsText.anchorX = 0.5
	jackpotSettingsText:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(jackpotSettingsText)
	lastY = lastY + jackpotSettingsText.height + 50
	local optionsText = display.newText({
		parent = optionsGroup,
		x = getCenterX(optionsBox),
		y = lastY,
		width = optionsBox.width,
		text = Lang.jackpot.skinprices .. ":",
		font = Font.counterstrike,
		fontSize = 62,
		align = "center"
	})
	optionsText.anchorX = 0.5
	optionsText:setFillColor(unpack(Color.white))
	FontOffset.setOffset(optionsText)
	lastY = lastY + optionsText.height + 20
	local sliderTexts = {}
	for i = 1, #Jackpot.difficulties do
		table.insert(sliderTexts, Jackpot.difficulties[i].name)
	end
	difficultySlider = TextSlider.create(optionsGroup, box.x + 100, lastY, box.width - 200, 110, sliderTexts, function(text)
		if Jackpot.isStarted() then
			return
		end
		actualText = text
		Game.jackpot.type = difficultySlider:getTextId()
		updateSettingsTexts()
	end)
	difficultySlider:setText(actualText)
	lastY = lastY + 150
	priceRangeText = display.newText({
		parent = optionsGroup,
		x = getCenterX(optionsBox),
		y = lastY,
		width = optionsBox.width - 50,
		text = "",
		font = Font.default,
		fontSize = 48,
		align = "center"
	})
	priceRangeText.anchorX = 0.5
	priceRangeText:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(priceRangeText)
	lastY = lastY + 90
	local jackpotModeText = display.newText({
		parent = optionsGroup,
		x = getCenterX(optionsBox),
		y = lastY,
		width = optionsBox.width,
		text = Lang.jackpot.jackpottype .. ":",
		font = Font.counterstrike,
		fontSize = 62,
		align = "center"
	})
	jackpotModeText.anchorX = 0.5
	FontOffset.setOffset(jackpotModeText)
	lastY = lastY + jackpotModeText.height + 20
	local modeSlider
	modeSlider = TextSlider.create(optionsGroup, box.x + 100, lastY, box.width - 200, 110, jackpotModeTexts, function(text)
		if Jackpot.isStarted() then
			return
		end
		actualModeText = text
		Game.jackpot.mode = modeSlider:getTextId()
	end, 72)
	modeSlider:setText(actualModeText)
	lastY = lastY + 175
	local backButton = GUI.createButton(optionsGroup, optionsBox.width * 0.6, lastY, optionsBox.width * 0.5, 120, Lang.common.back, ButtonType.blue, function()
		mainGroup.alpha = 1
		optionsGroup.alpha = 0
	end, 60)
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
		updateImages()
		updatePlayerTexts()
		updateJackpotTexts(true)
		updateButtons()
		if Jackpot.getItemCount() > 0 and Jackpot.getStatus() <= 1 then
			gearWheel.alpha = 0
		else
			gearWheel.alpha = 1
		end
		updateSettingsTexts()
		if 0 < #Game.jackpot.otherItems then
			Game.jackpot.otherItems = {}
			Game.save()
		end
	elseif phase == "did" then
		Runtime:addEventListener("enterFrame", onEnterFrame)
	end
end
function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Runtime:removeEventListener("enterFrame", onEnterFrame)
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
