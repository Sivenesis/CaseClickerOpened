local composer = require("composer")
local VerticalSlider = require("gui.verticalslider")
local scene = composer.newScene()
local skinTable, titleText, secondText
local skinTableHeight = 0
local skinsPerRow = 3
local alternativeView = false
local function onRowRender(event)
	local row = event.row
	local skins = event.row.params.items
	if not skins or row.params.text then
		local fontSize = 52
		if row.params.text then
			fontSize = 72
		end
		local text = display.newText({
			parent = row,
			x = getCenterX(row),
			y = row.height / 2,
			text = row.params.text or Lang.jackpotItems.noItems,
			font = Font.counterstrike,
			fontSize = fontSize,
			align = "center"
		})
		text.anchorX = 0.5
		text.anchorY = 0.5
		if row.params.text then
			text:setFillColor(unpack(Color.gold))
		else
			text:setFillColor(unpack(Color.lightText))
		end
		FontOffset.setOffset(text)
		GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
		return
	end
	for i = 1, skinsPerRow - 1 do
		GUI.drawVerticalLine(row, row.x + row.width * (i * (1 / skinsPerRow)), row.x, row.height)
	end
	for i = 1, #skins do
		local columnX = (i - 1) * (1 / skinsPerRow * row.width)
		local columnWidth = 1 / skinsPerRow * row.width
		local itemBox = GUI.createItemBox(row, skins[i], columnX + columnWidth / 2 - 345 * Game.guiScale / 2 - 4, 25, skins[i].statTrak, 1, {
			quality = skins[i].quality,
			pattern = skins[i].pattern
		})
		GUI.createButton(row, itemBox.x, itemBox.y + itemBox.height + 5, 345 * Game.guiScale, 60, "$" .. formatPrice(Game.getItemPrice(skins[i])), RarityButtons[skins[i].rarity], function()
		end, 32)
	end
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local function insertRows()
	skinTable:deleteAllRows()
	skinTableHeight = 0
	if Jackpot.getItemCount() == 0 then
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
			rowHeight = 250
		})
		skinTableHeight = skinTableHeight + 250 * Game.guiScale
		return
	end
	if alternativeView then
		local itemList = {}
		for _, item in ipairs(Game.jackpot.playerItems) do
			table.insert(itemList, item)
		end
		for _, items in pairs(Game.jackpot.otherItems) do
			for _, item in ipairs(items) do
				table.insert(itemList, item)
			end
		end
		table.sort(itemList, function(a, b)
			return Game.getItemPrice(a) > Game.getItemPrice(b)
		end)
		for i = 0, math.ceil(#itemList / skinsPerRow) - 1 do
			local params = {}
			for j = 1, skinsPerRow do
				if not itemList[i * skinsPerRow + j] then
					break
				end
				params[j] = itemList[i * skinsPerRow + j]
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
				rowHeight = 470
			})
			skinTableHeight = skinTableHeight + 470 * Game.guiScale
		end
		return
	end
	local itemTable = {}
	for player, items in pairs(Game.jackpot.otherItems) do
		itemTable[player] = items
	end
	itemTable[Lang.jackpotItems.your] = Game.jackpot.playerItems
	for player, items in pairs(itemTable) do
		if 0 < #items then
			table.sort(items, function(a, b)
				return Game.getItemPrice(a) > Game.getItemPrice(b)
			end)
			skinTable:insertRow({
				params = {
					text = player .. " " .. Lang.common.items
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
				rowHeight = 120
			})
			skinTableHeight = skinTableHeight + 120 * Game.guiScale
			if 0 < #items then
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
						rowHeight = 470
					})
					skinTableHeight = skinTableHeight + 470 * Game.guiScale
				end
			else
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
					rowHeight = 140
				})
				skinTableHeight = skinTableHeight + 140 * Game.guiScale
			end
		end
	end
end
function scene:create(event)
	local sceneGroup = self.view
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.6)
	background:addEventListener("tap", function()
		return true
	end)
	local mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.01, display.safeActualContentHeight * 0.01, display.safeActualContentWidth * 0.98, display.safeActualContentHeight * 0.98, ucfirst(Lang.common.items))
	titleText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = mainBox.y + 38,
		text = Lang.jackpotItems.itemsInTheJackpot,
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
		text = Lang.jackpotItems.newItems .. ":",
		font = Font.counterstrike,
		fontSize = 62,
		align = "center"
	})
	secondText.anchorX = 0.5
	FontOffset.setOffset(secondText)
	local okButton = GUI.createButton(sceneGroup, mainBox.x + 170, mainBox.y + mainBox.height - 150, mainBox.width - 340 - 500 - 15, 120, Lang.common.ok, ButtonType.default, function(event)
		composer.hideOverlay()
	end, 70)
	local changeViewButton = GUI.createButton(sceneGroup, mainBox.x + mainBox.width - 170 - 500, mainBox.y + mainBox.height - 150, 500, 120, Lang.jackpotItems.changeView, ButtonType.default, function(event)
		alternativeView = not alternativeView
		insertRows()
		local tableMaxScroll = -skinTableHeight + skinTable.height
		slider:setTableView(skinTable, tableMaxScroll)
		slider:scrollBar(0)
	end, 60)
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
		insertRows()
		secondText.text = Jackpot.getItemCount() .. " / 50"
		slider:scrollBar(0)
		local tableMaxScroll = -skinTableHeight * Game.guiScale + skinTable.height
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
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
