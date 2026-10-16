local composer = require("composer")
local scene = composer.newScene()
local drawMainBox = function(sceneGroup)
	mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth / 2 - 600, display.safeActualContentHeight * 0.05, 1200, display.safeActualContentHeight * 0.9, Lang.qrCode.qrCode)
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
	local titleText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = mainBox.y + 40,
		text = event.params.title,
		font = Font.counterstrike,
		fontSize = 99,
		align = "center"
	})
	titleText.anchorX = 0.5
	FontOffset.setOffset(titleText)
	local code = event.params.code
	local squareSize = 32
	local codeSize = #code
	for x = 0, codeSize + 1 do
		for y = 0, codeSize + 1 do
			local rect = display.newRect(sceneGroup, getCenterX(mainBox) + x * squareSize - 23 * squareSize / 2, getCenterY(mainBox) - 55 + y * squareSize - 21 * squareSize / 2, squareSize, squareSize)
			if 0 < x and 0 < y and x <= #code and y <= #code[x] then
				if 0 < code[x][y] then
					rect:setFillColor(unpack(Color.black))
				elseif code[x][y] < 0 then
					rect:setFillColor(unpack(Color.white))
				else
					rect:setFillColor(unpack(Color.gold))
				end
			end
		end
	end
	GUI.createButton(sceneGroup, getCenterX(mainBox) - squareSize * 23 / 2, mainBox.y + mainBox.height - 160, squareSize * 23, 120, Lang.common.ok, ButtonType.green, function()
		composer.hideOverlay("fade", 200)
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
