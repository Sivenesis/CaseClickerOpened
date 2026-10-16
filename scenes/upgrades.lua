local composer = require("composer")
local widget = require("widget")
local TextSlider = require("gui.textslider")
local scene = composer.newScene()
local tableView, upgradeCounter
local lastYPosition = 0
local maxY = 0
local sliderTexts = Lang.upgradesTab.sliderTexts
local sliderOptions = {
	{
		text = sliderTexts[1]
	},
	{
		text = sliderTexts[2],
		upgradeType = Upgrade.moneyandsearch
	},
	{
		text = sliderTexts[3],
		upgradeType = Upgrade.unlockable
	},
	{
		text = sliderTexts[4],
		upgradeType = Upgrade.singleuse
	},
	{
		text = sliderTexts[5],
		upgradeType = Upgrade.other
	}
}
local actualText = sliderTexts[1]
local function updateUpgradeCounter()
	upgradeCounter.text = Lang.upgradesTab.bought .. ": " .. StatisticManager.getStatistic("upgradesBought") .. " / " .. tableLength(Game.upgrades)
end
local function refreshUpgradeList()
	local sliderOption = sliderOptions[1]
	for i = 1, #sliderOptions do
		if sliderOptions[i].text == actualText then
			sliderOption = sliderOptions[i]
			break
		end
	end
	maxY = 0
	tableView:deleteAllRows()
	local upgradeTable = {}
	for key, upgrade in pairsByKeys(Game.upgrades) do
		if upgrade.unlocked and not upgrade.bought then
			local canInsert = true
			if sliderOption.upgradeType and upgrade.type ~= sliderOption.upgradeType then
				canInsert = false
			end
			if canInsert then
				table.insert(upgradeTable, {
					params = {upgrade = upgrade, key = key},
					rowColor = {
						default = Color.row
					},
					lineColor = {
						0,
						0,
						0,
						0
					},
					rowHeight = 240 * Game.guiScale
				})
				maxY = maxY + 240 * Game.guiScale
			end
		end
	end
	table.sort(upgradeTable, function(a, b)
		return a.params.upgrade.requirements.cost < b.params.upgrade.requirements.cost
	end)
	for i = 1, #upgradeTable do
		tableView:insertRow(upgradeTable[i])
	end
	if #upgradeTable == 0 then
		tableView:insertRow({
			params = {upgrade = nil},
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = 240
		})
	end
	updateUpgradeCounter()
end
local function buyUpgrade(upgradeId)
	Game.buyUpgrade(upgradeId)
	lastYPosition = tableView:getContentPosition()
	refreshUpgradeList()
	if lastYPosition < -(maxY - tableView.height) then
		lastYPosition = -(maxY - tableView.height)
		if 0 < lastYPosition then
			lastYPosition = 0
		end
	end
	tableView:scrollToY({y = lastYPosition, time = 0})
end
local canBuyUpgrade = function(upgrade)
	local req = upgrade.requirements
	if req.cost and Game.money < req.cost then
		return false
	end
	if req.openedBoxes and StatisticManager.getStatistic("openedBoxes") < req.openedBoxes then
		return false
	end
	return true
end
local function onRowRender(event)
	local row = event.row
	local upgrade = row.params.upgrade
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
	if not upgrade then
		local text = display.newText({
			parent = row,
			x = getCenterX(row),
			y = row.height / 2,
			text = Lang.upgradesTab.noupgrades .. ".",
			font = Font.counterstrike,
			fontSize = 72,
			align = "center"
		})
		text.anchorX = 0.5
		text.anchorY = 0.5
		text:setFillColor(unpack(Color.lightText))
		FontOffset.setOffset(text)
		return
	end
	if Game.upgrades[row.params.key].bought then
		tableView:deleteRow(event.row.id)
		return
	end
	local image = display.newImageRect(row, "images/" .. upgrade.image.name, upgrade.image.width * Game.guiScale, upgrade.image.height * Game.guiScale)
	image.x = row.x + row.width * 0.08
	image.y = row.height / 2
	image.anchorX = 0.5
	image.anchorY = 0.5
	local requirementCount = tableLength(upgrade.requirements)
	local fontSize = 52
	local upgradeNameText = Lang.upgrades[row.params.key].name
	if upgradeNameText:len() >= 30 then
		fontSize = 37
	elseif upgradeNameText:len() >= 25 then
		fontSize = 42
	elseif upgradeNameText:len() >= 20 then
		fontSize = 46
	end
	local upgradeName = display.newText({
		parent = row,
		x = row.x + row.width * 0.18,
		y = row.height * 0.2,
		text = upgradeNameText:gsub("IIII", "IV"),
		font = Font.counterstrike,
		fontSize = fontSize * Game.guiScale,
		align = "left"
	})
	upgradeName.anchorY = 0.5
	local actualRequirementNo = 0
	if upgrade.requirements.cost then
		actualRequirementNo = actualRequirementNo + 1
		local costRequirementText = display.newText({
			parent = row,
			x = upgradeName.x,
			y = upgradeName.y + 35 * actualRequirementNo * Game.guiScale,
			text = Lang.upgradesTab.cost .. ":",
			font = Font.counterstrike,
			fontSize = 37 * Game.guiScale,
			align = "left"
		})
		FontOffset.setOffset(costRequirementText)
		local cost = upgrade.requirements.cost
		local costRequirementText2 = display.newText({
			parent = row,
			x = costRequirementText.x + costRequirementText.width + 10 * Game.guiScale,
			y = upgradeName.y + 35 * Game.guiScale,
			text = "$" .. formatPrice(cost),
			font = Font.counterstrike,
			fontSize = 37 * Game.guiScale,
			align = "left"
		})
		FontOffset.setOffset(costRequirementText2)
		if cost <= Game.money then
			costRequirementText2:setFillColor(0, 1, 0)
		else
			costRequirementText2:setFillColor(1, 0, 0)
		end
	end
	if upgrade.requirements.openedBoxes then
		actualRequirementNo = actualRequirementNo + 1
		local requiredBoxesText = display.newText({
			parent = row,
			x = upgradeName.x,
			y = upgradeName.y + 35 * actualRequirementNo * Game.guiScale,
			text = Lang.upgradesTab.openedcases .. ":",
			font = Font.counterstrike,
			fontSize = 37 * Game.guiScale,
			align = "left"
		})
		FontOffset.setOffset(requiredBoxesText)
		local cost = upgrade.requirements.openedBoxes
		local requiredBoxesText2 = display.newText({
			parent = row,
			x = requiredBoxesText.x + requiredBoxesText.width + 10 * Game.guiScale,
			y = upgradeName.y + 35 * actualRequirementNo * Game.guiScale,
			text = math.min(StatisticManager.getStatistic("openedBoxes"), cost) .. " / " .. cost,
			font = Font.counterstrike,
			fontSize = 37 * Game.guiScale,
			align = "left"
		})
		FontOffset.setOffset(requiredBoxesText2)
		if cost <= StatisticManager.getStatistic("openedBoxes") then
			requiredBoxesText2:setFillColor(0, 1, 0)
		else
			requiredBoxesText2:setFillColor(1, 0, 0)
		end
	end
	if Lang.upgrades[row.params.key].description then
		local fontSize = 34
		if upgrade.fontSize then
			fontSize = upgrade.fontSize
		end
		local descriptionText = display.newText({
			parent = row,
			x = upgradeName.x,
			y = upgradeName.y + 35 * (actualRequirementNo + 1) * Game.guiScale - 8,
			text = Lang.upgrades[row.params.key].description,
			font = Font.default,
			fontSize = fontSize * Game.guiScale,
			width = row.width * 0.5,
			align = "left"
		})
		descriptionText:setFillColor(unpack(Color.lightText))
	end
	local buttonType = ButtonType.red
	if canBuyUpgrade(upgrade) then
		buttonType = ButtonType.green
	end
	Game.upgrades[row.params.key].row = row
	Game.upgrades[row.params.key].button = GUI.createButton(row, row.width * 0.725, row.height * 0.15, row.width * 0.25, row.height * 0.7, Lang.upgradesTab.buyupgrade, buttonType, function()
		if not canBuyUpgrade(Game.upgrades[row.params.key]) then
			return
		end
		buyUpgrade(row.params.key)
	end)
	Game.upgrades[row.params.key].button.anchorX = 0.5
	Game.upgrades[row.params.key].button.anchorY = 0.5
	GUI.drawVerticalLine(row, row.x + row.width * 0.16, row.x, row.height)
	GUI.drawVerticalLine(row, row.x + row.width * 0.7, row.x, row.height)
end
local justCreated = false
function scene:create(event)
	local sceneGroup = self.view
	justCreated = true
	local box = GUI.drawMainBox(sceneGroup, "")
	local slider = TextSlider.create(sceneGroup, box.x, box.y, box.width, 110 * Game.guiScale, sliderTexts, function(text)
		actualText = text
		refreshUpgradeList()
	end, 80 * Game.guiScale)
	tableView = widget.newTableView({
		left = box.x,
		top = box.y + 110 * Game.guiScale,
		width = box.width,
		height = box.height - 110 * Game.guiScale,
		isBounceEnabled = true,
		backgroundColor = Color.row,
		onRowRender = onRowRender
	})
	upgradeCounter = display.newText({
		parent = sceneGroup,
		x = getCenterX(box),
		y = box.y - 28,
		text = "",
		font = Font.counterstrike,
		fontSize = 36,
		align = "center"
	})
	upgradeCounter.anchorX = 0.5
	upgradeCounter.anchorY = 0.5
	upgradeCounter:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(upgradeCounter)
	refreshUpgradeList()
	sceneGroup:insert(tableView)
end
function scene:show(event)
	local sceneGroup = self.tableView
	local phase = event.phase
	if phase == "will" then
		Menu.show()
		if justCreated then
			justCreated = false
		else
			refreshUpgradeList()
			tableView:reloadData()
		end
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
