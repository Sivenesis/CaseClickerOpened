local composer = require("composer")
local scene = composer.newScene()
local mainBox, tableView
local games = {
	{
		name = "Jackpot",
		upgrade = "Jackpot",
		scene = "scenes.jackpot",
		image = "upgrades/jackpot.png"
	},
	{
		name = "Scratches",
		scene = "scenes.games.scratches",
		image = "games/scratch_gold.png"
	},
	{
		name = "Item Upgrader",
		getButtonText = function()
			if Game.others.upgraderBought then
				return "Play!"
			else
				return "Buy for $200"
			end
		end,
		getButtonType = function()
			if Game.others.upgraderBought then
				return ButtonType.green
			else
				return ButtonType.purple
			end
		end,
		cost = 200,
		buyCallback = function()
			Game.others.upgraderBought = true
			Menu.refreshItems()
		end,
		callback = function()
			composer.gotoScene("scenes.games.upgrader", {
				params = {deselectItems = true}
			})
		end,
		image = "games/upgrader.png",
		scene = "scenes.games.upgrader"
	}
}
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
		y = row.height / 2,
		text = params.gameName,
		font = BitmapFont.counterstrike,
		fontSize = 68,
		align = "center"
	})
	nameText.anchorX = 0.5
	nameText.anchorY = 0.5
	nameText:setFillColor(unpack(Color.white))
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
local function drawMainBox()
	local sceneGroup = scene.view
	mainBox = GUI.drawMainBox(sceneGroup, "Games")
	tableView = widget.newTableView({
		left = mainBox.x,
		top = mainBox.y,
		width = mainBox.width,
		height = mainBox.height,
		isBounceEnabled = true,
		backgroundColor = Color.row,
		onRowRender = onRowRender
	})
	sceneGroup:insert(tableView)
	for _, game in ipairs(games) do
		tableView:insertRow({
			params = {
				getButtonType = function()
					if game.getButtonType then
						return game.getButtonType()
					end
					if game.buttonType then
						return game.buttonType
					end
					if not game.upgrade then
						return ButtonType.green
					end
					if Game.isUpgradeBought(game.upgrade) then
						return ButtonType.green
					end
					return ButtonType.purple
				end,
				getButtonText = function(buttonType)
					if game.getButtonText then
						return game.getButtonText()
					end
					if game.buttonText then
						return game.buttonText
					end
					if buttonType == ButtonType.green then
						return "Play!"
					else
						return "Buy for $" .. formatPrice(Game.upgrades[game.upgrade].requirements.cost)
					end
				end,
				buttonCallback = function(buttonType)
					if not game.scene then
						return true
					end
					if buttonType == ButtonType.green then
						if game.callback then
							game.callback()
						else
							composer.gotoScene(game.scene)
						end
						Menu.updateItems()
					else
						local cost = game.cost or Game.upgrades[game.upgrade].requirements.cost
						if cost <= Game.money then
							if game.cost then
								Game.removeMoney(game.cost, "Other", game.name .. " unlock")
								game.buyCallback()
							else
								Game.buyUpgrade(game.upgrade)
							end
							tableView:reloadData()
							return true
						else
							GUI.showMessageBox("Not enough money", "You need $" .. formatPrice(cost) .. " to buy this game.")
						end
					end
				end,
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
	drawMainBox()
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
		tableView:reloadData()
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
