local composer = require("composer")
local scene = composer.newScene()
local items = {}
local itemsPrice = 0
function scene:create(event)
	local sceneGroup = self.view
	local params = event.params
	items = params.items
	for _, itemId in pairs(items) do
		itemsPrice = itemsPrice + Game.getPrice(Game.equipment[itemId])
	end
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.6)
	background:addEventListener("touch", function()
		return true
	end)
	background:addEventListener("tap", function()
		return true
	end)
	local mainBoxHeight = 0.45
	local mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.05, display.safeActualContentHeight * ((1 - mainBoxHeight) / 2), display.safeActualContentWidth * 0.9, display.safeActualContentHeight * mainBoxHeight, Lang.sellConfirmation.confirm)
	local fontSize = 72
	local firstText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = mainBox.y + mainBox.height * 0.2,
		text = Lang.sellConfirmation.question,
		font = Font.counterstrike,
		fontSize = fontSize,
		align = "center"
	})
	firstText.anchorX = 0.5
	FontOffset.setOffset(firstText)
	local secondText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = firstText.y + firstText.height + 13,
		text = #items .. " items",
		font = Font.counterstrike,
		fontSize = fontSize,
		align = "center"
	})
	secondText.anchorX = 0.5
	secondText:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(secondText)
	local thirdText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = secondText.y + secondText.height + 13,
		text = Lang.sellConfirmation.forr .. " $" .. formatPrice(itemsPrice) .. "?",
		font = Font.counterstrike,
		fontSize = fontSize,
		align = "center"
	})
	thirdText.anchorX = 0.5
	FontOffset.setOffset(thirdText)
	local buttonY = mainBox.y + mainBox.height - 150
	local yesButton = Button.create(sceneGroup, mainBox.x + mainBox.width * 0.1 - 10, buttonY, mainBox.width * 0.4, 110, Lang.common.yes, ButtonType.green, function(event)
		local itemCount = #items
		for _, item in ipairs(items) do
			Game.internalSellSkin(Game.equipment[item], item)
		end
		items = {}
		if params.callback then
			params.callback(true)
		end
		composer.hideOverlay()
		GUI.showMessageBox("Success!", itemCount .. " items have been sold!")
	end, {fontSize = 70, blockTime = 500})
	local noButton = Button.create(sceneGroup, mainBox.x + mainBox.width * 0.5 + 10, buttonY, mainBox.width * 0.4, 110, Lang.common.no, ButtonType.red, function(event)
		composer.hideOverlay()
		showingOverlay = false
		if params.callback then
			params.callback(false)
		end
	end, {fontSize = 70})
	sceneGroup:toFront()
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
	elseif phase == "did" then
		composer.removeScene("overlays.massitemssell")
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
