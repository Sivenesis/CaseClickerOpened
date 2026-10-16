local composer = require("composer")
local VerticalSlider = require("gui.verticalslider")
local scene = composer.newScene()
local skinTable, titleText, secondText
local skinsPerRow = 3
local priceButtons = true
local priceInfoOnClick = false
local rowHeight = 470
local showOwned = false
local ownedList = {}
local function onRowRender(event)
	local row = event.row
	local skins = event.row.params.items
	if not skins then
		local text = display.newText({
			parent = row,
			x = getCenterX(row),
			y = 125,
			text = Lang.itemlist.noitems,
			font = Font.counterstrike,
			fontSize = 72,
			align = "center"
		})
		text.anchorX = 0.5
		text.anchorY = 0.5
		text:setFillColor(unpack(Color.lightText))
		FontOffset.setOffset(text)
		return
	end
	for i = 1, skinsPerRow - 1 do
		GUI.drawVerticalLine(row, row.x + row.width * (i * (1 / skinsPerRow)), row.x, row.height)
	end
	for i = 1, #skins do
		local columnX = (i - 1) * (1 / skinsPerRow * row.width)
		local columnWidth = 1 / skinsPerRow * row.width
		local options = {
			name = skins[i].n or skins[i].name,
			quality = skins[i].quality,
			stickers = skins[i].stickers
		}
		if skins[i].count then
			options.additionalText = "x" .. skins[i].count
		end
		local itemBox = GUI.createItemBox(row, skins[i], columnX + columnWidth / 2 - 345 * Game.guiScale / 2 - 4, 25, skins[i].statTrak, 1, options)
		if priceInfoOnClick then
			itemBox:addEventListener("tap", function()
				if skins[i].type == Item.skin or skins[i].type == Item.sticker or skins[i].type == Item.glove then
					Game.showPriceInfo(skins[i])
				end
			end)
		end
		if showOwned then
			local text = "Not owned"
			local textColor = Color.white
			if skins[i].type == Item.skin and Game.skins[skins[i].id].patterns then
				if ownedList[skins[i].id .. "." .. (skins[i].pattern or 0)] then
					text = "Owned"
					textColor = Color.gold
				end
			elseif ownedList[skins[i].id] then
				text = "Owned"
				textColor = Color.gold
			end
			local ownedText = display.newText({
				parent = row,
				x = columnX + columnWidth / 2,
				y = itemBox.y + itemBox.height + 25,
				text = text,
				font = Font.counterstrike,
				fontSize = 42 * Game.guiScale,
				align = "center"
			})
			ownedText.anchorX = 0.5
			ownedText.anchorY = 0.5
			FontOffset.setOffset(ownedText)
			ownedText:setFillColor(unpack(textColor))
		end
		if priceButtons then
			GUI.createButton(row, itemBox.x, itemBox.y + itemBox.height + 5, 345 * Game.guiScale, 60 * Game.guiScale, "$" .. formatPrice(Game.getItemPrice(skins[i])), RarityButtons[skins[i].rarity], function()
			end, 32)
		end
	end
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local function insertRows(items)
	skinTable:deleteAllRows()
	if #items == 0 then
		skinTable:insertRow({
			params = {},
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = 250 * Game.guiScale
		})
		return
	end
	for i = 0, math.ceil(#items / skinsPerRow) - 1 do
		local params = {}
		for j = 1, skinsPerRow do
			if not items[i * skinsPerRow + j] then
				break
			end
			params[j] = items[i * skinsPerRow + j]
		end
		skinTable:insertRow({
			params = {items = params},
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = rowHeight * Game.guiScale
		})
	end
end
function scene:create(event)
	local sceneGroup = self.view
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.6)
	background:addEventListener("touch", function()
		return true
	end)
	background:addEventListener("tap", function()
		return true
	end)
	local mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.01, display.safeActualContentHeight * 0.01, display.safeActualContentWidth * 0.98, display.safeActualContentHeight * 0.98, "Items")
	titleText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = mainBox.y + 38,
		text = Lang.itemlist.winner .. "!",
		font = Font.counterstrike,
		fontSize = 102,
		align = "center"
	})
	titleText.anchorX = 0.5
	titleText:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(titleText)
	secondText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = titleText.y + titleText.height + 10,
		text = Lang.itemlist.newitems .. ":",
		font = Font.counterstrike,
		fontSize = 62,
		align = "center"
	})
	secondText.anchorX = 0.5
	FontOffset.setOffset(secondText)
	local okButton = GUI.createButton(sceneGroup, mainBox.x + 170, mainBox.y + mainBox.height - 150, mainBox.width - 340, 120, event.params.okButtonText or Lang.common.yeah .. "!", ButtonType.purple, function()
		composer.hideOverlay()
		if event.params.okButtonCallback then
			event.params.okButtonCallback()
		end
	end, 70)
	slider = VerticalSlider.create(sceneGroup, mainBox.x + mainBox.width - 150, mainBox.y + 170, 100, mainBox.height * 0.7)
	skinTable = widget.newTableView({
		left = mainBox.x + 50,
		top = mainBox.y + 170,
		width = mainBox.width - 200,
		height = mainBox.height * 0.7,
		isBounceEnabled = false,
		hideBackground = true,
		onRowRender = onRowRender,
		listener = function(event)
			slider:scrollListener(event)
		end,
		hideScrollBar = true
	})
	sceneGroup:insert(skinTable)
	skinsPerRow = calculateSkinsPerRow(skinTable.width)
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	local params = event.params
	if phase == "will" then
		Game.showingOverlay = true
		titleText.text = params.firstText or Lang.itemlist.winner .. "!"
		secondText.text = params.secondText or Lang.itemlist.newitems .. ":"
		rowHeight = 470
		showOwned = false
		priceButtons = true
		if type(event.params.priceButtons) ~= "nil" then
			priceButtons = event.params.priceButtons
			rowHeight = 450
		end
		if type(event.params.showOwned) ~= "nil" then
			showOwned = event.params.showOwned
			ownedList = event.params.ownedList
		end
		priceInfoOnClick = event.params.priceInfoOnClick
		insertRows(params.items)
		slider:scrollBar(0)
		local tableMaxScroll = -(skinTable:getNumRows() * rowHeight * Game.guiScale) + skinTable.height
		slider:setTableView(skinTable, tableMaxScroll)
	elseif phase == "did" then
	end
end
function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Game.showingOverlay = false
	elseif phase == "did" then
		composer.removeScene("scenes.itemlist")
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
