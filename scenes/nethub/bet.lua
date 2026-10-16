local composer = require("composer")
local VerticalSlider = require("gui.verticalslider")
local scene = composer.newScene()
local match, slider, statusText, tableText, leftSelectButton, leftSelectedButton, rightSelectButton, rightSelectedButton, leftRect, rightRect, bet, getItemsButton, smallReturnButton, bigReturnButton
local function getItemsPrice()
	local itemsPrice = 0
	for _, id in ipairs(Bets.bet.items) do
		if bet then
			itemsPrice = itemsPrice + Game.getItemPrice(id)
		else
			itemsPrice = itemsPrice + Game.getPrice(Game.equipment[id])
		end
	end
	return itemsPrice
end
local function updateTableText()
	local s = "s"
	if #Bets.bet.items == 1 then
		s = ""
	end
	tableText.text = #Bets.bet.items .. " item" .. s .. " worth $" .. formatPrice(getItemsPrice())
end
local function updateStatusText()
	if bet then
		local betTeam = match.a
		if bet.team == 2 then
			betTeam = match.b
		end
		if match.closed == 0 then
			local itemsPrice = 0
			for _, item in ipairs(Bets.bet.items) do
				itemsPrice = itemsPrice + Game.getItemPrice(item)
			end
			statusText.text = "You've placed a bet on " .. betTeam .. ". If they win you'll receive new items worth $" .. formatPrice(itemsPrice * bet.value) .. "!"
			return
		else
			if match.winner == bet.team then
				statusText.text = "You've placed a bet on " .. betTeam .. " and they have won! Congratulations!"
				return
			end
			if match.winner ~= bet.team and match.winner < 3 then
				statusText.text = "You've placed a bet on " .. betTeam .. " and they have lost."
				return
			end
			if match.winner == 3 then
				statusText.text = "Match has been cancelled or there was a draw."
				if bet.status == 0 then
					statusText.text = statusText.text .. "\r\nYour items will be returned."
				end
				return
			end
		end
	end
	if Bets.bet.selected == 0 then
		statusText.text = "Please select a team."
		return
	end
	if #Bets.bet.items == 0 then
		statusText.text = "Please add items that you want to bet."
		return
	end
	Bets.bet.value = match.apercent / match.bpercent
	local teamName = match.b
	if Bets.bet.selected == 1 then
		teamName = match.a
		Bets.bet.value = match.bpercent / match.apercent
	end
	if Bets.bet.value > 10 then
		Bets.bet.value = 10
	end
	local itemsPrice = 0
	for _, id in ipairs(Bets.bet.items) do
		itemsPrice = itemsPrice + Game.getPrice(Game.equipment[id])
	end
	statusText.text = "If " .. teamName .. " win, you'll receive new items worth $" .. formatPrice(itemsPrice * Bets.bet.value)
end
local function fadeInLeftRectangle()
	if rightRect.alpha == 1 then
		transition.fadeOut(rightRect, {time = 250})
	end
	if leftRect.alpha == 0 then
		transition.fadeIn(leftRect, {time = 250})
	end
end
local function fadeInRightRectangle()
	if leftRect.alpha == 1 then
		transition.fadeOut(leftRect, {time = 250})
	end
	if rightRect.alpha == 0 then
		transition.fadeIn(rightRect, {time = 250})
	end
end
local function updateButtons()
	if bet then
		return
	end
	local selected = Bets.bet.selected
	leftSelectButton.alpha = 0
	leftSelectedButton.alpha = 0
	rightSelectButton.alpha = 0
	rightSelectedButton.alpha = 0
	if selected == 0 then
		leftSelectButton.alpha = 1
		rightSelectButton.alpha = 1
	elseif selected == 1 then
		leftSelectedButton.alpha = 1
		rightSelectButton.alpha = 1
		fadeInLeftRectangle()
	elseif selected == 2 then
		leftSelectButton.alpha = 1
		rightSelectedButton.alpha = 1
		fadeInRightRectangle()
	end
	updateStatusText()
end
local function addItemsToTableView(tableView)
	local itemTableHeight = 0
	slider:scrollBar(0)
	tableView:deleteAllRows()
	if #Bets.bet.items == 0 then
		tableView:insertRow({
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
			rowHeight = 350 * Game.guiScale
		})
		slider:setTableView(tableView, tableView.height, 2)
		return
	end
	for i = 1, #Bets.bet.items do
		local params = {
			itemId = Bets.bet.items[i]
		}
		if type(Bets.bet.items[i]) == "table" then
			params = {
				item = Bets.bet.items[i]
			}
		end
		tableView:insertRow({
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
			rowHeight = 470 * Game.guiScale
		})
		itemTableHeight = itemTableHeight + 470 * Game.guiScale
	end
	slider:setTableView(tableView, -itemTableHeight + tableView.height, 2)
end
local function onRowRender(event)
	local row = event.row
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
	if row.params.empty then
		local emptyText = display.newText({
			parent = row,
			x = row.width / 2,
			y = row.height / 2,
			text = "No items added",
			font = Font.default,
			fontSize = 52,
			align = "center"
		})
		emptyText.anchorX = 0.5
		emptyText.anchorY = 0.5
		FontOffset.setOffset(emptyText)
		return
	end
	local item = row.params.item or Game.equipment[row.params.itemId]
	local itemBox = GUI.createItemBox(row, item, row.width / 2 - 345 * Game.guiScale / 2, 25, item.statTrak, 1, {
		quality = item.quality,
		pattern = item.pattern,
		stickers = item.stickers
	})
	if bet then
		GUI.createButton(row, itemBox.x, itemBox.y + itemBox.height + 5, 345 * Game.guiScale, 60, "$" .. formatPrice(Game.getItemPrice(item)), RarityButtons[item.rarity], function()
		end, 32)
	else
		GUI.createButton(row, itemBox.x, itemBox.y + itemBox.height + 5, 345 * Game.guiScale, 60, "Remove", RarityButtons[item.rarity], function()
			for i = 1, #Bets.bet.items do
				if row.params.itemId == Bets.bet.items[i] then
					table.remove(Bets.bet.items, i)
					itemTable:deleteRow(row.id)
					Game.equipment[row.params.itemId].tmpLock = false
					updateTableText()
					timer.performWithDelay(800, function()
						if #Bets.bet.items == 0 then
							addItemsToTableView(itemTable)
						end
					end)
					return true
				end
			end
		end, 32)
	end
end
function scene:create(event)
	local sceneGroup = self.view
	bet = event.params.bet
	match = event.params.match or bet.match
	if bet then
		for _, item in ipairs(bet.items) do
			table.insert(Bets.bet.items, item)
		end
	end
	Bets.bet.matchId = match.lounge_id
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.6)
	background:addEventListener("tap", function()
		return true
	end)
	local padding = 10
	local mainBox = GUI.createBox(sceneGroup, padding, padding, display.safeActualContentWidth - 2 * padding, display.safeActualContentHeight - 2 * padding, "Place a bet")
	local padding = 60
	tableText = display.newText({
		parent = sceneGroup,
		x = mainBox.x + padding + 287.5,
		y = mainBox.y + padding,
		text = "",
		font = Font.counterstrike,
		fontSize = 40,
		align = "center"
	})
	tableText.anchorX = 0.5
	FontOffset.setOffset(tableText)
	local itemTableHeight = mainBox.height - padding * 2 - 75 - 40
	if bet then
		itemTableHeight = itemTableHeight + 75
	end
	slider = VerticalSlider.create(sceneGroup, mainBox.x + padding + 500, mainBox.y + padding + 40, 75, itemTableHeight)
	itemTable = widget.newTableView({
		left = mainBox.x + padding,
		top = mainBox.y + padding + 40,
		width = 500,
		height = itemTableHeight,
		isBounceEnabled = false,
		backgroundColor = Color.row,
		onRowRender = onRowRender,
		listener = function(event)
			slider:scrollListener(event)
		end,
		hideScrollBar = true
	})
	sceneGroup:insert(itemTable)
	if not bet then
		GUI.createButton(sceneGroup, itemTable.x, itemTable.y + itemTable.height, itemTable.width + 75, 75, "Add Items", ButtonType.green, function(event)
			if Game.showingOverlay then
				return
			end
			composer.gotoScene("scenes.itemselection", {
				params = {
					type = ItemSelection.bet
				}
			})
		end, 55)
	end
	local minX = itemTable.x + itemTable.width + 75 + 20
	local lastY = mainBox.y + 20 + padding
	local centerX = (minX + mainBox.x + mainBox.width - 10) / 2
	local widthX = mainBox.x + mainBox.width - 10 - minX
	match.event = match.event or match.tournament or "Tournament Match"
	match.timeStr = match.timeStr or "Live"
	local eventTextSize = 96
	if #match.event >= 14 then
		eventTextSize = 64
	end
	local eventText = display.newText({
		parent = sceneGroup,
		x = centerX,
		y = lastY,
		text = match.event,
		font = Font.counterstrike,
		fontSize = eventTextSize,
		align = "center"
	})
	eventText.anchorX = 0.5
	FontOffset.setOffset(eventText)
	local dateText = display.newText({
		parent = sceneGroup,
		x = centerX,
		y = lastY + 70,
		text = match.timeStr,
		font = Font.counterstrike,
		fontSize = 40,
		align = "center"
	})
	dateText.anchorX = 0.5
	FontOffset.setOffset(dateText)
	lastY = lastY + 95
	local vsText = display.newText({
		parent = sceneGroup,
		x = centerX,
		y = lastY + 75,
		text = "vs",
		font = Font.counterstrike,
		fontSize = 82,
		align = "center"
	})
	vsText.anchorX = 0.5
	vsText.anchorY = 0.5
	FontOffset.setOffset(vsText)
	vsText:setFillColor(unpack(Color.gold))
	local team1alpha = 1
	local team2alpha = 1
	if bet then
		if bet.team == 1 then
			team2alpha = 0.3
		else
			team1alpha = 0.3
		end
		if match.winner == 0 then
			if bet.team == 1 then
				team2alpha = 0.3
			else
				team1alpha = 0.3
			end
		end
	end
	local team1logo = Bets.createTeamLogo(sceneGroup, match.a)
	team1logo.x = minX + widthX / 4 * 1
	team1logo.y = lastY - 20
	team1logo.anchorX = 0.5
	team1logo.alpha = team1alpha
	local team2logo = Bets.createTeamLogo(sceneGroup, match.b)
	team2logo.x = minX + widthX / 4 * 3
	team2logo.y = lastY - 20
	team2logo.anchorX = 0.5
	team2logo.alpha = team2alpha
	if bet and (match.winner == 1 or match.winner == 2) then
		local tick = display.newImageRect(sceneGroup, "images/tick.png", 75, 75)
		tick.anchorX = 0.5
		tick.anchorY = 0.5
		tick.y = team1logo.y + team1logo.height
		if match.winner == 1 then
			tick.x = team1logo.x + team1logo.width / 2
		else
			tick.x = team2logo.x - team2logo.width / 2
		end
	end
	lastY = lastY + 150
	local firstTeamText = match.a
	if match.apercent then
		firstTeamText = firstTeamText .. " (" .. match.apercent .. "%)"
	end
	local team1text = display.newText({
		parent = sceneGroup,
		x = minX + widthX / 4 * 1,
		y = lastY,
		text = firstTeamText,
		font = Font.default,
		fontSize = 46,
		align = "center"
	})
	team1text.anchorX = 0.5
	FontOffset.setOffset(team1text)
	team1text.alpha = team1alpha
	local secondTeamText = match.b
	if match.bpercent then
		secondTeamText = secondTeamText .. " (" .. match.bpercent .. "%)"
	end
	local team2text = display.newText({
		parent = sceneGroup,
		x = minX + widthX / 4 * 3,
		y = lastY,
		text = secondTeamText,
		font = Font.default,
		fontSize = 46,
		align = "center"
	})
	team2text.anchorX = 0.5
	FontOffset.setOffset(team2text)
	team2text.alpha = team2alpha
	if not bet then
		lastY = lastY + 75
		GUI.drawHorizontalLine(sceneGroup, minX, lastY, widthX, {
			rgb(33, 46, 62)
		})
		lastY = lastY + 45
		local valueText = display.newText({
			parent = sceneGroup,
			x = centerX,
			y = lastY,
			text = "Values",
			font = Font.counterstrike,
			fontSize = 72,
			align = "center"
		})
		valueText.anchorX = 0.5
		valueText.anchorY = 0.5
		FontOffset.setOffset(valueText)
		lastY = lastY + 75
		leftRect = display.newRoundedRect(sceneGroup, minX + widthX / 4 * 1 - 270, lastY - 25, 540, 200, 50)
		leftRect:setFillColor(unpack(Color.row))
		leftRect.alpha = 0
		rightRect = display.newRoundedRect(sceneGroup, minX + widthX / 4 * 3 - 270, lastY - 25, 540, 200, 50)
		rightRect:setFillColor(unpack(Color.row))
		rightRect.alpha = 0
		local leftValueText = display.newText({
			parent = sceneGroup,
			x = minX + widthX / 4 * 1,
			y = lastY,
			text = formatPrice(math.min(10, match.bpercent / match.apercent)) .. " for 1",
			font = Font.default,
			fontSize = 46,
			align = "center"
		})
		leftValueText.anchorX = 0.5
		FontOffset.setOffset(leftValueText)
		local rightValueText = display.newText({
			parent = sceneGroup,
			x = minX + widthX / 4 * 3,
			y = lastY,
			text = formatPrice(math.min(10, match.apercent / match.bpercent)) .. " for 1",
			font = Font.default,
			fontSize = 46,
			align = "center"
		})
		rightValueText.anchorX = 0.5
		FontOffset.setOffset(rightValueText)
		lastY = lastY + 75
		leftSelectButton = GUI.createButton(sceneGroup, minX + widthX / 4 * 1 - 200, lastY, 400, 75, "Select", ButtonType.green, function(event)
			Bets.bet.selected = 1
			updateButtons()
		end, 50)
		rightSelectButton = GUI.createButton(sceneGroup, minX + widthX / 4 * 3 - 200, lastY, 400, 75, "Select", ButtonType.green, function(event)
			Bets.bet.selected = 2
			updateButtons()
		end, 50)
		leftSelectedButton = GUI.createButton(sceneGroup, minX + widthX / 4 * 1 - 200, lastY, 400, 75, "Selected", ButtonType.default, function(event)
		end, 50)
		rightSelectedButton = GUI.createButton(sceneGroup, minX + widthX / 4 * 3 - 200, lastY, 400, 75, "Selected", ButtonType.default, function(event)
		end, 50)
		leftSelectedButton.alpha = 0
		rightSelectedButton.alpha = 0
	end
	if bet then
		lastY = lastY + 75
	else
		lastY = lastY + 135
	end
	if bet and bet.team == match.winner then
		GUI.drawHorizontalLine(sceneGroup, minX, lastY, widthX, {
			rgb(33, 46, 62)
		})
		lastY = lastY + 75
		local valueText = display.newText({
			parent = sceneGroup,
			x = centerX,
			y = lastY,
			width = widthX - 40,
			text = "Winnings: $" .. formatPrice(bet.value * getItemsPrice()),
			font = Font.default,
			fontSize = 48,
			align = "center"
		})
		valueText.anchorX = 0.5
		valueText.anchorY = 0.5
		FontOffset.setOffset(valueText)
		lastY = lastY + 75
	end
	GUI.drawHorizontalLine(sceneGroup, minX, lastY, widthX, {
		rgb(33, 46, 62)
	})
	lastY = lastY + 100
	statusText = display.newText({
		parent = sceneGroup,
		x = centerX,
		y = lastY,
		width = widthX - 40,
		text = "",
		font = Font.default,
		fontSize = 48,
		align = "center"
	})
	statusText.anchorX = 0.5
	statusText.anchorY = 0.5
	FontOffset.setOffset(statusText)
	updateStatusText()
	lastY = lastY + 95
	GUI.drawHorizontalLine(sceneGroup, minX, lastY, widthX, {
		rgb(33, 46, 62)
	})
	lastY = lastY + 30
	if bet then
		bigReturnButton = GUI.createButton(sceneGroup, minX + widthX * 0.1, lastY, widthX * 0.8, 180, "Return", ButtonType.default, function(event)
			Bets.reloadBetList = true
			composer.gotoScene("scenes.nethub.matches")
			composer.removeScene("scenes.nethub.bet")
			for i = 1, #Game.equipment do
				Game.equipment[i].tmpLock = nil
			end
			Bets.bet.items = {}
			Bets.bet.matchId = 0
			Bets.bet.selected = 0
			Bets.bet.value = 0
		end, 60)
		bigReturnButton.alpha = 0
		if match.closed == 1 and bet.status == 0 then
			getItemsButton = GUI.createButton(sceneGroup, minX + widthX * 0.1, lastY, widthX * 0.8, 170, "Get Items", ButtonType.green, function(event)
				Bets.getItems(bet.id, function(success, response)
					if success then
						getItemsButton.alpha = 0
						smallReturnButton.alpha = 0
						bigReturnButton.alpha = 1
					end
				end)
			end, 60)
			lastY = lastY + 180
		end
		smallReturnButton = GUI.createButton(sceneGroup, minX + widthX * 0.1, lastY, widthX * 0.8, 90, "Return", ButtonType.default, function(event)
			composer.gotoScene("scenes.nethub.matches")
			composer.removeScene("scenes.nethub.bet")
			for i = 1, #Game.equipment do
				Game.equipment[i].tmpLock = nil
			end
			Bets.bet.items = {}
			Bets.bet.matchId = 0
			Bets.bet.selected = 0
			Bets.bet.value = 0
		end, 60)
	else
		GUI.createButton(sceneGroup, minX + widthX * 0.1, lastY, widthX * 0.8, 90, "Place bet!", ButtonType.green, function(event)
			if #Bets.bet.items == 0 or Bets.bet.selected == 0 then
				return GUI.showMessageBox(Lang.common.information, statusText.text)
			end
			GUI.showMessageBox(Lang.bets.placingBet, Lang.common.pleaseWait .. "...", false)
			Bets.placeBet(function(success, output)
				composer.hideOverlay()
				if not success or output and output.error then
					local text = "Could not place bet."
					if output and output.text then
						text = output.text
					end
					composer.gotoScene("scenes.nethub.matches")
					composer.removeScene("scenes.nethub.bet")
					Bets.bet.items = {}
					Bets.bet.matchId = 0
					Bets.bet.selected = 0
					Bets.bet.value = 0
					return GUI.showMessageBox(Lang.common.error, text)
				end
				composer.gotoScene("scenes.nethub.matches")
				composer.removeScene("scenes.nethub.bet")
				Bets.reloadBetList = true
				Bets.bet.items = {}
				Bets.bet.matchId = 0
				Bets.bet.selected = 0
				Bets.bet.value = 0
				GUI.showMessageBox(Lang.common.success, Lang.bets.betPlaced)
			end)
		end, 60, {blockTime = 1000})
		lastY = lastY + 100
		GUI.createButton(sceneGroup, minX + widthX * 0.1, lastY, widthX * 0.8, 90, "Cancel", ButtonType.red, function(event)
			composer.gotoScene("scenes.nethub.matches")
			composer.removeScene("scenes.nethub.bet")
			for i = 1, #Game.equipment do
				Game.equipment[i].tmpLock = nil
			end
			Bets.bet.items = {}
			Bets.bet.matchId = 0
			Bets.bet.selected = 0
			Bets.bet.value = 0
		end, 60)
	end
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.hide()
		addItemsToTableView(itemTable)
		updateButtons()
		updateStatusText()
		updateTableText()
	elseif phase == "did" then
	end
end
function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
