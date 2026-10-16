local composer = require("composer")
local scene = composer.newScene()
local buttonTexts = Lang.itemoverlay.buttonTexts
local stickerImages = {}
local scratchesAlphaTables = {
	[1] = 0,
	[2] = 0.13,
	[3] = 0.2,
	[4] = 0.3,
	[5] = 0.45
}
local stickerBackgroundEffects = {
	[626] = "fireeffect.jpg"
}
local skinBackgroundEffects = {
	[Skin.AWP_medusa] = "medusa.png"
}
local selectedSticker
function scene:onStickerTap(stickerImage, stickerId, id, stickerRemoveCallback, x, y, width, height, removeButton)
	for i = 1, #stickerImages do
		stickerImages[i].alpha = 1
	end
	if selectedSticker and selectedSticker == id then
		self.stickerGroup:removeSelf()
		selectedSticker = nil
		for i = 1, #stickerImages do
		end
		return true
	end
	if self.stickerGroup then
		self.stickerGroup:removeSelf()
	end
	selectedSticker = id
	local sceneGroup = self.view
	self.stickerGroup = display.newGroup()
	sceneGroup:insert(self.stickerGroup)
	for i = 1, #stickerImages do
		if i == id then
			stickerImages[i].alpha = 1
		else
			stickerImages[i].alpha = 0.4
		end
	end
	local rect = display.newRoundedRect(self.stickerGroup, x, y, width, height, 20)
	rect:setFillColor(unpack(Color.black))
	rect.anchorX = 0.5
	rect.anchorY = 1
	rect.alpha = 0.8
	local name = Game.stickers[stickerId].name:gsub("-", "@")
	name = name:gsub(" | ", "\r\n"):gsub("Holo", "H"):gsub("Foil", "F"):gsub("Red", "R"):gsub("Blue", "B")
	local stickerNameText = PonyFont.newText({
		parent = self.stickerGroup,
		x = rect.x,
		y = rect.y - rect.height + 40,
		text = name,
		font = BitmapFont.counterstrike,
		fontSize = 36,
		align = "center"
	})
	stickerNameText.anchorX = 0.5
	local dimensions = Stickers.getStickerImageDimensions(stickerId)
	local image = display.newImageRect(self.stickerGroup, "images/stickers/" .. stickerId .. ".png", dimensions.width * 1.1, dimensions.height * 1.1)
	image.x = rect.x
	image.y = rect.y - rect.height * 0.65
	image.anchorX = 0.5
	image.anchorY = 0.5
	if removeButton then
		local removeButton = Button.create(self.stickerGroup, image.x - rect.width * 0.35, rect.y - 250, rect.width * 0.7, 75, "Remove Sticker", ButtonType.red, function()
			stickerRemoveCallback()
			return true
		end, {fontSize = 45})
	end
	self.stickerImageGroup:toFront()
end
function scene:create(event)
	local sceneGroup = self.view
	local item = event.params.item
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.7)
	background:addEventListener("touch", function()
		return true
	end)
	background:addEventListener("tap", function()
		return true
	end)
	local width = 1527.5 * Game.guiScale
	local height = 1084.5 * Game.guiScale
	local mainBoxText = event.params.titleText or Lang.itemoverlay.iteminfo .. ": " .. item.name:gsub("-", "@")
	local mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.5 - width / 2, display.safeActualContentHeight * 0.5 - height / 2, width, height, mainBoxText, false)
	local image = display.newImageRect(sceneGroup, RarityBackgrounds[item.rarity], mainBox.width - 5, mainBox.height - 5)
	image.x = getCenterX(mainBox)
	image.y = getCenterY(mainBox)
	image.anchorX = 0.5
	image.anchorY = 0.5
	local fontSize = 82
	if item.name:len() > 32 then
		fontSize = 52
	elseif item.name:len() > 25 then
		fontSize = 57
	elseif item.name:len() > 20 then
		fontSize = 68
	end
	local itemName = item.name:gsub("-", "@")
	local nameStrings = string.explode(itemName, " | ")
	if 1 < #nameStrings and item.n and item.type == Item.skin and 0 < #item.n then
		itemName = nameStrings[1] .. " | \"" .. item.n .. "\""
	end
	if 1 < #nameStrings and event.params.customName and item.type == Item.skin and 0 < #event.params.customName then
		itemName = nameStrings[1] .. " | \"" .. event.params.customName .. "\""
	end
	local priceText = item.type == Item.skin or item.type == Item.sticker or item.type == Item.glove
	local titleText = PonyFont.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = mainBox.y + 30,
		text = itemName,
		font = BitmapFont.counterstrike,
		fontSize = fontSize * Game.guiScale,
		align = "center"
	})
	titleText.anchorX = 0.5
	titleText:addEventListener("tap", function()
		Game.unlockAchievement("Secret IV")
	end)
	if not priceText then
		titleText.y = titleText.y + 30
	end
	local price = 0
	if priceText then
		price = Game.getPrice({
			id = item.id,
			statTrak = event.params.statTrak,
			quality = event.params.quality,
			pattern = event.params.pattern,
			stickers = event.params.stickers,
			type = item.type
		})
		local priceText = PonyFont.newText({
			parent = sceneGroup,
			x = getCenterX(mainBox),
			y = titleText.y + 86 * Game.guiScale - 5,
			text = Lang.itemoverlay.price .. ": $" .. formatPrice(price),
			font = BitmapFont.counterstrike,
			fontSize = 44 * Game.guiScale,
			align = "center"
		})
		priceText.anchorX = 0.5
		if isIOS() then
			priceText.y = priceText.y - 10
		end
	end
	local buttonType = ButtonType.default
	if item.rarity then
		if item.rarity == Rarity.pink then
			buttonType = ButtonType.pink
		elseif item.rarity == Rarity.red then
			buttonType = ButtonType.red
		elseif item.rarity == Rarity.purple then
			buttonType = ButtonType.purple
		elseif item.rarity == Rarity.blue then
			buttonType = ButtonType.blue
		elseif item.rarity == Rarity.gold then
			buttonType = ButtonType.yellow
		elseif item.rarity == Rarity.gray then
			buttonType = ButtonType.gray
		end
	end
	local okButtonX = image.x - image.width / 2 + 10
	local okButtonWidth = image.width - 20
	if item.type == Item.sticker and event.params.stickable then
		okButtonWidth = okButtonWidth - 220
		GUI.createButton(sceneGroup, okButtonX + okButtonWidth + 15, image.y + image.height / 2 - 120 * Game.guiScale, 205, 110 * Game.guiScale, nil, buttonType, function()
			composer.gotoScene("scenes.itemselection", {
				params = {
					stickerEquipmentId = event.params.equipmentId,
					type = ItemSelection.sticker
				}
			})
			return true
		end, 70, {
			image = {
				name = "icons/stick.png",
				width = 81 * Game.guiScale,
				height = 81 * Game.guiScale
			}
		})
	end
	if event.params.lockable then
		okButtonWidth = okButtonWidth - 160
		if Game.settings.equipmentCategories then
			GUI.createButton(sceneGroup, okButtonX + okButtonWidth + 15, image.y + image.height / 2 - 120 * Game.guiScale, 145, 110 * Game.guiScale, nil, buttonType, function()
				if event.params.lockCallback then
					event.params.lockCallback()
				end
				return true
			end, 70, {
				image = {
					name = "icons/move.png",
					width = 72 * Game.guiScale,
					height = 72 * Game.guiScale
				}
			})
		elseif event.params.locked then
			GUI.createButton(sceneGroup, okButtonX + okButtonWidth + 15, image.y + image.height / 2 - 120 * Game.guiScale, 145, 110 * Game.guiScale, nil, buttonType, function()
				if event.params.unlockCallback then
					event.params.unlockCallback()
				end
				composer.hideOverlay("slideDown", 200)
				return true
			end, 70, {
				image = {
					name = "icons/lock_unlocked.png",
					width = 53.6 * Game.guiScale,
					height = 72 * Game.guiScale
				}
			})
		else
			GUI.createButton(sceneGroup, okButtonX + okButtonWidth + 15, image.y + image.height / 2 - 120 * Game.guiScale, 145, 110 * Game.guiScale, nil, buttonType, function()
				if event.params.lockCallback then
					event.params.lockCallback()
				end
				composer.hideOverlay("slideDown", 200)
				return true
			end, 70, {
				image = {
					name = "icons/lock_locked.png",
					width = 53.6 * Game.guiScale,
					height = 72 * Game.guiScale
				}
			})
		end
	end
	if event.params.titleText and not event.params.lockable and price < 30 and (item.type == Item.skin or item.type == Item.sticker) then
		okButtonWidth = okButtonWidth - 160
		GUI.createButton(sceneGroup, okButtonX + okButtonWidth + 15, image.y + image.height / 2 - 120 * Game.guiScale, 145, 110 * Game.guiScale, nil, buttonType, function(buttonEvent)
			Menu.removeAlert("Equipment")
			Game.sellEquipmentItem(Game.equipment[event.params.itemPosition], event.params.itemPosition, buttonEvent, true)
			composer.hideOverlay("slideDown", 200)
			return true
		end, 70, {
			image = {
				name = "icons/dustbin.png",
				width = 58.400000000000006 * Game.guiScale,
				height = 72 * Game.guiScale
			},
			blockTime = 250
		})
	end
	local okButtonText = "Ok"
	if event.params.newItem then
		okButtonText = choose(buttonTexts)
	end
	local okButton = GUI.createButton(sceneGroup, okButtonX, image.y + image.height / 2 - 120 * Game.guiScale, okButtonWidth, 110 * Game.guiScale, okButtonText, buttonType, function(event)
		composer.hideOverlay("slideDown", 200)
		return true
	end, 70)
	for i = 1, 15 do
		local shadow = display.newRoundedRect(sceneGroup, getCenterX(mainBox), getCenterY(mainBox) - 25, (636 - 2 * i) * Game.guiScale, (636 - 2 * i) * Game.guiScale, 20)
		shadow.anchorX = 0.5
		shadow.anchorY = 0.5
		shadow:setFillColor(unpack(RarityColors[item.rarity]))
		shadow.alpha = 0.05
	end
	local itemBackground = display.newRoundedRect(sceneGroup, getCenterX(mainBox), getCenterY(mainBox) - 25, 600 * Game.guiScale, 600 * Game.guiScale, 13)
	itemBackground.anchorX = 0.5
	itemBackground.anchorY = 0.5
	itemBackground:setFillColor(0, 0, 0, 0.75)
	if item.type == Item.skin and Game.isKnife(item.id) then
		local container = display.newContainer(itemBackground.width, itemBackground.height)
		sceneGroup:insert(container)
		local image = display.newImageRect(container, "images/itemeffect.png", 830.4 * Game.guiScale, 830.4 * Game.guiScale)
		image.anchorX = 0.5
		image.anchorY = 0.5
		image.alpha = 0.2
		local function rotate(item)
			if not item or not image.rotation then
				return
			end
			item.rotation = item.rotation + 0.5
			timer.performWithDelay(25, function()
				rotate(item)
			end)
		end
		timer.performWithDelay(25, function()
			rotate(image)
		end)
		container.x = itemBackground.x - itemBackground.width / 2
		container.y = itemBackground.y - itemBackground.height / 2
	end
	if item.type == Item.sticker and stickerBackgroundEffects[item.id] or item.type == Item.skin and skinBackgroundEffects[item.id] then
		local imagePath = "images/bgeffects/"
		if item.type == Item.skin then
			imagePath = imagePath .. skinBackgroundEffects[item.id]
		else
			imagePath = imagePath .. stickerBackgroundEffects[item.id]
		end
		local container = display.newContainer(itemBackground.width, itemBackground.height)
		sceneGroup:insert(container)
		local image = display.newImageRect(container, imagePath, 761.2 * Game.guiScale, 761.2 * Game.guiScale)
		image.anchorX = 0.5
		image.anchorY = 0.5
		image.alpha = 0.2
		container.x = itemBackground.x - itemBackground.width / 2
		container.y = itemBackground.y - itemBackground.height / 2
	end
	local itemImage
	if item.type == Item.case then
		itemImage = display.newImageRect(sceneGroup, "images/cases/" .. item.image, 482 * Game.guiScale, 352 * Game.guiScale)
	elseif item.type == Item.key then
		itemImage = display.newImageRect(sceneGroup, "images/keys/" .. item.image, 414 * Game.guiScale, 356 * Game.guiScale)
	elseif item.type == Item.skin then
		local path = "images/skins/" .. item.id
		if event.params.pattern then
			path = path .. "_" .. event.params.pattern
		end
		local imageWidth = 540
		local imageHeight = 450
		if Game.checkForItemNewImage(item.id, event.params.pattern) then
			imageWidth = 537.6
			imageHeight = 403.20000000000005
		end
		itemImage = display.newImageRect(sceneGroup, path .. ".png", imageWidth * Game.guiScale, imageHeight * Game.guiScale)
	elseif item.type == Item.glove then
		itemImage = display.newImageRect(sceneGroup, "images/gloves/" .. item.id .. ".png", 512 * Game.guiScale, 384 * Game.guiScale)
	elseif item.type == Item.capsule then
		itemImage = display.newImageRect(sceneGroup, "images/capsules/" .. item.image, 512 * Game.guiScale, 384 * Game.guiScale)
	elseif item.type == Item.sticker then
		local imageWidth = 538.1999999999999
		local imageHeight = 538.1999999999999
		if item.id > 587 then
			imageWidth = 535.04
			imageHeight = 401.28
		end
		itemImage = display.newImageRect(sceneGroup, "images/stickers/" .. item.id .. ".png", imageWidth * Game.guiScale, imageHeight * Game.guiScale)
	elseif item.type == Item.other then
		itemImage = display.newImageRect(sceneGroup, "images/otheritems/" .. item.image.path, item.image.width * 2.07 * Game.guiScale, item.image.height * 2.07 * Game.guiScale)
	end
	itemImage.x = getCenterX(mainBox)
	itemImage.y = getCenterY(mainBox) - 25
	itemImage.anchorX = 0.5
	itemImage.anchorY = 0.5
	if item.type == Item.skin and event.params.quality and event.params.quality ~= Quality.factorynew then
		local ss, se = item.name:find(" | ")
		local weaponName = item.name:sub(0, ss - 1):lower()
		if weaponName == "gut knife" and item.id >= 737 and item.id < 784 and not event.params.pattern then
			weaponName = "gut knife new"
		end
		if weaponName == "m9 bayonet" and item.id >= 737 and item.id < 784 and not event.params.pattern then
			weaponName = "m9 bayonet new"
		end
		if weaponName == "karambit" and item.id >= 737 and item.id < 784 and not event.params.pattern then
			weaponName = "karambit new"
		end
		if weaponName == "bayonet" and item.id >= 737 and item.id < 784 and not event.params.pattern then
			weaponName = "bayonet new"
		end
		local imageWidth = 540
		local imageHeight = 450
		if event.params.pattern or item.id >= 785 then
			weaponName = "_" .. weaponName
			imageWidth = 535.04
			imageHeight = 401.28
		end
		if weaponName == "_karambit" and event.params.pattern and item.id < 785 and item.id ~= 740 then
			weaponName = "_karambit old"
		end
		if weaponName == "_m9 bayonet" and event.params.pattern and item.id == 293 then
			weaponName = "_m9 bayonet old"
		end
		local scratchesImage = display.newImageRect(sceneGroup, "images/scratches/" .. weaponName .. ".png", imageWidth * Game.guiScale, imageHeight * Game.guiScale)
		if scratchesImage then
			scratchesImage.x = getCenterX(mainBox)
			scratchesImage.y = getCenterY(mainBox) - 25
			scratchesImage.anchorX = 0.5
			scratchesImage.anchorY = 0.5
			scratchesImage.alpha = scratchesAlphaTables[event.params.quality]
		end
	end
	local showQuality = true
	if item.type == Item.skin and Game.skins[item.id].dontShowQuality then
		showQuality = false
	end
	if event.params.quality and showQuality then
		local text = QualityNames[event.params.quality]:gsub("-", "@")
		if item.type == Item.skin and event.params.statTrak and Game.skins[item.id].souvenirAvailable then
			text = text .. " | Souvenir"
		end
		if event.params.pattern then
			local patternId = Game.skins[item.id].patterns[event.params.pattern]
			local patternName = PatternInfo[patternId].name
			text = text .. " | " .. patternName
		end
		local qualityText = PonyFont.newText({
			parent = sceneGroup,
			x = getCenterX(mainBox),
			y = mainBox.y + mainBox.height - 205 * Game.guiScale,
			text = text,
			font = BitmapFont.counterstrike,
			fontSize = 60 * Game.guiScale,
			align = "center"
		})
		if item.type == Item.glove then
			qualityText.y = itemBackground.y + itemBackground.height / 2 + 32
		end
		qualityText.anchorX = 0.5
		qualityText.anchorY = 0
	end
	if item.type == Item.skin and event.params.stickers then
		local stickers = event.params.stickers
		local count = math.min(4, #stickers)
		self.stickerImageGroup = display.newGroup()
		sceneGroup:insert(self.stickerImageGroup)
		local stickerPositions = {
			[1] = {0},
			[2] = {-0.4, 0.4},
			[3] = {
				-0.8,
				0,
				0.8
			},
			[4] = {
				-1.2,
				-0.4,
				0.4,
				1.2
			}
		}
		for i = 1, count do
			local dimensions = Stickers.getStickerImageDimensions(stickers[i])
			local width = dimensions.width * 0.7 * Game.guiScale
			local stickerImage = display.newImageRect(self.stickerImageGroup, "images/stickers/" .. stickers[i] .. ".png", width, dimensions.height * 0.7 * Game.guiScale)
			stickerImage.anchorX = 0.5
			stickerImage.anchorY = 0.5
			stickerImage.x = getCenterX(mainBox) + width * stickerPositions[count][i]
			stickerImage.y = itemBackground.y + itemBackground.height / 2 - 70
			stickerImage:addEventListener("tap", function()
				self:onStickerTap(stickerImage, stickers[i], i, function()
					table.remove(stickers, i)
					if #stickers == 0 then
						stickers = nil
					end
					event.params.stickerRemoveCallback()
					composer.showOverlay("overlays.itemoverlay", {
						isModal = true,
						effect = "slideDown",
						time = 200,
						params = event.params
					})
				end, itemBackground.x, getCenterY(itemBackground), itemBackground.width, itemBackground.height, event.params.stickable)
				return true
			end)
			table.insert(stickerImages, stickerImage)
		end
	end
	if item.type == Item.skin and event.params.statTrak and not Game.skins[item.id].statTrakAvailable then
		event.params.statTrak = false
	end
	if event.params.statTrak then
		local imageName = "stattrak.png"
		local imageWidth = 256
		local isChristmas = tonumber(os.date("%m")) == 12 and tonumber(os.date("%d")) >= 6
		if isChristmas and item.rarity == Rarity.red and event.params.titleText then
			imageWidth = 328
			imageName = "stattrak_christmas.png"
		end
		local imageHeight = imageWidth
		local statTrakImage = display.newImageRect(sceneGroup, "images/" .. imageName, imageWidth * Game.guiScale, imageHeight * Game.guiScale)
		statTrakImage.x = itemImage.x + itemImage.width * 0.5
		statTrakImage.y = itemImage.y + itemImage.height * 0.5
		if isChristmas and item.rarity == Rarity.red and event.params.titleText then
			statTrakImage.x = statTrakImage.x + 16
			statTrakImage.y = statTrakImage.y - 36
		end
		statTrakImage.anchorX = 0.5
		statTrakImage.anchorY = 0.5
	end
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
