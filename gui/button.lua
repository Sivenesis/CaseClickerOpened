local button = {holdTimer = nil}
button.__index = button
local lastTouch = 0
local buttonImages = {
	[ButtonType.default] = "button_default.png",
	[ButtonType.darkblue] = "button_default.png",
	[ButtonType.green] = "button_green.png",
	[ButtonType.red] = "button_red.png",
	[ButtonType.gray] = "button_gray.png",
	[ButtonType.lightblue] = "button_lightblue.png",
	[ButtonType.pink] = "button_pink.png",
	[ButtonType.purple] = "button_purple.png",
	[ButtonType.blue] = "button_blue.png",
	[ButtonType.yellow] = "button_yellow.png",
	[ButtonType.black] = "button_black.png",
	[ButtonType.orange] = "button_orange.png"
}
local buttonStrokes = {
	[ButtonType.default] = {
		rgb(72, 99, 138)
	},
	[ButtonType.darkblue] = {
		rgb(77, 110, 141)
	},
	[ButtonType.green] = {
		rgb(116, 173, 56)
	},
	[ButtonType.red] = {
		rgb(196, 78, 74)
	},
	[ButtonType.gray] = {
		rgb(110, 115, 107)
	},
	[ButtonType.lightblue] = {
		rgb(77, 110, 141)
	},
	[ButtonType.pink] = {
		rgb(167, 89, 179)
	},
	[ButtonType.purple] = {
		rgb(119, 90, 172)
	},
	[ButtonType.blue] = {
		rgb(57, 96, 148)
	},
	[ButtonType.yellow] = {
		rgb(168, 168, 56)
	},
	[ButtonType.orange] = {
		rgb(240, 237, 2)
	},
	[ButtonType.black] = {
		rgb(5, 10, 2)
	}
}
local function buttonHoldCheck(event, buttonGroup, options, lastTime)
	if not buttonGroup.touching then
		return
	end
	if options.holdCallback then
		audio.play(Game.sounds.click, {
			channel = audio.findFreeChannel()
		})
		if options.holdCallback(event) == true then
			button.holdTimer = nil
			return true
		end
		if 100 < lastTime then
			lastTime = lastTime * 0.75
		end
		button.holdTimer = timer.performWithDelay(lastTime, function()
			buttonHoldCheck(event, buttonGroup, options, lastTime)
		end)
		return
	end
	buttonGroup.touching = false
end
function button:setText(text)
	self.text.text = text
end
function button:getText()
	if not self.text then
		return nil
	end
	return self.text.text
end
function button:setImage(imageData)
	if self.image then
		self.image:removeSelf()
	end
	self.image = display.newImageRect(self.group, "images/" .. imageData.name, imageData.width, imageData.height)
	self.image.x = self.background.x + self.background.width / 2
	self.image.y = self.background.y + self.background.height / 2
	self.image.anchorX = 0.5
	self.image.anchorY = 0.5
end
function button:hide()
	self.group.alpha = 0
end
function button:show()
	self.group.alpha = 1
end
function button:addListeners()
	if self.tapListener then
		self.background:addEventListener("tap", self.tapListener)
	end
	if self.touchListener then
		self.background:addEventListener("touch", self.touchListener)
	end
end
function button:getType()
	return self.type
end
function button:setType(newType)
	local x = self.background.x
	local y = self.background.y
	local width = self.background.width
	local height = self.background.height
	self.background:removeSelf()
	self.background = display.newImageRect(self.group, "images/gui/" .. buttonImages[newType], width, height)
	self.background.x = x
	self.background.y = y
	self.background:toBack()
	self.type = newType
	self:addListeners()
end
function button.create(parent, x, y, width, height, text, buttonType, callback, options)
	local newButton = {}
	setmetatable(newButton, button)
	newButton.options = options or {}
	newButton.group = display.newGroup()
	newButton.type = buttonType
	newButton.x = display.getNearestHorizontalPixel(x)
	newButton.y = display.getNearestVerticalPixel(y)
	newButton.width = display.getNearestHorizontalPixel(width)
	newButton.height = display.getNearestHorizontalPixel(height)
	newButton.background = display.newImageRect(newButton.group, "images/gui/" .. buttonImages[buttonType], width, height)
	newButton.background.x = x
	newButton.background.y = y
	newButton.background.strokeWidth = math.ceil(display.pixelWidth)
	newButton.background:setStrokeColor(unpack(buttonStrokes[buttonType]))
	newButton.blackOverlay = display.newRect(newButton.group, x, y, width, height)
	newButton.blackOverlay:setFillColor(unpack(Color.black))
	newButton.blackOverlay.alpha = 0
	if text and not options.image then
		local fontSize = options.fontSize or width / #text * 1.5
		local font = Font.counterstrike
		if options.font then
			font = options.font
		end
		newButton.text = display.newText({
			parent = newButton.group,
			x = getCenterX(newButton.background),
			y = getCenterY(newButton.background),
			text = text,
			width = width,
			font = font,
			fontSize = fontSize * Game.guiScale,
			align = "center"
		})
		newButton.text.anchorX = 0.5
		newButton.text.anchorY = 0.5
		FontOffset.setOffset(newButton.text)
	else
		newButton.image = display.newImageRect(newButton.group, "images/" .. options.image.name, options.image.width, options.image.height)
		newButton.image.x = newButton.background.x + newButton.background.width / 2
		newButton.image.y = newButton.background.y + newButton.background.height / 2
		newButton.image.anchorX = 0.5
		newButton.image.anchorY = 0.5
	end
	parent:insert(newButton.group)
	newButton.touching = false
	newButton.touchStart = 0
	if options.callbackAsHoldCallback then
		options.holdCallback = callback
	end
	if not callback then
		return newButton.group
	end
	if options.holdCallback then
		local blockTime = options.blockTime or 0
		function newButton.tapListener(event)
			if system.getTimer() - lastTouch < blockTime or Game.blockButtons then
				return false
			end
			audio.play(Game.sounds.click, {
				channel = audio.findFreeChannel()
			})
			callback(event)
			lastTouch = system.getTimer()
			newButton.blackOverlay.alpha = 0
			display.currentStage:setFocus(nil)
			return true
		end
		function newButton.touchListener(event)
			if event.phase == "began" then
				newButton.blackOverlay.alpha = 0.1
				newButton.group.touching = true
				newButton.group.touchStart = system.getTimer()
				local holdStartTime = options.holdStartTime or 750
				button.holdTimer = timer.performWithDelay(holdStartTime, function()
					buttonHoldCheck(event, newButton.group, options, holdStartTime)
				end)
				display.currentStage:setFocus(newButton.background)
			elseif event.phase == "ended" or event.phase == "cancelled" then
				newButton.blackOverlay.alpha = 0
				display.currentStage:setFocus(nil)
				if button.holdTimer then
					timer.cancel(button.holdTimer)
					button.holdTimer = nil
				end
				if newButton.touching == false then
					return
				end
				newButton.touching = false
			end
			return true
		end
	else
		local blockTime = options.blockTime or 0
		function newButton.tapListener(event)
			if system.getTimer() - lastTouch < blockTime or Game.blockButtons then
				return false
			end
			audio.play(Game.sounds.click, {
				channel = audio.findFreeChannel()
			})
			callback(event)
			lastTouch = system.getTimer()
			newButton.blackOverlay.alpha = 0
			return true
		end
		function newButton.touchListener(event)
			if event.phase == "began" then
				newButton.blackOverlay.alpha = 0.1
				display.currentStage:setFocus(newButton.background)
			elseif event.phase == "ended" or event.phase == "cancelled" then
				newButton.blackOverlay.alpha = 0
				display.currentStage:setFocus(nil)
			end
			return true
		end
	end
	newButton:addListeners()
	return newButton
end
return button
