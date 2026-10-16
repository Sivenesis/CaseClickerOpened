local scene = composer.newScene()
local textInput, titleText, createCallback
local drawMainBox = function(sceneGroup)
	mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.1, display.safeActualContentHeight * 0.2, display.safeActualContentWidth * 0.8, display.safeActualContentHeight * 0.45, "New category")
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
		text = "Please enter name for the new category:",
		font = Font.counterstrike,
		fontSize = 66,
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
	GUI.createButton(sceneGroup, getCenterX(mainBox) + 10, textInput.y + textInput.height + 60, 500, 130, "Create", ButtonType.green, function()
		local text = textInput.text
		local success, str = EquipmentManager.validateCategoryName(text)
		if not success then
			return GUI.showMessageBox(Lang.common.error, str, true, function()
				timer.performWithDelay(50, function()
					composer.showOverlay("overlays.categoryrename", {
						params = {inputText = text, createCallback = createCallback}
					})
				end)
			end)
		end
		table.insert(Game.equipmentCategories, {name = text})
		if createCallback then
			createCallback()
		end
		composer.hideOverlay()
	end, 60)
	GUI.createButton(sceneGroup, getCenterX(mainBox) - 510, textInput.y + textInput.height + 60, 500, 130, Lang.common.cancel, ButtonType.red, function()
		composer.hideOverlay()
	end, 60)
	textInput.text = event.params.inputText or ""
	createCallback = event.params.createCallback
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
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
