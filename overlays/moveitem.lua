local composer = require("composer")
local VerticalSlider = require("gui.verticalslider")
local scene = composer.newScene()
local categoryView
local items = {}
local okButtonCallback
local multipleItems = false
local function onRowRender(event)
	local row = event.row
	local categoryId = row.params.id
	local category = Game.equipmentCategories[categoryId]
	local buttonType = ButtonType.green
	if Game.equipment[items[1]].ec and Game.equipment[items[1]].ec == categoryId then
		buttonType = ButtonType.default
	end
	if Game.settings.equipmentCategories and not Game.equipment[items[1]].ec and categoryId == 1 then
		buttonType = ButtonType.default
	end
	Button.create(row, 30, 10, row.width - 120 - 60 - 10, 110, category.name, buttonType, function()
		if buttonType == ButtonType.default then
			return
		end
		if category.locked then
			for _, item in ipairs(items) do
				Game.equipment[item].locked = true
			end
		else
			for _, item in ipairs(items) do
				Game.equipment[item].locked = nil
			end
		end
		for _, item in ipairs(items) do
			Game.equipment[item].ec = categoryId
		end
		if okButtonCallback then
			okButtonCallback()
		end
		composer.hideOverlay("slideDown", 200)
	end, {fontSize = 60, noTapEffect = true})
	local lockImage = "icons/lock_unlocked.png"
	if category.locked then
		lockImage = "icons/lock_locked.png"
	end
	Button.create(row, row.width - 90 - 60, 10, 120, 110, nil, buttonType, function(event)
	end, {
		fontSize = 70,
		image = {
			name = lockImage,
			width = 50.25,
			height = 67.5
		},
		noTapEffect = true
	})
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
	if event.params.item then
		multipleItems = false
		items[1] = event.params.item
	else
		multipleItems = true
		items = event.params.items
	end
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
	local height = 280 + math.min(7, #Game.equipmentCategories) * 120
	local mainBoxTitle = ""
	if multipleItems then
		mainBoxTitle = "Moving " .. #items .. " items"
	else
		mainBoxTitle = "Move Item"
	end
	local mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth / 2 - width / 2, display.safeActualContentHeight / 2 - height / 2, width + 100, height, mainBoxTitle)
	mainBox:setFillColor(rgb(22, 30, 40))
	local tableViewWidth = mainBox.width - 10 - 100
	local tableViewHeight = mainBox.height - 140 - 30 - 20
	self.slider = VerticalSlider.create(sceneGroup, mainBox.x + 5 + tableViewWidth, mainBox.y + 30, 100, tableViewHeight)
	categoryView = widget.newTableView({
		left = mainBox.x + 5,
		top = mainBox.y + 30,
		width = tableViewWidth,
		height = tableViewHeight,
		isBounceEnabled = true,
		backgroundColor = Color.row,
		onRowRender = onRowRender,
		listener = function(event)
			self.slider:scrollListener(event)
		end,
		hideScrollBar = true
	})
	sceneGroup:insert(categoryView)
	Button.create(sceneGroup, mainBox.x + 30, mainBox.y + mainBox.height - 140, mainBox.width - 60, 120, "Cancel", ButtonType.red, function()
		composer.hideOverlay("slideDown", 200)
	end, {fontSize = 60})
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		itemId = event.params.equipmentId
		okButtonCallback = event.params.okButtonCallback
		Game.showingOverlay = true
		insertRows()
		self.slider:scrollBar(0)
		local tableMaxScroll = -(categoryView:getNumRows() * 120) + categoryView.height
		self.slider:setTableView(categoryView, tableMaxScroll)
	elseif phase == "did" then
	end
end
function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Game.showingOverlay = false
	elseif phase == "did" then
		composer.removeScene("overlays.moveitem")
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
