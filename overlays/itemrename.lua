local scene = composer.newScene()
local textInput, titleText
local item = 0
local drawMainBox = function(sceneGroup)
	mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.1, display.safeActualContentHeight * 0.15, display.safeActualContentWidth * 0.8, display.safeActualContentHeight * 0.5, "Weapon Name Tag")
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
	Button.create(sceneGroup, getCenterX(mainBox) + 10, textInput.y + textInput.height + 60, 500, 130, Lang.nametag.renameItem, ButtonType.green, function()
		local text = textInput.text
		GUI.showMessageBox(Lang.nametag.renaming, Lang.common.pleaseWait .. "...", false)
		timer.performWithDelay(500, function()
			local success, str = EquipmentManager.validateName(text)
			if not success and not textInput.text == "" then
				return GUI.showMessageBox(Lang.common.error, str, true, function()
					timer.performWithDelay(50, function()
						composer.showOverlay("overlays.itemrename", {
							params = {item = item, inputText = text}
						})
					end)
				end)
			end
			if textInput.text == "" then
				Game.equipment[item].n = nil
			else
				Game.equipment[item].n = text
			end
			Game.removeMoney(50, "Shop", "Name Tag")
			composer.gotoScene("scenes.shop")
			timer.performWithDelay(50, function()
				GUI.showMessageBox(Lang.common.success, Lang.nametag.renameMsg)
			end)
		end)
	end, {fontSize = 60, blockTime = 400})
	Button.create(sceneGroup, getCenterX(mainBox) - 510, textInput.y + textInput.height + 60, 500, 130, Lang.common.cancel, ButtonType.red, function()
		composer.hideOverlay()
	end, {fontSize = 60})
	item = event.params.item
	local equipmentItem = Game.equipment[item]
	local inputText = ""
	if equipmentItem.n then
		inputText = equipmentItem.n
	else
		local strings = string.explode(equipmentItem.name, " | ")
		if strings[2] then
			inputText = strings[2]
		end
	end
	textInput.text = event.params.inputText or inputText
end
function scene:show(event)
	local phase = event.phase
	if phase == "will" then
		Game.showingOverlay = true
	elseif phase == "did" then
	end
end
function scene:hide(event)
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
