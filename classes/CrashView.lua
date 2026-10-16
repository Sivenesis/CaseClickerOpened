local crashView = {}
crashView.__index = crashView
function crashView:removeLines()
	if self.lines then
		for _, line in ipairs(self.lines) do
			line:removeSelf()
		end
	end
	self.lines = {}
end
function crashView:drawLine(values)
	local startX = 0
	local startY = self.height
	if self.lastLine then
		startX = self.lastLine.x2
		startY = self.lastLine.y2
	end
	local width = values.time / self.currentMaxTime * self.width
	local height = (values.value - 1) / (self.currentMaxValue - 1) * self.height
	local line = display.newLine(self.group, startX, startY, width, self.height - height)
	line.x2 = width
	line.y2 = self.height - height
	line.strokeWidth = 4
	self.lastLine = line
	table.insert(self.lines, line)
end
function crashView:drawLines()
	self:removeLines()
	self.lastLine = nil
	local skip = math.ceil(#self.valueList / 13)
	self:drawLine(self.valueList[1])
	for i = 2, #self.valueList - 1, skip do
		self:drawLine(self.valueList[i])
	end
	self:drawLine(self.valueList[#self.valueList])
end
function crashView:addValue()
	local delta = (system.getTimer() - self.lastValueAddTime) / 1000
	self.lastValueAddTime = system.getTimer()
	self.valueAdd = self.valueAdd * (1 + (0.02 + self.valueAddAdd) * (delta * 10))
	local value = self.valueAdd
	self.currentTime = (system.getTimer() - self.startTime) / 1000
	self.currentMaxTime = math.max(self.currentMaxTime, self.currentTime)
	self.currentValue = math.min(self.currentValue + value, self.crashPoint)
	self.currentMaxValue = math.max(self.currentMaxValue, self.currentValue)
	table.insert(self.valueList, {
		value = self.currentValue,
		time = self.currentTime
	})
	self:drawLines()
	if self.currentValue >= 25 then
		self:crash()
	end
	if self.crashPoint <= self.currentValue then
		self:crash()
	end
end
function crashView:removeValueLines()
	if self.valueLines and #self.valueLines > 0 then
		for _, line in ipairs(self.valueLines) do
			line:removeSelf()
		end
	end
	self.valueLines = {}
end
function crashView:removeValueTexts()
	if self.valueTexts and #self.valueTexts > 0 then
		for _, text in ipairs(self.valueTexts) do
			text:removeSelf()
		end
	end
	self.valueTexts = {}
end
function crashView:drawValueLines()
	self:removeValueLines()
	self:removeValueTexts()
	local lineDistance = self.height / ((self.currentMaxValue - 1) * 10)
	local iSkip = 2
	if self.currentMaxValue > 8 then
		iSkip = 40
	elseif self.currentMaxValue > 6 then
		iSkip = 20
	elseif self.currentMaxValue > 4 then
		iSkip = 10
	elseif self.currentMaxValue > 2 then
		iSkip = 5
	end
	for i = 0, (self.currentMaxValue - 1) * 10, iSkip do
		local line = display.newLine(self.group, 0, self.height - i * lineDistance, 10, self.height - i * lineDistance)
		line.strokeWidth = 4
		table.insert(self.valueLines, line)
		local text = display.newText({
			parent = self.group,
			x = line.x - 5,
			y = line.y,
			text = i / 10 + 1 .. "x",
			font = Font.default,
			fontSize = 26,
			align = "center"
		})
		text.anchorY = 0.5
		text.anchorX = 1
		text:setFillColor(unpack(Color.white))
		table.insert(self.valueTexts, text)
	end
end
function crashView:removeTimeLines()
	if self.timeLines and #self.timeLines > 0 then
		for _, line in ipairs(self.timeLines) do
			line:removeSelf()
		end
	end
	self.timeLines = {}
end
function crashView:removeTimeTexts()
	if self.timeTexts and #self.timeTexts > 0 then
		for _, text in ipairs(self.timeTexts) do
			text:removeSelf()
		end
	end
	self.timeTexts = {}
end
function crashView:drawBottomLines()
	self:removeTimeLines()
	self:removeTimeTexts()
	local lineDistance = self.width / self.currentMaxTime
	local iSkip = 1
	if self.currentMaxTime >= 40 then
		iSkip = 10
	elseif self.currentMaxTime >= 20 then
		iSkip = 5
	elseif self.currentMaxTime >= 12 then
		iSkip = 2
	end
	for i = 0, self.currentMaxTime, iSkip do
		local line = display.newLine(self.group, i * lineDistance, self.height, i * lineDistance, self.height - 10)
		line.strokeWidth = 4
		table.insert(self.timeLines, line)
		local text = display.newText({
			parent = self.group,
			x = line.x,
			y = line.y,
			text = i,
			font = Font.default,
			fontSize = 26,
			align = "center"
		})
		text.anchorX = 0.5
		text:setFillColor(unpack(Color.white))
		table.insert(self.timeTexts, text)
	end
end
function crashView:update()
	self:addValue()
	self:drawBottomLines()
	self:drawValueLines()
	if self.started then
		self.bigText.text = "x" .. formatPrice(math.round(self.currentValue * 100) / 100)
	end
end
function crashView:stop()
	self.started = false
	self.bigText.text = "x" .. formatPrice(math.round(self.currentValue * 100) / 100)
	self.bigText:setFillColor(unpack(Color.green))
	StatisticManager.addStatistic("crashWon")
	Analytics.addEvent("Crash:Win", self.currentValue)
	return self.currentValue
end
function crashView:start(onCrashCallback)
	self.crashCallback = onCrashCallback
	self:reset()
	self.bigText:setFillColor(unpack(Color.white))
	self.startTime = system.getTimer()
	self.started = true
	self.bigText.size = 250
	self.smallText.alpha = 0
	self.valueAdd = math.random(3, 6) / 1000
	self.valueAddAdd = math.random(-8, 12) / 10000
	self.lastValueAddTime = system.getTimer()
	local instantCrashChance = 2
	local crashProfit = StatisticManager.getStatistic("crashProfit")
	if 1000000 <= crashProfit then
		instantCrashChance = 3
	end
	if instantCrashChance >= math.random(1, 100) then
		self:crash()
	end
	local crashChanceMultiplier = 1
	if 10000000 <= crashProfit then
		crashChanceMultiplier = 1.15
	elseif 1000000 <= crashProfit then
		crashChanceMultiplier = 1.1
	elseif 500000 <= crashProfit then
		crashChanceMultiplier = 1.05
	end
	for i = 100, 2500 do
		local crashChance = 1 * (math.min(i, 130) / 100) / 2 / 100 * crashChanceMultiplier
		if math.random(1, 10000) <= crashChance * 10000 then
			self.crashPoint = i / 100
			break
		end
	end
	local highCrashChance = 2
	if crashProfit <= 500000 then
		highCrashChance = 3
	end
	if highCrashChance >= math.random(1, 100) then
		self.crashPoint = math.random(300, 2400) / 100
	end
end
function crashView:crash()
	self.bigText:setFillColor(unpack(Color.lightRed))
	self.bigText.size = 145
	self.bigText.text = "Crash at " .. formatPrice(self.currentValue) .. "x!"
	self.started = false
	StatisticManager.addStatistic("crashLost")
	Analytics.addEvent("Crash:Lose", self.currentValue)
	self.crashCallback()
end
function crashView:draw(parent, x, y, width, height)
	self.parent = parent
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.group = display.newGroup()
	parent:insert(self.group)
	self.group.x = x
	self.group.y = y
	self.background = display.newRect(self.group, 0, 0, width, height)
	self.background:setFillColor(Color.row[1] * 1.25, Color.row[2] * 1.25, Color.row[3] * 1.25)
	self.bigText = display.newText({
		parent = self.group,
		x = width / 2,
		y = height / 2 - 40,
		text = "",
		font = Font.default,
		fontSize = 250,
		align = "center"
	})
	self.bigText.anchorX = 0.5
	self.bigText.anchorY = 0.5
	self.bigText:setFillColor(unpack(Color.lightText))
	self.smallText = display.newText({
		parent = self.group,
		x = width / 2,
		y = height / 2 + 120,
		text = "",
		font = Font.default,
		fontSize = 65,
		align = "center"
	})
	self.smallText.anchorX = 0.5
	self.smallText.anchorY = 0.5
	self.smallText:setFillColor(unpack(Color.green))
	self.smallText.alpha = 0
	self:drawBottomLines()
	self:drawValueLines()
end
function crashView:reset()
	self:removeTimeLines()
	self:removeTimeTexts()
	self:removeValueLines()
	self:removeValueTexts()
	self:removeLines()
	self.started = false
	self.valueList = {}
	self.currentTime = 0
	self.currentValue = 1
	self.currentMaxTime = 6
	self.currentMaxValue = 2
end
function crashView:showSmallText(text)
	self.smallText.text = text
	transition.to(self.smallText, {alpha = 1, time = 300})
end
function crashView.create()
	local view = {}
	setmetatable(view, crashView)
	view:reset()
	return view
end
return crashView
