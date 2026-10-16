local composer = require("composer")
local scene = composer.newScene()
local price = 0
local priceText, totalText1, totalText2, totalText3, itemsToSell, totalPrice
local items = {}
local okButtonCallback
local function updateTexts()
	priceText.text = "$" .. formatPrice(price)
	itemsToSell = 0
	totalPrice = 0
	for i = 1, #items do
		if not Game.equipment[items[i]].locked then
			local itemPrice = Game.getPrice(Game.equipment[items[i]])
			if itemPrice <= price then
				itemsToSell = itemsToSell + 1
				totalPrice = totalPrice + itemPrice
			end
		end
	end
	local items = Lang.common.items
	if itemsToSell == 1 then
		items = Lang.common.item
	end
	totalText2.text = itemsToSell .. " " .. items
	totalText3.text = "$" .. formatPrice(totalPrice)
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
	local mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.1, display.safeActualContentHeight * 0.19, display.safeActualContentWidth * 0.8, display.safeActualContentHeight * 0.62, Lang.itemSell.sellItems)
	local firstText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = mainBox.y + 48,
		text = Lang.itemSell.sellItemsThatCost .. ":",
		font = Font.counterstrike,
		fontSize = 72,
		align = "center"
	})
	firstText.anchorX = 0.5
	FontOffset.setOffset(firstText)
	priceText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = firstText.y + firstText.height + 70,
		text = "$0.00",
		font = Font.counterstrike,
		fontSize = 100,
		align = "center"
	})
	priceText.anchorX = 0.5
	priceText:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(priceText)
	GUI.createButton(sceneGroup, priceText.x + 300, priceText.y - 25, 130, 130, "+", ButtonType.green, function(event)
		price = price + 0.1
		updateTexts()
	end, 70, {
		font = Font.default,
		callbackAsHoldCallback = true
	})
	GUI.createButton(sceneGroup, priceText.x - 300 - 130, priceText.y - 25, 130, 130, "-", ButtonType.green, function(event)
		if price <= 0 then
			price = 0
			return
		end
		price = price - 0.1
		updateTexts()
	end, 70, {
		font = Font.default,
		callbackAsHoldCallback = true
	})
	local secondText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = priceText.y + 130,
		text = Lang.itemSell.orLess,
		font = Font.counterstrike,
		fontSize = 72,
		align = "center"
	})
	secondText.anchorX = 0.5
	FontOffset.setOffset(secondText)
	totalText1 = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = secondText.y + secondText.height + 30,
		text = Lang.itemSell.total .. ":",
		font = Font.counterstrike,
		width = mainBox.width,
		fontSize = 72,
		align = "center"
	})
	totalText1.anchorX = 0.5
	totalText1:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(totalText1)
	totalText2 = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = totalText1.y + totalText1.height + 25,
		text = "",
		font = Font.counterstrike,
		width = mainBox.width,
		fontSize = 56,
		align = "center"
	})
	totalText2.anchorX = 0.5
	FontOffset.setOffset(totalText2)
	totalText3 = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = totalText2.y + totalText2.height + 25,
		text = "",
		font = Font.counterstrike,
		width = mainBox.width,
		fontSize = 56,
		align = "center"
	})
	totalText3.anchorX = 0.5
	FontOffset.setOffset(totalText3)
	local okButton = GUI.createButton(sceneGroup, mainBox.x + 170 + ((mainBox.width - 340) / 2 + 20), mainBox.y + mainBox.height - 150, (mainBox.width - 340) / 2, 120, Lang.itemSell.sellItemsButton, ButtonType.green, function(event)
		GUI.showMessageBox("Selling items", "Please wait...", false)
		timer.performWithDelay(200, function()
			for i = #items, 1, -1 do
				if not Game.equipment[items[i]].locked then
					local itemPrice = Game.getPrice(Game.equipment[items[i]])
					if itemPrice <= price then
						Game.sellEquipmentItem(Game.equipment[items[i]], items[i], nil, true)
					end
				end
			end
			GUI.showMessageBox(Lang.itemSell.itemsSold, Lang.itemSell.itemsSoldMessage .. " " .. itemsToSell .. " " .. Lang.common.items .. "\r\n" .. Lang.sellConfirmation.forr .. " $" .. formatPrice(totalPrice), true, function()
				okButtonCallback()
				composer.hideOverlay()
			end)
			Game.recalculateEquipmentWorth()
		end)
	end, 70)
	local cancelButton = GUI.createButton(sceneGroup, mainBox.x + 170, mainBox.y + mainBox.height - 150, (mainBox.width - 340) / 2, 120, Lang.common.back, ButtonType.default, function(event)
		composer.hideOverlay()
	end, 70)
	updateTexts()
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		items = event.params.items
		okButtonCallback = event.params.callback
		if priceText then
			price = tonumber(event.params.maximumPrice)
			updateTexts()
		end
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
