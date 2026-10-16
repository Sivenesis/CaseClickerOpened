local widget = require("widget")
local TextSlider = require("gui.textslider")
local scene = composer.newScene()
local shopTable
local function onRowRender(event)
	local row = event.row
	local shopItem = event.row.params
	local image = display.newImageRect(row, "images/" .. shopItem.image.path, shopItem.image.width * Game.guiScale, shopItem.image.height * Game.guiScale)
	image.x = row.width * 0.1 * Game.guiScale
	image.y = row.height / 2
	image.anchorX = 0.5
	image.anchorY = 0.5
	if shopItem.imageCallback then
		image:addEventListener("touch", function(event)
			shopItem.imageCallback(event)
			Game.blockButtons = true
			timer.performWithDelay(300, function()
				Game.blockButtons = false
			end, 2)
			return true
		end)
	end
	local fontSize = 55
	if #shopItem.name > 20 then
		fontSize = 45
	end
	local name = display.newText({
		parent = row,
		x = row.width * (0.2 * Game.guiScale + 0.01),
		y = row.height * 0.25,
		text = shopItem.name,
		font = Font.counterstrike,
		fontSize = fontSize * Game.guiScale,
		align = "left"
	})
	name.anchorY = 0.5
	FontOffset.setOffset(name)
	local nextY = name.y + name.height - 23
	if shopItem.subName then
		local subName = display.newText({
			parent = row,
			x = name.x,
			y = name.y + 40 * Game.guiScale,
			text = shopItem.subName,
			font = Font.counterstrike,
			fontSize = 40 * Game.guiScale,
			align = "left"
		})
		subName.anchorY = 0.5
		FontOffset.setOffset(subName)
		nextY = subName.y + 20
	end
	if shopItem.description or shopItem.getDescription then
		local descText = shopItem.description or shopItem.getDescription()
		local description = display.newText({
			parent = row,
			x = name.x,
			y = nextY + 4,
			text = descText,
			font = Font.default,
			fontSize = 34 * Game.guiScale,
			width = row.width * 0.5 - 10,
			align = "left"
		})
		description.anchorY = 0
		description:setFillColor(0.75, 0.8, 1)
	end
	GUI.drawVerticalLine(row, row.x + row.width * 0.2 * Game.guiScale, row.x, row.height)
	GUI.drawVerticalLine(row, row.x + row.width * 0.7, row.x, row.height)
	if shopItem.isUnlocked and shopItem.isUnlocked() == false then
		local shade = display.newRect(row, 0, 0, row.width, row.height)
		shade:setFillColor(0, 0, 0, 0.85)
		local notUnlockedText = display.newText({
			parent = row,
			x = row.width / 2,
			y = row.height / 2,
			text = Lang.shop.notunlocked,
			font = Font.counterstrike,
			fontSize = 64,
			align = "left"
		})
		notUnlockedText.anchorX = 0.5
		notUnlockedText.anchorY = 0.5
		notUnlockedText:setFillColor(0.75, 0.8, 1, 0.5)
		return
	end
	local buttonType = ButtonType.red
	if shopItem.canBeBought() then
		buttonType = ButtonType.gold
	end
	local buttonText = shopItem.buttonText
	if shopItem.getButtonText then
		buttonText = shopItem.getButtonText()
	end
	local options = {}
	if shopItem.holdBuy then
		options.callbackAsHoldCallback = true
	end
	local button = GUI.createButton(row, row.width * 0.725, row.height * 0.15, row.width * 0.25, row.height * 0.7, buttonText, buttonType, function(event)
		if shopItem.canBeBought() or Game.testMode then
			shopItem.onBuy(event)
			StatisticManager.addStatistic("itemsBought")
			shopTable:reloadData()
			return false
		end
		shopTable:reloadData()
		return true
	end, 56, options)
	button.anchorX = 0.5
	button.anchorY = 0.5
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local function insertItems()
	shopTable:deleteAllRows()
	local itemTable = Game.shopItems["Paid Bonuses"]
	for _, shopItem in pairs(itemTable) do
		shopTable:insertRow({
			params = shopItem,
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = 200 * Game.guiScale
		})
	end
end
local justCreated = false
function scene:create(event)
	local sceneGroup = self.view
	justCreated = true
	local box = GUI.drawMainBox(sceneGroup, Lang.menu.shop)
	actualTextId = 1
	local buttonBackground = display.newRect(sceneGroup, box.x, box.y, box.width, box.height)
	buttonBackground:setFillColor(unpack(Color.line))
	shopTable = widget.newTableView({
		left = box.x,
		top = box.y,
		width = box.width,
		height = box.height,
		isBounceEnabled = true,
		backgroundColor = Color.row,
		onRowRender = onRowRender
	})
	insertItems()
	sceneGroup:insert(shopTable)
end
local refreshTimer = nil
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
		if justCreated then
			justCreated = false
		else
			shopTable:reloadData()
		end
		if refreshTimer then
			timer.cancel(refreshTimer)
			refreshTimer = nil
		end
		refreshTimer = timer.performWithDelay(1000, function()
			if composer.getSceneName("current") == "scenes.paidbonuses" and shopTable then
				shopTable:reloadData()
			end
		end, -1)
	elseif phase == "did" then
	end
end
function scene:hide(event)
	local phase = event.phase
	if phase == "will" then
		if refreshTimer then
			timer.cancel(refreshTimer)
			refreshTimer = nil
		end
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
