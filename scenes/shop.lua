local widget = require("widget")
local TextSlider = require("gui.textslider")
local scene = composer.newScene()
local shopTable
local translatedSliderTexts = Lang.shop.sliderTexts
local sliderTexts = {
	"Bonuses",
	"Cases",
	"Keys",
	"Capsules",
	"Collections",
	"Souvenirs",
	"Autographs"
}
local actualTextId = 1
local xButtonValues = {
	1,
	5,
	10,
	25,
	50
}
local xButtons = {}
local actualXButton = 1
local buyMultiplier = 1
local function setXButton(buttonId)
	for i = 1, #xButtons do
		if i ~= buttonId then
			xButtons[i].alpha = 0
		else
			xButtons[i].alpha = 1
		end
	end
	actualXButton = buttonId
	buyMultiplier = xButtonValues[actualXButton]
end
local function toggleXButton()
	local actualButtonId = 0
	for i = 1, #xButtons do
		if xButtons[i].alpha == 1 then
			actualButtonId = i
			break
		end
	end
	if actualButtonId + 1 > #xButtonValues then
		return setXButton(1)
	else
		return setXButton(actualButtonId + 1)
	end
end
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
			if event.phase == "ended" then
				shopItem.imageCallback(event)
				Game.blockButtons = true
				timer.performWithDelay(300, function()
					Game.blockButtons = false
				end, 2)
			end
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
	if shopItem.canBeBought(buyMultiplier) then
		buttonType = ButtonType.green
	end
	local buttonText = shopItem.buttonText
	if shopItem.getButtonText then
		buttonText = shopItem.getButtonText(buyMultiplier)
	end
	local options = {}
	if shopItem.holdBuy then
		options.callbackAsHoldCallback = true
	end
	local button = GUI.createButton(row, row.width * 0.725, row.height * 0.15, row.width * 0.25, row.height * 0.7, buttonText, buttonType, function(event)
		if shopItem.canBeBought(buyMultiplier) or Game.testMode then
			if 1 < buyMultiplier and shopItem.onMultipleBuy then
				shopItem.onMultipleBuy(event, buyMultiplier)
			else
				for i = 1, buyMultiplier do
					shopItem.onBuy(event, i)
					if not shopItem.multipleBuy then
						break
					end
				end
			end
			StatisticManager.addStatistic("itemsBought")
			shopTable:reloadData()
			return false
		end
		shopTable:reloadData()
		return true
	end, 46, options)
	button.anchorX = 0.5
	button.anchorY = 0.5
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local function insertItems()
	shopTable:deleteAllRows()
	local itemTable = Game.shopItems[sliderTexts[actualTextId]]
	for _, shopItem in pairs(itemTable) do
		local canAdd = true
		if shopItem.isUnlocked then
			canAdd = shopItem.isUnlocked()
		end
		if canAdd then
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
	for _, shopItem in pairs(itemTable) do
		local canAdd = false
		if shopItem.isUnlocked then
			canAdd = not shopItem.isUnlocked()
		end
		if canAdd then
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
end
local justCreated = false
function scene:create(event)
	local sceneGroup = self.view
	justCreated = true
	local box = GUI.drawMainBox(sceneGroup, Lang.menu.shop)
	actualTextId = 1
	local buttonBackground = display.newRect(sceneGroup, box.x, box.y, box.width, box.height)
	buttonBackground:setFillColor(unpack(Color.line))
	local slider = TextSlider.create(sceneGroup, box.x, box.y, box.width - 200, 110 * Game.guiScale, translatedSliderTexts, function(text, textId)
		actualTextId = textId
		insertItems()
	end, 80 * Game.guiScale)
	shopTable = widget.newTableView({
		left = box.x,
		top = box.y + 110 * Game.guiScale,
		width = box.width,
		height = box.height - 110 * Game.guiScale,
		isBounceEnabled = true,
		backgroundColor = Color.row,
		onRowRender = onRowRender,
		listener = function(event)
			if GUI.holdTimer then
				timer.cancel(GUI.holdTimer)
				GUI.holdTimer = nil
			end
		end
	})
	for i, value in ipairs(xButtonValues) do
		xButtons[i] = GUI.createButton(sceneGroup, box.x + box.width - 200 + 6 * Game.guiScale, box.y + 2, 192, 105 * Game.guiScale, "x" .. value, ButtonType.darkblue, function()
			toggleXButton()
			shopTable:reloadData()
		end, 64)
	end
	setXButton(1)
	insertItems()
	sceneGroup:insert(shopTable)
end
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
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
