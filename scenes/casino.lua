local composer = require("composer")
local scene = composer.newScene()
local balanceBox, gameBox, tableView, balanceText
local balanceBoxHeightMultiplier = 0.3
local games = {
	{
		name = Lang.casino.roulette,
		upgrade = "Roulette",
		scene = "scenes.casino.roulette",
		image = "upgrades/roulette.png",
		ticketGame = true
	},
	{
		name = "Coinflip",
		upgrade = "Coinflip",
		scene = "scenes.casino.coinflip",
		image = "casino/ct.png",
		ticketGame = true
	},
	{
		name = "Minesweeper",
		upgrade = "Minesweeper",
		scene = "scenes.casino.minesweeper",
		image = "casino/bomb.png",
		ticketGame = true
	},
	{
		name = "Crash",
		upgrade = "Crash",
		scene = "scenes.casino.crash",
		image = "casino/crash.png",
		ticketGame = true
	}
}
local function updateBalance()
	balanceText.text = commaValue(Game.roulette.balance) .. " " .. Lang.casino.tickets
end
local function drawBalanceBox()
	local sceneGroup = scene.view
	balanceBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.25 + 10, 10, display.safeActualContentWidth - display.safeActualContentWidth * 0.25 - 20, display.safeActualContentHeight * balanceBoxHeightMultiplier, Lang.casino.yourBalance)
	local mainText = PonyFont.newText({
		parent = sceneGroup,
		x = getCenterX(balanceBox),
		y = balanceBox.y + 50,
		text = Lang.casino.yourBalance .. ":",
		font = BitmapFont.counterstrike,
		fontSize = 62,
		align = "center"
	})
	mainText.anchorX = 0.5
	balanceText = PonyFont.newText({
		parent = sceneGroup,
		x = getCenterX(balanceBox),
		y = mainText.y + 86,
		text = "",
		font = BitmapFont.counterstrike,
		fontSize = 72,
		align = "center"
	})
	balanceText.anchorX = 0.5
	balanceText:setFillColor(unpack(Color.gold))
	local depositButton = Button.create(sceneGroup, getCenterX(balanceBox) - 175 - 175 - 20, balanceBox.y + balanceBox.height - 80 - 35, 350, 80, Lang.casino.deposit, ButtonType.default, function(event)
		if Game.roulette.balance >= 100000 then
			return GUI.showMessageBox(Lang.common.info, Lang.casino.depositLimitMsg:gsub("{1}", "100 000"))
		end
		if not Game.isUpgradeBought("Roulette") and not Game.isUpgradeBought("Coinflip") and not Game.isUpgradeBought("Minesweeper") and not Game.isUpgradeBought("Crash") then
			return GUI.showMessageBox(Lang.common.info, "Unlock one of the games before depositing skins")
		end
		composer.gotoScene("scenes.itemselection", {
			params = {
				type = ItemSelection.casino
			}
		})
	end, {blockTime = 600, fontSize = 42})
	local withdrawButton = Button.create(sceneGroup, getCenterX(balanceBox), balanceBox.y + balanceBox.height - 80 - 35, 350, 80, Lang.casino.withdraw, ButtonType.default, function(event)
		if Game.roulette.ticketsToPlay > 0 then
			return GUI.showMessageBox(Lang.common.info, Lang.casino.ticketsPlayMsg:gsub("{1}", commaValue(Game.roulette.ticketsToPlay)))
		end
		composer.showOverlay("overlays.ticketwithdraw", {
			isModal = true,
			params = {
				okButtonCallback = function()
					updateBalance()
				end
			}
		})
	end, {blockTime = 600, fontSize = 42})
	updateBalance()
end
local onRowRender = function(event)
	local row = event.row
	local params = row.params
	local image = display.newImageRect(row, "images/" .. params.image.name, params.image.width, params.image.height)
	image.x = 100
	image.y = row.height / 2
	image.anchorX = 0.5
	image.anchorY = 0.5
	local firstLine = GUI.drawVerticalLine(row, row.x + image.x + 80 + 20, row.x, row.height)
	local secondLine = GUI.drawVerticalLine(row, row.x + row.width * 0.6 - 15, row.x, row.height)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
	local nameText = PonyFont.newText({
		parent = row,
		x = firstLine.x + (secondLine.x - firstLine.x) / 2,
		y = row.height / 2 - 10,
		text = params.gameName,
		font = BitmapFont.counterstrike,
		fontSize = 62,
		align = "center"
	})
	nameText.anchorX = 0.5
	nameText.anchorY = 0.5
	nameText:setFillColor(unpack(Color.white))
	if params.ticketGame then
		local ticketGameText = PonyFont.newText({
			parent = row,
			x = nameText.x,
			y = nameText.y + 45,
			text = "Ticket Game",
			font = BitmapFont.counterstrike,
			fontSize = 38,
			align = "center"
		})
		ticketGameText.anchorX = 0.5
		ticketGameText.anchorY = 0.5
		ticketGameText:setFillColor(unpack(Color.lightText))
	end
	local buttonType = params.getButtonType()
	local fontSize = 58
	if buttonType ~= ButtonType.green then
		fontSize = 48
	end
	Button.create(row, row.width * 0.6, 10, row.width * 0.4 - 10, row.height - 20, params.getButtonText(buttonType), buttonType, function(event)
		params.buttonCallback(buttonType)
		return true
	end, {fontSize = fontSize})
end
local function drawGameBox()
	local sceneGroup = scene.view
	local boxY = 10 + display.safeActualContentHeight * balanceBoxHeightMultiplier + 10
	local boxHeight = display.safeActualContentHeight - boxY - 10
	gameBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.25 + 10, boxY, display.safeActualContentWidth - display.safeActualContentWidth * 0.25 - 20, boxHeight, Lang.casino.games, true)
	tableView = widget.newTableView({
		left = gameBox.x,
		top = gameBox.y,
		width = gameBox.width,
		height = gameBox.height,
		isBounceEnabled = true,
		backgroundColor = Color.row,
		onRowRender = onRowRender
	})
	sceneGroup:insert(tableView)
	for _, game in ipairs(games) do
		tableView:insertRow({
			params = {
				getButtonType = function()
					if Game.isUpgradeBought(game.upgrade) then
						return ButtonType.green
					end
					return ButtonType.purple
				end,
				getButtonText = function(buttonType)
					if buttonType == ButtonType.green then
						return "Play!"
					else
						return "Buy for $" .. formatPrice(Game.upgrades[game.upgrade].requirements.cost)
					end
				end,
				buttonCallback = function(buttonType)
					if buttonType == ButtonType.green then
						composer.gotoScene(game.scene)
					else
						local cost = Game.upgrades[game.upgrade].requirements.cost
						if cost <= Game.money then
							Game.buyUpgrade(game.upgrade)
							tableView:reloadData()
							return true
						else
							GUI.showMessageBox("Not enough money", "You need $" .. formatPrice(cost) .. " to buy this game.")
						end
					end
				end,
				ticketGame = game.ticketGame,
				gameName = game.name,
				image = {
					name = game.image,
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
			rowHeight = 200 * Game.guiScale
		})
	end
end
function scene:create(event)
	local sceneGroup = self.view
	drawBalanceBox()
	drawGameBox()
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
		if balanceText then
			updateBalance()
		end
		tableView:reloadData()
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
