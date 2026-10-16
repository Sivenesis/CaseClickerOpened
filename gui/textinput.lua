local TextInput = {}
TextInput.__index = TextInput
local offscreenInput
function TextInput:shake()
	local initialX = self.group.x
	for i = 6, 1, -1 do
		timer.performWithDelay((6 - i) * 60, function()
			local newPos = initialX + i * 5
			if i % 2 == 0 then
				newPos = initialX + i * -5
			end
			if i == 1 then
				newPos = initialX
			end
			transition.to(self.group, {time = 59, x = newPos})
		end)
	end
end
function TextInput:internalValidate()
	local text = self:getText()
	local validator = self.options.validator or {}
	if validator.minLength and #text < validator.minLength then
		return self:showError("Field needs to have at least " .. validator.minLength .. " letters")
	end
	if validator.maxLength and #text > validator.maxLength then
		return self:showError("Field is too long (" .. #text .. " / " .. validator.maxLength .. ")")
	end
	if #text == 0 then
		return self:hideError()
	end
	if validator.regex and text:match(validator.regex) and #text:match(validator.regex) ~= #text then
		return self:showError("Field contains illegal characters")
	end
	return self:hideError()
end
function TextInput:validate()
	if not self:internalValidate() then
		self:shake()
		return false
	end
	return true
end
function TextInput:showError(text)
	self.errorText.text = text
	transition.to(self.errorText, {alpha = 1, time = 300})
	return false
end
function TextInput:hideError()
	transition.to(self.errorText, {alpha = 0, time = 300})
	return true
end
function TextInput:setText(text)
	self.text.text = text
	self.text.currentText = text
end
function TextInput:getText()
	return self.text.currentText
end
local function setupTextInput(widgetInput)
	if offscreenInput then
		offscreenInput:removeSelf()
	end
	offscreenInput = native.newTextField(-500, -500, 100, 100)
	offscreenInput:setReturnKey("done")
	native.setKeyboardFocus(offscreenInput)
	offscreenInput.text = widgetInput.text.currentText
	if isIOS() then
		transition.to(widgetInput.group, {
			time = 200,
			x = display.safeActualContentWidth / 2 - widgetInput.group.width / 2,
			y = display.safeActualContentHeight * 0.17
		})
	end
	offscreenInput:addEventListener("userInput", function(event)
		if event.phase == "began" then
			offscreenInput.text = widgetInput.text.currentText
		elseif event.phase == "editing" then
			if not widgetInput.text.width then
				return true
			end
			widgetInput.text.currentText = event.text
			widgetInput.text.text = event.text
			if widgetInput.text.width > widgetInput.background.width - 50 then
				local avgLetterWidth = widgetInput.text.width / #widgetInput.text.currentText
				widgetInput.text.text = event.text:sub(0, (widgetInput.background.width - 60) / avgLetterWidth) .. "..."
			end
			if widgetInput.placeholder then
				if #widgetInput.text.text > 0 then
					widgetInput.placeholder.alpha = 0
				else
					widgetInput.placeholder.alpha = 0.3
				end
			end
			widgetInput:internalValidate()
		elseif event.phase == "submitted" or event.phase == "ended" then
			native.setKeyboardFocus(nil)
			widgetInput:internalValidate()
			if isIOS() then
				transition.to(widgetInput.group, {
					time = 200,
					x = widgetInput.x,
					y = widgetInput.y
				})
			end
		end
	end)
end
function TextInput.create(sceneGroup, x, y, width, height, text, options)
	local input = {}
	setmetatable(input, TextInput)
	input.options = options or {}
	input.x = x
	input.y = y
	input.width = width
	input.height = height
	input.group = display.newGroup()
	sceneGroup:insert(input.group)
	input.group.x = x
	input.group.y = y
	input.background = display.newRoundedRect(input.group, 0, 0, width, height, 10)
	input.background:setFillColor(unpack(Color.lightRow))
	input.background.strokeWidth = 3
	input.background:setStrokeColor(unpack(Color.contourLine))
	input.text = display.newText({
		parent = input.group,
		x = 10,
		y = getCenterY(input.background),
		text = "",
		font = native.systemFont,
		fontSize = 36,
		align = "left"
	})
	input.text.anchorY = 0.5
	input.text:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(input.text)
	input.text.currentText = text or ""
	input:setText(text or "")
	input.errorText = display.newText({
		parent = input.group,
		x = width / 2,
		y = input.background.y + input.background.height + 15,
		text = "",
		font = native.systemFont,
		fontSize = 32,
		align = "left"
	})
	input.errorText.anchorX = 0.5
	input.errorText:setFillColor(unpack(Color.lightRed))
	FontOffset.setOffset(input.errorText)
	input.errorText.alpha = 0
	if input.options.placeholder then
		input.placeholder = display.newText({
			parent = input.group,
			x = 10,
			y = getCenterY(input.background),
			text = input.options.placeholder,
			font = native.systemFont,
			fontSize = 36,
			align = "left"
		})
		input.placeholder.anchorY = 0.5
		input.placeholder:setFillColor(unpack(Color.lightText))
		FontOffset.setOffset(input.placeholder)
		input.placeholder.alpha = 0.3
		if text and 0 < #text then
			input.placeholder.alpha = 0
		end
	end
	input.background:addEventListener("tap", function()
		setupTextInput(input)
	end)
	return input
end
return TextInput
