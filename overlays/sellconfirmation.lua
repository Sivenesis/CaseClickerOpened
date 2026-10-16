local composer = require("composer")
local scene = composer.newScene()
function scene:create(event)
	local sceneGroup = self.view
	local params = event.params
	local item = params.item
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
	if params.item then
		local name = "Unnamed"
		if item.name then
			name = item.name
		elseif item.id then
			if item.type == Item.sticker then
				name = Game.stickers[item.id].name
			else
				name = Game.skins[item.id].name
			end
		end
		local sellPrice = 0
		if item.sellPrice then
			sellPrice = item.sellPrice
		else
			sellPrice = Game.getPrice(item)
		end
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
			text = name,
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
			text = Lang.sellConfirmation.forr .. " $" .. formatPrice(sellPrice) .. "?",
			font = Font.counterstrike,
			fontSize = fontSize,
			align = "center"
		})
		thirdText.anchorX = 0.5
		FontOffset.setOffset(thirdText)
	else
		local text = display.newText({
			parent = sceneGroup,
			x = getCenterX(mainBox),
			y = mainBox.y + mainBox.height * 0.5 - 75,
			width = mainBox.width * 0.9,
			text = params.text,
			font = Font.counterstrike,
			fontSize = fontSize,
			align = "center"
		})
		text.anchorX = 0.5
		text.anchorY = 0.5
		FontOffset.setOffset(text)
	end
	local buttonY = mainBox.y + mainBox.height - 150
	local yesButton = GUI.createButton(sceneGroup, mainBox.x + mainBox.width * 0.1 - 10, buttonY, mainBox.width * 0.4, 110, Lang.common.yes, ButtonType.green, function(event)
		if params.item then
			if item.type == Item.case then
				Game.internalSellCase(item.id)
				composer.gotoScene("scenes.cases")
			elseif item.type == Item.sticker then
				Game.internalSellSticker(item, params.entryId)
				composer.hideOverlay("fade", 300)
				showingOverlay = false
			elseif item.type == Item.collection then
				Game.internalSellCollection(item.id)
				composer.gotoScene("scenes.cases")
			elseif item.type == Item.souvenir then
				Game.internalSellSouvenir(item.id)
				composer.gotoScene("scenes.cases")
			elseif params.entryId then
				Game.internalSellSkin(item, params.entryId)
				composer.hideOverlay("fade", 300)
				showingOverlay = false
			elseif item.type == Item.capsule then
				Game.internalSellCapsule(item.id)
				composer.gotoScene("scenes.cases")
			end
		end
		if params.callback then
			params.callback(true)
		end
	end, 70)
	local noButton = GUI.createButton(sceneGroup, mainBox.x + mainBox.width * 0.5 + 10, buttonY, mainBox.width * 0.4, 110, Lang.common.no, ButtonType.red, function(event)
		composer.hideOverlay("fade", 300)
		showingOverlay = false
		if params.callback then
			params.callback(false)
		end
	end, 70)
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
		composer.removeScene("overlays.sellconfirmation")
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
