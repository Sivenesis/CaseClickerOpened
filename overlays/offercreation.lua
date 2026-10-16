local composer = require("composer")
local scene = composer.newScene()
local drawMainBox = function(sceneGroup, title)
	local boxWidthMultiplier = 0.8
	local boxHeightMultiplier = 0.58
	mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * (1 - boxWidthMultiplier) / 2, display.safeActualContentHeight * (1 - boxHeightMultiplier) / 2, display.safeActualContentWidth * boxWidthMultiplier, display.safeActualContentHeight * boxHeightMultiplier, title)
	mainBox:setFillColor(unpack(Color.row))
	return mainBox
end
function scene:create(event)
	local sceneGroup = self.view
	local params = event.params
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.8)
	background:addEventListener("touch", function()
		return true
	end)
	background:addEventListener("tap", function()
		return true
	end)
	local mainBox = drawMainBox(sceneGroup, "Guild Creation")
	local offeringText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = mainBox.y + 40,
		text = "What items are you offering?",
		font = Font.main,
		fontSize = 62,
		align = "center"
	})
	offeringText.anchorX = 0.5
	offeringText:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(offeringText)
	local offeringTextInput = TextInput.create(sceneGroup, getCenterX(mainBox) - mainBox.width * 0.325, offeringText.y + 110, mainBox.width * 0.65, 75, Game.others.lastMarketOffer.offering or "", {
		placeholder = "AWP Dragon Lore FN ST",
		validator = Market.offerValidator
	})
	local receivingText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = offeringTextInput.y + offeringTextInput.height + 70,
		text = "What do you want in return?",
		font = Font.main,
		fontSize = 62,
		align = "center"
	})
	receivingText.anchorX = 0.5
	receivingText:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(receivingText)
	local receivingTextInput = TextInput.create(sceneGroup, getCenterX(mainBox) - mainBox.width * 0.325, receivingText.y + 110, mainBox.width * 0.65, 75, Game.others.lastMarketOffer.receiving or "", {
		placeholder = "Anything!",
		validator = Market.offerValidator
	})
	local createButton = Button.create(sceneGroup, getCenterX(mainBox) - mainBox.width * 0.35 - 10, mainBox.y + mainBox.height - 120 - 20, mainBox.width * 0.35, 120, "Create Offer", ButtonType.green, function(event)
		if not offeringTextInput:validate() or not receivingTextInput:validate() then
			return false
		end
		GUI.showMessageBox("Creating offer", "Please wait...", false)
		timer.performWithDelay(33, function()
			Market.addOffer({
				offering = offeringTextInput:getText(),
				receiving = receivingTextInput:getText()
			}, function(success, data)
				if not success then
					return GUI.showMessageBox("Error", data)
				end
				composer.hideOverlay("fade", 300)
				params.successCallback()
				return true
			end)
			return true
		end)
	end, {fontSize = 46})
	local backButton = Button.create(sceneGroup, getCenterX(mainBox) + 10, mainBox.y + mainBox.height - 120 - 20, mainBox.width * 0.35, 120, "Back", ButtonType.default, function(event)
		composer.hideOverlay("fade", 300)
	end, {fontSize = 46, blockTime = 250})
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
	elseif phase == "did" then
	end
end
function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
