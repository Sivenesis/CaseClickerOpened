local composer = require("composer")
local Scratch = require("games.Scratch")
local ScratchView = require("games.ScratchView")
local scene = composer.newScene()
local mainBox
function scene:drawMainBox()
	local widthMultiplier = 0.6
	local heightMultiplier = 0.88
	mainBox = GUI.createBox(self.view, display.safeActualContentWidth * (1 - widthMultiplier) / 2, display.safeActualContentHeight * (1 - heightMultiplier) / 2, display.safeActualContentWidth * widthMultiplier, display.safeActualContentHeight * heightMultiplier, "Scratch!")
	mainBox:setFillColor(unpack(ColorTools.darken(self.params.color, 5)))
end
function scene:updateButtons()
	if not self.finished then
		self.button:setType(ButtonType.default)
		self.button:setText(#self.scratch.fields - tableLength(self.scratch.scratchedFields) .. " fields left!")
		return true
	end
	if self.won then
		self.button:setType(ButtonType.green)
		self.button:setText("Claim reward!")
	else
		self.button:setType(ButtonType.red)
		self.button:setText("You have lost :(")
	end
end
function scene:create(event)
	local sceneGroup = self.view
	self.params = event.params
	self.finished = false
	self.won = true
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.8)
	background:addEventListener("touch", function()
		return true
	end)
	background:addEventListener("tap", function()
		return true
	end)
	self:drawMainBox()
	self.scratch = Scratch.create(event.params.type, event.params.price, function(result, reward)
		self.finished = true
		self.won = result
		self.reward = reward
		self:updateButtons()
	end, function()
		self:updateButtons()
	end)
	local scratchSize = mainBox.height - 20 - 30 - 120
	print(scratchSize)
	self.scratchView = ScratchView.create({
		parent = sceneGroup,
		x = getCenterX(mainBox) - 450,
		y = mainBox.y + 20,
		width = scratchSize,
		height = scratchSize,
		color = event.params.color,
		scratch = self.scratch
	})
	self.scratchView:draw()
	self.button = Button.create(sceneGroup, getCenterX(mainBox) - mainBox.width / 2 + 15, mainBox.y + mainBox.height - 120 - 15, mainBox.width - 30, 120, "Ok", ButtonType.green, function()
		if self.button.type == ButtonType.red then
			composer.hideOverlay("fade", 300)
		elseif self.button.type == ButtonType.green then
			local itemTab
			if self.reward.type == Item.skin then
				itemTab = Game.skins[self.reward.id]
			elseif self.reward.type == Item.sticker then
				itemTab = Game.stickers[self.reward.id]
			else
				itemTab = Game.gloves[self.reward.id]
			end
			Game.addItem(itemTab, true, self.reward.statTrak, true, {
				pattern = self.reward.pattern
			})
		end
	end, {fontSize = 60, blockTime = 300})
	self:updateButtons()
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Game.showingOverlay = true
	elseif phase == "did" then
		RandomSkins.hide()
	end
end
function scene:hide(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Game.showingOverlay = false
	elseif phase == "did" then
		composer.removeScene("overlays.scratch")
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
