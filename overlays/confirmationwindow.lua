local composer = require("composer")
local scene = composer.newScene()
function scene:create(event)
	local sceneGroup = self.view
	local params = event.params
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	if event.params.overlay then
		background:setFillColor(0, 0, 0, 0.7)
	else
		background:setFillColor(0, 0, 0, 0.2)
	end
	local mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.05, display.safeActualContentHeight * 0.25, display.safeActualContentWidth * 0.9, display.safeActualContentHeight * 0.5, params.boxName)
	mainBox:setFillColor(rgb(22, 30, 40))
	local mainText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = getCenterY(mainBox) - 200,
		text = params.text,
		font = Font.counterstrike,
		width = display.safeActualContentWidth * 0.8,
		fontSize = 72,
		align = "center"
	})
	mainText.anchorX = 0.5
	GUI.createButton(sceneGroup, getCenterX(mainBox) - 580, mainText.y + 200, 480, 140, Lang.common.yes, ButtonType.green, function()
		if params.overlay then
			composer.hideOverlay()
		end
		params.yesButtonCallback()
	end, 60)
	GUI.createButton(sceneGroup, getCenterX(mainBox) + 100, mainText.y + 200, 480, 140, Lang.common.no, ButtonType.red, function()
		if params.overlay then
			composer.hideOverlay()
		end
		params.noButtonCallback()
	end, 60)
	FontOffset.setOffset(mainText)
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		if not event.params.overlay then
			Menu.hide()
		end
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
