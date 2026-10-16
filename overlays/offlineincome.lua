local composer = require("composer")
local scene = composer.newScene()
local drawMainBox = function(sceneGroup)
	mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.05, display.safeActualContentHeight * 0.2, display.safeActualContentWidth * 0.9, display.safeActualContentHeight * 0.6, Lang.offlineIncome.offlineIncome)
	mainBox:setFillColor(rgb(22, 30, 40))
	return mainBox
end
function scene:create(event)
	local sceneGroup = self.view
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.8)
	local mainBox = drawMainBox(sceneGroup)
	local text1 = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = getCenterY(mainBox) - 260,
		text = Lang.offlineIncome.youHaveBeenOffline .. ":",
		font = Font.counterstrike,
		fontSize = 72,
		align = "center"
	})
	text1.anchorX = 0.5
	FontOffset.setOffset(text1)
	local offlineTime = math.ceil(math.min(Game.others.offlineIncomeTime, os.time() - Game.others.saveTime) / 60)
	local text2 = display.newText({
		parent = sceneGroup,
		x = text1.x,
		y = text1.y + text1.height + 20,
		text = offlineTime .. " / " .. math.ceil(Game.others.offlineIncomeTime / 60) .. " " .. Lang.offlineIncome.minutes,
		font = Font.counterstrike,
		fontSize = 72,
		align = "center"
	})
	text2.anchorX = 0.5
	text2:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(text2)
	if offlineTime == math.ceil(Game.others.offlineIncomeTime / 60) then
		text2:addEventListener("tap", function()
			Game.unlockAchievement("Secret VI")
		end)
	end
	local text3 = display.newText({
		parent = sceneGroup,
		x = text2.x,
		y = text2.y + text2.height + 50,
		text = Lang.offlineIncome.youHaveEarned .. ":",
		font = Font.counterstrike,
		fontSize = 72,
		align = "center"
	})
	text3.anchorX = 0.5
	FontOffset.setOffset(text3)
	local incomeTime = math.min(Game.others.offlineIncomeTime, os.time() - Game.others.saveTime)
	local income = incomeTime * Game.moneyPerSecond
	local text4 = display.newText({
		parent = sceneGroup,
		x = text3.x,
		y = text3.y + text3.height + 20,
		text = "$" .. formatPrice(income),
		font = Font.counterstrike,
		fontSize = 72,
		align = "center"
	})
	text4.anchorX = 0.5
	FontOffset.setOffset(text4)
	text4:setFillColor(unpack(Color.gold))
	local text5 = display.newText({
		parent = sceneGroup,
		x = text4.x,
		y = text4.y + text4.height + 50,
		text = Lang.common.awesome .. "!",
		font = Font.counterstrike,
		fontSize = 72,
		align = "center"
	})
	text5.anchorX = 0.5
	FontOffset.setOffset(text5)
	local buttonWidth = mainBox.width * 0.5
	GUI.createButton(sceneGroup, getCenterX(mainBox) - buttonWidth / 2, mainBox.y + mainBox.height - 180, buttonWidth, 120, "Ok", ButtonType.green, function()
		composer.hideOverlay("slideDown", 400)
		Game.save()
	end, 60)
	if income < 0 then
		return
	end
	Game.addMoney(income, "Main", "Offline Income")
	Game.save()
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
