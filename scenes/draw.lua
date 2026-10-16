local composer = require("composer")
local scene = composer.newScene()
local drawBackground, drawBackgroundOverlay, pointer, drawText, mainBox, caseContainer, drawType, case, capsule, collection, souvenir, callbackFunc, jackpotCallback
local jackpotDraw = {}
local enabledButtons = false
local nextSound = 1
local draw = {
	speed = math.random(4100, 4300),
	speedDecrease = math.random(800, 850),
	started = false,
	screenItems = {},
	lastItem = nil,
	allCases = false,
	firstItem = 1,
	running = false,
	dailyDraw = false,
	caseKeysOnly = false,
	changeProfit = false,
	jackpotDraw = false,
	onlineJackpotDraw = false,
	paidBonus = false
}
local simulationResult = 1
local mainBox
local function simulateDraw(speed, speedDecrease)
	local boxes = {}
	local firstItem = 1
	local lastItem
	local result = 1
	for i = 1, 44 do
		local box = {
			[1] = {width = 324.3}
		}
		box.x = 500 + (i - 1) * 360
		box.width = 336.4
		boxes[i] = box
	end
	while true do
		if boxes[firstItem].x + boxes[firstItem].width < -caseContainer.width * 0.5 then
			firstItem = firstItem + 1
		end
		local actualBox
		for i = firstItem, firstItem + 3 do
			if boxes[i] and boxes[i].x <= 0 and 0 <= boxes[i].x + boxes[i][1].width - 6 then
				actualBox = boxes[i]
			end
		end
		if not actualBox and speed < 30 then
			speed = 30
		end
		if lastItem ~= actualBox and actualBox ~= nil then
			result = result + 1
		end
		lastItem = actualBox
		boxes[firstItem].x = boxes[firstItem].x - speed * 0.015
		for i = firstItem + 1, firstItem + 4 do
			boxes[i].x = boxes[i - 1].x + 360
		end
		local decrease = 0.015
		if speed < 800 then
			decrease = 0.025
		elseif speed < 1200 then
			decrease = 0.02
		elseif speed < 2000 then
			decrease = 0.018
		end
		speed = speed - speedDecrease * decrease
		speedDecrease = speedDecrease - 1
		if speed <= 0 and actualBox then
			simulationResult = result
			result = 1
			return true
		end
	end
end
local function setupOnlineJackpotDraw(sceneGroup)
	local sceneGroup = scene.view
	local win = draw.win
	jackpotDraw.win = win
	local playerName = Game.onlineJackpot.name
	local idList = {}
	local chanceList = {}
	if OnlineJackpots.getWinChance() > 0 then
		chanceList[OnlineJackpots.playerId] = OnlineJackpots.getWinChance()
		idList[OnlineJackpots.playerId] = true
	end
	for _, item in ipairs(OnlineJackpots.items) do
		idList[item.player] = true
		if not chanceList[item.player] then
			chanceList[item.player] = OnlineJackpots.getWinChance(item.player)
		end
	end
	local ids = {}
	for playerId, chance in pairs(chanceList) do
		local toAdd = math.ceil(chance * 10)
		for i = 1, toAdd do
			table.insert(ids, playerId)
		end
	end
	ids = shuffleTable(ids)
	for i = 1, 44 do
		local name = "Unknown Player"
		local avatar = Jackpot.botNames[2]:lower()
		local rarity = Rarity.blue
		local id = OnlineJackpots.playerId
		if win and i + 1 == simulationResult then
			id = OnlineJackpots.playerId
		elseif i + 1 == simulationResult then
			id = OnlineJackpots.winner
		else
			id = ids[i]
			while i + 1 == simulationResult do
				if id == OnlineJackpots.playerId then
					id = choose(ids)
				else
					break
				end
			end
		end
		if OnlineJackpots.room.players[id] then
			if OnlineJackpots.room.players[id].name then
				name = OnlineJackpots.room.players[id].name
			end
			if OnlineJackpots.room.players[id].avatar then
				avatar = Jackpot.botNames[OnlineJackpots.room.players[id].avatar]:lower()
			end
		end
		if i + 1 == simulationResult then
			jackpotDraw.winner = name
			jackpotDraw.winnerPercent = formatPrice(chanceList[id] or 1) .. "%"
		end
		if id == OnlineJackpots.playerId then
			rarity = Rarity.purple
		end
		draw.screenItems[i] = GUI.createItemBox(sceneGroup, {}, 500 + (i - 1) * 360, 0, false, 0.94, {
			image = {
				path = "images/avatars/" .. avatar .. ".jpg",
				width = 343,
				height = 236
			},
			name = name .. "\r\n" .. formatPrice(chanceList[id] or 1) .. "%",
			rarity = rarity,
			dontUseGUIScale = true
		})
		caseContainer:insert(draw.screenItems[i])
	end
	draw.started = true
end
local function setupJackpotDraw(sceneGroup)
	local sceneGroup = scene.view
	local win = draw.win
	jackpotDraw.win = win
	local playerName = Lang.draw.playername
	if GameServices and GameServices.getPlayerName() ~= "" then
		playerName = GameServices.getPlayerName()
	end
	local nameList = {playerName}
	local chanceList = {}
	for name, _ in pairs(Game.jackpot.otherItems) do
		table.insert(nameList, name)
		chanceList[name] = Jackpot.getWinChance(name)
	end
	chanceList[playerName] = Jackpot.getWinChance()
	local names = {}
	for key, val in pairs(chanceList) do
		local toAdd = math.ceil(val * 50)
		for i = 1, toAdd do
			table.insert(names, key)
		end
	end
	names = shuffleTable(names)
	for i = 1, 44 do
		local name = "???"
		local rarity = Rarity.blue
		if win and i + 1 == simulationResult then
			name = playerName
		else
			name = names[i]
			while i + 1 == simulationResult do
				if name == playerName then
					name = choose(names)
				else
					break
				end
			end
		end
		if i + 1 == simulationResult then
			jackpotDraw.winner = name
			jackpotDraw.winnerPercent = formatPrice(chanceList[name] * 100) .. "%"
		end
		if name == playerName then
			rarity = Rarity.purple
		end
		draw.screenItems[i] = GUI.createItemBox(sceneGroup, {}, 500 + (i - 1) * 360, 0, statTrak, 0.94, {
			image = {
				path = "images/avatars/" .. name:lower() .. ".jpg",
				width = 343,
				height = 236
			},
			name = name .. "\r\n" .. formatPrice(chanceList[name] * 100) .. "%",
			rarity = rarity,
			dontUseGUIScale = true
		})
		caseContainer:insert(draw.screenItems[i])
	end
	draw.started = true
end
local function getDrawItem()
	local item, statTrak
	if drawType == Item.case then
		item = Game.cases[Game.getRandomCaseId(draw.allCases)]
	elseif drawType == Item.key then
		if draw.caseKeysOnly then
			local caseKeys = {
				Key.huntsman,
				Key.vanguard,
				Key.chroma2,
				Key.breakout,
				Key.weapon,
				Key.chroma,
				Key.winter,
				Key.phoenix,
				Key.esports,
				Key.falchion
			}
			item = Game.keys[choose(caseKeys)]
		else
			item = choose(Game.keys)
		end
	elseif drawType == Item.collection or drawType == Item.souvenir then
		item = Game.skins[Game.getCollectionRandomItemId(collection)]
		Game.skins[item.id].n = nil
	elseif drawType == Item.skin then
		local skinId = Game.getRandomCaseItemId(case, {dailyDraw = true})
		if skinId < 0 then
			item = {
				id = skinId,
				type = Item.rare,
				n = nil
			}
			if case.gloves then
				item.type = Item.rareGlove
			end
		else
			item = Game.skins[skinId]
			item.n = nil
		end
		if math.random(1, 100) <= Game.others.statTrakChance or 0 < Game.others.statTrakGuarantees then
			statTrak = true
		end
	elseif drawType == Item.sticker then
		item = Game.stickers[Game.getRandomCapsuleItemId(capsule)]
		item.n = nil
	elseif drawType == Item.glove then
		item = Game.getRandomGlove()
	elseif drawType == Item.knife then
		if draw.paidBonus then
			item = Game.getRandomKnife(200)
		else
			item = Game.getRandomKnife()
		end
		if math.random(1, 100) <= Game.others.statTrakChance then
			statTrak = true
		end
	elseif drawType == Item.custom then
		local listId = math.random(1, #draw.items)
		item = draw.items[listId]
		item.listId = listId
		if draw.items[listId].statTrak then
			statTrak = true
		end
	end
	return item, statTrak
end
local function getDrawResult(actualBox)
	local actualItem
	if actualBox.itemId < 0 then
		local allowed = true
		repeat
			allowed = true
			if actualBox.itemId == -1 and case and type(case.knifes) == "table" then
				actualItem = Game.skins[choose(case.knifes)]
			elseif case.gloves then
				actualItem = Game.gloves[math.random(GloveIds[actualBox.itemId][1], GloveIds[actualBox.itemId][2])]
			else
				actualItem = Game.skins[math.random(KnifeIds[actualBox.itemId][1], KnifeIds[actualBox.itemId][2])]
			end
			if case and case.disabledKnifeGroups then
				for i = 1, #case.disabledKnifeGroups do
					if actualItem.id >= case.disabledKnifeGroups[i][1] and actualItem.id <= case.disabledKnifeGroups[i][2] then
						allowed = false
						break
					end
				end
			end
			if case and case.disabledKnives then
				for _, knifeList in ipairs(case.disabledKnives) do
					for _, knifeId in ipairs(knifeList) do
						if actualItem.id == knifeId then
							allowed = false
							break
						end
					end
				end
			end
		until allowed
	elseif drawType == Item.skin or drawType == Item.collection or drawType == Item.souvenir or drawType == Item.knife then
		actualItem = Game.skins[actualBox.itemId]
		if drawType == Item.skin then
			Game.others.statTrakGuarantee = false
		end
		if drawType == Item.souvenir then
			actualBox.statTrak = true
		end
	elseif drawType == Item.glove then
		actualItem = Game.gloves[actualBox.itemId]
	elseif drawType == Item.key then
		actualItem = Game.keys[actualBox.itemId]
	elseif drawType == Item.case then
		actualItem = Game.cases[actualBox.itemId]
	elseif drawType == Item.sticker then
		actualItem = Game.stickers[actualBox.itemId]
	elseif drawType == Item.custom then
		actualItem = draw.items[actualBox.listId]
	end
	if draw.dailyDraw then
		Game.lastDailies[draw.boxId] = {
			type = actualItem.type,
			id = actualItem.id,
			pattern = Game.getSkinRandomPattern(actualItem),
			statTrak = actualItem.statTrak,
			quality = actualItem.quality,
			day = tonumber(os.date("%d")),
			month = tonumber(os.date("%m"))
		}
	end
	if drawType == Item.skin and 0 < Game.others.statTrakGuarantees then
		Game.others.statTrakGuarantees = Game.others.statTrakGuarantees - 1
	end
	if Game.lastScene == "scenes.draw" then
		Game.lastScene = "scenes.cases"
	end
	composer.gotoScene(Game.lastScene or "scenes.cases")
	timer.performWithDelay(50, function()
		if draw.changeProfit then
			Game.addItem(actualItem, true, actualBox.statTrak, true, {
				changeProfit = draw.changeProfit,
				case = case,
				collection = collection,
				capsule = capsule,
				souvenir = souvenir,
				newItem = draw.newItem,
				drawType = drawType
			})
		else
			local addItemOptions = {
				newItem = draw.newItem
			}
			if drawType == Item.custom then
				addItemOptions.quality = actualItem.quality
			end
			Game.addItem(actualItem, true, actualBox.statTrak, true, addItemOptions)
		end
	end)
end
local function setupDraw(sceneGroup)
	local sceneGroup = scene.view
	for i = 1, 44 do
		local item
		local statTrak = false
		local fakeStatTrak = false
		local options = {dontUseGUIScale = true}
		item, statTrak = getDrawItem()
		if drawType == Item.collection or drawType == Item.souvenir then
			if i < simulationResult - 1 and math.random(1, 100) <= Game.others.statTrakChance * 2 then
				if math.random(1, 2) == 1 then
					fakeStatTrak = true
				else
					statTrak = true
				end
			end
			if i + 1 == simulationResult and drawType == Item.souvenir then
				statTrak = true
			end
		end
		if fakeStatTrak then
			options.showStatTrak = true
		end
		if drawType == Item.custom then
			options.showQuality = true
			options.quality = item.quality
		end
		draw.screenItems[i] = GUI.createItemBox(sceneGroup, item, 500 + (i - 1) * 360, 0, statTrak, 0.94, options)
		draw.screenItems[i].statTrak = statTrak
		draw.screenItems[i].itemId = item.id
		draw.screenItems[i].listId = item.listId or nil
		draw.screenItems[i].rarity = item.rarity
		caseContainer:insert(draw.screenItems[i])
	end
	draw.started = true
end
function drawStep(event)
	if not draw.running then
		return
	end
	if not draw.started then
		if draw.onlineJackpotDraw then
			setupOnlineJackpotDraw(sceneGroup)
		elseif draw.jackpotDraw then
			setupJackpotDraw(sceneGroup)
		else
			setupDraw(sceneGroup)
		end
	end
	drawBackgroundOverlay:toFront()
	if draw.screenItems[draw.firstItem].x + draw.screenItems[draw.firstItem].width < -caseContainer.width * 0.5 then
		draw.firstItem = draw.firstItem + 1
	end
	local actualBox
	for i = draw.firstItem, draw.firstItem + 3 do
		if draw.screenItems[i] and draw.screenItems[i].x <= 0 and 0 <= draw.screenItems[i].x + draw.screenItems[i][1].width - 6 then
			actualBox = draw.screenItems[i]
		end
	end
	if not actualBox and draw.speed < 30 then
		draw.speed = 30
	end
	if draw.lastItem ~= actualBox and actualBox ~= nil then
		audio.play(Game.sounds.scrollSounds[nextSound], {
			channel = 5 + nextSound
		})
		nextSound = nextSound + 1
		if nextSound > #Game.sounds.scrollSounds then
			nextSound = 1
		end
	end
	draw.lastItem = actualBox
	draw.screenItems[draw.firstItem].x = draw.screenItems[draw.firstItem].x - draw.speed * 0.015
	for i = draw.firstItem + 1, draw.firstItem + 4 do
		draw.screenItems[i].x = draw.screenItems[i - 1].x + 360
	end
	local decrease = 0.015
	if draw.speed < 800 then
		decrease = 0.025
	elseif draw.speed < 1200 then
		decrease = 0.02
	elseif draw.speed < 2000 then
		decrease = 0.018
	end
	draw.speed = draw.speed - draw.speedDecrease * decrease
	draw.speedDecrease = draw.speedDecrease - 1
	if 0 >= draw.speed and actualBox then
		Runtime:removeEventListener("enterFrame", drawStep)
		local resultDelay = 800
		if Game.settings.speedUpDrawAnimations then
			resultDelay = 450
		end
		timer.performWithDelay(resultDelay, function()
			if draw.jackpotDraw then
				composer.showOverlay("overlays.jackpotresult", {
					isModal = true,
					effect = "slideDown",
					time = 200,
					params = {
						win = jackpotDraw.win,
						winner = jackpotDraw.winner,
						winnerPercent = jackpotDraw.winnerPercent,
						onlineJackpot = draw.onlineJackpotDraw
					}
				})
				if callbackFunc then
					callbackFunc()
					callbackFunc = nil
				end
				return true
			end
			getDrawResult(actualBox)
		end)
	end
end
local function drawMainBox(sceneGroup)
	local boxHeightMultiplier = 0.85
	mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.05, display.safeActualContentHeight * (1 - boxHeightMultiplier) / 2, display.safeActualContentWidth * 0.9, display.safeActualContentHeight * boxHeightMultiplier, Lang.draw.draw)
	mainBox:setFillColor(rgb(22, 30, 40))
	return mainBox
end
local function drawPointer(sceneGroup)
	local mainLine = display.newLine(sceneGroup, drawBackground.x, drawBackground.y - drawBackground.height / 2 - 26, drawBackground.x, drawBackground.y + drawBackground.height / 2 - 76)
	mainLine:setStrokeColor(rgb(111, 78, 29))
	mainLine.strokeWidth = 3
	return mainLine
end
local function drawDrawText()
	local sceneGroup = scene.view
	if drawText and drawText.removeSelf then
		drawText:removeSelf()
		drawText = nil
	end
	local text = Lang.draw.randomcasedraw
	if drawType == Item.skin then
		text = case.name .. " " .. Lang.draw.draw2
	elseif drawType == Item.key then
		text = Lang.draw.randomkeydraw
	elseif drawType == Item.collection then
		text = collection.name .. " " .. Lang.draw.draw2
	elseif drawType == Item.souvenir then
		souvenir = Game.getSouvenirByCollectionId(collection.id)
		text = souvenir.name .. " " .. Lang.draw.draw2
	elseif drawType == Item.sticker then
		text = capsule.name .. " " .. Lang.draw.draw2
	elseif drawType == Item.knife then
		text = Lang.draw.randomknifedraw
	elseif drawType == Item.glove then
		text = Lang.draw.randomglovedraw
	elseif draw.jackpotDraw then
		text = Lang.draw.jackpotdraw
	end
	local fontSize = 92
	if 25 < #text then
		fontSize = 82
	end
	drawText = PonyFont.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = mainBox.y + mainBox.height * 0.08,
		text = text,
		font = BitmapFont.counterstrike,
		fontSize = fontSize,
		align = "center"
	})
	drawText:setFillColor(unpack(Color.mainText))
	drawText.anchorX = 0.5
end
function scene:create(event)
	local sceneGroup = self.view
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.2)
	mainBox = drawMainBox(sceneGroup)
	drawDrawText(sceneGroup)
	drawBackground = display.newImageRect(sceneGroup, "images/drawbackground.png", 1116, 432)
	drawBackground.anchorX = 0.5
	drawBackground.anchorY = 0.5
	drawBackground.x = drawText.x
	drawBackground.y = drawText.y + 360 + 60
	drawBackground:scale(1.25, 1.25)
	drawBackgroundOverlay = display.newImageRect(sceneGroup, "images/drawbackgroundover.png", 1116, 432)
	drawBackgroundOverlay.x = drawBackground.x
	drawBackgroundOverlay.y = drawBackground.y
	drawBackgroundOverlay.anchorX = 0.5
	drawBackgroundOverlay.anchorY = 0.5
	drawBackgroundOverlay:scale(1.25, 1.25)
	caseContainer = display.newContainer(sceneGroup, drawBackground.width - 12, drawBackground.height * 2)
	caseContainer:translate(drawBackground.x - drawBackground.width / 2 - 128, drawBackground.y - drawBackground.height / 2 - 520)
	caseContainer:scale(1.25, 1.25)
	pointer = drawPointer(sceneGroup)
	pointer:scale(1.25, 1.25)
	local openingButtonText = Lang.draw.unlockingcontainer .. "..."
	self.openingButton = Button.create(sceneGroup, drawBackground.x - drawBackground.width * 1.25 / 2, drawBackground.y + 290, drawBackground.width * 1.25, 160, openingButtonText, ButtonType.purple, function(event)
	end, {fontSize = 60})
	self.openingButton:hide()
	local skipButtonWidth = 250
	local rollButtonY = drawBackground.y + 290
	self.rollButton = Button.create(sceneGroup, drawBackground.x - drawBackground.width * 1.25 / 2, rollButtonY, drawBackground.width * 1.25 - skipButtonWidth - 15, 160, "-", ButtonType.green, function(event)
		if draw.started or not enabledButtons then
			return
		end
		self.skipButton:hide()
		self.rollButton:hide()
		self.openingButton:show()
		audio.play(Game.sounds.caseOpen, {
			channel = audio.findFreeChannel()
		})
		draw.running = true
	end, {fontSize = 70, blockTime = 200})
	self.skipButton = Button.create(sceneGroup, self.rollButton.x + self.rollButton.width + 15, rollButtonY, skipButtonWidth, 160, nil, ButtonType.green, function(event)
		if draw.started or not enabledButtons then
			return
		end
		if self.skipButton:getType() ~= ButtonType.green then
			return GUI.showMessageBox("Information", "You cannot skip this draw!")
		end
		setupDraw(sceneGroup)
		getDrawResult(draw.screenItems[43])
		Runtime:removeEventListener("enterFrame", drawStep)
		return true
	end, {
		image = {
			name = "icons/skip.png",
			width = 67.5,
			height = 67.5
		},
		blockTime = 200
	})
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		enabledButtons = false
		Menu.hide()
		local params = event.params
		if not params and Game.lastDrawParams then
			params = Game.lastDrawParams
		end
		drawType = params.drawType
		local rollText = Lang.draw.roll
		case = nil
		collection = nil
		capsule = nil
		if drawType == Item.skin then
			case = Game.cases[params.caseId]
			rollText = Lang.draw.usekey
		elseif drawType == Item.collection or drawType == Item.souvenir then
			collection = params.collection
		elseif drawType == Item.sticker then
			capsule = Game.capsules[params.capsuleId]
			if capsule.keyId then
				rollText = Lang.draw.usekey
			end
		end
		self.openingButton:hide()
		self.rollButton:show()
		self.skipButton:show()
		self.rollButton:setText(rollText)
		for i = 1, #draw.screenItems do
			draw.screenItems[i]:removeSelf()
		end
		local speed = math.random(4100, 4300)
		local speedDecrease = math.random(800, 850)
		if Game.settings.speedUpDrawAnimations then
			speed = speed * 2
			speedDecrease = speedDecrease * 3.7
		end
		draw = {
			speed = speed,
			speedDecrease = speedDecrease,
			started = false,
			screenItems = {},
			lastItem = nil,
			allCases = false,
			firstItem = 1,
			running = false,
			dailyDraw = false,
			caseKeysOnly = false,
			changeProfit = false,
			jackpotDraw = false,
			onlineJackpotDraw = false
		}
		if params.newItem then
			draw.newItem = params.newItem
		end
		if params.caseKeysOnly then
			draw.caseKeysOnly = params.caseKeysOnly
		end
		if params.allCases then
			draw.allCases = params.allCases
		end
		if params.paidBonus then
			draw.paidBonus = params.paidBonus
		end
		if params.dailyDraw then
			draw.dailyDraw = params.dailyDraw
		end
		if params.onlineJackpotDraw then
			draw.onlineJackpotDraw = true
		end
		if params.boxId then
			draw.boxId = params.boxId
		end
		if params.items then
			draw.items = params.items
		else
			draw.items = nil
		end
		if params.jackpotDraw then
			draw.jackpotDraw = true
		end
		if params.jackpotDraw or drawType == Item.collection or drawType == Item.souvenir then
			simulateDraw(speed, speedDecrease)
		end
		if params.postDrawCallback then
			callbackFunc = params.postDrawCallback
		else
			callbackFunc = nil
		end
		if params.changeProfit then
			draw.changeProfit = true
		end
		if params.win then
			draw.win = true
		end
		self.skipButton:setType(ButtonType.green)
		if draw.jackpotDraw or draw.onlineJackpotDraw then
			self.skipButton:setType(ButtonType.red)
		end
		drawDrawText()
		Runtime:addEventListener("enterFrame", drawStep)
		RandomSkins.hide()
		Game.lastDrawParams = nil
	elseif phase == "did" then
		Game.openLock = false
		enabledButtons = true
		Game.save()
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
