local composer = require("composer")
local VerticalSlider = require("gui.verticalslider")
local TextSlider = require("gui.textslider")
local scene = composer.newScene()
local box, slider, tradeCounter, tradeView
local trades = {}
local status = ""
local tradesToday = 0
local tradeViewHeight = 0
local sliderTexts = Lang.trades.sliderTexts
local actualTextId = 1
local tradesShown = 0
local createdTexts = {}
local lastTime = system.getTimer()
local lastUpdate = 0
local function onEnterFrame(event)
	deltaTime = event.time - lastTime
	lastTime = system.getTimer()
	if system.getTimer() - lastUpdate >= 250 then
		lastUpdate = system.getTimer()
		for _, text in pairs(createdTexts) do
			text.text = getTimeElapsedString(text.time)
		end
	end
end
local function updateTradeList()
	tradeView:deleteAllRows()
	createdTexts = {}
	tradeView:insertRow({
		params = {button = true},
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
	tradeViewHeight = 140
	tradesShown = 0
	for i = 1, #trades do
		if actualTextId == 1 and (trades[i].state == 0 or trades[i].state == 3) or actualTextId == 2 and trades[i].state == 2 or actualTextId == 3 and trades[i].state == 1 then
			tradeView:insertRow({
				params = trades[i],
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
			tradesShown = tradesShown + 1
			tradeViewHeight = tradeViewHeight + 250 * Game.guiScale
		end
	end
	if #trades == 0 or tradesShown == 0 then
		if actualTextId == 1 then
			status = Lang.trades.noActiveTrades .. ".\r\n" .. Lang.trades.maybeCreateOne
		elseif actualTextId == 2 then
			status = Lang.trades.noAcceptedTrades
		else
			status = Lang.trades.noCancelledTrades
		end
		tradeView:insertRow({
			params = {empty = true},
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = 350
		})
		tradeViewHeight = tradeViewHeight + 350
	end
	slider:scrollBar(0)
	slider:setTableView(tradeView, math.min(-tradeViewHeight + tradeView.height, -1))
end
local function refreshList()
	trades = {}
	updateTradeList()
	status = Lang.common.loading .. "..."
	tradeView:reloadData()
	NetHub.getTradeList(function(success, result)
		if not success then
			status = Lang.common.couldNotConnect
			tradeView:reloadData()
			return
		end
		tradesToday = result.trades_today
		tradeCounter.text = tradesToday .. " / " .. NetHub.tradeLimit .. " " .. Lang.trades.tradesToday
		if #result.trades == 0 then
			status = Lang.trades.noActiveTrades .. ".\r\n" .. Lang.trades.maybeCreateOne
			tradeView:reloadData()
			return
		end
		trades = result.trades
		table.sort(trades, function(a, b)
			return a.state > b.state
		end)
		status = ""
		updateTradeList()
	end)
end
local function onRowRender(event)
	local row = event.row
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
	if row.params.empty then
		local emptyText = display.newText({
			parent = row,
			x = row.width / 2,
			y = row.height / 2,
			text = status,
			width = tradeView.width * 0.8,
			font = Font.default,
			fontSize = 52,
			align = "center"
		})
		emptyText.anchorX = 0.5
		emptyText.anchorY = 0.5
		FontOffset.setOffset(emptyText)
		return
	end
	if row.params.button then
		GUI.createButton(row, 50, 24, row.width - 100, row.height - 48, Lang.trades.createNewTrade, ButtonType.green, function(event)
			if status == Lang.common.loading .. "..." then
				return false
			end
			if tradesToday >= NetHub.tradeLimit then
				GUI.showMessageBox(Lang.common.info, Lang.trades.cantCreateMoreTrades)
				return
			end
			composer.showOverlay("overlays.tradecreation", {isModal = true})
		end, 55)
		return
	end
	local status = row.params.state
	local image = display.newImageRect(row, "images/trades/" .. TradeImages[status], 117 * Game.guiScale, 117 * Game.guiScale)
	image.anchorY = 0.5
	image.x = 30
	image.y = row.height / 2
	GUI.drawVerticalLine(row, 170, 0, row.height)
	local statusText = display.newText({
		parent = row,
		x = 200,
		y = 20 * Game.guiScale,
		text = TradeStatuses[status],
		font = Font.counterstrike,
		fontSize = 46 * Game.guiScale,
		align = "left"
	})
	FontOffset.setOffset(statusText)
	local tradingPerson = row.params.user1
	if tradingPerson == NetHub.getNickname() then
		tradingPerson = row.params.user2
	end
	local tradePersonText = display.newText({
		parent = row,
		x = 200,
		y = statusText.y + statusText.height + (6 * Game.guiScale),
		text = Lang.trades.tradeWith .. ": " .. tradingPerson,
		font = Font.counterstrike,
		fontSize = 40 * Game.guiScale,
		width = box.width - 440 - 215,
		align = "left"
	})
	tradePersonText:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(tradePersonText)
	local viewButtonType = ButtonType.green
	if status == Trade.accepted and row.params.userReceived == true or status == Trade.cancelled and row.params.userReceived == true or status == Trade.pending and row.params.userAccepted == true then
		viewButtonType = ButtonType.default
	end
	local textId = (row.params and row.params.id) or row.index or (#createdTexts + 1)
	createdTexts[textId] = display.newText({
		parent = row,
		x = 200,
		y = tradePersonText.y + tradePersonText.height + (6 * Game.guiScale),
		text = getTimeElapsedString(row.params.created),
		font = Font.counterstrike,
		fontSize = 32 * Game.guiScale
	})
	createdTexts[textId].time = row.params.created
	createdTexts[textId]:setFillColor(unpack(ColorTools.lighten(Color.row, 3.2)))
	FontOffset.setOffset(createdTexts[textId])
	local btnH = 120 * Game.guiScale
	local viewButton = GUI.createButton(row, box.width - 440, row.height / 2 - btnH / 2, 330, btnH, Lang.trades.view, viewButtonType, function(event)
		NetHub.loadTrade(row.params.id)
	end, 55)
end
local function drawMainBox()
	local sceneGroup = scene.view
	box = GUI.drawMainBox(sceneGroup, "")
	tradeCounter = display.newText({
		parent = sceneGroup,
		x = getCenterX(box),
		y = box.y - 26,
		text = Lang.common.loading .. "...",
		font = Font.counterstrike,
		fontSize = 36
	})
	tradeCounter.anchorX = 0.5
	tradeCounter.anchorY = 0.5
	tradeCounter:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(tradeCounter)
	local textSlider = TextSlider.create(sceneGroup, box.x, box.y, box.width, 100 * Game.guiScale, sliderTexts, function(text, textId)
		actualTextId = textId
		updateTradeList()
	end, 80 * Game.guiScale)
	slider = VerticalSlider.create(sceneGroup, box.x + box.width - 80, box.y + 100 * Game.guiScale, 80, box.height - 110 * Game.guiScale - 100 * Game.guiScale)
	tradeView = widget.newTableView({
		left = box.x,
		top = box.y + 100 * Game.guiScale,
		width = box.width - 80,
		height = box.height - 110 * Game.guiScale - 100 * Game.guiScale,
		isBounceEnabled = false,
		backgroundColor = Color.row,
		onRowRender = onRowRender,
		listener = function(event)
			slider:scrollListener(event)
		end,
		hideScrollBar = true
	})
	local buttonMargin = 5
	local buttonBackground = display.newRect(sceneGroup, box.x, box.y + box.height - 110 * Game.guiScale, box.width, 110 * Game.guiScale)
	buttonBackground:setFillColor(unpack(Color.row))
	local refreshButton = GUI.createButton(sceneGroup, box.x + buttonMargin, box.y + box.height - 110 * Game.guiScale + buttonMargin, box.width / 2 - buttonMargin * 2, 110 * Game.guiScale - buttonMargin * 2, Lang.trades.refreshList, ButtonType.default, function(event)
		refreshList()
	end, 55)
	local returnButton = GUI.createButton(sceneGroup, box.x + box.width / 2 + buttonMargin, box.y + box.height - 110 * Game.guiScale + buttonMargin, box.width / 2 - buttonMargin * 2, 110 * Game.guiScale - buttonMargin * 2, Lang.common.return_, ButtonType.purple, function(event)
		composer.gotoScene("scenes.nethub.nethub")
		Menu.updateItems()
	end, 55)
	sceneGroup:insert(tradeView)
end
function scene:create(event)
	local sceneGroup = self.view
	drawMainBox()
	status = "Loading..."
	updateTradeList()
end
local function onMouseWheel(event)
	if event.scrollY and tradeView and tradeView.scrollToY then
		local currentY = tradeView:getContentPosition()
		local targetY = currentY + (event.scrollY * 50)
		tradeView:scrollToY({ y = targetY, time = 40 })
	end
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
		slider:setTableView(tradeView)
		if not event.params or not event.params.loadFromCache then
			refreshList()
			slider:scrollBar(0)
			slider:setTableView(tradeView, math.min(-tradeViewHeight + tradeView.height, -1))
		end
		Runtime:addEventListener("enterFrame", onEnterFrame)
		Runtime:addEventListener("mouse", onMouseWheel)
	elseif phase == "did" then
	end
end
function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Runtime:removeEventListener("enterFrame", onEnterFrame)
		Runtime:removeEventListener("mouse", onMouseWheel)
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
