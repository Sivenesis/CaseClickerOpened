local scene = composer.newScene()
local textInput, titleText, text, statusText, afterOkButton, beforeGroup, afterGroup
local function hideBeforeGroup()
	if textInput then
		textInput:removeSelf()
		textInput = nil
	end
	beforeGroup.alpha = 0
	afterGroup.alpha = 1
end
local function showBeforeGroup()
	if not textInput then
		native.newTextField(titleText.x - 300, text.y + text.height + 50, 600, 75)
	end
	beforeGroup.alpha = 1
	afterGroup.alpha = 0
end
local drawMainBox = function(sceneGroup)
	mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.07, display.safeActualContentHeight * 0.1, display.safeActualContentWidth * 0.86, display.safeActualContentHeight * 0.55, Lang.tradeCreation.creatingNewTrade)
	mainBox:setFillColor(rgb(22, 30, 40))
	return mainBox
end
function scene:create(event)
	local sceneGroup = self.view
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.8)
	background:addEventListener("touch", function()
		return true
	end)
	background:addEventListener("tap", function()
		return true
	end)
	local mainBox = drawMainBox(sceneGroup)
	titleText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = mainBox.y + 50,
		text = Lang.tradeCreation.newTrade,
		font = Font.counterstrike,
		fontSize = 99,
		align = "center"
	})
	titleText.anchorX = 0.5
	FontOffset.setOffset(titleText)
	beforeGroup = display.newGroup()
	textInput = native.newTextField(titleText.x - 300, titleText.y + titleText.height + 40, 600, 75)
	textInput:setReturnKey("done")
	textInput:addEventListener("userInput", function(event)
		if event.phase == "submitted" or event.phase == "ended" then
			native.setKeyboardFocus(nil)
		end
	end)
	text = display.newText({
		parent = beforeGroup,
		x = titleText.x,
		y = textInput.y + textInput.height + 60,
		width = mainBox.width - 150,
		height = 200,
		text = Lang.tradeCreation.enterName .. ".",
		font = Font.default,
		fontSize = 65,
		align = "center"
	})
	text.anchorX = 0.5
	text:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(text)
	GUI.createButton(beforeGroup, getCenterX(mainBox) + 10, text.y + text.height + 30, 500, 110, Lang.common.ok, ButtonType.green, function()
		local text = textInput.text
		hideBeforeGroup()
		NetHub.createTrade(text, function(success, output)
			if not success then
				local text = Lang.common.connectionFailed
				if output and output.text then
					text = output.text
				end
				statusText.text = text
			elseif output.trade then
				NetHub.cache.trades[output.trade.id] = output.trade
				NetHub.loadTrade(output.trade.id, true)
				Analytics.addEvent("Trade:Create")
			else
				statusText.text = output.text
			end
			afterOkButton.alpha = 1
		end)
	end, 60)
	GUI.createButton(beforeGroup, getCenterX(mainBox) - 510, text.y + text.height + 30, 500, 110, Lang.common.cancel, ButtonType.red, function()
		composer.gotoScene("scenes.nethub.trades", {
			params = {loadFromCache = true}
		})
	end, 60)
	afterGroup = display.newGroup()
	statusText = display.newText({
		parent = afterGroup,
		x = titleText.x,
		y = text.y,
		width = mainBox.width - 150,
		height = 200,
		text = Lang.tradeCreation.connecting .. "...",
		font = Font.default,
		fontSize = 72,
		align = "center"
	})
	statusText.anchorX = 0.5
	statusText:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(statusText)
	afterOkButton = GUI.createButton(afterGroup, getCenterX(mainBox) - 400, text.y + text.height + 30, 800, 110, Lang.common.ok, ButtonType.green, function()
		hideBeforeGroup()
		composer.gotoScene("scenes.nethub.trades")
	end, 60)
	afterOkButton.alpha = 0
	afterGroup.alpha = 0
	sceneGroup:insert(beforeGroup)
	sceneGroup:insert(afterGroup)
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Game.showingOverlay = true
	elseif phase == "did" then
	end
end
function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Game.showingOverlay = false
		hideBeforeGroup()
	elseif phase == "did" then
		composer.removeScene("overlays.tradecreation")
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
