local composer = require("composer")
local scene = composer.newScene()
local drawMainBox = function(sceneGroup, title)
	local widthMultiplier = 0.83
	local heightMultiplier = 0.58
	mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * (1 - widthMultiplier) / 2, display.safeActualContentHeight * (1 - heightMultiplier) / 2, display.safeActualContentWidth * widthMultiplier, display.safeActualContentHeight * heightMultiplier, title)
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
	local mainBox = drawMainBox(sceneGroup, event.params.title)
	local titleText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = getCenterY(mainBox) - 260,
		text = event.params.title,
		font = Font.counterstrike,
		fontSize = 99,
		align = "center"
	})
	titleText.anchorX = 0.5
	FontOffset.setOffset(titleText)
	local text = display.newText({
		parent = sceneGroup,
		x = titleText.x,
		y = titleText.y + 220,
		width = mainBox.width - 100,
		height = 300,
		text = event.params.text,
		font = Font.counterstrike,
		fontSize = 72,
		align = "center"
	})
	text.anchorX = 0.5
	text:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(text)
	if event.params.okButton then
		GUI.createButton(sceneGroup, getCenterX(mainBox) - 240, mainBox.y + mainBox.height - 180, 480, 120, "Ok", ButtonType.green, function()
			if event.params.okButtonCallback then
				event.params.okButtonCallback()
			end
			composer.hideOverlay("fade", 300)
		end, 60)
	end
	if event.params.okButton == false then
		local sheetOptions = {
			width = 128,
			height = 128,
			numFrames = 12
		}
		preloaderSheet = graphics.newImageSheet("images/gui/preloader.png", sheetOptions)
		sequenceData = {
			name = "explosion",
			start = 1,
			count = 11,
			time = 700,
			loopCount = 0,
			loopDirection = "forward"
		}
		local preloader = display.newSprite(sceneGroup, preloaderSheet, sequenceData)
		preloader.anchorX = 0.5
		preloader.anchorY = 0.5
		preloader.x = mainBox.x + mainBox.width / 2
		preloader.y = mainBox.y + mainBox.height - 200
		preloader:play()
	end
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
