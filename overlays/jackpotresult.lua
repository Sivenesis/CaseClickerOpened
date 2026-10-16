local composer = require("composer")
local scene = composer.newScene()
local loseTexts = Lang.jackpot.losebuttontexts
local winTexts = Lang.jackpot.winbuttontexts
function scene:create(event)
	local sceneGroup = self.view
	local win = event.params.win
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.7)
	local width = 1527.5
	local height = 1084.5
	local mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.5 - width / 2, display.safeActualContentHeight * 0.5 - height / 2, width, height, Lang.jackpot.jackpotresult, false)
	local rarityBG = "images/rarities/redBG.png"
	if win then
		rarityBG = "images/rarities/greenBG.png"
	end
	local image = display.newImageRect(sceneGroup, rarityBG, 1487.5, 1004.5)
	image.x = getCenterX(mainBox)
	image.y = getCenterY(mainBox)
	image.anchorX = 0.5
	image.anchorY = 0.5
	local text = Lang.jackpot.youvelost
	if win then
		text = Lang.jackpot.youvewon
	end
	local titleText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = image.y - image.height / 2 + 60,
		text = text,
		font = Font.counterstrike,
		fontSize = 72,
		align = "center"
	})
	titleText.anchorX = 0.5
	FontOffset.setOffset(titleText)
	local buttonType = ButtonType.red
	if win then
		buttonType = ButtonType.green
	end
	local okButtonX = image.x - image.width / 2 + 10
	local okButtonWidth = image.width - 20
	local okButtonText = choose(loseTexts)
	if win then
		okButtonText = choose(winTexts)
	end
	local okButton = GUI.createButton(sceneGroup, okButtonX, image.y + image.height / 2 - 120, okButtonWidth, 110, okButtonText, buttonType, function()
		if Jackpot.okButtonCallback and not event.params.onlineJackpot then
			Jackpot.okButtonCallback()
		elseif OnlineJackpots.okButtonCallback and event.params.onlineJackpot then
			OnlineJackpots.okButtonCallback()
		else
			composer.gotoScene("scenes.jackpot")
		end
		return true
	end, 70)
	local rarityColor = RarityColors[Rarity.red]
	if win then
		rarityColor = {
			107,
			200,
			72
		}
	end
	for i = 1, 15 do
		local shadow = display.newRoundedRect(sceneGroup, getCenterX(mainBox), getCenterY(mainBox) - 100, 721 - 2 * i, 526 - 2 * i, 20)
		shadow.anchorX = 0.5
		shadow.anchorY = 0.5
		shadow:setFillColor(unpack(rarityColor))
		shadow.alpha = 0.05
	end
	local itemBackground = display.newRoundedRect(sceneGroup, getCenterX(mainBox), getCenterY(mainBox) - 100, 685, 490, 13)
	itemBackground.anchorX = 0.5
	itemBackground.anchorY = 0.5
	itemBackground:setFillColor(0, 0, 0, 0.75)
	local winnerText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = itemBackground.y + itemBackground.height / 2 + 45,
		text = Lang.jackpot.winner .. ":",
		font = Font.counterstrike,
		fontSize = 56,
		align = "center"
	})
	winnerText.anchorX = 0.5
	FontOffset.setOffset(winnerText)
	local winnerName = ""
	if event.params.onlineJackpot then
		winnerName = OnlineJackpots.getWinner().name
	else
		winnerName = event.params.winner
	end
	local winnerText2 = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = winnerText.y + 60,
		text = winnerName,
		font = Font.counterstrike,
		fontSize = 77,
		align = "center"
	})
	winnerText2.anchorX = 0.5
	winnerText2:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(winnerText2)
	local winnerText3 = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = winnerText2.y + 80,
		text = event.params.winnerPercent,
		font = Font.counterstrike,
		fontSize = 44,
		align = "center"
	})
	winnerText3.anchorX = 0.5
	winnerText3:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(winnerText3)
	local imagePath = ""
	if event.params.onlineJackpot then
		local avatarName = Jackpot.botNames[OnlineJackpots.getWinner().avatar]:lower()
		imagePath = "images/avatars/" .. avatarName .. ".jpg"
	else
		imagePath = "images/avatars/" .. event.params.winner:lower() .. ".jpg"
	end
	local itemImage = display.newImageRect(sceneGroup, imagePath, 675, 475.20000000000005)
	itemImage = itemImage or display.newImageRect(sceneGroup, "images/avatars/you.jpg", 675, 475.20000000000005)
	itemImage.x = getCenterX(mainBox)
	itemImage.y = getCenterY(mainBox) - 100
	itemImage.anchorX = 0.5
	itemImage.anchorY = 0.5
	sceneGroup:toFront()
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
