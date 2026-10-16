local composer = require("composer")
local scene = composer.newScene()
local mainBox, tableView
ScratchType = {
	bronze = 1,
	silver = 2,
	gold = 3,
	platinum = 4
}
ScratchTypes = {
	[ScratchType.bronze] = {
		type = ScratchType.bronze,
		name = "Bronze Scratch",
		image = "games/scratch_bronze.png",
		price = 2,
		color = {
			ColorTools.rgb(188, 141, 57)
		}
	},
	[ScratchType.silver] = {
		type = ScratchType.silver,
		name = "Silver Scratch",
		image = "games/scratch_silver.png",
		price = 10,
		color = {
			ColorTools.rgb(189, 189, 189)
		}
	},
	[ScratchType.gold] = {
		type = ScratchType.gold,
		name = "Gold Scratch",
		image = "games/scratch_gold.png",
		price = 25,
		color = {
			ColorTools.rgb(255, 233, 46)
		}
	},
	[ScratchType.platinum] = {
		type = ScratchType.platinum,
		name = "Platinum Scratch",
		image = "games/scratch_platinum.png",
		price = 40,
		color = {
			ColorTools.rgb(230, 232, 234)
		}
	}
}
local function onRowRender(event)
	local row = event.row
	local params = row.params
	local scratch = params.scratch
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
	if not scratch then
		Button.create(row, 24, 24, row.width - 48, row.height - 48, "Back", ButtonType.purple, function(event)
			composer.gotoScene("scenes.games")
			Menu.updateItems()
		end, {fontSize = 55})
		return true
	end
	local image = display.newImageRect(row, "images/" .. scratch.image, 160 * Game.guiScale, 160 * Game.guiScale)
	image.x = 100
	image.y = row.height / 2
	image.anchorX = 0.5
	image.anchorY = 0.5
	local firstLine = GUI.drawVerticalLine(row, row.x + image.x + 80 + 20, row.x, row.height)
	local secondLine = GUI.drawVerticalLine(row, row.x + row.width * 0.6 - 15, row.x, row.height)
	local fontSize = 68
	if detectSquareScreen() then
		fontSize = 50
	end
	local nameText = display.newText({
		parent = row,
		x = firstLine.x + (secondLine.x - firstLine.x) / 2,
		y = row.height / 2,
		text = scratch.name,
		font = Font.counterstrike,
		fontSize = fontSize,
		align = "center"
	})
	nameText.anchorX = 0.5
	nameText.anchorY = 0.5
	nameText:setFillColor(unpack(Color.white))
	FontOffset.setOffset(nameText)
	local buttonType = ButtonType.red
	if Game.money >= scratch.price then
		buttonType = ButtonType.green
	end
	Button.create(row, row.width * 0.6, 10, row.width * 0.4 - 10, row.height - 20, "Scratch for $" .. scratch.price, buttonType, function(event)
		if buttonType == ButtonType.red then
			return GUI.showMessageBox("Not enough money!", "You need at least $" .. scratch.price .. " to play this game.")
		end
		Game.removeMoney(scratch.price, "Other", "Scratch")
		tableView:reloadData()
		composer.showOverlay("overlays.scratch", {
			params = {
				type = scratch.type,
				price = scratch.price,
				color = scratch.color
			}
		})
		return true
	end, {fontSize = 46})
end
local function drawMainBox()
	local sceneGroup = scene.view
	mainBox = GUI.drawMainBox(sceneGroup, "Scratches!")
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
	for _, scratch in ipairs(ScratchTypes) do
		tableView:insertRow({
			params = {scratch = scratch},
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
	tableView:insertRow({
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
		rowHeight = 140 * Game.guiScale
	})
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
