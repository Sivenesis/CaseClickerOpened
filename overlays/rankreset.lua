local composer = require("composer")
local scene = composer.newScene()
function scene:create(event)
	local sceneGroup = self.view
	local params = event.params
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.8)
	local mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.05, display.safeActualContentHeight * 0.25, display.safeActualContentWidth * 0.9, display.safeActualContentHeight * 0.5, "Rank Reset")
	mainBox:setFillColor(rgb(22, 30, 40))
	local mainText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = getCenterY(mainBox) - 200,
		text = Lang.rankReset.question .. "?",
		font = Font.counterstrike,
		width = display.safeActualContentWidth * 0.8,
		fontSize = 66,
		align = "center"
	})
	mainText.anchorX = 0.5
	FontOffset.setOffset(mainText)
	local text = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = mainText.y + mainText.height + 50,
		text = Lang.rankReset.additionalMoneyPerMission .. ":",
		font = Font.counterstrike,
		width = display.safeActualContentWidth * 0.8,
		fontSize = 56,
		align = "center"
	})
	text.anchorX = 0.5
	FontOffset.setOffset(text)
	text = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = text.y + text.height + 30,
		text = "$" .. formatPrice(6 * Game.others.expResets) .. " @> " .. "$" .. formatPrice(6 * (Game.others.expResets + 1)),
		font = Font.counterstrike,
		width = display.safeActualContentWidth * 0.8,
		fontSize = 80,
		align = "center"
	})
	text.anchorX = 0.5
	FontOffset.setOffset(text)
	text:setFillColor(unpack(Color.gold))
	GUI.createButton(sceneGroup, getCenterX(mainBox) - 580, mainBox.y + mainBox.height - 180, 480, 140, Lang.common.yes, ButtonType.green, function()
		Game.others.expResets = Game.others.expResets + 1
		Game.expRank = 1
		Game.experience = 0
		composer.hideOverlay()
		params.yesButtonCallback()
	end, 60)
	GUI.createButton(sceneGroup, getCenterX(mainBox) + 100, mainBox.y + mainBox.height - 180, 480, 140, Lang.common.no, ButtonType.red, function()
		composer.hideOverlay()
		params.noButtonCallback()
	end, 60)
end
scene:addEventListener("create", scene)
return scene
