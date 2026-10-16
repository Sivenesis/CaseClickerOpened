local composer = require("composer")
local scene = composer.newScene()
local item
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
	item = event.params.item
	local typeName = ucfirst(Lang.common.skin)
	local boxHeightMultiplier = 0.7
	local boxWidthMultiplier = 0.5
	if detectSquareScreen() then
		boxWidthMultiplier = 0.6
	end
	if item.type == Item.sticker then
		typeName = ucfirst(Lang.common.sticker)
		boxHeightMultiplier = 0.58
	end
	local mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * (1 - boxWidthMultiplier) / 2, display.safeActualContentHeight * (1 - boxHeightMultiplier) / 2, display.safeActualContentWidth * boxWidthMultiplier, display.safeActualContentHeight * boxHeightMultiplier, Lang.itemoverlay.iteminfo)
	mainBox:setFillColor(rgb(22, 30, 40))
	local lastY = mainBox.y + 40
	local name = item.name:gsub("-", "@")
	if 28 <= #name then
		name = name:sub(0, 28) .. "..."
	end
	local nameText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = lastY,
		text = name,
		font = Font.counterstrike,
		fontSize = 56,
		align = "center"
	})
	nameText.anchorX = 0.5
	FontOffset.setOffset(nameText)
	lastY = lastY + 120
	local typeTextOffsetY = 0
	if isIOS() then
		typeTextOffsetY = -30
	end
	local typeText = display.newText({
		parent = sceneGroup,
		x = nameText.x,
		y = lastY + typeTextOffsetY,
		width = mainBox.width - 50,
		height = 300,
		text = typeName,
		font = Font.counterstrike,
		fontSize = 52,
		align = "center"
	})
	typeText.anchorX = 0.5
	typeText:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(typeText)
	local itemPattern
	if item.type == Item.skin and Game.skins[item.id].patterns and item.pattern then
		itemPattern = PatternInfo[Game.skins[item.id].patterns[item.pattern]]
		typeText.text = itemPattern.name .. " | " .. typeText.text
	end
	local itemImage
	if item.type == Item.skin then
		local imagePath = "images/skins/" .. item.id
		if item.pattern then
			imagePath = imagePath .. "_" .. item.pattern
		end
		imagePath = imagePath .. ".png"
		itemImage = display.newImageRect(sceneGroup, imagePath, 189, 157.5)
	elseif item.type == Item.glove then
		itemImage = display.newImageRect(sceneGroup, "images/gloves/" .. item.id .. ".png", 189, 157.5)
	else
		local imageWidth = 208
		local imageHeight = 208
		if item.id > 587 then
			imageWidth = 204.8
			imageHeight = 153.60000000000002
		end
		itemImage = display.newImageRect(sceneGroup, "images/stickers/" .. item.id .. ".png", imageWidth, imageHeight)
	end
	itemImage.x = getCenterX(mainBox)
	itemImage.anchorX = 0.5
	itemImage.y = lastY
	itemImage.anchorY = 0
	lastY = lastY + itemImage.height + 10
	if item.type == Item.sticker then
		local priceText1 = display.newText({
			parent = sceneGroup,
			x = nameText.x,
			y = lastY,
			width = mainBox.width - 50,
			text = Lang.itemoverlay.price .. ":",
			font = Font.counterstrike,
			fontSize = 60,
			align = "center"
		})
		priceText1.anchorX = 0.5
		priceText1:setFillColor(unpack(Color.lightText))
		FontOffset.setOffset(priceText1)
		lastY = lastY + 70
		local priceText2 = display.newText({
			parent = sceneGroup,
			x = nameText.x,
			y = lastY,
			width = mainBox.width - 50,
			text = "$" .. formatPrice(Game.stickers[item.id].price),
			font = Font.counterstrike,
			fontSize = 70,
			align = "center"
		})
		priceText2.anchorX = 0.5
		FontOffset.setOffset(priceText2)
	else
		lastY = itemImage.y + itemImage.height
		local columns = {"", "Normal"}
		local prices = {}
		if item.type == Item.skin then
			prices = {
				QualityAbbreviations,
				Game.skins[item.id].prices.normal
			}
			if Game.skins[item.id].statTrakAvailable then
				table.insert(columns, "StatTrak")
				table.insert(prices, Game.skins[item.id].prices.statTrak)
			elseif Game.skins[item.id].souvenirAvailable then
				table.insert(columns, "Souvenir")
				table.insert(prices, Game.skins[item.id].prices.statTrak)
			end
		else
			prices = {
				QualityAbbreviations,
				Game.gloves[item.id].prices
			}
		end
		for i = 1, #columns do
			local columnX = mainBox.x + mainBox.width / 2
			if 2 < #columns then
				if i == 1 then
					columnX = columnX - mainBox.width * 0.33
				elseif i == 2 then
					columnX = columnX - mainBox.width * 0.1
				else
					columnX = columnX + mainBox.width * 0.25
				end
			elseif i == 1 then
				columnX = columnX - mainBox.width * 0.25
			else
				columnX = columnX + mainBox.width * 0.25
			end
			local columnNameText = display.newText({
				parent = sceneGroup,
				x = columnX,
				y = lastY,
				width = mainBox.width - 50,
				text = columns[i],
				font = Font.counterstrike,
				fontSize = 60,
				align = "center"
			})
			columnNameText.anchorX = 0.5
			FontOffset.setOffset(columnNameText)
			columnNameText:setFillColor(unpack(Color.lightText))
			for j = 1, #prices[i] do
				local allowed = true
				local displayText = prices[i][j]
				if 1 < i then
					local priceMultiplier = 1
					if itemPattern then
						priceMultiplier = itemPattern.priceMultiplier
					end
					displayText = "$" .. formatPrice(tonumber(prices[i][j]) * priceMultiplier)
					if not Game.isQualityAvailable(item.id, j) then
						displayText = "@@"
					end
				end
				local text = display.newText({
					parent = sceneGroup,
					x = columnX,
					y = lastY + 50 * j + 20,
					width = columnX,
					text = displayText,
					font = Font.counterstrike,
					fontSize = 40,
					align = "center"
				})
				text.anchorX = 0.5
				FontOffset.setOffset(text)
				if i == 1 then
					text:setFillColor(unpack(Color.lightText))
				end
			end
		end
	end
	GUI.createButton(sceneGroup, getCenterX(mainBox) - mainBox.width * 0.3, mainBox.y + mainBox.height - 160, mainBox.width * 0.6, 120, "Ok", ButtonType.green, function()
		composer.hideOverlay("slideDown", 200)
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
