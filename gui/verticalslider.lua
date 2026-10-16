local VerticalSlider = {}
VerticalSlider.__index = VerticalSlider
function VerticalSlider:scrollListener(event, yPosition)
	if not self.tableView or not self.tableView.height then
		return false
	end
	local yPos = yPosition or self.tableView:getContentPosition()
	local percentPos = yPos / self.maxScroll
	if self.maxScroll >= -1 or self.tableView.height > math.abs(self.maxScroll) + self.tableView.height then
		return
	end
	if percentPos < 0 then
		percentPos = 0
	elseif 1 < percentPos then
		percentPos = 1
	end
	self:scrollBar(percentPos)
end
function VerticalSlider:scrollBar(position)
	if self.inside.y and self.background.y then
		self.inside.y = self.background.y + 10 + position * (self.background.height - 20 - self.inside.height)
	end
end
function VerticalSlider:setTableView(tableView, maxScroll, id)
	self.tableView = tableView
	if maxScroll then
		local insideHeight = 1 * (self.background.height - 20)
		local visibleHeight = tableView.height
		if visibleHeight < math.abs(maxScroll) + tableView.height and not (-1 <= maxScroll) then
			insideHeight = math.max(0.15, math.min(0.8, math.abs(visibleHeight / maxScroll))) * (self.background.height - 20)
		end
		self.inside.height = insideHeight
		self.maxScroll = maxScroll
	end
end
function VerticalSlider:toFront()
	self.group:toFront()
end
function VerticalSlider:moveX(x)
	self.group.x = self.group.x + x
end
function VerticalSlider:moveY(val)
	self.group.y = self.group.y + val
	self.y = self.y + val
end
function VerticalSlider.create(sceneGroup, x, y, width, height)
	local bar = {}
	setmetatable(bar, VerticalSlider)
	bar.group = display.newGroup()
	bar.background = display.newRect(bar.group, x, y, width, height)
	bar.background.anchorX = 0
	bar.background:setFillColor(rgb(43, 55, 77))
	bar.y = y
	bar.background:addEventListener("touch", function(event)
		if bar.maxScroll >= -1 or bar.tableView.height > math.abs(bar.maxScroll) + bar.tableView.height then
			return
		end
		local percent = (event.y - bar.y) / height
		bar:scrollBar(percent)
		bar.tableView:scrollToY({
			y = bar.maxScroll * percent,
			time = 0
		})
	end)
	bar.inside = display.newRect(bar.group, x + 10, y + 10, width - 20, height / 6)
	bar.inside.anchorX = 0
	bar.inside:setFillColor(rgb(62, 81, 114))
	sceneGroup:insert(bar.group)
	return bar
end
return VerticalSlider
