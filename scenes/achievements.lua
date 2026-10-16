local widget = require("widget")
local scene = composer.newScene()
local achievementView, achievementCounter
local actualOption = 1
local sliderTexts = {
	"All",
	"Unlocked",
	"Not unlocked",
	"Secrets"
}
local function updateAchievementCounter()
	achievementCounter.text = Lang.achievementsTab.unlocked .. ": " .. StatisticManager.getStatistic("unlockedAchievements") .. " / " .. tableLength(Game.achievements)
end
local function insertAchievements()
	achievementView:deleteAllRows()
	local rewardable = {}
	local rewarded = {}
	local locked = {}
	if GameServices.loggedIn then
		achievementView:insertRow({
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
			rowHeight = 120 * Game.guiScale
		})
	end
	for _, achievement in pairsByKeys(Game.achievements) do
		local add = true
		if actualOption == 4 and not achievement.name:find("Secret") then
			add = false
		end
		if add then
			if achievement.unlocked then
				if achievement.rewarded then
					table.insert(rewarded, achievement)
				else
					table.insert(rewardable, achievement)
				end
			else
				table.insert(locked, achievement)
			end
		end
	end
	if actualOption ~= 3 then
		for i = 1, #rewardable do
			achievementView:insertRow({
				params = rewardable[i],
				rowColor = {
					default = Color.row
				},
				lineColor = {
					0,
					0,
					0,
					0
				},
				rowHeight = 150 * Game.guiScale
			})
		end
		for i = 1, #rewarded do
			achievementView:insertRow({
				params = rewarded[i],
				rowColor = {
					default = Color.row
				},
				lineColor = {
					0,
					0,
					0,
					0
				},
				rowHeight = 150 * Game.guiScale
			})
		end
	end
	if actualOption ~= 2 then
		for i = 1, #locked do
			achievementView:insertRow({
				params = locked[i],
				rowColor = {
					default = Color.row
				},
				lineColor = {
					0,
					0,
					0,
					0
				},
				rowHeight = 150 * Game.guiScale,
				locked = true
			})
		end
	end
end
local function onRowRender(event)
	local row = event.row
	local achievement = event.row.params
	local background = display.newRect(row, 0, 0, row.width, row.height)
	if not achievement.name then
		background:setFillColor(0, 1, 0, 0.1)
		background.alpha = 0
		local buttonText = Lang.achievementsTab.googleplayachievements
		if isIOS() then
			buttonText = Lang.achievementsTab.gamecenterachievements
		end
		GUI.createButton(row, 10, 10, row.width - 20, row.height - 20, buttonText, ButtonType.blue, function()
			GameServices.showAchievements()
			return true
		end, 60)
		return
	end
	if achievement.unlocked then
		background:setFillColor(0, 1, 0, 0.1)
		background.alpha = 0
	else
		background:setFillColor(0.4, 0.4, 0.4, 0.1)
	end
	local name = display.newText({
		parent = row,
		x = 20,
		y = 15,
		text = achievement.name,
		font = Font.counterstrike,
		fontSize = 55 * Game.guiScale,
		align = "left"
	})
	name.anchorY = 0
	FontOffset.setOffset(name)
	local desc = achievement.description
	if event.row.params.locked and achievement.preDescription then
		desc = achievement.preDescription
	end
	local description = display.newText({
		parent = row,
		x = 20,
		y = name.y + name.height + 10,
		text = desc,
		font = Font.default,
		width = row.width * 0.67,
		fontSize = 34 * Game.guiScale,
		align = "left"
	})
	description.anchorY = 0
	description:setFillColor(0.75, 0.8, 1)
	FontOffset.setOffset(description)
	if not achievement.unlocked then
		description.alpha = 0.3
		name.alpha = 0.3
	end
	local buttonType = ButtonType.gray
	local buttonText = Lang.achievementsTab.notunlocked
	if achievement.unlocked then
		if not achievement.rewarded then
			buttonType = ButtonType.pink
			buttonText = Lang.achievementsTab.getreward
		else
			buttonType = ButtonType.green
			buttonText = Lang.achievementsTab.unlocked
		end
	end
	local button = GUI.createButton(row, row.width * 0.7, 0, row.width * 0.3, row.height, buttonText, buttonType, function(event)
		if not achievement.unlocked then
			return true
		end
		if not achievement.rewarded then
			local moneyToAdd = 0.2 + StatisticManager.getStatistic("unlockedAchievements") * 0.01
			GUI.showAnimatedText(nil, "+$" .. formatPrice(moneyToAdd), event.x * (math.random(95, 105) / 100), event.y * (math.random(95, 100) / 100))
			achievement.rewarded = true
			achievementView:reloadData()
			Game.addMoney(moneyToAdd, "Achievement", achievement.name)
			local expReward = math.random(100, 200)
			GUI.showInfoBox("Exp reward", expReward .. " exp awarded", InfoBoxType.experience)
			Game.addExperience(expReward)
			return true
		end
	end, 50, {noTapEffect = true})
	button.anchorX = 0.5
	button.anchorY = 0.5
	GUI.drawVerticalLine(row, row.x + row.width * 0.7 - 10, row.x, row.height)
	GUI.drawHorizontalLine(row, 0, 150 * Game.guiScale - 8, row.width * 0.7 - 10)
end
function scene:create(event)
	local sceneGroup = self.view
	local box = GUI.drawMainBox(sceneGroup, "")
	local sliderY = box.y
	local slider = TextSlider.create(sceneGroup, box.x, sliderY, box.width, 110 * Game.guiScale, sliderTexts, function(text, optionId)
		actualOption = optionId
		insertAchievements()
	end, 80 * Game.guiScale)
	local listY = box.y + 110 * Game.guiScale
	local listHeight = box.height - 110 * Game.guiScale
	achievementView = widget.newTableView({
		left = box.x,
		top = listY,
		width = box.width,
		height = listHeight,
		isBounceEnabled = true,
		backgroundColor = Color.row,
		onRowRender = onRowRender,
		friction = 0.976,
		maxVelocity = 3
	})
	achievementCounter = display.newText({
		parent = sceneGroup,
		x = getCenterX(box),
		y = box.y - 28,
		text = "",
		font = Font.counterstrike,
		fontSize = 35,
		align = "center"
	})
	achievementCounter.anchorX = 0.5
	achievementCounter.anchorY = 0.5
	achievementCounter:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(achievementCounter)
	updateAchievementCounter()
	sceneGroup:insert(achievementView)
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
		updateAchievementCounter()
		if achievementView and Game.achievementChange then
			insertAchievements()
			Game.achievementChange = false
		end
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
