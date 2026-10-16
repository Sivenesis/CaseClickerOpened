local composer = require("composer")
local VerticalSlider = require("gui.verticalslider")
local scene = composer.newScene()
local skinTable
local ownedTable = {}
local canBeCompleted = true
local skinsPerRow = 3
local souvenir = false
local function onRowRender(event)
	local row = event.row
	local skins = event.row.params
	for i = 1, #skins do
		GUI.drawVerticalLine(row, row.x + row.width * (i * (1 / skinsPerRow)), row.x, row.height)
	end
	for i = 1, #skins do
		local columnX = (i - 1) * (1 / skinsPerRow * row.width)
		local columnWidth = 1 / skinsPerRow * row.width
		local itemBoxParams = {
			type = Item.skin,
			id = skins[i]
		}
		local specialItem = false
		if type(skins[i]) ~= "number" and (skins[i].isKnife or skins[i].isGlove) then
			itemBoxParams = {
				type = Item.rare,
				id = skins[i].id
			}
			if skins[i].isGlove then
				itemBoxParams.type = Item.rareGlove
			end
			specialItem = true
		end
		if isCapsule then
			itemBoxParams.type = Item.sticker
		end
		local itemBox = GUI.createItemBox(row, itemBoxParams, columnX + columnWidth / 2 - 345 * Game.guiScale / 2 - 4, 25, souvenir)
		itemBox:addEventListener("tap", function()
			if itemBoxParams.type == Item.skin or itemBoxParams.type == Item.sticker then
				Game.showPriceInfo(itemBoxParams)
			end
		end)
		if not specialItem then
			local ownedText = display.newText({
				parent = row,
				x = columnX + columnWidth / 2,
				y = itemBox.y + itemBox.height + 40,
				text = Lang.caseinfo.notowned,
				font = Font.counterstrike,
				fontSize = 42 * Game.guiScale,
				align = "center"
			})
			ownedText.anchorX = 0.5
			ownedText.anchorY = 0.5
			FontOffset.setOffset(ownedText)
			if ownedTable[skins[i]] then
				ownedText.text = Lang.caseinfo.owned
				ownedText:setFillColor(unpack(Color.gold))
			end
		end
	end
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local function insertRows(case)
	skinTable:deleteAllRows()
	local itemType = Item.skin
	if case.stickers then
		isCapsule = true
		itemType = Item.sticker
	else
		isCapsule = false
	end
	local skins = case.skins or case.stickers
	local actualItem = 1
	ownedTable = {}
	canBeCompleted = true
	for i = 1, #skins do
		ownedTable[skins[i]] = Game.isItemOwned({
			id = skins[i],
			type = itemType,
			statTrak = souvenir
		})
		if not ownedTable[skins[i]] then
			canBeCompleted = false
		end
	end
	local skinCount = #skins
	local jAdd = 0
	if case.knifes or case.gloves then
		skinCount = skinCount + 1
		jAdd = 1
	end
	for i = 0, math.ceil(skinCount / skinsPerRow) - 1 do
		local params = {}
		for j = 1, skinsPerRow do
			if not skins[actualItem] then
				break
			end
			if i == 0 and j == 1 and (case.knifes or case.gloves) then
				local id = case.knifes or case.gloves
				if type(id) == "table" then
					id = -1
				end
				if case.knifes then
					table.insert(params, {isKnife = true, id = id})
				elseif case.gloves then
					table.insert(params, {isGlove = true, id = id})
				end
			else
				table.insert(params, skins[actualItem])
				actualItem = actualItem + 1
			end
		end
		skinTable:insertRow({
			params = params,
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = 450 * Game.guiScale
		})
	end
end
function scene:create(event)
	if not event.params then
		composer.gotoScene("scenes.main")
		return true
	end
	local sceneGroup = self.view
	local case = event.params.case
	local info = event.params.case
	if event.params.info then
		info = event.params.info
	end
	if info.collection then
		souvenir = true
	end
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.6)
	background:addEventListener("tap", function()
		return true
	end)
	local mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.01, display.safeActualContentHeight * 0.01, display.safeActualContentWidth * 0.98, display.safeActualContentHeight * 0.98, Lang.caseinfo.caseinfo)
	local titleText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = mainBox.y + 48,
		text = info.name,
		font = Font.counterstrike,
		fontSize = 102,
		align = "center"
	})
	titleText.anchorX = 0.5
	FontOffset.setOffset(titleText)
	local completedText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = titleText.y + titleText.height + 8,
		text = info.opened .. " " .. Lang.caseinfo.opened,
		font = Font.counterstrike,
		fontSize = 42,
		align = "center"
	})
	completedText.anchorX = 0.5
	FontOffset.setOffset(completedText)
	local minus = ""
	profit = 0
	if info.profit then
		profit = info.profit
	end
	if 0 > profit then
		minus = "@"
	end
	completedText.text = completedText.text .. " | " .. Lang.caseinfo.profit .. ": " .. minus .. "$" .. formatPrice(profit)
	if info.completed then
		completedText.text = completedText.text .. " | " .. Lang.caseinfo.completed
		completedText:setFillColor(unpack(Color.gold))
	else
		completedText.text = completedText.text .. " | " .. Lang.caseinfo.notcompleted
	end
	local okButton = GUI.createButton(sceneGroup, mainBox.x + 170, mainBox.y + mainBox.height - 150, mainBox.width - 340, 120, "Ok", ButtonType.blue, function(event)
		composer.gotoScene(Game.lastScene or "scenes.cases")
	end, 70)
	slider = VerticalSlider.create(sceneGroup, mainBox.width - 125, mainBox.y + 170, 100, mainBox.height * 0.7)
	skinTable = widget.newTableView({
		left = mainBox.x + 50,
		top = mainBox.y + 170,
		width = mainBox.width - 200,
		height = mainBox.height * 0.7,
		isBounceEnabled = false,
		backgroundColor = Color.row,
		hideBackground = false,
		onRowRender = onRowRender,
		listener = function(event)
			slider:scrollListener(event)
		end,
		hideScrollBar = true
	})
	sceneGroup:insert(skinTable)
	skinsPerRow = calculateSkinsPerRow(skinTable.width)
	insertRows(case)
	if not info.completed and canBeCompleted then
		local getRewardButton
		getRewardButton = GUI.createButton(sceneGroup, mainBox.x + 170, mainBox.y + mainBox.height - 150, mainBox.width - 340, 120, Lang.caseinfo.getreward, ButtonType.green, function(event)
			getRewardButton.alpha = 0
			okButton.alpha = 1
			Game.completeCollection(info)
			completedText.text = Lang.caseinfo.completed
			completedText:setFillColor(unpack(Color.gold))
		end, 70)
		okButton.alpha = 0
	end
	sceneGroup:toFront()
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.hide()
		slider:scrollBar(0)
		local tableMaxScroll = -(skinTable:getNumRows() * 450 * Game.guiScale) + skinTable.height
		slider:setTableView(skinTable, tableMaxScroll)
	elseif phase == "did" then
	end
end
function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
	elseif phase == "did" then
		composer.removeScene("scenes.caseinfo")
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
