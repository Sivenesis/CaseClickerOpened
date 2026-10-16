local composer = require("composer")
local ProgressBar = require("gui.progressbar")
local scene = composer.newScene()
local rankBox, rankText
local rankImages = {}
local rankProgressBar, resetButton, advanceButton
local actualImageId = 0
local topLeftBox, topRightBox
local missionGroups = {}
local function updateRankBox(sceneGroup)
	local actualRank = Game.expRanks[Game.expRank]
	actualImageId = Game.expRank
	if rankText then
		rankText.text = Lang.privateRanks[Game.expRank]
	end
	if 0 < #rankImages then
		for i = 1, #rankImages do
			if rankImages[i].removeSelf then
				rankImages[i]:removeSelf()
			end
		end
	end
	for i = 1, 2 do
		rankImages[i] = display.newImageRect(sceneGroup, "images/expranks/" .. Game.expRank .. ".png", 100, 100)
		rankImages[i].anchorX = 0.5
		rankImages[i].anchorY = 0.5
		rankImages[i].y = rankBox.y + 260
	end
	rankImages[1].x = rankText.x - 90
	rankImages[2].x = rankText.x + 90
end
local function updateProgressBar()
	if Game.expRank == #Game.expRanks then
		rankProgressBar:setProgress(100, true)
		rankProgressBar:setText(Lang.missions.maximumRank .. "!")
		return
	end
	local experience = Game.experience
	local experienceToAdvance = Game.expRanks[Game.expRank].expForAdvance
	rankProgressBar:setProgress(experience / experienceToAdvance * 100)
	rankProgressBar:setText(experience .. " / " .. experienceToAdvance)
	if Game.others.expRankRewardsAvailable > 0 then
		advanceButton.alpha = 1
	else
		if Game.expRank == 40 then
			resetButton.alpha = 1
		end
		advanceButton.alpha = 0
	end
end
function scene:refreshMissionBoxes()
	self:drawMissionBoxContents(topLeftBox, 1)
	self:drawMissionBoxContents(topRightBox, 2)
	self:drawMissionBoxContents(bottomLeftBox, 3)
end
function scene:drawMissionBox(missionId, x, y, text)
	local sceneGroup = self.view
	local box = GUI.createBox(sceneGroup, x, y, (display.safeActualContentWidth - display.safeActualContentWidth * 0.25 - 30) / 2, (display.safeActualContentHeight - 30) / 2, text)
	return box
end
function scene:drawMissionBoxContents(box, missionId)
	local sceneGroup = self.view
	if missionGroups[missionId] then
		missionGroups[missionId]:removeSelf()
	end
	missionGroups[missionId] = display.newGroup()
	sceneGroup:insert(missionGroups[missionId])
	local group = missionGroups[missionId]
	local mission = MissionManager.getMission(missionId)
	if mission.locked then
		local lockImage = display.newImageRect(group, "images/gui/lock_big.png", 230.4, 230.4)
		lockImage.anchorX = 0.5
		lockImage:setFillColor(unpack(Color.lightText))
		lockImage.x = getCenterX(box)
		lockImage.y = box.y + box.height * 0.15
		if mission.rank and Game.rank >= mission.rank then
			lockImage.y = lockImage.y - 15
		end
		lockImage.alpha = 0.3
		local lockedText = PonyFont.newText({
			parent = group,
			x = getCenterX(box),
			y = lockImage.y + lockImage.height + 30,
			text = "slot locked",
			font = BitmapFont.counterstrike,
			fontSize = 62,
			align = "center"
		})
		lockedText.anchorX = 0.5
		lockedText:setFillColor(unpack(Color.lightText))
		if mission.rank and Game.rank < mission.rank then
			local infoText = PonyFont.newText({
				parent = group,
				x = getCenterX(box),
				y = lockedText.y + 90,
				text = "Required rank:",
				font = BitmapFont.counterstrike,
				fontSize = 62,
				align = "center"
			})
			infoText.anchorX = 0.5
			infoText:setFillColor(unpack(Color.lightText))
			local infoText2 = PonyFont.newText({
				parent = group,
				x = infoText.x,
				y = infoText.y + 70,
				text = Game.ranks[mission.rank].name,
				font = BitmapFont.counterstrike,
				fontSize = 62,
				align = "center"
			})
			infoText2.anchorX = 0.5
			infoText2:setFillColor(unpack(Color.gold))
		else
			local buttonType = ButtonType.red
			if Game.money >= mission.cost then
				buttonType = ButtonType.green
			end
			local buttonWidthMultiplier = 0.8
			if detectSquareScreen() then
				buttonWidthMultiplier = 0.92
			end
			local unlockButton = Button.create(group, lockedText.x - box.width * (buttonWidthMultiplier / 2), lockedText.y + 100, box.width * buttonWidthMultiplier, 90, "Unlock for $" .. formatPrice(mission.cost), buttonType, function(event)
				if buttonType == ButtonType.red then
					return true
				end
				if Game.money < mission.cost then
					return true
				end
				Game.removeMoney(mission.cost, "Other", "Mission Slot")
				MissionManager.unlockSlot(missionId)
				self:refreshMissionBoxes()
				GUI.showAnimatedText(nil, "Unlocked!", event.x * (math.random(95, 105) / 100), event.y * (math.random(95, 100) / 100))
				return true
			end, {fontSize = 45, addCoin = true})
		end
		return true
	end
	local missionInfo = MissionManager.getMissionInfo(missionId)
	local imageWidth = missionInfo.image.width
	local imageHeight = missionInfo.image.height
	local proportions = imageHeight / imageWidth
	local scale = 1
	if missionInfo.image.scale then
		scale = missionInfo.image.scale
	end
	imageHeight = 220 * scale
	imageWidth = 220 / proportions * scale
	local image = display.newImageRect(group, "images/" .. missionInfo.image.path, imageWidth, imageHeight)
	image.x = getCenterX(box)
	image.y = box.y + 122.5
	image.anchorX = 0.5
	image.anchorY = 0.5
	if not mission.completed then
		image.y = image.y + 50
	end
	local firstTextFontSize = 48
	if #missionInfo.firstText >= 28 then
		firstTextFontSize = 42
	end
	if detectSquareScreen() then
		firstTextFontSize = firstTextFontSize - 4
	end
	local secondText = PonyFont.newText({
		parent = group,
		x = getCenterX(box),
		y = image.y + image.height / 2 + 30,
		text = missionInfo.secondText,
		font = BitmapFont.counterstrikeTight,
		fontSize = 55,
		align = "center"
	})
	secondText.anchorX = 0.5
	secondText:setFillColor(unpack(Color.lightText))
	local firstText = PonyFont.newText({
		parent = group,
		x = getCenterX(box),
		y = secondText.y + 180,
		text = missionInfo.firstText,
		width = box.width * 0.98,
		font = BitmapFont.counterstrikeTight,
		fontSize = firstTextFontSize,
		align = "center"
	})
	firstText.anchorX = 0.5
	firstText:setFillColor(unpack(Color.lightText))
	if missionInfo.noProgressBar then
		secondText.y = secondText.y + 30
		firstText.y = firstText.y - 40
		secondText.size = 64
		firstText.size = firstText.size + 8
		firstText:setFillColor(unpack(Color.white))
	else
		local progressBar = ProgressBar.create(group, getCenterX(box), secondText.y + 70, box.width * 0.9, 60, ProgressBarType.default, {fontSize = 28})
		local firstValue = missionInfo.actualValue - missionInfo.startValue
		local secondValue = missionInfo.endValue - missionInfo.startValue
		firstValue = math.min(firstValue, secondValue)
		progressBar:setProgress(firstValue / secondValue * 100)
		if missionInfo.formatValueAsPrice then
			progressBar:setText("$" .. formatPrice(firstValue) .. " / $" .. secondValue)
		else
			progressBar:setText(firstValue .. " / " .. secondValue)
		end
	end
	if mission.completed then
		Button.create(group, getCenterX(box) - box.width * 0.35, box.y + box.height - 90, box.width * 0.7, 70, "Get reward!", ButtonType.green, function(event)
			MissionManager.completeMission(missionId)
			self:refreshMissionBoxes()
			updateProgressBar()
			return true
		end, {fontSize = 46})
		firstText.y = firstText.y - 20
	end
	if mission.newMission then
		group.alpha = 0
		transition.to(group, {alpha = 1, time = 500})
		mission.newMission = nil
	end
end
local function drawRankBox(sceneGroup)
	rankBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.25 + 15 + topLeftBox.width + 10, topLeftBox.y + topLeftBox.height + 10, (display.safeActualContentWidth - display.safeActualContentWidth * 0.25 - 30) / 2, (display.safeActualContentHeight - 30) / 2, Lang.missions.yourrank)
	local actualRankText = PonyFont.newText({
		parent = sceneGroup,
		x = rankBox.x + rankBox.width / 2,
		y = rankBox.y + 110,
		text = Lang.missions.actualrank .. ":",
		font = BitmapFont.counterstrike,
		fontSize = 52,
		align = "center"
	})
	actualRankText:setFillColor(unpack(Color.white))
	actualRankText.anchorX = 0.5
	actualRankText.anchorY = 0.5
	local rankName = Lang.privateRanks[Game.expRank]
	rankText = PonyFont.newText({
		parent = sceneGroup,
		x = actualRankText.x,
		y = actualRankText.y + actualRankText.height + 25,
		text = "",
		font = BitmapFont.counterstrike,
		fontSize = 82,
		align = "center"
	})
	rankText:setFillColor(unpack(Color.gold))
	rankText.anchorX = 0.5
	rankText.anchorY = 0.5
	rankText:addEventListener("tap", function()
		Game.unlockAchievement("Secret III")
	end)
	rankProgressBar = ProgressBar.create(sceneGroup, rankBox.x + rankBox.width / 2, rankBox.y + rankBox.height * 0.58, rankBox.width * 0.85, 60, ProgressBarType.gold)
	advanceButton = GUI.createButton(sceneGroup, getCenterX(rankBox) - rankBox.width * 0.45, rankBox.y + rankBox.height * 0.62 + 75, rankBox.width * 0.9, 80, "Get reward", ButtonType.green, function(event)
		Game.others.expRankRewardsAvailable = Game.others.expRankRewardsAvailable - 1
		if Game.others.expRankRewardsAvailable == 0 then
			advanceButton.alpha = 0
			if Game.expRank == 40 then
				resetButton.alpha = 1
			end
		end
		local availableCollections = {
			Collection.dust2,
			Collection.dust,
			Collection.bank,
			Collection.vertigo,
			Collection.train,
			Collection.safehouse,
			Collection.mirage,
			Collection.lake,
			Collection.italy,
			Collection.inferno,
			Collection.aztec
		}
		Game.showCollectionDraw(choose(availableCollections))
	end, 55)
	advanceButton.alpha = 0
	resetButton = GUI.createButton(sceneGroup, getCenterX(rankBox) - rankBox.width * 0.45, rankBox.y + rankBox.height * 0.62 + 75, rankBox.width * 0.9, 80, "Reset rank", ButtonType.yellow, function(event)
		composer.removeScene("overlays.rankreset")
		local options = {
			isModal = true,
			params = {
				yesButtonCallback = function()
					resetButton.alpha = 0
					updateRankBox(sceneGroup)
					updateProgressBar()
					GUI.showMessageBox(Lang.common.success, Lang.missions.resetMessage)
					AchievementManager.onRankReset()
				end,
				noButtonCallback = function()
				end
			}
		}
		composer.showOverlay("overlays.rankreset", options)
	end, 55)
	resetButton.alpha = 0
	actualImageId = Game.rank
	updateRankBox(sceneGroup)
	updateProgressBar()
end
function scene:create(event)
	local sceneGroup = self.view
	topLeftBox = self:drawMissionBox(1, display.safeActualContentWidth * 0.25 + 10, 10, "Mission 1")
	topRightBox = self:drawMissionBox(2, display.safeActualContentWidth * 0.25 + 15 + topLeftBox.width + 10, 10, "Mission 2")
	bottomLeftBox = self:drawMissionBox(3, display.safeActualContentWidth * 0.25 + 10, topLeftBox.y + topLeftBox.height + 10, "Mission 3")
	drawRankBox(sceneGroup)
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
		MissionManager.checkMissionsForCompletion()
		updateRankBox(sceneGroup)
		self:refreshMissionBoxes()
		updateProgressBar()
		if Game.others.expRankRewardsAvailable > 0 and advanceButton then
			advanceButton.alpha = 1
		elseif Game.expRank == 40 then
			resetButton.alpha = 1
		end
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
