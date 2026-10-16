local composer = require("composer")
local VerticalSlider = require("gui.verticalslider")
local widget = require("widget")
local scene = composer.newScene()
local rowHeight = 180
local textInputHeight = 90
local tradeText, trade, textInput, sendButton, sendingButton, slider, chatTable
local refreshTimer, mouseWheelListener
local messages = {}

local function hideTextInput()
	if textInput then
		textInput:removeSelf()
		textInput = nil
	end
end

local function showTextInput()
	if not textInput and chatTable then
		textInput = native.newTextField(chatTable.x, chatTable.y - textInputHeight, chatTable.width - 320, textInputHeight)
		textInput:setReturnKey("done")
		textInput:addEventListener("userInput", function(event)
			if event.phase == "submitted" or event.phase == "ended" then
				native.setKeyboardFocus(nil)
			end
		end)
	end
end

local function updateTradeText()
	if not trade or not tradeText then return end
	local name = trade.user1 or "Trader"
	if trade.user1 == NetHub.getNickname() then
		name = trade.user2 or "Trader"
	end
	tradeText.text = Lang.tradeChat.chatWith .. " " .. name
end

local function insertMessageRow(message)
	if not chatTable then return end
	chatTable:insertRow({
		params = {message = message},
		rowColor = {
			default = Color.row
		},
		lineColor = {
			0,
			0,
			0,
			0
		},
		rowHeight = rowHeight
	})
end

local function insertRows()
	if not chatTable then return end
	chatTable:deleteAllRows()
	if not messages or #messages == 0 then
		chatTable:insertRow({
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
			rowHeight = rowHeight
		})
		return
	end
	for i = 1, math.min(50, #messages) do
		insertMessageRow(messages[i])
	end
	if slider then
		slider:scrollBar(0)
		local tableMaxScroll = -(chatTable:getNumRows() * rowHeight) + chatTable.height
		slider:setTableView(chatTable, tableMaxScroll)
	end
end

local function refreshChat()
	if composer.getSceneName("current") ~= "scenes.nethub.chat" then
		return
	end
	if not trade or not trade.id then
		return
	end
	NetHub.loadMessages(trade.id, function(success, result)
		if composer.getSceneName("current") ~= "scenes.nethub.chat" then
			return
		end
		if refreshTimer then
			timer.cancel(refreshTimer)
			refreshTimer = nil
		end
		refreshTimer = timer.performWithDelay(5000, refreshChat)
		if not success then
			return
		end
		if result and result.messages then
			messages = result.messages
			insertRows()
		end
	end)
end

local function onRowRender(event)
	local row = event.row
	local message = event.row.params and event.row.params.message
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
	if not message then
		local statusText = display.newText({
			parent = row,
			x = (chatTable and chatTable.width or row.width) / 2,
			y = rowHeight / 2,
			text = Lang.tradeChat.noMessages,
			font = Font.counterstrike,
			fontSize = 62,
			width = row.width,
			align = "center"
		})
		statusText.anchorX = 0.5
		statusText.anchorY = 0.5
		FontOffset.setOffset(statusText)
		return
	end

	local userName = Lang.tradeChat.you
	if message.nick and #message.nick > 0 then
		userName = message.nick
	elseif message.user == 1 and trade and trade.user1 ~= NetHub.getNickname() then
		userName = trade.user1
	elseif message.user == 2 and trade and trade.user2 ~= NetHub.getNickname() then
		userName = trade.user2
	end

	local nameText = display.newText({
		parent = row,
		x = 10,
		y = 30,
		text = tostring(userName) .. ":",
		font = Font.default,
		fontSize = 32,
		width = (chatTable and chatTable.width or row.width) * 0.9,
		align = "left"
	})
	nameText:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(nameText)

	local msgBody = message.message or message.text or ""
	local messageText = display.newText({
		parent = row,
		x = 20,
		y = 90,
		text = tostring(msgBody),
		font = Font.default,
		fontSize = 42,
		width = (chatTable and chatTable.width or row.width) * 0.9,
		align = "left"
	})
	FontOffset.setOffset(messageText)
end

function scene:create(event)
	local sceneGroup = self.view
	trade = (event and event.params and event.params.trade) or {}
	messages = trade.messages or {}
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.6)
	local mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.01, display.safeActualContentHeight * 0.01, display.safeActualContentWidth * 0.98, display.safeActualContentHeight * 0.98, Lang.tradeChat.tradeChat)
	tradeText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = mainBox.y + 48,
		text = "",
		font = Font.counterstrike,
		fontSize = 70,
		align = "center"
	})
	tradeText.anchorX = 0.5
	FontOffset.setOffset(tradeText)
	slider = VerticalSlider.create(sceneGroup, mainBox.width - 125, mainBox.y + 170 + 50, 80, mainBox.height * 0.7 - 50)
	chatTable = widget.newTableView({
		left = mainBox.x + 50,
		top = mainBox.y + 170 + 50,
		width = mainBox.width - 200,
		height = mainBox.height * 0.7 - 50,
		isBounceEnabled = false,
		backgroundColor = Color.row,
		hideBackground = false,
		onRowRender = onRowRender,
		listener = function(event)
			slider:scrollListener(event)
		end,
		hideScrollBar = true
	})
	sceneGroup:insert(chatTable)
	sendButton = GUI.createButton(sceneGroup, chatTable.x + chatTable.width - 320, chatTable.y - textInputHeight, 400, textInputHeight, Lang.tradeChat.send, ButtonType.green, function()
		if not textInput then return end
		local message = textInput.text
		if not message or #message:gsub("%s+", "") == 0 then return end
		sendButton.alpha = 0
		sendingButton.alpha = 1
		textInput.text = ""
		NetHub.sendMessage(trade.id, message, function(success, result)
			sendButton.alpha = 1
			sendingButton.alpha = 0
			if not success then
				hideTextInput()
				return GUI.showMessageBox("Error", result or "Could not send message.", true, function()
					showTextInput()
					if textInput then textInput.text = message end
				end)
			end
			local userId = (trade.user1 == NetHub.getNickname()) and 1 or 2
			table.insert(messages, 1, {
				user = userId,
				text = message,
				message = message,
				nick = NetHub.getNickname(),
				timestamp = os.time()
			})
			insertRows()
		end)
	end, 55)
	sendingButton = GUI.createButton(sceneGroup, chatTable.x + chatTable.width - 320, chatTable.y - textInputHeight, 400, textInputHeight, Lang.tradeChat.sending .. "...", ButtonType.blue, function()
	end, 55)
	local exitButton = GUI.createButton(sceneGroup, chatTable.x, chatTable.y + chatTable.height, chatTable.width + 80, 100, Lang.common.exit, ButtonType.purple, function()
		hideTextInput()
		NetHub.loadTrade(trade.id, true)
	end, 70)
end

function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		if sendButton then sendButton.alpha = 1 end
		if sendingButton then sendingButton.alpha = 0 end
		trade = (event and event.params and event.params.trade) or trade or {}
		messages = trade.messages or {}
		insertRows()
		updateTradeText()
		showTextInput()
		if slider then
			slider:scrollBar(0)
			local tableMaxScroll = -(chatTable:getNumRows() * rowHeight) + chatTable.height
			slider:setTableView(chatTable, tableMaxScroll)
		end

		if not mouseWheelListener then
			mouseWheelListener = function(e)
				if chatTable and chatTable.scrollBy and composer.getSceneName("current") == "scenes.nethub.chat" then
					chatTable:scrollBy(0, e.scrollY * 40)
				end
			end
			Runtime:addEventListener("mouse", mouseWheelListener)
		end
	elseif phase == "did" then
		if refreshTimer then
			timer.cancel(refreshTimer)
			refreshTimer = nil
		end
		refreshTimer = timer.performWithDelay(5000, refreshChat)
	end
end

function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		hideTextInput()
		if refreshTimer then
			timer.cancel(refreshTimer)
			refreshTimer = nil
		end
		if mouseWheelListener then
			Runtime:removeEventListener("mouse", mouseWheelListener)
			mouseWheelListener = nil
		end
	elseif phase == "did" then
		composer.removeScene("scenes.nethub.chat")
	end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
