local scene = composer.newScene()
local titleText
local drawMainBox = function(sceneGroup, title)
	mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.1, display.safeActualContentHeight * 0.2, display.safeActualContentWidth * 0.8, display.safeActualContentHeight * 0.45, title)
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
	local mainBox = drawMainBox(sceneGroup, params.title or "")
	titleText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = mainBox.y + 70,
		text = params.text,
		font = Font.main,
		fontSize = 66,
		align = "center"
	})
	titleText.anchorX = 0.5
	FontOffset.setOffset(titleText)
	local textInput = TextInput.create(sceneGroup, titleText.x - 300, titleText.y + titleText.height + 20, 600, 75, event.params.inputText or "", {
		validator = event.params.validator
	})
	Button.create(sceneGroup, getCenterX(mainBox) + 10, textInput.y + textInput.height + 80, 500, 130, event.params.buttonText or "Create", ButtonType.green, function()
		local text = textInput:getText()
		if not textInput:validate() then
			return false
		end
		composer.hideOverlay("fade", 300)
		if params.callback then
			params.callback(text)
		end
	end, {fontSize = 50})
	Button.create(sceneGroup, getCenterX(mainBox) - 510, textInput.y + textInput.height + 80, 500, 130, "Cancel", ButtonType.red, function()
		composer.hideOverlay("fade", 300)
	end, {fontSize = 50})
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
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
