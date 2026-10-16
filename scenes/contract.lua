local composer = require("composer")
local scene = composer.newScene()
local mainBox
local animationPhase = 0
local animationTicks = 0
local contractImage
local skinTexts = {}
local mainSkinText, params, approvedImage
local scale = 1
local signButton, okButton
local skinNamesPositions = {
	[1] = {x = 85, y = 385},
	[2] = {x = 85, y = 410},
	[3] = {x = 85, y = 435},
	[4] = {x = 85, y = 462},
	[5] = {x = 325, y = 385},
	[6] = {x = 325, y = 410},
	[7] = {x = 325, y = 435},
	[8] = {x = 325, y = 462},
	[9] = {x = 612, y = 385},
	[10] = {x = 612, y = 410}
}
local function enterFrame()
	if animationPhase == 0 then
		return
	elseif animationPhase == 1 then
		for i = 1, 10 do
			skinTexts[i] = display.newText({
				parent = scene.view,
				x = contractImage.x - contractImage.width / 2 + skinNamesPositions[i].x * scale,
				y = contractImage.y - contractImage.height / 2 + skinNamesPositions[i].y * scale,
				text = "",
				font = Font.counterstrike,
				fontSize = 16 * scale,
				align = "center"
			})
			skinTexts[i]:setFillColor(rgb(56, 79, 111))
			FontOffset.setOffset(skinTexts[i])
		end
		mainSkinText = display.newText({
			parent = scene.view,
			x = contractImage.x - contractImage.width / 2 + 640 * scale,
			y = contractImage.y - contractImage.height / 2 + 268 * scale,
			text = "",
			font = Font.counterstrike,
			fontSize = 32,
			align = "center"
		})
		mainSkinText:setFillColor(rgb(56, 79, 111))
		FontOffset.setOffset(mainSkinText)
		animationPhase = 2
		return
	elseif animationPhase == 2 then
		animationTicks = animationTicks + 1
		if animationTicks == 8 then
			local changed = false
			for i = 1, 10 do
				if #skinTexts[i].text < #params.names[i] then
					skinTexts[i].text = params.names[i]:sub(0, #skinTexts[i].text + 1)
					changed = true
				end
			end
			animationTicks = 0
			if not changed then
				animationPhase = 3
			end
		end
	elseif animationPhase == 3 then
		animationTicks = animationTicks + 1
		if animationTicks == 8 then
			if #mainSkinText.text < #params.toAdd.name then
				mainSkinText.text = params.toAdd.name:sub(0, #mainSkinText.text + 1)
			else
				animationPhase = 4
				animationTicks = 0
				return
			end
			animationTicks = 0
		end
	elseif animationPhase == 4 then
		animationTicks = animationTicks + 1
		if animationTicks == 25 then
			approvedImage = display.newImageRect(scene.view, "images/contracts/approved.png", 394 * scale, 149 * scale)
			approvedImage.x = contractImage.x - contractImage.width / 2 + 330 * scale
			approvedImage.y = contractImage.y - contractImage.height / 2 + 330 * scale
			animationPhase = 5
		end
	end
end
local function drawMainBox(sceneGroup)
	mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.05, display.safeActualContentHeight * 0.05, display.safeActualContentWidth * 0.9, display.safeActualContentHeight * 0.9, Lang.contract.contract)
	mainBox:setFillColor(rgb(22, 30, 40))
	return mainBox
end
local lastX, lastY
function scene:create(event)
	local sceneGroup = self.view
	params = event.params
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.2)
	local mainBox = drawMainBox(sceneGroup)
	scale = mainBox.width * 0.86 / 1197.3
	contractImage = display.newImageRect(sceneGroup, "images/contracts/contract.png", 1197.3 * scale, 559 * scale)
	contractImage.anchorX = 0.5
	contractImage.anchorY = 0.5
	contractImage.x = getCenterX(mainBox)
	contractImage.y = getCenterY(mainBox) - 100
	local drawGroup = display.newGroup()
	sceneGroup:insert(drawGroup)
	contractImage:addEventListener("touch", function(event)
		if animationPhase ~= 0 then
			return
		end
		if lastX and lastY and (math.abs(lastX - event.x) > 140 or 140 < math.abs(lastY - event.y)) then
			lastX = nil
			lastY = nil
		end
		if not lastX then
			lastX = event.x
			lastY = event.y
		end
		if event.phase == "ended" then
			lastX = nil
			lastY = nil
			return
		end
		if event.phase ~= "moved" then
			return
		end
		local line = display.newLine(drawGroup, lastX, lastY, event.x, event.y)
		line.strokeWidth = math.ceil(6 * scale)
		line:setStrokeColor(rgb(56, 79, 111))
		lastX = event.x
		lastY = event.y
	end)
	local playerName = Lang.contract.playername
	if GameServices and GameServices.loggedIn then
		playerName = GameServices.getPlayerName()
	end
	local nameText = display.newText({
		parent = sceneGroup,
		x = contractImage.x - contractImage.width / 2 + 90 * scale,
		y = contractImage.y - contractImage.height / 2 + 163 * scale,
		text = playerName,
		font = Font.counterstrike,
		fontSize = 36 * scale,
		align = "center"
	})
	nameText:setFillColor(rgb(56, 79, 111))
	FontOffset.setOffset(nameText)
	local rankName = Game.ranks[Game.rank].name
	if 24 <= #rankName then
		rankName = rankName:sub(0, 21) .. "..."
	end
	local rankText = display.newText({
		parent = sceneGroup,
		x = contractImage.x - contractImage.width / 2 + 690 * scale,
		y = contractImage.y - contractImage.height / 2 + 163 * scale,
		text = rankName,
		font = Font.counterstrike,
		fontSize = 36 * scale,
		align = "center"
	})
	rankText:setFillColor(rgb(56, 79, 111))
	FontOffset.setOffset(rankText)
	local number10Text = display.newText({
		parent = sceneGroup,
		x = contractImage.x - contractImage.width / 2 + 360 * scale,
		y = contractImage.y - contractImage.height / 2 + 253 * scale,
		text = "10",
		font = Font.counterstrike,
		fontSize = 36 * scale,
		align = "center"
	})
	number10Text:setFillColor(rgb(56, 79, 111))
	FontOffset.setOffset(number10Text)
	local formNoText = display.newText({
		parent = sceneGroup,
		x = contractImage.x - contractImage.width / 2 + 265 * scale,
		y = contractImage.y - contractImage.height / 2 + 113 * scale,
		text = math.random(100000, 1000000),
		font = Font.counterstrike,
		fontSize = 32 * scale,
		align = "center"
	})
	formNoText:setFillColor(rgb(56, 79, 111))
	FontOffset.setOffset(formNoText)
	local dateText = display.newText({
		parent = sceneGroup,
		x = contractImage.x - contractImage.width / 2 + 915 * scale,
		y = contractImage.y - contractImage.height / 2 + 43 * scale,
		text = os.date("%A, %b %d, %Y"),
		font = Font.counterstrike,
		fontSize = 20 * scale,
		align = "center"
	})
	dateText:setFillColor(rgb(56, 79, 111))
	FontOffset.setOffset(dateText)
	signButton = GUI.createButton(sceneGroup, contractImage.x - contractImage.width / 2, contractImage.y + contractImage.height / 2 + 30, contractImage.width, 120, Lang.contract.signacontract, ButtonType.green, function(event)
		if animationPhase == 0 then
			animationPhase = 1
			signButton.alpha = 0
			okButton.alpha = 1
		end
	end, 47)
	okButton = GUI.createButton(sceneGroup, contractImage.x - contractImage.width / 2, contractImage.y + contractImage.height / 2 + 30, contractImage.width, 120, Lang.common.okay, ButtonType.green, function(event)
		animationPhase = 0
		Game.addItem(params.toAdd, true, params.statTrak, true, {
			overlayDelay = 340,
			quality = params.quality
		})
		Game.blockButtons = true
		timer.performWithDelay(200, function()
			Game.blockButtons = false
		end, 3)
		composer.gotoScene(Game.lastScene)
		Game.recalculateEquipmentWorth()
		composer.removeScene("scenes.contract")
	end, 47)
	okButton.alpha = 0
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.hide()
		Runtime:addEventListener("enterFrame", enterFrame)
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
