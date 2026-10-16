local composer = require("composer")
local VerticalSlider = require("gui.verticalslider")
if Game.qrScanner then
	local qrencoder = require("tools.qrencode")
	local qrscanner = require("plugin.qrscanner")
end
local scene = composer.newScene()
local nickBox, optionBox, nickText, greenChangeNameButton, blueChangeNameButton, selectActionGroup, registerGroup, connectButton, connectingButton, actualStatus, scanQrButton, showQrButton, slider
local nickBoxHeightMultiplier = 0.26
local tableView
local onRowRender = function(event)
	local row = event.row
	local params = row.params
	if params.image and params.image.name then
		local image = display.newImageRect(row, "images/" .. params.image.name, params.image.width, params.image.height)
		image.x = 100
		image.y = row.height / 2
		image.anchorX = 0.5
		image.anchorY = 0.5
		image:addEventListener("tap", function()
			Game.unlockAchievement("Secret V")
		end)
	end
	local firstLine = GUI.drawVerticalLine(row, row.x + 100 + 80 + 20, row.x, row.height)
	local secondLine = GUI.drawVerticalLine(row, row.x + row.width * 0.7 - 15, row.x, row.height)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
	local nameText = PonyFont.newText({
		parent = row,
		x = firstLine.x + (secondLine.x - firstLine.x) / 2,
		y = row.height / 2,
		text = params.gameName,
		font = BitmapFont.counterstrike,
		fontSize = 62,
		align = "center"
	})
	nameText.anchorX = 0.5
	nameText.anchorY = 0.5
	nameText:setFillColor(unpack(Color.white))
	local buttonType = params.getButtonType()
	local fontSize = 58
	Button.create(row, row.width * 0.7, 10, row.width * 0.3 - 10, row.height - 20, params.getButtonText(buttonType), buttonType, function(event)
		params.buttonCallback(event, buttonType)
		Menu.updateItems()
		return true
	end, {fontSize = fontSize})
end
local function updateNick()
	nickText.text = NetHub.getNickname()
end
local function updateNickChangeButtons()
	Game.lastNickChange = Game.lastNickChange or 0
	if blueChangeNameButton then blueChangeNameButton.alpha = 0; blueChangeNameButton.isVisible = false end
	if greenChangeNameButton then greenChangeNameButton.alpha = 1; greenChangeNameButton.isVisible = true end
end
local function connect()
	connectButton.alpha = 0
	connectingButton.alpha = 1
	actualStatus.text = Lang.common.connecting
	NetHub.register(function(success, errorText)
		if success then
			updateNick()
			selectActionGroup.alpha = 1
			registerGroup.alpha = 0
			if Game.qrScanner then
				scanQrButton.alpha = 1
				showQrButton.alpha = 1
			end
			updateNickChangeButtons()
		else
			connectButton.alpha = 1
			connectingButton.alpha = 0
			if errorText then
				actualStatus.text = errorText
			else
				actualStatus.text = Lang.nethub.connectionFailed
			end
		end
	end)
end
local function drawNickBox()
	local sceneGroup = scene.view
	nickBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.25 + 10, 10, display.safeActualContentWidth - display.safeActualContentWidth * 0.25 - 20, display.safeActualContentHeight * nickBoxHeightMultiplier, "Your Nick")
	local mainText = PonyFont.newText({
		parent = sceneGroup,
		x = getCenterX(nickBox),
		y = nickBox.y + 40,
		text = Lang.nethub.yourNick .. ":",
		font = BitmapFont.counterstrike,
		fontSize = 62,
		align = "center"
	})
	mainText.anchorX = 0.5
	nickText = PonyFont.newText({
		parent = sceneGroup,
		x = getCenterX(nickBox),
		y = mainText.y + 76,
		text = "",
		font = BitmapFont.counterstrike,
		fontSize = 72,
		align = "left"
	})
	nickText.anchorX = 0.5
	nickText:setFillColor(unpack(Color.gold))
	updateNick()
	if Game.qrScanner then
		scanQrButton = GUI.createButton(sceneGroup, getCenterX(optionBox) + 10, nickBox.y + nickBox.height - 115, 450, 80, Lang.nethub.scanTradeCode, ButtonType.default, function(event)
			local listener = function(message)
				NetHub.createTrade(message, function(success, output)
					if not success then
						local text = Lang.common.connectionFailed
						if output and output.text then
							text = output.text
						end
						return GUI.showMessageBox(Lang.common.error, text)
					elseif output.trade then
						NetHub.cache.trades[output.trade.id] = output.trade
						NetHub.loadTrade(output.trade.id, true)
						Analytics.addEvent("Trade:Create")
					else
						return GUI.showMessageBox(Lang.common.error, message)
					end
				end)
			end
			qrscanner.show(listener, {
				string = {
					title = Lang.nethub.tradeCodeScanner
				}
			})
		end, 50)
		showQrButton = GUI.createButton(sceneGroup, getCenterX(optionBox) - 225 - 225 - 10, nickBox.y + nickBox.height - 115, 450, 80, "Show trade code", ButtonType.default, function(event)
			local success, code = qrencoder.qrcode(NetHub.getNickname())
			if not success then
				return GUI.showMessageBox(Lang.common.error, Lang.nethub.couldNotGenerateQR)
			end
			composer.showOverlay("overlays.qrcode", {
				isModal = true,
				effect = "fade",
				time = 200,
				params = {
					title = Lang.nethub.yourTradeCode .. ":",
					code = code
				}
			})
		end, 50)
		scanQrButton.alpha = 0
		showQrButton.alpha = 0
	end
	greenChangeNameButton = GUI.createButton(sceneGroup, getCenterX(nickBox) - 250, mainText.y + 76 + 70, 500, 70, "Change name", ButtonType.green, function(event)
		composer.showOverlay("overlays.nethubrename", {
			params = {
				successCallback = function()
					updateNick()
					Game.lastNickChange = os.time()
					updateNickChangeButtons()
				end
			}
		})
	end, 55)
	greenChangeNameButton.alpha = 1
	greenChangeNameButton.isVisible = true
end
local function onMouseWheel(event)
	if event.scrollY and tableView and tableView.scrollToY then
		local currentY = tableView:getContentPosition()
		local targetY = currentY + (event.scrollY * 50)
		tableView:scrollToY({ y = targetY, time = 40 })
	end
end

local function setupSelectActionGroup()
	selectActionGroup = display.newGroup()
	local sliderWidth = 60
	slider = VerticalSlider.create(selectActionGroup, optionBox.x + optionBox.width - sliderWidth, optionBox.y, sliderWidth, optionBox.height)
	tableView = widget.newTableView({
		left = optionBox.x,
		top = optionBox.y,
		width = optionBox.width - sliderWidth,
		height = optionBox.height,
		isBounceEnabled = true,
		backgroundColor = Color.row,
		onRowRender = onRowRender,
		listener = function(event)
			if slider and slider.scrollListener then
				slider:scrollListener(event)
			end
		end,
		hideScrollBar = true
	})
	selectActionGroup:insert(tableView)
	local totalHeight = 0
	for _, item in ipairs(NetHub.items) do
		local rowH = 200 * Game.guiScale
		totalHeight = totalHeight + rowH
		tableView:insertRow({
			params = {
				getButtonType = function()
					if item.buttonType then
						return item.buttonType
					end
					if not item.upgrade then
						return ButtonType.green
					end
					if Game.isUpgradeBought(item.upgrade) then
						return ButtonType.green
					end
					return ButtonType.purple
				end,
				getButtonText = function(buttonType)
					return item.buttonText or "Play!"
				end,
				buttonCallback = function(event, buttonType)
					if buttonType == ButtonType.green or not item.upgrade then
						item.callback(event)
					elseif buttonType == ButtonType.purple and item.upgrade then
						local up = Game.upgrades[item.upgrade]
						if up and up.requirements and up.requirements.cost then
							local cost = up.requirements.cost
							if cost <= Game.money then
								Game.buyUpgrade(item.upgrade)
								tableView:reloadData()
								Menu.refreshItems()
								GUI.showMessageBox("Unlocked!", "You bought the \"" .. item.upgrade .. "\" upgrade!")
							else
								GUI.showMessageBox("Not Unlocked", "You need $" .. formatPrice(cost) .. " to buy the \"" .. item.upgrade .. "\" upgrade.")
							end
						else
							GUI.showMessageBox("Not Unlocked", "You need to buy the \"" .. item.upgrade .. "\" to unlock this feature.")
						end
					end
				end,
				gameName = item.name,
				image = {
					name = item.image,
					width = 160 * Game.guiScale,
					height = 160 * Game.guiScale
				}
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
			rowHeight = rowH
		})
	end
	if slider then
		slider:scrollBar(0)
		slider:setTableView(tableView, math.min(-totalHeight + tableView.height, -1))
	end
end
local function drawOptionBox()
	local sceneGroup = scene.view
	local boxY = 10 + display.safeActualContentHeight * nickBoxHeightMultiplier + 10
	local boxHeight = display.safeActualContentHeight - boxY - 10
	optionBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.25 + 10, boxY, display.safeActualContentWidth - display.safeActualContentWidth * 0.25 - 20, boxHeight, "NetHub")
end
local function setupRegisterGroup()
	registerGroup = display.newGroup()
	registerGroup.isVisible = false
	registerGroup.alpha = 0
end
function scene:create(event)
	local sceneGroup = self.view
	drawOptionBox()
	drawNickBox()
	setupSelectActionGroup()
	setupRegisterGroup()
	selectActionGroup.alpha = 1
	selectActionGroup.isVisible = true
	registerGroup.alpha = 0
	registerGroup.isVisible = false
	sceneGroup:insert(selectActionGroup)
	sceneGroup:insert(registerGroup)
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
		selectActionGroup.alpha = 1
		selectActionGroup.isVisible = true
		registerGroup.alpha = 0
		registerGroup.isVisible = false
		if nickText then
			updateNick()
		end
		updateNickChangeButtons()
		tableView:reloadData()
		Runtime:addEventListener("mouse", onMouseWheel)
	elseif phase == "did" then
		updateNickChangeButtons()
	end
end
function scene:hide(event)
	local phase = event.phase
	if phase == "will" then
		Runtime:removeEventListener("mouse", onMouseWheel)
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
