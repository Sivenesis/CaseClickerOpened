local checkbox = {}
checkbox.__index = checkbox
function checkbox:select()
	self.selected = true
	transition.fadeIn(self.firstLine, {time = 150})
	transition.fadeIn(self.secondLine, {time = 150})
	self.callback(1)
end
function checkbox:deselect()
	self.selected = false
	transition.fadeOut(self.firstLine, {time = 150})
	transition.fadeOut(self.secondLine, {time = 150})
	self.callback(0)
end
function checkbox:toggle()
	if self.selected then
		self:deselect()
	else
		self:select()
	end
end
function checkbox:reset()
	if self.default == self.selected then
		return
	end
	if self.default == true then
		self:select()
	else
		self:deselect()
	end
end
function checkbox:removeSelf()
	self.group:removeSelf()
end
function checkbox.create(sceneGroup, options)
	local _checkbox = {}
	setmetatable(_checkbox, checkbox)
	_checkbox.group = display.newGroup()
	_checkbox.selected = options.selected
	_checkbox.default = options.selected or false
	_checkbox.callback = options.callback
	options.size = options.size * Game.guiScale
	_checkbox.rectangle = display.newRoundedRect(_checkbox.group, options.x, options.y, options.size, options.size, 10)
	_checkbox.rectangle.anchorY = 0.5
	_checkbox.rectangle:setFillColor(rgb(55, 65, 92))
	_checkbox.rectangle.strokeWidth = 3
	_checkbox.rectangle:setStrokeColor(rgb(29, 41, 55))
	_checkbox.group:insert(_checkbox.rectangle)
	_checkbox.firstLine = display.newLine(_checkbox.group, options.x + 9, options.y - options.size / 2 + 9, options.x + options.size - 9, options.y + options.size / 2 - 9)
	_checkbox.firstLine.strokeWidth = 5
	_checkbox.secondLine = display.newLine(_checkbox.group, options.x + options.size - 9, options.y - options.size / 2 + 9, options.x + 9, options.y + options.size / 2 - 9)
	_checkbox.secondLine.strokeWidth = 5
	if not _checkbox.selected then
		_checkbox.firstLine.alpha = 0
		_checkbox.secondLine.alpha = 0
	end
	if not options.text then
		_checkbox.rectangle:addEventListener("tap", function()
			_checkbox:toggle()
		end)
	end
	if options.text then
		local textMargin = options.textMargin or options.size + 30
		_checkbox.text = display.newText({
			parent = _checkbox.group,
			x = options.x + textMargin,
			y = options.y,
			text = options.text,
			font = Font.counterstrike,
			fontSize = (options.fontSize or options.size * 0.75) * Game.guiScale,
			align = "center"
		})
		_checkbox.text.anchorY = 0.5
		FontOffset.setOffset(_checkbox.text)
		if options.fontColor then
			_checkbox.text:setFillColor(unpack(options.fontColor))
		end
		_checkbox.selectionRectangle = display.newRect(_checkbox.group, options.x, options.y, textMargin + _checkbox.text.width + options.size, options.size)
		_checkbox.selectionRectangle.anchorY = 0.5
		_checkbox.selectionRectangle.isHitTestable = true
		_checkbox.selectionRectangle.alpha = 0
		_checkbox.selectionRectangle:addEventListener("tap", function()
			_checkbox:toggle()
		end)
	end
	sceneGroup:insert(_checkbox.group)
	return _checkbox
end
return checkbox
