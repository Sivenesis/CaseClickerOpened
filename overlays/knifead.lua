local composer = require("composer")
local scene = composer.newScene()
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
	local widthMultiplier = 0.75
	local heightMultiplier = 0.75
	local mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * (1 - widthMultiplier) / 2, display.safeActualContentHeight * (1 - heightMultiplier) / 2, display.safeActualContentWidth * widthMultiplier, display.safeActualContentHeight * heightMultiplier, "Buy knife!")
	mainBox:setFillColor(rgb(22, 30, 40))
	local image = display.newImageRect(sceneGroup, "images/knifead.jpg", mainBox.width, mainBox.height - 120)
	image.x = mainBox.x
	image.y = mainBox.y
	GUI.createButton(sceneGroup, getCenterX(mainBox) - mainBox.width / 2, mainBox.y + mainBox.height - 120, mainBox.width, 120, "Ok", ButtonType.green, function()
		composer.hideOverlay()
	end, 60)
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
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
