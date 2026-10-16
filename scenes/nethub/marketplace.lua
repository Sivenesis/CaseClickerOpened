Market = require("online.Market")
local composer = require("composer")
local VerticalSlider = require("gui.verticalslider")
local scene = composer.newScene()
local mainBox, slider, offerCounter, offerView
local status = ""
local offerViewHeight = 0
local loading = false
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
local function updateList()
	offerView:deleteAllRows()
	createdTexts = {}
	offerView:insertRow({
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
	offerViewHeight = 140
	for i = 1, #Market.offers do
		offerView:insertRow({
			params = {
				id = i,
				offer = Market.offers[i]
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
			rowHeight = 200
		})
		offerViewHeight = offerViewHeight + 200
	end
	if #Market.offers == 0 then
		status = "No market offers found"
		offerView:insertRow({
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
		offerViewHeight = offerViewHeight + 350
	end
	slider:scrollBar(0)
	slider:setTableView(offerView, math.min(-offerViewHeight + offerView.height, -1))
	offerCounter.text = "Total: " .. #Market.offers .. " market offers"
end
local function refreshList(force, silent)
	updateList()
	status = "Loading..."
	loading = true
	offerView:reloadData()
	Market.get(function(success, data)
		loading = false
		if not success then
			status = offerList or "Could not connect with the server"
			offerView:reloadData()
			return
		end
		if #Market.offers == 0 then
			status = "No market offers found"
			offerView:reloadData()
			return
		end
		updateList()
	end, force, silent)
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
			width = offerView.width * 0.8,
			font = Font.counterstrike,
			fontSize = 52,
			align = "center"
		})
		emptyText.anchorX = 0.5
		emptyText.anchorY = 0.5
		FontOffset.setOffset(emptyText)
		return
	end
	if row.params.button then
		local addOfferButtonType = ButtonType.red
		if Market.canAddOffer() and Game.money > Market.getOfferPrice() then
			addOfferButtonType = ButtonType.green
		end
		Button.create(row, 50, 24, row.width - 100, row.height - 48, "Add offer @ " .. "$" .. Market.getOfferPrice(), addOfferButtonType, function(event)
			if loading then
				return false
			end
			if Game.money < Market.getOfferPrice() then
				return GUI.showMessageBox("Information", "You do not have enough money to add the offer")
			end
			if addOfferButtonType == ButtonType.red then
				return GUI.showMessageBox("Information", "Please wait at least 10 minutes before adding next offer")
			end
			composer.showOverlay("overlays.offercreation", {
				time = 300,
				effect = "fade",
				params = {
					successCallback = function()
						timer.performWithDelay(100, function()
							refreshList(true)
						end)
						Game.removeMoney(Market.getOfferPrice(), "Other", "Market Offer")
						return true
					end
				}
			})
		end, {fontSize = 65})
		return
	end
	local offer = row.params.offer
	local lastY = 24
	local playerNameText = display.newText({
		parent = row,
		x = 16,
		y = lastY,
		text = offer.name,
		font = Font.counterstrike,
		fontSize = 62
	})
	FontOffset.setOffset(playerNameText)
	playerNameText:setFillColor(unpack(Color.gold))
	local textId = (row.params and row.params.id) or row.index or (#createdTexts + 1)
	createdTexts[textId] = display.newText({
		parent = row,
		x = row.width * 0.7 - 10,
		y = lastY,
		text = "",
		font = Font.counterstrike,
		fontSize = 36
	})
	createdTexts[textId].time = offer.created
	createdTexts[textId].anchorX = 1
	createdTexts[textId]:setFillColor(unpack(ColorTools.lighten(Color.row, 3.2)))
	FontOffset.setOffset(createdTexts[textId])
	lastY = lastY + 65
	local offersText = display.newText({
		parent = row,
		x = 12,
		y = lastY,
		text = "Offers:",
		font = Font.main,
		fontSize = 36
	})
	offersText:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(offersText)
	local offersFontSize = 32
	if #offer.offering >= 75 then
		offersFontSize = 26
	elseif 50 <= #offer.offering then
		offersFontSize = 30
	end
	local offersText2 = display.newText({
		parent = row,
		x = 132,
		y = offersText.y,
		width = row.width * 0.7 - 150 - 10,
		text = offer.offering,
		font = Font.main,
		fontSize = offersFontSize
	})
	lastY = lastY + 60
	local wantsText = display.newText({
		parent = row,
		x = 12,
		y = lastY,
		text = "Wants:",
		font = Font.main,
		fontSize = 36
	})
	wantsText:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(wantsText)
	local wantsFontSize = 32
	if 75 <= #offer.receiving then
		wantsFontSize = 26
	elseif 50 <= #offer.receiving then
		wantsFontSize = 30
	end
	local wantsText2 = display.newText({
		parent = row,
		x = 132,
		y = wantsText.y,
		width = row.width * 0.7 - 150 - 10,
		text = offer.receiving,
		font = Font.main,
		fontSize = wantsFontSize
	})
	GUI.drawVerticalLine(row, row.width * 0.7 - 8, 0, row.height - 7)
	local buttonColor = ButtonType.green
	if offer.name == Game.others.netNick then
		buttonColor = ButtonType.default
	end
	local tradeButton = Button.create(row, row.width * 0.7 + 5, 10, row.width * 0.3 - 15, row.height - 26, "Trade", buttonColor, function()
		if buttonColor ~= ButtonType.green then
			return GUI.showMessageBox("Information", "You cannot trade with yourself.")
		end
		GUI.showMessageBox("Creating Trade", "Please wait...", {loading = true})
		NetHub.createTrade(offer.name, function(success, output)
			if not success then
				local text = Lang.common.connectionFailed
				if output and output.text then
					text = output.text
				end
				return GUI.showMessageBox("Error", text)
			elseif output.trade then
				NetHub.cache.trades[output.trade.id] = output.trade
				NetHub.loadTrade(output.trade.id, true)
			else
				GUI.showMessageBox("Info", output.text)
			end
		end)
	end, {fontSize = 62})
end
local function drawMainBox()
	local sceneGroup = scene.view
	mainBox = GUI.drawMainBox(sceneGroup, "")
	offerCounter = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = mainBox.y - 28,
		text = "Loading...",
		font = Font.counterstrike,
		fontSize = 36
	})
	offerCounter.anchorX = 0.5
	offerCounter.anchorY = 0.5
	offerCounter:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(offerCounter)
	slider = VerticalSlider.create(sceneGroup, mainBox.x + mainBox.width - 80, mainBox.y, 80, mainBox.height - 110 * Game.guiScale)
	offerView = widget.newTableView({
		left = mainBox.x,
		top = mainBox.y,
		width = mainBox.width - 80,
		height = mainBox.height - 110 * Game.guiScale,
		isBounceEnabled = false,
		backgroundColor = Color.row,
		onRowRender = onRowRender,
		listener = function(event)
			slider:scrollListener(event)
		end,
		hideScrollBar = true
	})
	local buttonMargin = 5
	local buttonBackground = display.newRect(sceneGroup, mainBox.x, mainBox.y + mainBox.height - 110 * Game.guiScale, mainBox.width, 110 * Game.guiScale)
	buttonBackground:setFillColor(unpack(Color.row))
	local refreshButton = Button.create(sceneGroup, mainBox.x + buttonMargin, mainBox.y + mainBox.height - 110 * Game.guiScale + buttonMargin, mainBox.width / 2 - buttonMargin * 2, 110 * Game.guiScale - buttonMargin * 2, "Refresh List", ButtonType.default, function(event)
		refreshList(true)
	end, {fontSize = 55, blockTime = 1000})
	local returnButton = Button.create(sceneGroup, mainBox.x + mainBox.width / 2 + buttonMargin, mainBox.y + mainBox.height - 110 * Game.guiScale + buttonMargin, mainBox.width / 2 - buttonMargin * 2, 110 * Game.guiScale - buttonMargin * 2, "Return", ButtonType.purple, function(event)
		composer.gotoScene("scenes.nethub.nethub")
	end, {fontSize = 55})
	sceneGroup:insert(offerView)
end
function scene:create(event)
	local sceneGroup = self.view
	drawMainBox()
	status = "Loading..."
	updateList()
end
local function onMouseWheel(event)
	if event.scrollY and offerView and offerView.scrollToY then
		local currentY = offerView:getContentPosition()
		local targetY = currentY + (event.scrollY * 50)
		offerView:scrollToY({ y = targetY, time = 40 })
	end
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
		slider:setTableView(offerView)
		if #Market.offers > 0 then
			refreshList(false, true)
		else
			refreshList(true, true)
		end
		slider:scrollBar(0)
		slider:setTableView(offerView, math.min(-offerViewHeight + offerView.height, -1))
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
scene:addEventListener("hide", scene)
return scene
