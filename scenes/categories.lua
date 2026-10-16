local widget = require("widget")
local scene = composer.newScene()
local categoryView
local categoryItemCounts = {}
local function countCategoryItems()
	categoryItemCounts = {}
	for i, category in ipairs(Game.equipmentCategories) do
		categoryItemCounts[i] = 0
	end
	for _, item in ipairs(Game.equipment) do
		if item.ec then
			categoryItemCounts[item.ec] = categoryItemCounts[item.ec] + 1
		else
			categoryItemCounts[1] = categoryItemCounts[1] + 1
		end
	end
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
			rowHeight = 150
		})
	end
	if #Game.equipmentCategories < 10 then
		categoryView:insertRow({
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
			rowHeight = 150
		})
	end
end
local function deleteCategory(categoryId, moveItemsTo)
	GUI.showMessageBox("Moving items", Lang.common.pleaseWait, false)
	timer.performWithDelay(100, function()
		if moveItemsTo then
			for i = 1, #Game.equipment do
				if Game.equipment[i].ec and Game.equipment[i].ec == categoryId then
					Game.equipment[i].ec = moveItemsTo
					if Game.equipmentCategories[moveItemsTo].locked then
						Game.equipment[i].locked = true
					else
						Game.equipment[i].locked = nil
					end
				end
			end
		end
		table.remove(Game.equipmentCategories, categoryId)
		for i = 1, #Game.equipment do
			if Game.equipment[i].ec and Game.equipment[i].ec > categoryId then
				Game.equipment[i].ec = Game.equipment[i].ec - 1
			end
		end
		countCategoryItems()
		insertRows()
		composer.hideOverlay()
	end)
end
local function swapCategories(firstID, secondID)
	for i = 1, #Game.equipment do
		if Game.equipment[i].ec then
			if Game.equipment[i].ec == firstID then
				Game.equipment[i].ec = secondID
			elseif Game.equipment[i].ec == secondID then
				Game.equipment[i].ec = firstID
			end
		end
	end
	local firstCat = Game.equipmentCategories[firstID]
	local secondCat = Game.equipmentCategories[secondID]
	Game.equipmentCategories[firstID] = secondCat
	Game.equipmentCategories[secondID] = firstCat
	countCategoryItems()
	insertRows()
end
local function onRowRender(event)
	local row = event.row
	if not row.params.id then
		Button.create(row, 20, 20, row.width - 40, row.height - 40, "Add new category", ButtonType.green, function(event)
			composer.showOverlay("overlays.categorycreation", {
				params = {
					createCallback = function()
						insertRows()
					end
				}
			})
		end, {fontSize = 65})
		return
	end
	local category = Game.equipmentCategories[row.params.id]
	local categoryId = row.params.id
	local nameText = display.newText({
		parent = row,
		x = 15,
		y = 40,
		text = category.name,
		font = Font.counterstrike,
		fontSize = 55
	})
	nameText.anchorX = 0
	nameText.anchorY = 0
	nameText:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(nameText)
	if not categoryItemCounts[categoryId] then
		categoryItemCounts[categoryId] = 0
	end
	infoText = commaValue(categoryItemCounts[categoryId]) .. " item"
	if categoryItemCounts[categoryId] ~= 1 then
		infoText = infoText .. "s"
	end
	if 1 < categoryId then
		if category.locked then
			infoText = infoText .. " | Locked"
		else
			infoText = infoText .. " | Not locked"
		end
	end
	local infoText = display.newText({
		parent = row,
		x = 15,
		y = 100,
		text = infoText,
		font = Font.counterstrike,
		fontSize = 36
	})
	infoText.anchorX = 0
	infoText.anchorY = 0
	infoText:setFillColor(unpack(Color.white))
	FontOffset.setOffset(infoText)
	local lastButtonY = row.width - 5
	lastButtonY = lastButtonY - 150
	if 1 < categoryId and categoryId ~= #Game.equipmentCategories then
		Button.create(row, lastButtonY + 10, 3, 145, row.height - 3, nil, ButtonType.default, function(event)
			GUI.showMessageBox(Lang.common.pleaseWait, "Moving down", false)
			timer.performWithDelay(100, function()
				swapCategories(categoryId + 1, categoryId)
				composer.hideOverlay()
			end)
			return true
		end, {
			image = {
				name = "icons/arrow_down.png",
				width = 50.25,
				height = 67.5
			}
		})
	end
	if 2 < categoryId then
		lastButtonY = lastButtonY - 150
		Button.create(row, lastButtonY + 10, 3, 145, row.height - 3, nil, ButtonType.default, function(event)
			GUI.showMessageBox(Lang.common.pleaseWait, "Moving up", false)
			timer.performWithDelay(50, function()
				swapCategories(categoryId, categoryId - 1)
				composer.hideOverlay()
			end)
			return true
		end, {
			image = {
				name = "icons/arrow_up.png",
				width = 50.25,
				height = 67.5
			}
		})
	end
	if 1 < categoryId then
		lastButtonY = lastButtonY - 150
		if categoryId == 2 then
			lastButtonY = lastButtonY - 150
		end
		Button.create(row, lastButtonY + 10, 3, 145, row.height - 3, nil, ButtonType.red, function()
			if 0 < categoryItemCounts[categoryId] then
				composer.showOverlay("overlays.categoryselection", {
					params = {
						text = "Where do you want to move items?",
						disabledCategory = categoryId,
						selectionCallback = function(catId)
							deleteCategory(categoryId, catId)
						end
					}
				})
			else
				deleteCategory(categoryId, nil)
			end
		end, {
			image = {
				name = "icons/dustbin.png",
				width = 58.400000000000006 * Game.guiScale,
				height = 72 * Game.guiScale
			}
		})
		lastButtonY = lastButtonY - 150
		if not category.locked then
			Button.create(row, lastButtonY + 10, 3, 145, row.height - 3, nil, ButtonType.default, function(event)
				GUI.showMessageBox("Locking items", Lang.common.pleaseWait, false)
				timer.performWithDelay(250, function()
					Game.equipmentCategories[categoryId].locked = true
					for i = 1, #Game.equipment do
						if Game.equipment[i].ec and Game.equipment[i].ec == categoryId then
							Game.equipment[i].locked = true
						end
					end
					composer.hideOverlay()
					categoryView:reloadData()
				end)
				return true
			end, {
				image = {
					name = "icons/lock_unlocked.png",
					width = 50.25,
					height = 67.5
				}
			})
		else
			Button.create(row, lastButtonY + 10, 3, 145, row.height - 3, nil, ButtonType.default, function(event)
				GUI.showMessageBox("Unocking items", Lang.common.pleaseWait, false)
				timer.performWithDelay(250, function()
					Game.equipmentCategories[categoryId].locked = nil
					for i = 1, #Game.equipment do
						if Game.equipment[i].ec and Game.equipment[i].ec == categoryId then
							Game.equipment[i].locked = nil
						end
					end
					composer.hideOverlay()
					categoryView:reloadData()
				end)
				return true
			end, {
				image = {
					name = "icons/lock_locked.png",
					width = 50.25,
					height = 67.5
				}
			})
		end
	end
	lastButtonY = lastButtonY - 150
	if categoryId == 1 then
		lastButtonY = lastButtonY - 450
	end
	Button.create(row, lastButtonY + 10, 3, 145, row.height - 3, nil, ButtonType.green, function(event)
		composer.showOverlay("overlays.categoryrename", {
			params = {
				inputText = category.name,
				renameCallback = function(name)
					Game.equipmentCategories[row.params.id].name = name
					categoryView:reloadData()
				end
			}
		})
	end, {
		image = {
			name = "icons/rename.png",
			width = 67.5,
			height = 67.5
		}
	})
	GUI.drawHorizontalLine(row, 0, row.height - 6, row.width)
end
function scene:create(event)
	local sceneGroup = self.view
	local box = GUI.drawMainBox(sceneGroup, "Category manager")
	categoryView = widget.newTableView({
		left = box.x,
		top = box.y,
		width = box.width,
		height = box.height - 110,
		isBounceEnabled = true,
		backgroundColor = Color.row,
		onRowRender = onRowRender,
		hideScrollBar = false
	})
	sceneGroup:insert(categoryView)
	local buttonBackground = display.newRect(sceneGroup, box.x, box.y + box.height - 110, box.width, 110)
	buttonBackground:setFillColor(unpack(Color.row))
	Button.create(sceneGroup, box.x + 5, box.y + box.height - 110 + 5, box.width - 10, 100, Lang.common.back, ButtonType.default, function(event)
		composer.gotoScene("scenes.equipment")
	end, {fontSize = 75})
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
		countCategoryItems()
		insertRows()
	elseif phase == "did" then
		composer.removeScene("scenes.equipment")
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
