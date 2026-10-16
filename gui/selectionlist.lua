local selectionList = {}
selectionList.__index = selectionList
function selectionList:hide()
	self.group.alpha = 0
	self.button:hide()
end
function selectionList:show()
	self.group.alpha = 1
	self.button:show()
end
function selectionList:showOptions()
	self.showingOptions = true
	self.group:toFront()
	local actualY = self.y + self.height
	local actualI = 1
	for _, option in ipairs(self.options) do
		self.optionBoxes[actualI] = display.newGroup()
		if 1 < actualI then
			local line = display.newRect(self.optionBoxes[actualI], self.x + 4, actualY, self.width - 8, 4)
			line:setFillColor(rgb(32, 44, 59))
		end
		local rect = display.newRect(self.optionBoxes[actualI], self.x, actualY, self.width, 90)
		rect:setFillColor(rgb(29, 41, 55))
		rect:addEventListener("tap", function()
			if self.onClick and not self:onClick() then
				return true
			end
			self:hideOptions()
			if option.callback() and self.button:getText() ~= option.text then
				self.button:setText(option.text)
			end
			return true
		end)
		rect:addEventListener("touch", function()
			return true
		end)
		local margin = 4
		local insideRect = display.newRect(self.optionBoxes[actualI], self.x + margin, actualY + margin, self.width - margin * 2, 90 - margin * 2)
		insideRect:setFillColor(rgb(42, 58, 79))
		local text = display.newText({
			parent = self.optionBoxes[actualI],
			x = self.x + 15,
			y = actualY + 45,
			text = option.text,
			width = self.width - 30,
			font = Font.counterstrike,
			fontSize = 50,
			align = "left"
		})
		text.anchorX = 0
		text.anchorY = 0.5
		FontOffset.setOffset(text)
		self.group:insert(self.optionBoxes[actualI])
		actualI = actualI + 1
		actualY = actualY + 90
	end
end
function selectionList:hideOptions()
	self.showingOptions = false
	for i = 1, #self.optionBoxes do
		self.optionBoxes[i]:removeSelf()
	end
	self.optionBoxes = {}
end
function selectionList:addOption(text, callback, default)
	if default then
		self.button:setText(text)
	end
	table.insert(self.options, {text = text, callback = callback})
end
function selectionList.create(sceneGroup, x, y, width, height, options)
	local list = {}
	setmetatable(list, selectionList)
	list.group = display.newGroup()
	list.options = {}
	list.optionBoxes = {}
	list.x = x
	list.y = y
	list.width = width
	list.height = height
	list.showingOptions = false
	if options.onClick then
		list.onClick = options.onClick
	end
	list.button = Button.create(sceneGroup, x, y, width, height, "", ButtonType.default, function()
		if list.onClick and not list:onClick() then
			return true
		end
		if list.showingOptions then
			list:hideOptions()
		else
			list:showOptions()
		end
	end, {fontSize = 55})
	sceneGroup:insert(list.group)
	return list
end
return selectionList
