local widget = require("widget")
local ProgressBar = require("gui.progressbar")
local UpgraderManager = require("managers.UpgraderManager")
local selectedItem
local scene = composer.newScene()
local sceneGroup
local arrows = {}
local upgradeButtons = {}
local actualArrow = 1
local actualUpgradeButton = 1
local upgradeAnimation = false
local upgradeTypes = {
	{value = 1.5, chance = 60},
	{
		value = 2,
		chance = 45,
		maxItemPrice = 300
	},
	{
		value = 5,
		chance = 15,
		maxItemPrice = 120
	}
}
local function updateArrows()
	for i = 1, #arrows do
		if i == actualArrow then
			arrows[i]:setFillColor(unpack(ColorTools.lighten(Color.row, 2.8)))
		else
			arrows[i]:setFillColor(unpack(ColorTools.lighten(Color.row, 1.8)))
		end
	end
end
local lastArrowTime = system.getTimer()
local function upgraderEnterFrame(event)
	if upgradeAnimation then
		return true
	end
	if event.time - lastArrowTime >= 700 then
		lastArrowTime = event.time
		actualArrow = actualArrow + 1
		if actualArrow > #arrows then
			actualArrow = 1
		end
		updateArrows()
	end
end
local function updateUpgradeButtons()
	for i = 1, #upgradeButtons do
		if actualUpgradeButton == i then
			upgradeButtons[i]:setType(ButtonType.purple)
		else
			upgradeButtons[i]:setType(ButtonType.default)
		end
	end
	if UpgraderManager.getSelectedItemPrice() then
		local itemPrice = UpgraderManager.getSelectedItemPrice()
		for i = 1, #upgradeButtons do
			if upgradeTypes[i].maxItemPrice and itemPrice > upgradeTypes[i].maxItemPrice then
				upgradeButtons[i]:setType(ButtonType.red)
				if actualUpgradeButton == i then
					actualUpgradeButton = 1
					updateUpgradeButtons()
				end
			end
		end
	end
end
function scene:hasFailed()
	return self.statusText and self.statusText.text == "Failed!" and self.statusText.alpha == 1
end
function scene:deselectItem()
	UpgraderManager.deselectItem()
	self.statusText.alpha = 0.99
	transition.to(self.topText, {alpha = 0, time = 400})
	transition.to(self.statusText, {alpha = 0, time = 400})
	updateUpgradeButtons()
	self:drawItemBoxes()
end
function scene:startUpgradeAnimation()
	local selectedItemPrice = UpgraderManager.getSelectedItemPrice()
	local upgradeSuccess = UpgraderManager.upgradeItem(upgradeTypes[actualUpgradeButton].chance, upgradeTypes[actualUpgradeButton].value)
	upgradeAnimation = true
	self.statusText.text = "Upgrading..."
	self.statusText:setFillColor(unpack(Color.white))
	transition.to(self.statusText, {alpha = 1, time = 500})
	for i = 1, #arrows do
		arrows[i]:setFillColor(unpack(ColorTools.lighten(Color.row, 1.8)))
	end
	for i = 1, #arrows do
		timer.performWithDelay((i - 1) * 1000, function()
			transition.changeColor(arrows[i], {
				time = 1000,
				startColor = ColorTools.lighten(Color.row, 1.8),
				endColor = {
					ColorTools.rgb(0, 255, 0)
				}
			})
		end)
	end
	timer.performWithDelay(#arrows * 1000, function()
		for i = 1, 12 do
			timer.performWithDelay((i - 1) * 30, function()
				local x = math.random(self.rightItemBox.x, self.rightItemBox.x + self.rightItemBox.width)
				local y = math.random(self.rightItemBox.y, self.rightItemBox.y + self.rightItemBox.height)
				Animation.show("poof", x, y)
			end)
		end
	end)
	timer.performWithDelay(#arrows * 1000 + 360 + 200, function()
		if upgradeSuccess then
			for i = 1, 7 do
				timer.performWithDelay((i - 1) * 20, function()
					local x = math.random(self.rightItemBox.x, self.rightItemBox.x + self.rightItemBox.width)
					local y = math.random(self.rightItemBox.y, self.rightItemBox.y + self.rightItemBox.height)
					Animation.show("sparks1", x, y)
				end)
			end
			self.statusText.text = "Success!"
			self.topText.text = "+ $" .. formatPrice(UpgraderManager.getUpgradedItemPrice() - selectedItemPrice)
			transition.to(self.topText, {alpha = 1, time = 400})
			self.statusText:setFillColor(unpack(Color.green))
			self:drawRightItemBox()
			timer.performWithDelay(550, function()
				Game.showItemInfo(UpgraderManager.getUpgradedItem())
				upgradeAnimation = false
			end)
			self:update()
		else
			self.statusText.text = "Failed!"
			self.statusText:setFillColor(unpack(Color.lightRed))
			upgradeAnimation = false
			self:drawRightItemBox()
			self:update()
		end
	end)
end
function scene:update()
	transition.changeNumber(self.upgradeCostText, {
		time = 500,
		endNumber = UpgraderManager.getNextUpgradeCost(),
		suffix = "$"
	})
	self.successfulUpgradesCounter.text = StatisticManager.getStatistic("successfulUpgrades")
	self.failedUpgradesCounter.text = StatisticManager.getStatistic("failedUpgrades")
	transition.changeNumber(self.upgradeChanceText, {
		time = 500,
		endNumber = upgradeTypes[actualUpgradeButton].chance,
		suffix = "%"
	})
	if UpgraderManager.canUpgrade() and not UpgraderManager.getUpgradedItem() and not self:hasFailed() then
		self.upgradeButton:setType(ButtonType.green)
	else
		self.upgradeButton:setType(ButtonType.default)
	end
end
function scene:updateUpgradeTime()
	self.costResetText.text = "Loading..."
	self.refreshTimeButton:setType(ButtonType.default)
	UpgraderManager.getCosResetTimeLeft(function(success, time)
		if not success then
			self.costResetText.text = "Connection error"
			self.refreshTimeButton:setType(ButtonType.green)
			return
		end
		self.costResetText.text = time
		self.refreshTimeButton:setType(ButtonType.green)
		self:update()
	end)
end
function scene:drawRightItemBox()
	if self.rightItemBoxGroup then
		self.rightItemBoxGroup:removeSelf()
	end
	self.rightItemBoxGroup = display.newGroup()
	self.itemBoxesGroup:insert(self.rightItemBoxGroup)
	if UpgraderManager.getUpgradedItem() then
		local item = UpgraderManager.getUpgradedItem()
		self.rightItemBox = GUI.createItemBox(self.rightItemBoxGroup, item, self.mainBox.x + self.mainBox.width * 0.7 - self.leftItemBox.x - 345, self.leftItemBox.y, item.statTrak, 1, {
			quality = item.quality,
			pattern = item.pattern,
			stickers = item.stickers
		})
	elseif self:hasFailed() then
		self.rightItemBox = GUI.createItemBox(self.rightItemBoxGroup, {}, self.mainBox.x + self.mainBox.width * 0.7 - self.leftItemBox.x - 345, self.leftItemBox.y, false, 1, {
			image = {
				path = "images/games/noitem.png",
				width = 251.99999999999997,
				height = 210
			},
			name = "Failed!",
			rarity = Rarity.red
		})
	else
		local rightItemBoxText = "No item selected"
		if UpgraderManager.getSelectedItem() then
			rightItemBoxText = "? ? ?"
		end
		self.rightItemBox = GUI.createItemBox(self.rightItemBoxGroup, {}, self.mainBox.x + self.mainBox.width * 0.7 - self.leftItemBox.x - 345, self.leftItemBox.y, false, 1, {
			image = {
				path = "images/games/noitem.png",
				width = 251.99999999999997,
				height = 210
			},
			name = rightItemBoxText,
			rarity = 1
		})
	end
end
function scene:drawLeftItemBox()
	if self.leftItemBoxGroup then
		self.leftItemBoxGroup:removeSelf()
	end
	self.leftItemBoxGroup = display.newGroup()
	self.itemBoxesGroup:insert(self.leftItemBoxGroup)
	local leftItemBoxX = self.mainBox.width * 0.35 - 172.5 - 345
	if 120 < leftItemBoxX then
		leftItemBoxX = 120
	end
	if UpgraderManager.getSelectedItem() then
		local item = UpgraderManager.getSelectedItem()
		self.leftItemBox = GUI.createItemBox(self.leftItemBoxGroup, item, leftItemBoxX, self.mainBox.height * 0.1, item.statTrak, 1, {
			quality = item.quality,
			pattern = item.pattern,
			stickers = item.stickers
		})
		self.leftItemBox:addEventListener("tap", function()
			if upgradeAnimation then
				return true
			end
			self:deselectItem()
		end)
	else
		self.leftItemBox = GUI.createItemBox(self.leftItemBoxGroup, {}, leftItemBoxX, self.mainBox.height * 0.1, false, 1, {
			image = {
				path = "images/games/noitem.png",
				width = 251.99999999999997,
				height = 210
			},
			name = "Click to select!",
			rarity = -1
		})
		self.leftItemBox:addEventListener("tap", function()
			composer.gotoScene("scenes.itemselection", {
				params = {
					type = ItemSelection.upgrader
				}
			})
		end)
	end
end
function scene:drawItemBoxes()
	if self.itemBoxesGroup then
		self.itemBoxesGroup:removeSelf()
	end
	self.itemBoxesGroup = display.newGroup()
	self.mainBoxGroup:insert(self.itemBoxesGroup)
	self:drawLeftItemBox()
	self:drawRightItemBox()
end
function scene:drawUpgradeButtons()
	local buttonWidth = (self.upgradeButton.width - #upgradeTypes * 5) / #upgradeTypes
	local lastX = self.upgradeButton.x
	for i, upgradeType in ipairs(upgradeTypes) do
		upgradeButtons[i] = Button.create(self.mainBoxGroup, lastX, self.mainBox.height - 150 - 105, buttonWidth, 90, "x" .. formatPrice(upgradeType.value), ButtonType.green, function()
			if upgradeAnimation or upgradeButtons[i]:getType() == ButtonType.red then
				return true
			end
			actualUpgradeButton = i
			updateUpgradeButtons()
			self:update()
		end, {fontSize = 50})
		lastX = lastX + buttonWidth + 10
	end
	updateUpgradeButtons()
end
function scene:drawArrows()
	local arrowGap = 120
	if detectSquareScreen() then
		arrowGap = 100
	end
	for i = 1, 3 do
		local arrow = display.newImageRect(self.mainBoxGroup, "images/gui/arrow_right.png", 73.8, 120)
		arrow.anchorX = 0.5
		arrow.anchorY = 0.5
		arrow.x = (self.leftItemBox.x + self.rightItemBox.x + 345) / 2 - arrowGap + (i - 1) * arrowGap
		arrow.y = self.rightItemBox.y + self.rightItemBox.height / 2
		arrows[i] = arrow
	end
	updateArrows()
end
function scene:drawMainBoxContents()
	local boxGroup = display.newGroup()
	boxGroup.x = self.mainBox.x
	boxGroup.y = self.mainBox.y
	self.mainBoxGroup = boxGroup
	self.view:insert(boxGroup)
	local width = self.mainBox.width
	local height = self.mainBox.height
	self:drawItemBoxes()
	local buttonWidth = width * 0.6
	self.upgradeButton = Button.create(boxGroup, width * 0.35 - buttonWidth / 2, height - 150, buttonWidth, 120, "Upgrade item!", ButtonType.default, function()
		if upgradeAnimation then
			return true
		end
		if UpgraderManager.getUpgradedItem() or self:hasFailed() then
			self:deselectItem()
			return true
		end
		if self.upgradeButton:getType() ~= ButtonType.green then
			return true
		end
		if Game.money < UpgraderManager.getNextUpgradeCost() then
			return GUI.showMessageBox("Error", "You need $" .. formatPrice(UpgraderManager.getNextUpgradeCost()) .. " to upgrade this item.")
		end
		Game.removeMoney(UpgraderManager.getNextUpgradeCost(), "Other", "Item Upgrade")
		self:startUpgradeAnimation()
	end, {fontSize = 66, blockTime = 300})
	self:drawArrows()
	self.statusText = display.newText({
		parent = boxGroup,
		x = arrows[2].x,
		y = arrows[2].y + arrows[2].height,
		text = "",
		font = Font.counterstrike,
		fontSize = 50,
		align = "center"
	})
	self.statusText.anchorX = 0.5
	self.statusText:setFillColor(unpack(Color.white))
	FontOffset.setOffset(self.statusText)
	self.statusText.alpha = 0
	self.topText = display.newText({
		parent = boxGroup,
		x = arrows[2].x,
		y = arrows[2].y - arrows[2].height,
		text = "",
		font = Font.counterstrike,
		fontSize = 48,
		align = "center"
	})
	self.topText.anchorX = 0.5
	self.topText:setFillColor(unpack(ColorTools.lighten(Color.row, 2.8)))
	FontOffset.setOffset(self.topText)
	self.topText.alpha = 0
	self:drawUpgradeButtons()
	GUI.drawVerticalLine(boxGroup, width * 0.7, 0, height)
	GUI.drawHorizontalLine(boxGroup, width * 0.7 + 7, height * 0.5, width * 0.3 - 7)
	local text = display.newText({
		parent = boxGroup,
		x = width * 0.7 + width * 0.15,
		y = 40,
		text = "Upgrade chance:",
		font = Font.counterstrike,
		fontSize = 65,
		align = "center"
	})
	text.anchorX = 0.5
	text:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(text)
	self.upgradeChanceText = display.newText({
		parent = boxGroup,
		x = width * 0.7 + width * 0.15,
		y = height * 0.28,
		text = "",
		font = Font.counterstrike,
		fontSize = 105,
		align = "center"
	})
	self.upgradeChanceText.actualValue = 0
	self.upgradeChanceText.anchorX = 0.5
	self.upgradeChanceText.anchorY = 0.5
	self.upgradeChanceText:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(self.upgradeChanceText)
	text = display.newText({
		parent = boxGroup,
		x = width * 0.7 + width * 0.15,
		y = height / 2 + 40,
		text = "Upgrade cost:",
		font = Font.counterstrike,
		fontSize = 65,
		align = "center"
	})
	text.anchorX = 0.5
	text:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(text)
	self.upgradeCostText = display.newText({
		parent = boxGroup,
		x = width * 0.7 + width * 0.15,
		y = height * 0.78,
		text = "",
		font = Font.counterstrike,
		fontSize = 90,
		align = "center"
	})
	self.upgradeCostText.anchorX = 0.5
	self.upgradeCostText.anchorY = 0.5
	self.upgradeCostText:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(self.upgradeCostText)
	self.upgradeCostText.actualValue = 0
end
function scene:drawCoinBoxContents()
	local boxGroup = display.newGroup()
	boxGroup.x = self.coinBox.x
	boxGroup.y = self.coinBox.y
	self.view:insert(boxGroup)
	local width = self.coinBox.width
	local height = self.coinBox.height
	local text = display.newText({
		parent = boxGroup,
		x = width * 0.5,
		y = 40,
		text = "Upgrade cost reset in:",
		font = Font.counterstrike,
		fontSize = 65,
		align = "center"
	})
	text.anchorX = 0.5
	text:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(text)
	self.costResetText = display.newText({
		parent = boxGroup,
		x = text.x,
		y = text.y + 107,
		text = "",
		font = Font.counterstrike,
		fontSize = 76,
		align = "center"
	})
	self.costResetText.anchorX = 0.5
	self.costResetText:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(self.costResetText)
	GUI.drawHorizontalLine(boxGroup, 0, height - 200, width)
	self.refreshTimeButton = Button.create(boxGroup, width * 0.1, height - 150, width * 0.8, 120, "Refresh", ButtonType.green, function()
		if upgradeAnimation or self.refreshTimeButton:getType() ~= ButtonType.green then
			return true
		end
		self:updateUpgradeTime()
	end, {fontSize = 66, blockTime = 500})
end
function scene:drawButtonBoxContents()
	local boxGroup = display.newGroup()
	boxGroup.x = self.buttonBox.x
	boxGroup.y = self.buttonBox.y
	self.view:insert(boxGroup)
	local width = self.buttonBox.width
	local height = self.buttonBox.height
	local logo = display.newImageRect(boxGroup, "images/games/upgrader.png", 209.00000000000003, 209.00000000000003)
	logo.x = width * 0.1
	logo.y = 20
	local backButton = Button.create(boxGroup, width * 0.1, height - 150, width * 0.8, 120, "Back", ButtonType.default, function()
		if upgradeAnimation then
			return true
		end
		composer.gotoScene("scenes.games")
		Menu.updateItems()
	end, {fontSize = 65})
	local textX = logo.x + logo.width
	textX = textX + (width - 80 - textX) / 2
	local textY = logo.y + 20
	local text = display.newText({
		parent = boxGroup,
		x = textX,
		y = textY,
		text = "Successful:",
		font = Font.counterstrike,
		fontSize = 50,
		align = "center"
	})
	text.anchorX = 0.5
	text:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(text)
	self.successfulUpgradesCounter = display.newText({
		parent = boxGroup,
		x = textX,
		y = textY + 55,
		text = "",
		font = Font.counterstrike,
		fontSize = 50,
		align = "center"
	})
	self.successfulUpgradesCounter.anchorX = 0.5
	self.successfulUpgradesCounter:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(self.successfulUpgradesCounter)
	text = display.newText({
		parent = boxGroup,
		x = textX + 4,
		y = textY + logo.height / 2,
		text = "Failed:",
		font = Font.counterstrike,
		fontSize = 50,
		align = "center"
	})
	text.anchorX = 0.5
	text:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(text)
	self.failedUpgradesCounter = display.newText({
		parent = boxGroup,
		x = textX,
		y = textY + logo.height / 2 + 55,
		text = "",
		font = Font.counterstrike,
		fontSize = 50,
		align = "center"
	})
	self.failedUpgradesCounter.anchorX = 0.5
	self.failedUpgradesCounter:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(self.failedUpgradesCounter)
end
function scene:drawBoxes()
	local sceneGroup = self.view
	self.mainBox = GUI.createBox(sceneGroup, 10, 10, display.safeActualContentWidth - 20, display.safeActualContentHeight * 0.6, "Item upgrader")
	local coinBoxY = self.mainBox.y + self.mainBox.height + 10
	local coinBoxHeight = display.safeActualContentHeight - coinBoxY - 10
	local coinBoxWidth = display.safeActualContentWidth * 0.6
	self.coinBox = GUI.createBox(sceneGroup, 10, coinBoxY, coinBoxWidth, coinBoxHeight, "Coins")
	self.buttonBox = GUI.createBox(sceneGroup, coinBoxWidth + 20, coinBoxY, display.safeActualContentWidth - coinBoxWidth - 30, coinBoxHeight, "")
end
function scene:create(event)
	sceneGroup = self.view
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.6)
	self:drawBoxes()
	self:drawCoinBoxContents()
	self:drawButtonBoxContents()
	scene:drawMainBoxContents()
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.hide()
		self:update()
		if event.params and event.params.deselectItems then
			self:deselectItem()
		end
		self:drawItemBoxes()
		updateUpgradeButtons()
		Runtime:addEventListener("enterFrame", upgraderEnterFrame)
	elseif phase == "did" then
		self:updateUpgradeTime()
	end
end
function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Runtime:removeEventListener("enterFrame", upgraderEnterFrame)
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
