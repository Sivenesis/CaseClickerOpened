local composer = require("composer")
local VerticalSlider = require("gui.verticalslider")
local TextSlider = require("gui.textslider")
local scene = composer.newScene()
local box, slider, betCounter, matchView, betView
local status = ""
local matchViewHeight = 0
local betViewHeight = 0
local actualTextId = 1
local sliderTexts = Lang.matchList.sliderTexts
local function updateBetCounterText()
	betCounter.text = Bets.betsToday .. " / " .. Bets.betLimit .. " " .. Lang.matchList.betsToday
end
local calculatePercents = function(tab)
	for _, match in ipairs(tab) do
		match.apercent = 0
		match.bpercent = 0
		if match.abets == 0 and 0 < match.bbets then
			match.bpercent = 100
		elseif 0 < match.abets and match.bbets == 0 then
			match.apercent = 100
		elseif 0 < match.abets and 0 < match.bbets then
			local sum = match.abets + match.bbets
			match.apercent = round(match.abets / sum * 100)
			match.bpercent = round(match.bbets / sum * 100)
		end
	end
end
local function insertMatches()
	matchView:deleteAllRows()
	matchViewHeight = 0
	if #Bets.cache.matches == 0 then
		matchView:insertRow({
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
		matchViewHeight = matchViewHeight + 350 * Game.guiScale
	else
		for i = 1, #Bets.cache.matches do
			matchView:insertRow({
				params = Bets.cache.matches[i],
				rowColor = {
					default = Color.row
				},
				lineColor = {
					0,
					0,
					0,
					0
				},
				rowHeight = 320 * Game.guiScale
			})
			matchViewHeight = matchViewHeight + 320 * Game.guiScale
		end
	end
	slider:scrollBar(0)
	slider:setTableView(matchView, math.min(-matchViewHeight + matchView.height, -1))
end
local function insertBets()
	betView:deleteAllRows()
	betViewHeight = 0
	if tableLength(Bets.cache.bets) == 0 then
		betView:insertRow({
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
		betViewHeight = betViewHeight + 350 * Game.guiScale
	else
		for _, bet in pairsByKeys(Bets.cache.bets, function(a, b)
			return b < a
		end) do
			betView:insertRow({
				params = {bet = bet},
				rowColor = {
					default = Color.row
				},
				lineColor = {
					0,
					0,
					0,
					0
				},
				rowHeight = 320 * Game.guiScale
			})
			betViewHeight = betViewHeight + 320 * Game.guiScale
		end
	end
	slider:scrollBar(0)
	slider:setTableView(betView, math.min(-betViewHeight + betView.height, -1))
end
local function refreshMatchList()
	Bets.cache.matches = {}
	insertMatches()
	status = Lang.common.loading .. "..."
	Bets.loadMatches(function(success, result)
		if not success then
			status = Lang.matchList.couldNotConnect
			matchView:reloadData()
			return
		end
		if result.bets_today then
			Bets.betsToday = result.bets_today
		end
		updateBetCounterText()
		if #result.matches == 0 then
			status = Lang.matchList.noMatchesFound
			matchView:reloadData()
			return
		end
		Bets.cache.matches = result.matches
		calculatePercents(Bets.cache.matches)
		insertMatches()
	end)
end
local function refreshBetList()
	Bets.cache.bets = {}
	insertBets()
	status = Lang.common.loading .. "..."
	Bets.loadBets(function(success, result)
		if not success or not result.bets then
			status = Lang.matchList.couldNotConnect
			betView:reloadData()
			return
		end
		if result.bets and #result.bets == 0 then
			status = Lang.matchList.noBetsFound
			betView:reloadData()
			return
		end
		for _, bet in ipairs(result.bets) do
			Bets.cache.bets[bet.id] = bet
		end
		insertBets()
	end)
end
local function onRowRender(event)
	local row = event.row
	local match, bet
	if row.params.bet then
		bet = row.params.bet
		match = bet.match
	else
		match = row.params
	end
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
	if row.params.empty then
		local emptyText = display.newText({
			parent = row,
			x = row.width / 2,
			y = row.height / 2,
			text = status,
			font = Font.default,
			fontSize = 52,
			align = "center"
		})
		emptyText.anchorX = 0.5
		emptyText.anchorY = 0.5
		FontOffset.setOffset(emptyText)
		return
	end
	local logoZoneSize = 380
	if detectSquareScreen() then
		logoZoneSize = 320
	end
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
	local team1name = match.a
	local nameFontSize = 46
	if detectSquareScreen then
		nameFontSize = 40
	end
	if match.apercent then
		team1name = team1name .. " (" .. match.apercent .. "%)"
	end
	local team1text = display.newText({
		parent = row,
		x = logoZoneSize / 2,
		y = 35,
		text = team1name,
		font = Font.default,
		fontSize = nameFontSize,
		align = "left"
	})
	team1text.anchorX = 0.5
	FontOffset.setOffset(team1text)
	team1text.alpha = team1alpha
	local team1logo = Bets.createTeamLogo(row, match.a)
	team1logo.x = logoZoneSize / 2
	team1logo.anchorX = 0.5
	team1logo.y = row.height / 2 - 40
	team1logo.alpha = team1alpha
	local team2name = match.b
	if match.apercent then
		team2name = team2name .. " (" .. match.bpercent .. "%)"
	end
	local team2text = display.newText({
		parent = row,
		x = row.width - logoZoneSize / 2,
		y = 35,
		text = team2name,
		font = Font.default,
		fontSize = nameFontSize,
		align = "right"
	})
	team2text.anchorX = 0.5
	FontOffset.setOffset(team2text)
	team2text.alpha = team2alpha
	local team2logo = Bets.createTeamLogo(row, match.b)
	team2logo.x = row.width - logoZoneSize / 2
	team2logo.anchorX = 0.5
	team2logo.y = row.height / 2 - 40
	team2logo.alpha = team2alpha
	if bet and (match.winner == 1 or match.winner == 2) then
		local tick = display.newImageRect(row, "images/tick.png", 75, 75)
		tick.anchorX = 0.5
		tick.anchorY = 0.7
		tick.y = team1logo.y + team1logo.height
		if match.winner == 1 then
			tick.x = team1logo.x + team1logo.width
		else
			tick.x = team2logo.x - team2logo.width
		end
	end
	local vsText = display.newText({
		parent = row,
		x = row.width / 2,
		y = 35 * Game.guiScale,
		text = "vs",
		font = Font.counterstrike,
		fontSize = 82 * Game.guiScale,
		align = "center"
	})
	vsText.anchorX = 0.5
	FontOffset.setOffset(vsText)
	vsText:setFillColor(unpack(Color.gold))
	local status = match.timeStr or "Live"
	local statusColor = Color.lightText
	local playerWon = false
	if bet and (match.winner == 1 or match.winner == 2) then
		if bet.team == match.winner then
			status = Lang.matchList.youHaveWon
			statusColor = Color.green
			playerWon = true
		else
			status = Lang.matchList.youHaveLost
			statusColor = Color.red
		end
	end
	local statusText = display.newText({
		parent = row,
		x = row.width / 2,
		y = 110 * Game.guiScale,
		text = status or "Live",
		font = Font.counterstrike,
		fontSize = 52 * Game.guiScale,
		align = "center"
	})
	statusText.anchorX = 0.5
	FontOffset.setOffset(statusText)
	statusText:setFillColor(unpack(statusColor))
	local eventText = display.newText({
		parent = row,
		x = row.width / 2,
		y = 160 * Game.guiScale,
		text = match.event or match.tournament or "Tournament Match",
		font = Font.counterstrike,
		fontSize = 46 * Game.guiScale,
		align = "center"
	})
	eventText.anchorX = 0.5
	FontOffset.setOffset(eventText)
	if row.params.bet then
		local buttonType = ButtonType.default
		if (playerWon or match.winner == 3) and bet.status == 0 then
			buttonType = ButtonType.green
		end
		GUI.createButton(row, row.width / 2 - 200, row.height - 105 * Game.guiScale, 400, 70 * Game.guiScale, Lang.matchList.viewBet, buttonType, function(event)
			Bets.loadBet(bet.id)
		end, 55)
	elseif match.closed == 0 and 0 < match.abets and 0 < match.bbets and not match.started then
		GUI.createButton(row, row.width / 2 - 225, row.height - 105 * Game.guiScale, 450, 70 * Game.guiScale, Lang.matchList.bet, ButtonType.purple, function(event)
			if tonumber(Bets.betsToday) >= Bets.betLimit then
				GUI.showMessageBox(Lang.common.info, Lang.matchList.cantBetMoreMatches)
				return
			end
			composer.gotoScene("scenes.nethub.bet", {
				params = {match = match}
			})
		end, 55)
	end
	GUI.drawVerticalLine(row, logoZoneSize, 0, row.height)
	GUI.drawVerticalLine(row, row.width - logoZoneSize, 0, row.height)
end
local function drawMainBox()
	local sceneGroup = scene.view
	box = GUI.drawMainBox(sceneGroup, "")
	betCounter = display.newText({
		parent = sceneGroup,
		x = getCenterX(box),
		y = box.y - 28,
		text = Lang.common.loading .. "...",
		font = Font.counterstrike,
		fontSize = 36
	})
	betCounter.anchorX = 0.5
	betCounter.anchorY = 0.5
	betCounter:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(betCounter)
	local textSlider = TextSlider.create(sceneGroup, box.x, box.y, box.width, 100 * Game.guiScale, sliderTexts, function(text, id)
		actualTextId = id
		if id == 1 then
			matchView.alpha = 1
			betView.alpha = 0
			slider:scrollBar(0)
			slider:setTableView(matchView, math.min(-matchViewHeight + matchView.height, -1))
			matchView:scrollToY({y = 0, time = 0})
		else
			matchView.alpha = 0
			betView.alpha = 1
			if betView:getNumRows() == 0 or Bets.reloadBetList then
				refreshBetList()
				Bets.reloadBetList = false
			else
				slider:scrollBar(0)
				slider:setTableView(betView, math.min(-betViewHeight + betView.height, -1))
				betView:scrollToY({y = 0, time = 0})
			end
		end
	end, 80 * Game.guiScale)
	slider = VerticalSlider.create(sceneGroup, box.x + box.width - 80, box.y + 100 * Game.guiScale, 80, box.height - 110 * Game.guiScale - 100 * Game.guiScale)
	matchView = widget.newTableView({
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
	betView = widget.newTableView({
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
	betView.alpha = 0
	local buttonBackground = display.newRect(sceneGroup, box.x, box.y + box.height - 110 * Game.guiScale, box.width, 110 * Game.guiScale)
	buttonBackground:setFillColor(unpack(Color.row))
	local buttonMargin = 5
	local refreshButton = GUI.createButton(sceneGroup, box.x + buttonMargin, box.y + box.height - 110 * Game.guiScale + buttonMargin, box.width / 2 - buttonMargin * 2, 110 * Game.guiScale - buttonMargin * 2, Lang.matchList.refreshList, ButtonType.default, function(event)
		if actualTextId == 1 then
			refreshMatchList()
		else
			refreshBetList()
		end
	end, 55)
	local returnButton = GUI.createButton(sceneGroup, box.x + box.width / 2 + buttonMargin, box.y + box.height - 110 * Game.guiScale + buttonMargin, box.width / 2 - buttonMargin * 2, 110 * Game.guiScale - buttonMargin * 2, Lang.common.back, ButtonType.purple, function(event)
		composer.gotoScene("scenes.nethub.nethub")
		Menu.updateItems()
	end, 55)
	sceneGroup:insert(matchView)
	sceneGroup:insert(betView)
end
function scene:create(event)
	local sceneGroup = self.view
	drawMainBox()
	insertMatches()
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
		if matchView and matchView.alpha == 1 then
			slider:setTableView(matchView)
		elseif betView and betView.alpha == 1 then
			slider:setTableView(betView)
			if Bets.reloadBetList then
				refreshBetList()
				Bets.reloadBetList = false
			end
		end
		if matchView and 1 < matchView:getNumRows() and #Bets.cache.matches > 0 or betView and 1 < betView:getNumRows() then
			return
		end
		if actualTextId == 1 and matchView then
			refreshMatchList()
		elseif betView then
			refreshBetList()
		end
		slider:scrollBar(0)
		slider:setTableView(matchView, -matchViewHeight)
	elseif phase == "did" then
		updateBetCounterText()
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
