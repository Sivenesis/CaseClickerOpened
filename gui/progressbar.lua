local progressBar = {}
progressBar.__index = progressBar
local progressBarImages = {
	[ProgressBarType.default] = {
		center = "progressbar_default.png",
		left = "progressbar_default_left.png",
		right = "progressbar_default_right.png"
	},
	[ProgressBarType.gold] = {
		center = "progressbar_default.png",
		left = "progressbar_default_left.png",
		right = "progressbar_default_right.png"
	}
}
function progressBar:setProgress(percent, noAnimation)
	if 100 < percent then
		percent = 100
	end
	if not self.inside.width or not self.background.width then
		return
	end
	percent = math.round(percent)
	local barWidth = (self.background.width - 7 - 2) * (percent / 100)
	if noAnimation then
		self.inside.width = barWidth
		self.rightSide = self.inside.x + barWidth
	else
		transition.to(self.inside, {time = 100, width = barWidth})
		transition.to(self.insideRight, {
			time = 100,
			x = self.inside.x + barWidth
		})
	end
end
function progressBar:setText(text)
	if not self.mainText then
		return
	end
	self.mainText.text = text
	if self.secondText then
		self.secondText.text = text
	end
end
function progressBar.create(sceneGroup, x, y, width, height, barType)
	local bar = {}
	setmetatable(bar, progressBar)
	bar.group = display.newGroup()
	local sideScale = 40 / height
	local leftSide = display.newImageRect(bar.group, "images/gui/bar_left.png", 16 / sideScale, 40 / sideScale)
	leftSide.x = x - width / 2
	leftSide.y = y
	bar.rightSide = display.newImageRect(bar.group, "images/gui/bar_right.png", 16 / sideScale, 40 / sideScale)
	bar.rightSide.x = x + width / 2 - bar.rightSide.width
	bar.rightSide.y = y
	bar.background = display.newImageRect(bar.group, "images/gui/bar_inside.png", width - 2 * leftSide.width, height)
	bar.background.x = x
	bar.background.y = y
	bar.background.anchorX = 0.5
	local barHeight = bar.background.height * 0.7
	local barX = bar.background.x + 5 - bar.background.width / 2
	local barY = bar.background.y + bar.background.height / 2
	bar.inside = display.newImageRect(bar.group, "images/gui/" .. progressBarImages[barType].center, 0, barHeight)
	bar.inside.x = barX
	bar.inside.y = barY
	bar.inside.anchorY = 0.5
	bar.insideLeft = display.newImageRect(bar.group, "images/gui/" .. progressBarImages[barType].left, barHeight / 2.333, barHeight)
	bar.insideLeft.x = barX - bar.inside.width - bar.insideLeft.width
	bar.insideLeft.y = barY
	bar.insideLeft.anchorY = 0.5
	bar.insideRight = display.newImageRect(bar.group, "images/gui/" .. progressBarImages[barType].right, barHeight / 2.333, barHeight)
	bar.insideRight.x = barX - 4
	bar.insideRight.y = barY
	bar.insideRight.anchorY = 0.5
	bar.secondText = display.newText({
		parent = bar.group,
		x = getCenterX(bar.background) - bar.background.width / 2,
		y = getCenterY(bar.background),
		text = "",
		font = Font.counterstrike,
		fontSize = 46,
		align = "center"
	})
	bar.secondText.anchorX = 0.5
	bar.secondText.anchorY = 0.5
	bar.secondText:setFillColor(unpack(Color.black))
	FontOffset.setOffset(bar.secondText)
	bar.mainText = display.newText({
		parent = bar.group,
		x = getCenterX(bar.background) - bar.background.width / 2,
		y = getCenterY(bar.background),
		text = "",
		font = Font.counterstrike,
		fontSize = 46,
		align = "center"
	})
	bar.mainText.anchorX = 0.5
	bar.mainText.anchorY = 0.5
	bar.mainText:setFillColor(unpack(Color.white))
	FontOffset.setOffset(bar.mainText)
	sceneGroup:insert(bar.group)
	return bar
end
return progressBar
