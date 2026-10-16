local widget = require("widget")
local composer = require("composer")
Checkbox = require("gui.checkbox")
TextSlider = require("gui.textslider")
Button = require("gui.button")
SelectionList = require("gui.selectionlist")
TextInput = require("gui.textinput")
local gui = {}
gui.holdTimer = nil
local backgroundGroup
local buttonImages = {
	[ButtonType.default] = "button_default.png",
	[ButtonType.darkblue] = "button_default.png",
	[ButtonType.green] = "button_green.png",
	[ButtonType.orange] = "button_orange.png",
	[ButtonType.red] = "button_red.png",
	[ButtonType.gray] = "button_gray.png",
	[ButtonType.lightblue] = "button_lightblue.png",
	[ButtonType.pink] = "button_pink.png",
	[ButtonType.purple] = "button_purple.png",
	[ButtonType.blue] = "button_blue.png",
	[ButtonType.yellow] = "button_yellow.png",
	[ButtonType.black] = "button_black.png",
	[ButtonType.gold] = "button_gold.png"
}
local lastTouch = 0
function gui.backgroundToBack()
	backgroundGroup:toBack()
end
function gui.createBackground()
	backgroundGroup = display.newGroup()
	local bgRect = display.newRect(backgroundGroup, 0, 0, display.safeActualContentWidth, display.safeActualContentHeight)
	bgRect:setFillColor(rgb(16, 20, 26))
end
function gui.createItemBox(sceneGroup, item, x, y, statTrak, scale, options)
	options = options or {}
	scale = scale or 1
	if not options.dontUseGUIScale then
		scale = scale * Game.guiScale
	end
	local group = display.newGroup()
	group.x = x
	group.y = y
	local imagePath
	local imageWidth = 241 * scale
	local imageHeight = 176 * scale
	local pattern
	if options.image then
		imagePath = options.image.path
		imageWidth = options.image.width * scale
		imageHeight = options.image.height * scale
		item.rarity = options.rarity or Rarity.blue
		item.name = options.name or "???"
		options.center = true
	elseif item.type == Item.case then
		imagePath = "images/cases/" .. Game.cases[item.id].image
		item.rarity = Game.cases[item.id].rarity
		item.name = Game.cases[item.id].name
		options.center = true
	elseif item.type == Item.sticker then
		imagePath = "images/stickers/" .. item.id .. ".png"
		item.rarity = Game.stickers[item.id].rarity
		item.name = Game.stickers[item.id].name
		local dimensions = Stickers.getStickerImageDimensions(item.id)
		imageWidth = dimensions.width * 0.84 * scale
		imageHeight = dimensions.height * 0.84 * scale
	elseif item.type == Item.key then
		imagePath = "images/keys/" .. Game.keys[item.id].image
		imageWidth = 178.20000000000002 * scale
		imageHeight = 178.20000000000002 * scale
		item.rarity = Rarity.purple
		item.name = Game.keys[item.id].name
		options.center = true
	elseif item.type == Item.skin then
		imagePath = "images/skins/" .. item.id
		if item.pattern then
			pattern = item.pattern
		elseif options.pattern then
			pattern = options.pattern
		end
		if pattern then
			imagePath = imagePath .. "_" .. (item.pattern or options.pattern)
		end
		imagePath = imagePath .. ".png"
		if Game.checkForItemNewImage(item.id, pattern) then
			imageWidth = 276.48 * scale
			imageHeight = 207.36 * scale
		else
			imageWidth = 270 * scale
			imageHeight = 225 * scale
		end
		imageWidth = imageWidth * 1.04
		imageHeight = imageHeight * 1.04
		item.rarity = Game.skins[item.id].rarity
		item.name = Game.skins[item.id].name
		options.statTrakAvailable = Game.skins[item.id].statTrakAvailable
		options.souvenirAvailable = Game.skins[item.id].souvenirAvailable
		if statTrak and not Game.skins[item.id].statTrakAvailable and not Game.skins[item.id].souvenirAvailable then
			statTrak = false
		end
	elseif item.type == Item.rare then
		imagePath = KnifeGroups[item.id].image
		imageWidth = KnifeGroups[item.id].width * scale
		imageHeight = KnifeGroups[item.id].height * scale
		item.name = KnifeGroups[item.id].name
		item.rarity = Rarity.gold
	elseif item.type == Item.rareGlove then
		imagePath = GloveGroups[item.id].image
		imageWidth = GloveGroups[item.id].width * scale
		imageHeight = GloveGroups[item.id].height * scale
		item.name = GloveGroups[item.id].name
		item.rarity = Rarity.gold
	elseif item.type == Item.unknown then
		imagePath = "images/knifes/all.png"
		imageWidth = 256 * scale
		imageHeight = 198 * scale
		item.rarity = Rarity.gold
		item.name = Lang.dailies.available
	elseif item.type == Item.other then
		imagePath = "images/otheritems/" .. Game.otherItems[item.id].image.path
		imageWidth = Game.otherItems[item.id].image.width * scale
		imageHeight = Game.otherItems[item.id].image.height * scale
		item.rarity = Rarity.gold
	elseif item.type == Item.glove then
		imagePath = "images/gloves/" .. item.id .. ".png"
		item.rarity = Game.gloves[item.id].rarity
		item.name = Game.gloves[item.id].name
		imageWidth = 256 * scale
		imageHeight = 192 * scale
	end
	if options.highlight then
		local highlight = display.newImageRect(group, HighlightImages[item.rarity], 435 * scale, 435 * scale)
		highlight.x = -45 * scale
		highlight.y = -45 * scale
	end
	local backgroundImage = display.newImageRect(group, RarityImages[item.rarity], 345 * scale, 345 * scale)
	if options.infoOnClick then
		backgroundImage:addEventListener("tap", function()
			Game.showItemInfo(item)
			return true
		end)
	end
	local itemImage = display.newImageRect(group, imagePath, imageWidth, imageHeight)
	itemImage = itemImage or display.newImageRect(group, "images/avatars/you.jpg", imageWidth, imageHeight)
	itemImage.anchorX = 0.5
	itemImage.anchorY = 0.5
	itemImage.x = getCenterX(backgroundImage)
	itemImage.y = getCenterY(backgroundImage) - 40
	if imageHeight > 230 * scale then
		itemImage.y = getCenterY(backgroundImage) - 50
	end
	local name = item.name or Lang.gui.unknownitem
	name = name:gsub(" | ", "\r\n"):gsub(" Case", ""):gsub("Holo", "H"):gsub("Foil", "F")
	if item.type == Item.sticker then
		name = name:gsub("Red", "R"):gsub("Blue", "B")
	end
	if item.type == Item.sticker and not name:find("\r\n") then
		name = name .. "\r\nSticker"
	end
	local strings = string.explode(name, "\r\n")
	if item.n and item.type == Item.skin and not options.noNameTag then
		local success, str = EquipmentManager.validateName(item.n)
		if success then
			strings[2] = "\"" .. item.n .. "\""
		else
			item.n = nil
		end
	end
	if strings[2] and pattern then
		local patternId = Game.skins[item.id].patterns[pattern]
		local patternName = PatternInfo[patternId].abbreviation
		strings[2] = strings[2] .. " (" .. patternName .. ")"
	end
	if statTrak and item.type ~= Item.rare and options.statTrakAvailable then
		strings[1] = strings[1] .. " (StatTrak)"
	end
	if statTrak and item.type ~= Item.rare and options.souvenirAvailable then
		strings[1] = "Souvenir " .. strings[1]
	end
	for i = 1, #strings do
		if 18 <= #strings[i] then
			strings[i] = strings[i]:sub(0, 17) .. "..."
		end
	end
	name = strings[1]
	if strings[2] then
		name = name .. "\r\n" .. strings[2]
	end
	local fontSize = 34
	fontSize = fontSize * scale
	local align = "left"
	local xPos = backgroundImage.x + 10
	if options.center or item.type == Item.rare or item.type == Item.rareGlove then
		align = "center"
		xPos = getCenterX(backgroundImage)
	end
	local textY = backgroundImage.y + backgroundImage.height - 52
	if 1 > Game.guiScale then
		textY = backgroundImage.y + 0.85 * backgroundImage.height
	end
	local bgText = display.newText({
		parent = group,
		x = xPos + 1,
		y = textY + 1,
		text = name,
		font = Font.default,
		fontSize = fontSize,
		width = backgroundImage.width,
		align = align
	})
	bgText.anchorY = 0.5
	bgText:setFillColor(unpack(Color.black))
	local nameText = display.newText({
		parent = group,
		x = xPos,
		y = textY,
		text = name,
		font = Font.default,
		fontSize = fontSize,
		width = backgroundImage.width,
		align = align
	})
	nameText.anchorY = 0.5
	nameText:setFillColor(unpack(Color.white))
	if options.center or item.type == Item.rare or item.type == Item.rareGlove then
		bgText.anchorX = 0.5
		nameText.anchorX = 0.5
	end
	if options.showPrice or options.additionalText then
		local text = ""
		if options.showPrice then
			text = "$" .. formatPrice(Game.getItemPrice({
				id = item.id,
				n = item.n,
				type = item.type,
				statTrak = statTrak,
				pattern = options.pattern,
				quality = options.quality
			}))
		else
			text = options.additionalText
		end
		local priceText = display.newText({
			parent = group,
			x = backgroundImage.x + 7,
			y = backgroundImage.y + 6,
			text = text,
			font = Font.default,
			fontSize = 30 * Game.guiScale,
			align = "center"
		})
		priceText.anchorX = 0
		priceText:setFillColor(unpack(Color.mainText))
	end
	local showQuality = true
	if item.type == Item.skin and Game.skins[item.id].dontShowQuality then
		showQuality = false
	end
	if options.quality and (item.type == Item.skin or item.type == Item.glove) and QualityAbbreviations[options.quality] and showQuality then
		local qualityText = display.newText({
			parent = group,
			x = backgroundImage.x + backgroundImage.width - 6,
			y = backgroundImage.y + 6,
			text = QualityAbbreviations[options.quality],
			font = Font.default,
			fontSize = 30 * Game.guiScale,
			align = "center"
		})
		qualityText.anchorX = 1
		nameText:setFillColor(unpack(Color.mainText))
	end
	if item.type == Item.skin and options.stickers and not Game.isKnife(item.id) then
		local count = math.min(4, #options.stickers)
		local lastX = backgroundImage.x
		for i = 1, count do
			local dimensions = Stickers.getStickerImageDimensions(options.stickers[i])
			local stickerImage = display.newImageRect(group, "images/smallstickers/" .. options.stickers[i] .. ".png", dimensions.width * Game.guiScale * 0.35, dimensions.height * Game.guiScale * 0.35)
			stickerImage = stickerImage or display.newImageRect(group, "images/stickers/" .. options.stickers[i] .. ".png", dimensions.width * Game.guiScale * 0.35, dimensions.height * Game.guiScale * 0.35)
			stickerImage.anchorX = 0
			stickerImage.anchorY = 0.5
			stickerImage.x = lastX - 10
			stickerImage.y = backgroundImage.y + backgroundImage.height * 0.58
			lastX = lastX + stickerImage.width * 0.75
		end
	end
	if statTrak and item.type ~= Item.rare and options.statTrakAvailable or options.showStatTrak then
		local statTrakImage = display.newImageRect(group, "images/stattrak96.png", 96 * scale, 96 * scale)
		statTrakImage.x = itemImage.x + itemImage.width * 0.5
		statTrakImage.y = itemImage.y + itemImage.height * 0.52
		statTrakImage.anchorX = 0.5
		statTrakImage.anchorY = 0.5
	end
	sceneGroup:insert(group)
	return group
end
function gui.drawMainBox(sceneGroup, text, drawCorners, options)
	options = options or {}
	local corners = true
	if type(drawCorners) ~= "nil" then
		corners = drawCorners
	end
	return GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.25 + 10, 10, display.safeActualContentWidth - display.safeActualContentWidth * 0.25 - 20, display.safeActualContentHeight - 20, text, corners, options)
end
function gui.showAnimatedText(parent, text, x, y, color, size)
	if not x or not y then
		return
	end
	local size = size or math.random(66, 74)
	local titleText = PonyFont.newText({
		parent = parent,
		x = x,
		y = y - 11,
		text = text,
		font = BitmapFont.counterstrike,
		fontSize = size,
		align = "center"
	})
	titleText.anchorX = 0.5
	titleText.anchorY = 1
	if color then
		titleText:setFillColor(unpack(color))
	end
	transition.to(titleText, {
		time = 900,
		y = titleText.y - 95,
		alpha = 0,
		onComplete = function()
			titleText:removeSelf()
			titleText = nil
		end
	})
end
function gui.showMessageBox(title, text, okButton, okButtonCallback)
	text = text or ""
	if type(okButton) == "nil" then
		okButton = true
	end
	local options = {
		isModal = true,
		effect = "fade",
		time = 300,
		params = {
			title = title,
			text = text,
			okButton = okButton,
			okButtonCallback = okButtonCallback
		}
	}
	composer.showOverlay("overlays.messagebox", options)
end
local function buttonHoldCheck(event, buttonGroup, options, lastTime)
	if not buttonGroup.touching then
		return
	end
	if options.holdCallback then
		audio.play(Game.sounds.click, {
			channel = audio.findFreeChannel()
		})
		if options.holdCallback(event) == true then
			gui.holdTimer = nil
			return true
		end
		if 100 < lastTime then
			lastTime = lastTime * 0.75
		end
		gui.holdTimer = timer.performWithDelay(lastTime, function()
			buttonHoldCheck(event, buttonGroup, options, lastTime)
		end)
		return
	end
	buttonGroup.touching = false
end
function gui.createButton(parent, x, y, width, height, text, buttonType, callback, textSize, options)
	local options = options or {}
	local buttonGroup = display.newGroup()
	local background = display.newImageRect(buttonGroup, "images/gui/" .. buttonImages[buttonType], width, height)
	background.x = x
	background.y = y
	local blackOverlay = display.newRect(buttonGroup, x, y, width, height)
	blackOverlay:setFillColor(unpack(Color.black))
	blackOverlay.alpha = 0
	if text then
		local fontSize = textSize or width / #text * 1.5
		local font = Font.counterstrike
		if options.font then
			font = options.font
		end
		local buttonText = display.newText({
			parent = buttonGroup,
			x = getCenterX(background),
			y = getCenterY(background),
			text = text,
			width = width,
			font = font,
			fontSize = fontSize * Game.guiScale,
			align = "center"
		})
		buttonText.anchorX = 0.5
		buttonText.anchorY = 0.5
		FontOffset.setOffset(buttonText)
		buttonGroup.buttonText = buttonText
		buttonGroup.text = buttonText
	else
		local image = display.newImageRect(buttonGroup, "images/" .. options.image.name, options.image.width, options.image.height)
		image.x = background.x + background.width / 2
		image.y = background.y + background.height / 2
		image.anchorX = 0.5
		image.anchorY = 0.5
	end
	function buttonGroup:setText(newText)
		if self.buttonText then
			self.buttonText.text = tostring(newText or "")
		end
	end
	function buttonGroup:getText()
		if self.buttonText then
			return self.buttonText.text
		end
		return nil
	end
	parent:insert(buttonGroup)
	buttonGroup.touching = false
	buttonGroup.touchStart = 0
	if options.callbackAsHoldCallback then
		options.holdCallback = callback
	end
	if not callback then
		return buttonGroup
	end
	if options.holdCallback then
		local blockTime = options.blockTime or 0
		background:addEventListener("tap", function(event)
			if system.getTimer() - lastTouch < blockTime or Game.blockButtons then
				return false
			end
			audio.play(Game.sounds.click, {
				channel = audio.findFreeChannel()
			})
			callback(event)
			lastTouch = system.getTimer()
			blackOverlay.alpha = 0
			display.currentStage:setFocus(nil)
			return true
		end)
		background:addEventListener("touch", function(event)
			if event.phase == "began" then
				blackOverlay.alpha = 0.1
				buttonGroup.touching = true
				buttonGroup.touchStart = system.getTimer()
				local holdStartTime = options.holdStartTime or 750
				gui.holdTimer = timer.performWithDelay(holdStartTime, function()
					buttonHoldCheck(event, buttonGroup, options, holdStartTime)
				end)
				display.currentStage:setFocus(background)
			elseif event.phase == "ended" then
				blackOverlay.alpha = 0
				display.currentStage:setFocus(nil)
				if gui.holdTimer then
					timer.cancel(gui.holdTimer)
					gui.holdTimer = nil
				end
				if buttonGroup.touching == false then
					return
				end
				buttonGroup.touching = false
			end
			return true
		end)
	else
		local blockTime = options.blockTime or 0
		background:addEventListener("tap", function(event)
			if system.getTimer() - lastTouch < blockTime or Game.blockButtons then
				return false
			end
			audio.play(Game.sounds.click, {
				channel = audio.findFreeChannel()
			})
			callback(event)
			lastTouch = system.getTimer()
			blackOverlay.alpha = 0
			return true
		end)
		if not options.noTapEffect then
			background:addEventListener("touch", function(event)
				if event.phase == "began" then
					blackOverlay.alpha = 0.1
					display.currentStage:setFocus(background)
				elseif event.phase == "ended" then
					blackOverlay.alpha = 0
					display.currentStage:setFocus(nil)
				end
				return true
			end)
		end
	end
	return buttonGroup
end
function gui.createBox(sceneGroup, x, y, width, height, title, drawCorners, options)
	options = options or {}
	width = display.getNearestHorizontalPixel(width)
	height = display.getNearestVerticalPixel(height)
	x = display.getNearestHorizontalPixel(x) + display.safeScreenOriginX
	y = display.getNearestVerticalPixel(y) + display.safeScreenOriginY
	local pixelWidth = display.pixelWidth
	local pixelHeight = display.pixelHeight
	local smallBox = false
	if width / display.safeActualContentWidth < 0.4 then
		smallBox = true
	end
	local headerHeight = display.getNearestHorizontalPixel(58)
	local backgroundRectangleStroke = display.newRect(sceneGroup, x, y + headerHeight, width, height - headerHeight)
	backgroundRectangleStroke:setFillColor(unpack(Color.contourLine))
	local backgroundRectangle = display.newRect(sceneGroup, x + pixelWidth, y + headerHeight, width - 2 * pixelWidth, height - headerHeight - pixelHeight)
	backgroundRectangle:setFillColor(unpack(Color.boxBackground))
	local shadow = display.newImageRect(sceneGroup, "images/gui/box_shadow.png", backgroundRectangle.width, backgroundRectangle.height)
	shadow.x = backgroundRectangle.x
	shadow.y = backgroundRectangle.y
	local topRectangleStroke = display.newRect(sceneGroup, x, y, width, headerHeight)
	topRectangleStroke:setFillColor(unpack(Color.contourLine))
	local topRectangle = display.newRect(sceneGroup, x + pixelWidth, y + pixelHeight, width - 2 * pixelWidth, headerHeight - 2 * pixelHeight)
	topRectangle:setFillColor(unpack(Color.boxBackground))
	local headerBackground = display.newImageRect(sceneGroup, "images/gui/box_header.png", width - 2 * pixelWidth, headerHeight - 2 * pixelHeight)
	headerBackground.x = x + pixelWidth
	headerBackground.y = y + pixelHeight
	local ornamentFileName = "box_top_ornament.png"
	local ornamentWidth = 256
	local ornamentHeight = 45
	local scale = (headerHeight - 2 * pixelHeight) / 45
	local topLeftRectangleOrnament = display.newImageRect(sceneGroup, "images/gui/" .. ornamentFileName, ornamentWidth * scale, ornamentHeight * scale)
	topLeftRectangleOrnament.x = x
	topLeftRectangleOrnament.y = y
	local topRightRectangleOrnament = display.newImageRect(sceneGroup, "images/gui/" .. ornamentFileName, ornamentWidth * scale, ornamentHeight * scale)
	topRightRectangleOrnament.x = x + width
	topRightRectangleOrnament.y = y + pixelHeight
	topRightRectangleOrnament.xScale = -1
	local fontSize = 50
	if smallBox then
		fontSize = 42
	end
	local textOptions = {
		parent = sceneGroup,
		x = getCenterX(topRectangle),
		y = topRectangle.y + topRectangle.height / 2,
		text = title,
		font = Font.counterstrike,
		fontSize = fontSize,
		align = "center"
	}
	local titleText = display.newText(textOptions)
	titleText:setFillColor(unpack(Color.lightText))
	titleText.anchorX = 0.5
	titleText.anchorY = 0.5
	FontOffset.setOffset(titleText)
	if options.image then
		local backgroundImage = display.newImageRect(sceneGroup, options.image, width, height - 56)
		backgroundImage.x = x
		backgroundImage.y = y + 56
		backgroundImage.alpha = 0.1
	end
	local corners = true
	if type(drawCorners) ~= "nil" then
		corners = drawCorners
	end
	if not corners then
		return backgroundRectangle
	end
	local cornerWidth = 21 * pixelWidth
	local cornerHeight = 23 * pixelHeight
	local topLeftCorner, topRightCorner
	topRightCorner = display.newImageRect(sceneGroup, "images/gui/corner_top.png", cornerWidth, cornerHeight)
	topRightCorner.x = x + width - cornerWidth
	topRightCorner.y = backgroundRectangle.y - pixelHeight
	topRightCorner.anchorX = 1
	topRightCorner.anchorY = 0
	topRightCorner.xScale = -1
	topLeftCorner = display.newImageRect(sceneGroup, "images/gui/corner_top.png", cornerWidth, cornerHeight)
	topLeftCorner.x = backgroundRectangle.x
	topLeftCorner.y = backgroundRectangle.y - pixelHeight
	topLeftCorner.anchorX = 0
	topLeftCorner.anchorY = 0
	topLeftRectangleOrnament:toFront()
	topRightRectangleOrnament:toFront()
	local bottomLeftCorner = display.newImageRect(sceneGroup, "images/gui/bottom_corner.png", cornerWidth, cornerHeight)
	bottomLeftCorner.x = x
	bottomLeftCorner.y = backgroundRectangle.y + backgroundRectangle.height + pixelHeight
	bottomLeftCorner.anchorX = 0
	bottomLeftCorner.anchorY = 1
	local bottomRightCorner = display.newImageRect(sceneGroup, "images/gui/bottom_corner.png", cornerWidth, cornerHeight)
	bottomRightCorner.x = x + width - cornerWidth
	bottomRightCorner.y = y + height
	bottomRightCorner.anchorX = 1
	bottomRightCorner.anchorY = 1
	bottomRightCorner.xScale = -1
	function backgroundRectangle:moveTopCorners(moveX, moveY)
		if not topLeftCorner then
			return false
		end
		topLeftCorner.x = topLeftCorner.x + moveX
		topLeftCorner.y = topLeftCorner.y + moveY
		topRightCorner.x = topRightCorner.x + moveX
		topRightCorner.y = topRightCorner.y + moveY
	end
	function backgroundRectangle.cornersToFront()
		if smallBox then
			topLeftRectangleOrnament:toFront()
			topRightRectangleOrnament:toFront()
		else
			topLeftCorner:toFront()
			topRightCorner:toFront()
		end
		bottomLeftCorner:toFront()
		bottomRightCorner:toFront()
	end
	return backgroundRectangle
end
local displayingInfoBox = false
function gui.showInfoBox(firstText, secondText, boxType)
	if displayingInfoBox then
		timer.performWithDelay(1000, function()
			gui.showInfoBox(firstText, secondText, boxType)
		end, 1)
		return true
	end
	local resize = 0.53
	local boxType = boxType or InfoBoxType.padlock
	local image = "infoboxes/padlock.png"
	if boxType == InfoBoxType.chest then
		image = "infoboxes/chest.png"
		resize = 1
	elseif boxType == InfoBoxType.experience then
		image = "infoboxes/expbonus.png"
	elseif boxType == InfoBoxType.coin then
		image = "infoboxes/coin.png"
	elseif boxType == InfoBoxType.rank then
		image = "expranks/" .. Game.expRank .. ".png"
		resize = 0.65
	end
	local group = display.newGroup()
	displayingInfoBox = true
	local rectX = 0.25
	local rectWidth = 0.5
	if 22 < #secondText then
		rectX = 0.2
		rectWidth = 0.6
	end
	local backgroundRectangle = display.newRoundedRect(group, display.safeScreenOriginX + display.safeActualContentWidth * rectX, display.safeActualContentHeight * 1, display.safeActualContentWidth * rectWidth, display.safeActualContentHeight * 0.14, 25)
	backgroundRectangle:setFillColor(rgb(38, 48, 65))
	backgroundRectangle.strokeWidth = 3
	backgroundRectangle:setStrokeColor(rgb(73, 92, 123))
	local padlock = display.newImageRect(group, "images/" .. image, 250 * resize, 250 * resize)
	padlock.anchorY = 0.5
	padlock.x = backgroundRectangle.x + 20
	padlock.y = backgroundRectangle.y + backgroundRectangle.height / 2
	local unlockedText = display.newText({
		parent = group,
		x = padlock.x + padlock.width + 35,
		y = backgroundRectangle.y + 35,
		text = firstText,
		font = Font.counterstrike,
		fontSize = 52,
		align = "left"
	})
	unlockedText:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(unlockedText)
	local fontSize = 68
	if 25 <= secondText:len() then
		fontSize = 48
	elseif secondText:len() >= 15 then
		fontSize = 56
	end
	local nameText = display.newText({
		parent = group,
		x = unlockedText.x,
		y = unlockedText.y + unlockedText.height + 28,
		text = secondText,
		font = Font.counterstrike,
		fontSize = fontSize,
		align = "left"
	})
	FontOffset.setOffset(nameText)
	group.alpha = 0
	local opacityStep = 0
	timer.performWithDelay(120, function()
		transition.to(group, {
			alpha = 1,
			y = group.y - 195,
			time = 700,
			onComplete = function()
				timer.performWithDelay(900, function()
					transition.to(group, {
						alpha = 0,
						y = group.y + 195,
						time = 700,
						onComplete = function()
							group:removeSelf()
							group = nil
							displayingInfoBox = false
						end
					})
				end)
			end
		})
	end)
end
function gui.drawHorizontalLine(sceneGroup, x, y, width)
	local line = display.newImageRect(sceneGroup, "images/gui/horizontal_line.png", width, 6)
	line.x = x
	line.y = y
	return line
end
function gui.drawVerticalLine(sceneGroup, x, y, height)
	local line = display.newImageRect(sceneGroup, "images/gui/vertical_line.png", 6, height)
	line.x = x
	line.y = y
	return line
end
function gui.showConfirmationWindow(boxName, text, yesButtonCallback, noButtonCallback, overlay)
	composer.removeScene("overlays.confirmationwindow")
	local options = {
		params = {
			boxName = boxName,
			text = text,
			yesButtonCallback = yesButtonCallback,
			noButtonCallback = noButtonCallback,
			overlay = overlay
		}
	}
	if overlay then
		options.isModal = true
		composer.showOverlay("overlays.confirmationwindow", options)
	else
		composer.gotoScene("overlays.confirmationwindow", options)
	end
end
return gui
