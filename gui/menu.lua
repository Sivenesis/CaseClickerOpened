local composer = require("composer")
local Menu = {}
local menuPos = 1
local menuGroup
local menuTexts = {}
local menuImages = {}
local leftPanelBackground, rankText, rankImage, rankBox, firstGradient, secondGradient, tableView, balanceText
local showingPrivateRank = false
local defaultRowHeight = 120
local defaultSubItemRowHeight = 40
local itemTableHeight = 0
local actualClickedText
Menu.items = {
	{
		text = "Click!",
		scene = "main",
		alert = false,
		locked = false,
		image = "click"
	},
	{
		text = "Missions",
		scene = "missions",
		alert = false,
		locked = false,
		image = "missions"
	},
	{
		text = "Cases",
		scene = "cases",
		alert = false,
		locked = false,
		image = "case"
	},
	{
		text = "Equipment",
		scene = "equipment",
		alert = false,
		locked = false,
		image = "equipment"
	},
	{
		text = "Upgrades",
		scene = "upgrades",
		alert = false,
		locked = false,
		image = "upgrades"
	},
	{
		text = "Paid Bonuses",
		scene = "paidbonuses",
		alert = false,
		locked = true,
		image = "paidbonuses"
	},
	{
		text = "Shop",
		scene = "shop",
		alert = false,
		locked = false,
		image = "shop"
	},
	{
		text = "Dailies",
		scene = "dailies",
		alert = false,
		locked = false,
		image = "dailies"
	},
	{
		text = "Games",
		scene = "games",
		alert = false,
		locked = false,
		image = "games"
	},
	{
		text = "Casino",
		scene = "casino",
		alert = false,
		locked = false,
		image = "casino"
	},
	{
		text = "NetHub",
		scene = "nethub.nethub",
		alert = false,
		locked = true,
		image = "nethub"
	},
	{
		text = "Achievements",
		scene = "achievements",
		alert = false,
		locked = false,
		image = "achievements"
	},
	{
		text = "Statistics",
		scene = "statistics",
		alert = false,
		locked = false,
		image = "statistics"
	},
	{
		text = "Settings",
		scene = "settings",
		alert = false,
		locked = false,
		image = "settings"
	}
}
local function updateGradients()
	if not firstGradient then
		return
	end
	local positionPercent = math.round((1 + tableView:getContentPosition()) / -(itemTableHeight - tableView.height) * 10000) / 100
	if positionPercent < 0 then
		positionPercent = 0
	elseif 100 < positionPercent then
		positionPercent = 100
	end
	firstGradient.alpha = positionPercent / 100
	secondGradient.alpha = (100 - positionPercent) / 100
end
local function scrollToLastPosition()
	if lastScrollPosition < -(itemTableHeight - tableView.height) then
		lastScrollPosition = -(itemTableHeight - tableView.height)
		if lastScrollPosition > 0 then
			lastScrollPosition = 0
		end
	end
	tableView:scrollToY({y = lastScrollPosition, time = 0})
end
local function insertSubItems()
	if not NetHub then
		return
	end
	Menu.items[11].subItems = {}
	if NetHub.isConnected() then
		for _, subItem in ipairs(NetHub.items) do
			if (not subItem.upgrade or Game.isUpgradeBought(subItem.upgrade)) and not subItem.dontShowInMenu then
				table.insert(Menu.items[11].subItems, {
					text = subItem.shortName or subItem.name,
					scene = subItem.scene,
					callback = subItem.callback
				})
			end
		end
	end
	Menu.items[9].subItems = {}
	local subItems = {
		{
			name = "Jackpot",
			upgrade = "Jackpot",
			scene = "scenes.jackpot"
		},
		{
			name = "Scratches",
			scene = "scenes.games.scratches"
		},
		{
			name = "Upgrader",
			scene = "scenes.games.upgrader",
			isUnlocked = function()
				if Game.others then
					return Game.others.upgraderBought
				end
				return false
			end
		}
	}
	for _, subItem in ipairs(subItems) do
		if not ((not subItem.isUnlocked or not subItem.isUnlocked()) and (subItem.upgrade or subItem.isUnlocked)) or subItem.upgrade and Game.isUpgradeBought(subItem.upgrade) then
			table.insert(Menu.items[9].subItems, {
				text = subItem.name,
				scene = subItem.scene
			})
		end
	end
	Menu.items[10].subItems = {}
	subItems = {
		{
			name = Lang.casino.roulette,
			upgrade = "Roulette",
			scene = "scenes.casino.roulette"
		},
		{
			name = "Coinflip",
			upgrade = "Coinflip",
			scene = "scenes.casino.coinflip"
		},
		{
			name = "Minesweeper",
			upgrade = "Minesweeper",
			scene = "scenes.casino.minesweeper"
		},
		{
			name = "Crash",
			upgrade = "Crash",
			scene = "scenes.casino.crash"
		}
	}
	for _, subItem in ipairs(subItems) do
		if Game.isUpgradeBought(subItem.upgrade) then
			table.insert(Menu.items[10].subItems, {
				text = subItem.name,
				scene = subItem.scene
			})
		end
	end
end
local function onMenuTextClick()
	for i = 1, #menuTexts do
		if menuTexts[i] and menuTexts[i].setFillColor then
			if i == menuPos then
				menuTexts[i]:setFillColor(unpack(Color.mainText))
			else
				menuTexts[i]:setFillColor(unpack(Color.lightText))
			end
		end
	end
end
function Menu.updateLanguageTexts()
	for _, item in ipairs(Menu.items) do
		item.displayText = item.text
	end
	if tableView and tableView:getNumRows() > 0 then
		tableView:reloadData()
	end
end
function Menu.updateItems()
	for i, item in ipairs(Menu.items) do
		if composer.getSceneName("current") == "scenes." .. item.scene then
			menuPos = i
			Menu.removeAlert(menuPos)
			break
		end
	end
	actualClickedText = nil
	tableView:reloadData()
end
function Menu.show()
	menuGroup.alpha = 1
	menuGroup:toBack()
	GUI.backgroundToBack()
end
function Menu.updateBalanceText()
	if not Game.money then
		return
	end
	balanceText.text = "$" .. formatPrice(math.floor(Game.money * 100) / 100)
end
function Menu.hide()
	menuGroup.alpha = 0
end
function Menu.unlockItem(name)
	for i = 1, #Menu.items do
		if Menu.items[i].text == name then
			Menu.items[i].locked = false
			return
		end
	end
end
function Menu.lockItem(name)
	for i = 1, #Menu.items do
		if Menu.items[i].text == name then
			Menu.items[i].locked = true
			return
		end
	end
end
function Menu.tryToUnlockItems()
	if (Game.others.jackpotsUnlocked or Game.others.nethubUnlocked) and Game.others.nethubUnlocked then
		Menu.unlockItem("NetHub")
	end
	if Game.microPayments and not Game.cheatLock then
		Menu.unlockItem("Paid Bonuses")
	end
	Menu.refreshItems()
end
function Menu.refreshItems()
	lastScrollPosition = tableView:getContentPosition()
	insertSubItems()
	tableView:deleteAllRows()
	actualClickedText = nil
	defaultRowHeight = 120 * Game.guiScale
	defaultSubItemRowHeight = 60 * Game.guiScale
	itemTableHeight = 0
	tableView.totalRows = 0
	for i = 1, #Menu.items do
		if Menu.items[i].locked == false then
			tableView.totalRows = tableView.totalRows + 1
		end
	end
	for i = 1, #Menu.items do
		if Menu.items[i].locked == false then
			local height = defaultRowHeight
			if Menu.items[i].expanded then
				height = height + #Menu.items[i].subItems * defaultSubItemRowHeight
			end
			local params = {
				params = {
					item = Menu.items[i],
					id = i
				},
				rowColor = {
					default = Color.row
				},
				lineColor = {
					0,
					0,
					0,
					0
				},
				rowHeight = height
			}
			itemTableHeight = itemTableHeight + height
			tableView:insertRow(params)
		end
	end
	scrollToLastPosition()
	timer.performWithDelay(1, function()
		updateGradients()
	end)
end
function Menu.removeAlerts()
	for i = 1, #Menu.items do
		Menu.items[i].alert = false
	end
end
function Menu.addAlert(position)
	for i = 1, #Menu.items do
		if Menu.items[i].text == position then
			if menuPos == i then
				return
			end
			Menu.items[i].alert = true
			tableView:reloadData()
			return
		end
	end
end
function Menu.removeAlert(position)
	for i = 1, #Menu.items do
		if Menu.items[i].text == position then
			if menuPos == i then
				return
			end
			Menu.items[i].alert = false
			tableView:reloadData()
			return
		end
	end
end
function Menu.showRank()
	if not rankText then
		rankBox = display.newRect(menuGroup, 0, display.safeActualContentHeight * 0.88 - 30, leftPanelBackground.width - 1, display.safeActualContentHeight * 0.12)
		rankBox:setFillColor(unpack(Color.row))
		rankBox.anchorX = 0
		rankBox.anchorY = 0
		rankBox.alpha = 0
		rankBox.isHitTestable = true
		rankBox:addEventListener("tap", function()
			showingPrivateRank = not showingPrivateRank
			Menu.showRank()
		end)
	end
	Menu.updateBalanceText()
	if rankImage then
		rankImage:removeSelf()
	end
	if showingPrivateRank then
		rankImage = display.newImageRect(menuGroup, "images/expranks/" .. Game.expRank .. ".png", 86, 86)
	else
		rankImage = display.newImageRect(menuGroup, "images/ranks/" .. Game.rank .. ".png", 160.5, 64.5)
	end
	rankImage.x = rankBox.width / 2
	if showingPrivateRank then
		rankImage.y = rankBox.y + 10
	else
		rankImage.y = tableView.y + tableView.height + 20
	end
	rankImage.anchorX = 0.5
	rankImage.anchorY = 0
	rankImage:addEventListener("tap", function()
		Game.unlockAchievement("Secret II")
		if Game.testMode then
			local st = false
			if math.random(2, 10) < 3 then
				st = true
			end
			local item
			while true do
				item = EquipmentManager.getItemWithPrice(100)
				if item.type == Item.skin then
					break
				end
			end
			Game.addItem(Game.skins[item.id], false, st, false)
			Game.roulette.balance = Game.roulette.balance + 10000
		end
	end)
	if rankText then
		rankText:removeSelf()
	end
	local rankTextText = Game.ranks[Game.rank].name:gsub("IIII", "IV")
	if showingPrivateRank then
		rankTextText = Lang.privateRanks[Game.expRank]
	end
	local fontSize = 42
	if 22 <= #rankTextText then
		fontSize = 25
	elseif 16 <= #rankTextText then
		fontSize = 36
	end
	local textAddY = 25
	if showingPrivateRank then
		textAddY = 20
	end
	rankText = PonyFont.newText({
		parent = menuGroup,
		x = rankBox.width / 2,
		y = rankImage.y + rankImage.height + textAddY,
		text = rankTextText,
		font = BitmapFont.counterstrikeTight,
		fontSize = fontSize,
		align = "left"
	})
	rankText.anchorX = 0.5
	rankText.anchorY = 0.5
end
local function onRowRender(event)
	local row = event.row
	local menuItem = row.params.item
	local itemId = row.params.id
	local rowHeight = defaultRowHeight
	local triggerBox = display.newRect(row, 0, 0, row.width, row.height)
	triggerBox.alpha = 0
	triggerBox.isHitTestable = true
	triggerBox.anchorX = 0
	triggerBox.anchorY = 0
	triggerBox:addEventListener("tap", function(event)
		if Game.showingOverlay then
			return
		end
		if composer.getSceneName("current") == "scenes.jackpots.roomselection" then
			OnlineJackpots.disconnect()
		end
		composer.gotoScene("scenes." .. menuItem.scene)
		audio.play(Game.sounds.menuClick, {
			channel = audio.findFreeChannel()
		})
		menuPos = itemId
		Menu.items[itemId].alert = false
		onMenuTextClick()
		tableView:reloadData()
		if Game.others.lastAdWatch and system.getTimer() > 120000 and (isAndroid() and os.time() - Game.others.lastAdWatch > 75600 or isIOS() and os.time() - Game.others.lastAdWatch > 97200) and math.random(1, 100) < 5 then
			Game.others.lastAdWatch = os.time()
			ADS.showAd()
		end
		return true
	end)
	local fontSize = 57
	if #menuItem.text > 10 then
		fontSize = 50
	end
	if menuItem.subItems and 0 < #menuItem.subItems then
		local subItems = Menu.items[itemId].subItems
		local arrow = display.newImageRect(row, "images/gui/menuarrow.png", 58.08, 58.08)
		arrow.x = row.width - 50
		arrow.y = defaultRowHeight / 2
		arrow.anchorX = 0.5
		arrow.anchorY = 0.5
		arrow:setFillColor(rgb(55, 76, 109))
		if Menu.items[itemId].expanded then
			local rotationTime = 0
			if Menu.items[itemId].justExpanded then
				rotationTime = 300
				Menu.items[itemId].justExpanded = nil
			end
			transition.to(arrow, {rotation = 90, time = rotationTime})
		elseif Menu.items[itemId].justExpanded then
			arrow.rotation = 90
			Menu.items[itemId].justExpanded = nil
			transition.to(arrow, {rotation = 0, time = 300})
		end
		arrow:addEventListener("tap", function()
			if Menu.items[itemId].expanded then
				Menu.items[itemId].expanded = false
				Menu.items[itemId].justExpanded = true
				Menu.refreshItems()
				return true
			end
			local newHeight = row.height + 80 * #subItems
			Menu.items[itemId].expanded = true
			Menu.items[itemId].justExpanded = true
			Menu.refreshItems()
			return true
		end)
	end
	if menuItem.expanded then
		for i, item in ipairs(Menu.items[itemId].subItems) do
			local triggerImage = display.newRect(row, 0, rowHeight + (i - 1) * defaultSubItemRowHeight, row.width, defaultSubItemRowHeight)
			triggerImage.alpha = 0
			triggerImage.isHitTestable = true
			triggerImage.alpha = 0.04
			local text = PonyFont.newText({
				parent = row,
				x = triggerImage.x + 40,
				y = triggerImage.y + triggerImage.height / 2,
				text = item.text,
				font = BitmapFont.counterstrike,
				fontSize = 42 * Game.guiScale,
				align = "center"
			})
			text.anchorY = 0.5
			text:setFillColor(unpack(Color.lightText))
			triggerImage:addEventListener("tap", function()
				if Game.showingOverlay then
					return
				end
				if composer.getSceneName("current") == "scenes.jackpots.roomselection" then
					OnlineJackpots.disconnect()
				end
				if item.callback then
					item.callback()
				else
					composer.gotoScene(item.scene)
				end
				menuPos = itemId
				Menu.updateItems()
				onMenuTextClick()
				text:setFillColor(unpack(Color.white))
				if actualClickedText and actualClickedText.setFillColor then
					actualClickedText:setFillColor(unpack(Color.lightText))
				end
				actualClickedText = text
				return true
			end)
			if composer.getSceneName("current") == item.scene then
				text:setFillColor(unpack(Color.white))
			end
		end
	end
	if Menu.items[itemId].alert then
		local alert = display.newImageRect(row, "images/gui/menu_alert.png", 17.6, 63.2)
		alert.x = row.width - 40
		if menuItem.subItems and 0 < #menuItem.subItems then
			alert.x = alert.x - 60
		end
		alert.y = rowHeight / 2
		alert.anchorX = 0.5
		alert.anchorY = 0.5
	end
	local textX = 22
	if menuItem.image then
		local imagePath = "images/menuicons/" .. menuItem.image .. ".png"
		if itemId == menuPos then
			imagePath = "images/menuicons/" .. menuItem.image .. "_active.png"
		end
		menuImages[itemId] = display.newImageRect(row, imagePath, rowHeight * 0.33, rowHeight * 0.33)
		menuImages[itemId].anchorX = 0
		menuImages[itemId].anchorY = 0.5
		menuImages[itemId].x = 22
		menuImages[itemId].y = 120 * Game.guiScale / 2
		textX = textX + menuImages[itemId].width + 20 * Game.guiScale
	end
	menuTexts[itemId] = display.newText({
		parent = row,
		x = textX,
		y = rowHeight / 2,
		text = menuItem.displayText,
		font = Font.counterstrike,
		fontSize = fontSize * Game.guiScale,
		align = "left"
	})
	menuTexts[itemId].anchorX = 0
	menuTexts[itemId].anchorY = 0.5
	FontOffset.setOffset(menuTexts[itemId])
	if itemId ~= menuPos then
		if menuItem.color then
			menuTexts[itemId]:setFillColor(unpack(menuItem.color))
		else
			menuTexts[itemId]:setFillColor(unpack(Color.lightText))
		end
	end
	if itemId == menuPos then
		local rect = display.newRect(row, 0, 0, row.width, display.pixelHeight * 4)
		rect:setFillColor(unpack(Color.menuActiveStroke))
		rect = display.newRect(row, 0, rowHeight - display.pixelHeight * 4, row.width, display.pixelHeight * 4)
		rect:setFillColor(unpack(Color.menuActiveStroke))
		rect = display.newRect(row, 0, 0, display.pixelWidth * 4, rowHeight)
		rect:setFillColor(unpack(Color.menuActiveStroke))
		rect = display.newRect(row, row.width - display.pixelWidth * 4, 0, display.pixelWidth * 4, rowHeight)
		rect:setFillColor(unpack(Color.menuActiveStroke))
		local rect = display.newRect(row, display.pixelWidth * 4, display.pixelHeight * 4, row.width - display.pixelWidth * 8, display.pixelHeight)
		rect:setFillColor(unpack(Color.contourLine))
		rect = display.newRect(row, display.pixelWidth * 4, display.pixelHeight * 4, display.pixelWidth, rowHeight - display.pixelHeight * 8)
		rect:setFillColor(unpack(Color.contourLine))
		rect = display.newRect(row, row.width - display.pixelWidth * 5, display.pixelHeight * 4, display.pixelWidth, rowHeight - display.pixelHeight * 8)
		rect:setFillColor(unpack(Color.contourLine))
		rect = display.newRect(row, display.pixelWidth * 4, rowHeight - display.pixelHeight * 5, row.width - display.pixelWidth * 8, display.pixelHeight)
		rect:setFillColor(unpack(Color.contourLine))
		local shadow = display.newImageRect(row, "images/gui/active_menu_background.png", row.width - display.pixelWidth * 10, rowHeight - display.pixelHeight * 10)
		shadow.x = display.pixelWidth * 5
		shadow.y = display.pixelHeight * 5
		local triangle = display.newImageRect(row, "images/gui/active_menu_triangle.png", 48, 14)
		triangle.x = row.width / 2 - triangle.width / 2
		triangle.y = display.pixelHeight * 5
	end
	local canShowLine = true
	if itemId == tableView.totalRows + 1 then
		canShowLine = false
	elseif itemId == menuPos and not menuItem.expanded then
		canShowLine = false
	elseif itemId == menuPos - 1 then
		canShowLine = false
	end
	if canShowLine then
		local lineImage = display.newImageRect(row, "images/gui/separator.png", row.width, display.pixelHeight * 1.4)
		lineImage.y = display.getNearestVerticalPixel(row.height) - display.pixelHeight
	end
end
local function scrollListener(event)
	if event.phase == began then
		return
	end
	updateGradients()
end
function Menu.init()
	Menu.updateLanguageTexts()
	menuGroup = display.newGroup()
	menuGroup.x = display.safeScreenOriginX
	leftPanelBackground = display.newRect(menuGroup, 0, 0, display.safeActualContentWidth * 0.25, display.safeActualContentHeight)
	leftPanelBackground:setFillColor(unpack(Color.menuBackground))
	leftPanelBackground.anchorX = 0
	leftPanelBackground.anchorY = 0
	local scale = leftPanelBackground.width / 433
	local logoBackground = display.newImageRect(menuGroup, "images/gui/logo_background.png", leftPanelBackground.width, 140)
	local logoImage = "logo.png"
	local logo = display.newImageRect(menuGroup, "images/" .. logoImage, 202.4, 105.60000000000001)
	logo.x = leftPanelBackground.width / 2
	logo.y = 67
	logo.anchorX = 0.5
	logo.anchorY = 0.5
	logo:addEventListener("tap", function()
		Game.unlockAchievement("That's a nice logo!")
		StatisticManager.addStatistic("logoTaps")
	end)
	if Game.testMode and not isAndroid() and not Game.screenMode then
		logo.alpha = 0.2
		local testText = display.newText({
			parent = menuGroup,
			x = 130,
			y = 47,
			text = "Test Mode",
			font = Font.counterstrike,
			fontSize = 57,
			align = "center"
		})
		testText:addEventListener("tap", function()
			Game.money = Game.money + 50
		end)
		testText:setFillColor(unpack(Color.gold))
	end
	balanceText = PonyFont.newText({
		parent = menuGroup,
		x = getCenterX(leftPanelBackground),
		y = display.safeActualContentHeight - 40,
		text = "$5.00",
		font = BitmapFont.counterstrikeTight,
		fontSize = 32,
		align = "center"
	})
	balanceText.anchorX = 0.5
	balanceText:setFillColor(unpack(Color.lightText))
	tableView = widget.newTableView({
		left = 0,
		top = logoBackground.y + logoBackground.height,
		width = leftPanelBackground.width,
		height = display.safeActualContentHeight * 0.88 - 160,
		hideBackground = false,
		backgroundColor = Color.row,
		hideScrollBar = false,
		isBounceEnabled = false,
		onRowRender = onRowRender,
		listener = scrollListener
	})
	tableView.anchorX = 0
	tableView.anchorY = 0
	menuGroup:insert(tableView)
	local menuBottomImage = display.newImageRect(menuGroup, "images/gui/menu_bottom.png", leftPanelBackground.width, display.safeActualContentHeight - (tableView.y + tableView.height))
	menuBottomImage.y = tableView.y + tableView.height
	balanceText:toFront()
	Menu.refreshItems()
	firstGradient = display.newImageRect(menuGroup, "images/gui/menu/gradient_1.png", tableView.width, 66)
	firstGradient.anchorX = 0
	firstGradient.anchorY = 0
	firstGradient.x = 0
	firstGradient.y = tableView.y
	secondGradient = display.newImageRect(menuGroup, "images/gui/menu/gradient_2.png", tableView.width, 66)
	secondGradient.anchorX = 0
	secondGradient.anchorY = 1
	secondGradient.x = 0
	secondGradient.y = tableView.y + tableView.height
	Menu.showRank()
	updateGradients()
end
return Menu
