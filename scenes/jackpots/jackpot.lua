local widget = require("widget")
local ProgressBar = require("gui.progressbar")
local scene = composer.newScene()
local sceneGroup, mainBox, circle, jackpotOverlay
local jackpotImages = {}
local circleTexts = {}
local summaryTexts = {}
local chanceProgressBar, addItemsButton, checkButton, exitButton, restartButton
local loading = false
local statusText, roomIdText
local function updateRoomIdText()
	roomIdText.text = "Jackpot #" .. commaValue(tonumber(OnlineJackpots.room.uid))
end
local function updateImages()
	for i = 0, 50 do
		if jackpotImages[i] then
			jackpotImages[i].alpha = 0
		end
	end
	local itemCount = math.round(OnlineJackpots.getItemCount() / OnlineJackpots.getItemLimit() * 50)
	if 50 < itemCount then
		itemCount = 50
	end
	if not jackpotImages[itemCount] then
		jackpotImages[itemCount] = display.newImageRect(sceneGroup, "images/jackpot/jackpot_" .. itemCount .. ".png", circle.width + 78, circle.width + 78)
		jackpotImages[itemCount].alpha = 0
		jackpotImages[itemCount].anchorX = 0.5
		jackpotImages[itemCount].anchorY = 0.5
		jackpotImages[itemCount].x = circle.x
		jackpotImages[itemCount].y = circle.y + circle.height / 2
	end
	jackpotImages[itemCount].alpha = 1
	if not jackpotOverlay then
		jackpotOverlay = display.newImageRect(sceneGroup, "images/jackpot/overlay.png", circle.width + 75, circle.width + 75)
		jackpotOverlay.anchorX = 0.5
		jackpotOverlay.anchorY = 0.5
		jackpotOverlay.x = circle.x
		jackpotOverlay.y = circle.y + circle.height / 2
	end
	jackpotOverlay:toFront()
end
local lastTime = 0
local function updateSecondCounter()
	if composer.getSceneName("current") ~= "scenes.jackpots.jackpot" then
		return
	end
	if OnlineJackpots.checked or loading then
		return
	end
	if os.time() - lastTime > 20 then
		os.exit()
	end
	lastTime = os.time()
	local secondsLeft = OnlineJackpots.getTimeLeft()
	local second = Lang.onlineJackpots.second
	if secondsLeft ~= 1 then
		second = Lang.onlineJackpots.seconds
	end
	if (secondsLeft <= 0 or 10 <= secondsLeft) and (OnlineJackpots.winner or OnlineJackpots.checked) then
		circleTexts[2].text = Lang.onlineJackpots.finished .. "!"
	else
		circleTexts[2].text = secondsLeft .. " " .. second
	end
	if (secondsLeft <= 0 or 10 <= secondsLeft) and OnlineJackpots.winner and not OnlineJackpots.checked then
		checkButton.alpha = 1
		addItemsButton.alpha = 0
		exitButton.alpha = 0
		return
	end
	if secondsLeft <= 0 then
		local win = math.random(1, 1000) <= OnlineJackpots.getWinChance() * 10
		if win then
			OnlineJackpots.winner = OnlineJackpots.playerId
		else
			local playerList = {}
			for playerId, _ in pairs(OnlineJackpots.room.players) do
				table.insert(playerList, playerId)
			end
			while true do
				OnlineJackpots.winner = choose(playerList)
				if OnlineJackpots.winner ~= OnlineJackpots.playerId then
					break
				end
			end
		end
	end
	timer.performWithDelay(1000, updateSecondCounter)
end
local function updateCircleTexts()
	circleTexts[1].text = OnlineJackpots.getItemCount() .. " / " .. OnlineJackpots.getItemLimit()
	updateSecondCounter()
	circleTexts[3].text = Lang.onlineJackpots.total .. ": $" .. formatPrice(OnlineJackpots.getItemsWorth())
end
local function updateSummaryTexts()
	summaryTexts[1][2].text = OnlineJackpots.getItemCount()
	summaryTexts[2][2].text = OnlineJackpots.getPlayingPlayers()
	local itemString = Lang.itemSelection.itemsWorth
	if #OnlineJackpots.getPlayerItems() == 1 then
		itemString = Lang.itemSelection.itemWorth
	end
	summaryTexts[3][2].text = #OnlineJackpots.getPlayerItems() .. " " .. itemString .. " $" .. formatPrice(OnlineJackpots.getItemsWorth(true))
	chanceProgressBar:setProgress(OnlineJackpots.getWinChance())
	chanceProgressBar:setText(formatPrice(OnlineJackpots.getWinChance()) .. "%")
end
function scene:create(event)
	sceneGroup = self.view
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.6)
	mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.01, display.safeActualContentHeight * 0.01, display.safeActualContentWidth * 0.98, display.safeActualContentHeight * 0.98, "")
	roomIdText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = mainBox.y - 28,
		text = "",
		font = Font.counterstrike,
		fontSize = 35
	})
	roomIdText.anchorX = 1
	roomIdText.anchorY = 0.5
	roomIdText:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(roomIdText)
	updateRoomIdText()
	circle = display.newCircle(sceneGroup, mainBox.x + mainBox.height * 0.4, mainBox.y + mainBox.height * 0.1, mainBox.height * 0.32)
	circle.anchorX = 0.5
	circle.anchorY = 0
	circle:setFillColor(rgb(42, 58, 79))
	updateImages()
	circleTexts[1] = display.newText({
		parent = sceneGroup,
		x = circle.x,
		y = getCenterY(circle) - 90,
		text = "",
		font = Font.counterstrike,
		fontSize = 73,
		align = "center"
	})
	circleTexts[2] = display.newText({
		parent = sceneGroup,
		x = circleTexts[1].x,
		y = getCenterY(circle),
		text = "",
		font = Font.counterstrike,
		fontSize = 96,
		align = "center"
	})
	circleTexts[3] = display.newText({
		parent = sceneGroup,
		x = circleTexts[1].x,
		y = getCenterY(circle) + 90,
		text = "",
		font = Font.counterstrike,
		fontSize = 66,
		align = "center"
	})
	for i = 1, 3 do
		circleTexts[i].anchorX = 0.5
		circleTexts[i].anchorY = 0.5
		FontOffset.setOffset(circleTexts[i])
	end
	lastTime = os.time()
	updateCircleTexts()
	local buttonX = circle.x + circle.width / 2 + (mainBox.width - (circle.x + circle.width / 2)) / 2
	local lastY = circle.y - 40
	local summaryText = display.newText({
		parent = sceneGroup,
		x = buttonX,
		y = lastY,
		text = Lang.onlineJackpots.summary,
		font = Font.counterstrike,
		fontSize = 116,
		align = "center"
	})
	summaryText.anchorX = 0.5
	FontOffset.setOffset(summaryText)
	summaryText:setFillColor(unpack(Color.gold))
	local summaryTextsTexts = {
		Lang.onlineJackpots.itemsInTheJackpot .. ":",
		Lang.onlineJackpots.playersPlaying .. ":"
	}
	local fontSize = 66
	if detectSquareScreen() then
		fontSize = 58
	end
	lastY = lastY + 120
	for i = 1, #summaryTextsTexts do
		summaryTexts[i] = {}
		summaryTexts[i][1] = display.newText({
			parent = sceneGroup,
			x = buttonX + 220,
			y = lastY,
			text = summaryTextsTexts[i],
			font = Font.counterstrike,
			fontSize = fontSize,
			align = "left"
		})
		summaryTexts[i][1].anchorX = 1
		FontOffset.setOffset(summaryTexts[i][1])
		summaryTexts[i][2] = display.newText({
			parent = sceneGroup,
			x = summaryTexts[i][1].x + 15,
			y = lastY,
			text = "",
			font = Font.counterstrike,
			fontSize = fontSize,
			align = "left"
		})
		summaryTexts[i][2].anchorX = 0
		FontOffset.setOffset(summaryTexts[i][2])
		summaryTexts[i][2]:setFillColor(unpack(Color.gold))
		if i == 2 then
			lastY = lastY + 70
		end
		lastY = lastY + 70
	end
	summaryTexts[3] = {}
	summaryTexts[3][1] = display.newText({
		parent = sceneGroup,
		x = buttonX,
		y = lastY,
		text = Lang.onlineJackpots.yourItems .. ":",
		font = Font.counterstrike,
		fontSize = fontSize,
		align = "left"
	})
	summaryTexts[3][1].anchorX = 0.5
	FontOffset.setOffset(summaryTexts[3][1])
	lastY = lastY + 70
	summaryTexts[3][2] = display.newText({
		parent = sceneGroup,
		x = buttonX,
		y = lastY,
		text = "",
		font = Font.counterstrike,
		fontSize = fontSize - 8,
		align = "left"
	})
	summaryTexts[3][2].anchorX = 0.5
	FontOffset.setOffset(summaryTexts[3][2])
	summaryTexts[3][2]:setFillColor(unpack(Color.gold))
	lastY = lastY + 140
	summaryTexts[4] = {}
	summaryTexts[4][1] = display.newText({
		parent = sceneGroup,
		x = buttonX,
		y = lastY,
		text = Lang.onlineJackpots.yourWinChance .. ":",
		font = Font.counterstrike,
		fontSize = 66,
		align = "center"
	})
	summaryTexts[4][1].anchorX = 0.5
	FontOffset.setOffset(summaryTexts[4][1])
	chanceProgressBar = ProgressBar.create(sceneGroup, buttonX, lastY + 70, (mainBox.width - (circle.x + circle.width / 2)) * 0.8, 70, ProgressBarType.default)
	updateSummaryTexts()
	local bottomButtonY = circle.y + circle.height + 90
	local viewItemsButton = GUI.createButton(sceneGroup, circle.x - circle.width * 0.85 / 2, bottomButtonY, circle.width * 0.85, 140, Lang.onlineJackpots.viewItems, ButtonType.purple, function(event)
		composer.showOverlay("overlays.jackpotitems", {effect = "fade", time = 250})
	end, 55)
	exitButton = GUI.createButton(sceneGroup, buttonX - 350, bottomButtonY + 30, 700, 110, Lang.onlineJackpots.exitJackpot, ButtonType.lightblue, function(event)
		if OnlineJackpots.checked then
			RandomSkins.hide()
			composer.gotoScene("scenes.jackpots.roomselection")
		else
			local exitText = "Do you really want to exit from the jackpot?"
			if #OnlineJackpots.getPlayerItems() > 0 then
				exitText = exitText .. " You won't get your items back when you win."
			end
			GUI.showConfirmationWindow("Exit Jackpot", exitText, function()
				OnlineJackpots.exitRoom()
				RandomSkins.hide()
				composer.gotoScene("scenes.jackpots.roomselection")
			end, function()
			end, true)
		end
	end, 55)
	statusText = display.newText({
		parent = sceneGroup,
		x = buttonX,
		y = bottomButtonY + 30 - 140,
		text = "",
		font = Font.counterstrike,
		fontSize = 72,
		align = "center"
	})
	statusText.anchorX = 0.5
	FontOffset.setOffset(statusText)
	statusText:setFillColor(unpack(Color.lightText))
	statusText.alpha = 0
	addItemsButton = GUI.createButton(sceneGroup, buttonX - 350, bottomButtonY + 30 - 130, 700, 110, Lang.onlineJackpots.addItems, ButtonType.green, function(event)
		composer.gotoScene("scenes.itemselection", {
			params = {
				type = ItemSelection.onlineJackpot
			}
		})
	end, 55, {blockTime = 500})
	restartButton = GUI.createButton(sceneGroup, buttonX - 350, bottomButtonY + 30 - 130, 700, 110, Lang.onlineJackpots.restart, ButtonType.green, function(event)
		loading = true
		local actualRoom = OnlineJackpots.room
		OnlineJackpots.checked = false
		OnlineJackpots.winner = nil
		OnlineJackpots.room = {}
		GUI.showMessageBox(Lang.onlineJackpots.joiningRoom, Lang.common.pleaseWait .. "...", false)
		OnlineJackpots.joinRoom(OnlineJackpots.roomType, function(success, str)
			if not success then
				OnlineJackpots.room = actualRoom
				return GUI.showMessageBox(Lang.common.error, str, true, function()
				end)
			end
			loading = false
			composer.gotoScene("scenes.jackpots.jackpot")
			updateRoomIdText()
		end)
	end, 55)
	checkButton = GUI.createButton(sceneGroup, buttonX - 350, bottomButtonY + 30 - 130, 700, 240, Lang.onlineJackpots.check .. "!", ButtonType.green, function(event)
		checkButton.alpha = 0
		OnlineJackpots.check()
	end, 55, {blockTime = 800})
	checkButton.alpha = 0
	OnlineJackpots.setItemsAddCallback(function(items)
		updateImages()
		updateCircleTexts()
		updateSummaryTexts()
		if composer.getSceneName("current") ~= "scenes.jackpots.jackpot" then
			return
		end
		if composer.getSceneName("overlay") and composer.getSceneName("overlay") == "overlays.jackpotitems" and insertNewItemsToJackpotItemList then
			insertNewItemsToJackpotItemList(items)
		else
			for i, item in ipairs(items) do
				local price = Game.getItemPrice(item)
				timer.performWithDelay((i - 1) * 400, function()
					GUI.showAnimatedText(nil, "$" .. formatPrice(price), circleTexts[1].x, circleTexts[1].y)
				end)
			end
		end
	end)
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.hide()
		statusText.alpha = 0
		checkButton.alpha = 0
		addItemsButton.alpha = 0
		exitButton.alpha = 0
		restartButton.alpha = 0
		if OnlineJackpots.checked then
			exitButton.alpha = 1
			restartButton.alpha = 1
			if OnlineJackpots.winner == OnlineJackpots.playerId then
				circleTexts[2].text = Lang.onlineJackpots.youHaveWon .. "!"
			else
				circleTexts[2].text = Lang.onlineJackpots.youHaveLost .. "!"
			end
		elseif OnlineJackpots.winner then
			checkButton.alpha = 1
		else
			addItemsButton.alpha = 1
			exitButton.alpha = 1
		end
	elseif phase == "did" then
		lastTime = os.time()
		timer.performWithDelay(1000, updateSecondCounter)
		updateImages()
		updateCircleTexts()
		updateSummaryTexts()
		OnlineJackpots.registerJackpotEndCallback()
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
