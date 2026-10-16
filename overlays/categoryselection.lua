local composer = require("composer")
local scene = composer.newScene()
local categoryView, selectionCallback, disabledCategory, text
local function onRowRender(event)
	local row = event.row
	local categoryId = row.params.id
	local category = Game.equipmentCategories[categoryId]
	local buttonType = ButtonType.green
	if categoryId == disabledCategory then
		buttonType = ButtonType.default
	end
	GUI.createButton(row, 30, 10, row.width - 120 - 60 - 10, 110, category.name, buttonType, function()
		if buttonType == ButtonType.default then
			return
		end
		if selectionCallback then
			selectionCallback(categoryId)
		end
		composer.hideOverlay("slideDown", 200)
	end, 60, {noTapEffect = true})
	local lockImage = "icons/lock_unlocked.png"
	if category.locked then
		lockImage = "icons/lock_locked.png"
	end
	GUI.createButton(row, row.width - 90 - 60, 10, 120, 110, nil, buttonType, function(event)
	end, 70, {
		image = {
			name = lockImage,
			width = 50.25,
			height = 67.5
		},
		noTapEffect = true
	})
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local function insertRows()
	categoryView:deleteAllRows()
	for i, _ in ipairs(Game.equipmentCategories) do
		categoryView:insertRow({
			params = {id = i},
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = 120
		})
	end
end
function scene:create(event)
	local sceneGroup = self.view
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.8)
	background:addEventListener("touch", function()
		return true
	end)
	background:addEventListener("tap", function()
		return true
	end)
	local widthMultiplier = 1
	local heightMultiplier = 1
	local width = 850
	local height = 360 + math.min(6, #Game.equipmentCategories) * 120
	local mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth / 2 - width / 2, display.safeActualContentHeight / 2 - height / 2, width, height, "Select category")
	mainBox:setFillColor(rgb(22, 30, 40))
	text = display.newText({
		parent = sceneGroup,
		x = mainBox.x + 20,
		y = mainBox.y + 40,
		height = 80,
		text = "",
		width = mainBox.width - 40,
		font = Font.counterstrike,
		fontSize = 50,
		align = "center"
	})
	text.anchorX = 0
	text.anchorY = 0
	FontOffset.setOffset(text)
	categoryView = widget.newTableView({
		left = mainBox.x + 5,
		top = mainBox.y + 120,
		width = mainBox.width - 10,
		height = mainBox.height - 140 - 120 - 20,
		isBounceEnabled = true,
		backgroundColor = Color.row,
		onRowRender = onRowRender,
		hideScrollBar = false
	})
	sceneGroup:insert(categoryView)
	GUI.createButton(sceneGroup, mainBox.x + 30, mainBox.y + mainBox.height - 140, mainBox.width - 60, 120, "Cancel", ButtonType.red, function()
		composer.hideOverlay("slideDown", 200)
	end, 60)
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		selectionCallback = event.params.selectionCallback
		disabledCategory = event.params.disabledCategory
		text.text = event.params.text
		Game.showingOverlay = true
		insertRows()
	elseif phase == "did" then
	end
end
function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Game.showingOverlay = false
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
