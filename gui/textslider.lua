local textSlider = {}
textSlider.__index = textSlider
function textSlider:setText(text)
	self.mainText.text = text
	for i = 1, #self.texts do
		if text == self.texts[i] then
			self.actualText = i
			return
		end
	end
end
function textSlider:setDefaultValue()
	self.value = self.defaultValue
	self.mainText.text = 0
end
function textSlider:getTextId()
	return self.actualText
end
function textSlider:setTextId(id)
	self.actualText = id
	self.mainText.text = self.texts[self.actualText]
end
function textSlider.create(sceneGroup, x, y, width, height, texts, changeCallback, textSize)
	local slider = {}
	setmetatable(slider, textSlider)
	slider.actualText = 1
	slider.texts = texts
	slider.group = display.newGroup()
	slider.background = display.newRect(slider.group, x + 2, y + 2, width - 4, height - 4)
	slider.background:setFillColor(rgb(26, 46, 68))
	slider.background:addEventListener("touch", function()
		return true
	end)
	slider.background:addEventListener("tap", function()
		return true
	end)
	slider.background.strokeWidth = 3
	slider.background:setStrokeColor(unpack(Color.line))
	slider.rightArrow = GUI.createButton(slider.group, x + width - 2 * height + 4, y + 2, 2 * height - 4, height - 6, ">", ButtonType.darkblue, function()
		slider.actualText = slider.actualText + 1
		if slider.actualText > #slider.texts then
			slider.actualText = 1
		end
		slider.mainText.text = slider.texts[slider.actualText]
		changeCallback(slider.texts[slider.actualText], slider.actualText)
	end, 102)
	slider.leftArrow = GUI.createButton(slider.group, x + 2, y + 2, 2 * height - 4, height - 6, "<", ButtonType.darkblue, function()
		slider.actualText = slider.actualText - 1
		if slider.actualText < 1 then
			slider.actualText = #slider.texts
		end
		slider.mainText.text = slider.texts[slider.actualText]
		changeCallback(slider.texts[slider.actualText], slider.actualText)
	end, 102)
	slider.mainText = display.newText({
		parent = slider.group,
		x = getCenterX(slider.background),
		y = getCenterY(slider.background),
		text = texts[1],
		font = Font.counterstrike,
		fontSize = textSize or 80,
		align = "center"
	})
	slider.mainText.anchorX = 0.5
	slider.mainText.anchorY = 0.5
	slider.mainText:setFillColor(unpack(Color.white))
	FontOffset.setOffset(slider.mainText)
	sceneGroup:insert(slider.group)
	return slider
end
function textSlider.createValueSlider(sceneGroup, x, y, width, height, valueChangeCallback, defaultValue, textSize)
	local slider = {}
	setmetatable(slider, textSlider)
	slider.group = display.newGroup()
	slider.background = display.newRect(slider.group, x + 2, y + 2, width - 4, height - 4)
	slider.background:setFillColor(rgb(26, 46, 68))
	slider.background:addEventListener("touch", function()
		return true
	end)
	slider.background:addEventListener("tap", function()
		return true
	end)
	slider.background.strokeWidth = 3
	slider.background:setStrokeColor(unpack(Color.line))
	slider.defaultValue = 0
	slider.value = defaultValue or 0
	slider.rightArrow = GUI.createButton(slider.group, x + width - math.min(2 * height - 4, width * 0.3), y + 2, math.min(2 * height - 4, width * 0.3), height - 6, ">", ButtonType.darkblue, function()
		if not valueChangeCallback(slider.value, 1) then
			return false
		end
		slider.value = slider.value + 1
		slider.mainText.text = slider.value
	end, 102)
	slider.leftArrow = GUI.createButton(slider.group, x + 2, y + 2, math.min(2 * height - 4, width * 0.3), height - 6, "<", ButtonType.darkblue, function()
		if not valueChangeCallback(slider.value, -1) then
			return false
		end
		slider.value = slider.value - 1
		slider.mainText.text = slider.value
	end, 102)
	slider.mainText = display.newText({
		parent = slider.group,
		x = getCenterX(slider.background),
		y = getCenterY(slider.background),
		text = defaultValue or 0,
		font = Font.counterstrike,
		fontSize = textSize or 80,
		align = "center"
	})
	slider.mainText.anchorX = 0.5
	slider.mainText.anchorY = 0.5
	slider.mainText:setFillColor(unpack(Color.white))
	FontOffset.setOffset(slider.mainText)
	sceneGroup:insert(slider.group)
	return slider
end
return textSlider
