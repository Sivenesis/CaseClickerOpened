local scene = composer.newScene()
local textInput, titleText
local item = 0
local drawMainBox = function(sceneGroup)
	mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.1, display.safeActualContentHeight * 0.15, display.safeActualContentWidth * 0.8, display.safeActualContentHeight * 0.5, "NetHub nick change")
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
		y = mainBox.y + 90,
		text = Lang.nametag.enterNewName .. ":",
		font = Font.counterstrike,
		fontSize = 92,
		align = "center"
	})
	titleText.anchorX = 0.5
	FontOffset.setOffset(titleText)
	textInput = native.newTextField(titleText.x - 300, titleText.y + titleText.height + 50, 600, 75)
	textInput:setReturnKey("done")
	textInput:addEventListener("userInput", function(event)
		if event.phase == "submitted" or event.phase == "ended" then
			native.setKeyboardFocus(nil)
		end
	end)
	GUI.createButton(sceneGroup, getCenterX(mainBox) + 10, textInput.y + textInput.height + 60, 500, 130, "Change name", ButtonType.green, function()
		local text = textInput.text
		NetHub.changeName(text, function()
			if event.params and event.params.successCallback then
				event.params.successCallback()
			end
			composer.hideOverlay()
		end)
	end, 60)
	GUI.createButton(sceneGroup, getCenterX(mainBox) - 510, textInput.y + textInput.height + 60, 500, 130, Lang.common.cancel, ButtonType.red, function()
		composer.hideOverlay()
	end, 60)
	textInput.text = NetHub.getNickname()
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
		if textInput then
			textInput:removeSelf()
		end
	elseif phase == "did" then
		composer.removeScene("overlays.nethubrename")
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
