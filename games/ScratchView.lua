local ScratchView = {}
ScratchView.__index = ScratchView
function ScratchView:drawBackground()
	self.background = display.newRect(self.parent, self.x, self.y, self.width, self.height)
	self.background:setFillColor(unpack(ColorTools.darken(self.color, 2.5)))
end
function ScratchView:drawSquares()
	self.squares = {}
	local squarePadding = 15
	local squaresPerRow = math.sqrt(#self.scratch.fields)
	local squaresPerColumn = math.sqrt(#self.scratch.fields)
	local squareWidth = (self.width - squarePadding * (squaresPerRow + 1)) / squaresPerRow
	local squareHeight = (self.height - squarePadding * (squaresPerColumn + 1)) / squaresPerColumn
	local squareId = 1
	for x = 0, math.sqrt(#self.scratch.fields) - 1 do
		for y = 0, math.sqrt(#self.scratch.fields) - 1 do
			local squareX = x * (squareWidth + squarePadding) + squarePadding
			local squareY = y * (squareHeight + squarePadding) + squarePadding
			local fieldTable = {
				group = display.newGroup()
			}
			self.parent:insert(fieldTable.group)
			local item = self.scratch.fields[squareId]
			fieldTable.background = display.newRect(fieldTable.group, self.x + squareX, self.y + squareY, squareWidth, squareHeight)
			local rarityColor = RarityColors[Game.getItemRarity(item)]
			fieldTable.background.alpha = 0.7
			fieldTable.background.fill.effect = "generator.radialGradient"
			local color = rarityColor
			color[4] = 1
			local darkerColor = ColorTools.darken(rarityColor, 2)
			darkerColor[4] = 1
			fieldTable.background.fill.effect.color1 = color
			fieldTable.background.fill.effect.color2 = darkerColor
			fieldTable.background.fill.effect.center_and_radiuses = {
				0.5,
				0.5,
				0.25,
				0.75
			}
			fieldTable.itemImage = ItemView.create({
				item = item,
				parent = fieldTable.group,
				x = self.x + squareX + squareWidth / 2,
				y = self.y + squareY + squareHeight / 2,
				width = squareWidth * 0.8
			})
			fieldTable.scratchPoints = {}
			local pointId = 1
			local divide = 6
			for pointX = 0, divide - 1 do
				for pointY = 0, divide - 1 do
					local localPointId = pointId
					local localSquareId = squareId
					fieldTable.scratchPoints[pointId] = display.newRect(fieldTable.group, self.x + squareX + pointX * (squareWidth / divide), self.y + squareY + pointY * (squareHeight / divide), squareWidth / divide, squareHeight / divide)
					fieldTable.scratchPoints[pointId].alpha = 0
					fieldTable.scratchPoints[pointId].isHitTestable = true
					fieldTable.scratchPoints[pointId]:addEventListener("touch", function(event)
						if event.phase ~= "moved" then
							return true
						end
						self.squares[localSquareId].scratchPoints[localPointId]:removeSelf()
						self.squares[localSquareId].scratchPointsLeft = self.squares[localSquareId].scratchPointsLeft - 1
						if self.squares[localSquareId].scratchPointsLeft < divide * divide * 0.8 then
							self.scratch:scratchField(localSquareId)
							transition.to(fieldTable.mask, {alpha = 0, time = 500})
						end
						return true
					end)
					pointId = pointId + 1
				end
			end
			fieldTable.scratchPointsLeft = pointId
			fieldTable.mask = display.newSnapshot(fieldTable.group, squareWidth, squareHeight)
			fieldTable.mask.x = fieldTable.background.x
			fieldTable.mask.y = fieldTable.background.y
			fieldTable.mask.alpha = 1
			local maskBackground = display.newImageRect("images/games/scratchfield.png", squareWidth, squareHeight)
			maskBackground.x = -squareWidth / 2
			maskBackground.y = -squareHeight / 2
			local maskBackgroundColor = ColorTools.darken(self.color, 1.2)
			maskBackgroundColor[4] = 1
			local maskBackgroundDarkerColor = self.color
			maskBackgroundDarkerColor[4] = 1
			if squareId % 2 == 0 then
				maskBackground:setFillColor(unpack(maskBackgroundColor))
			else
				maskBackground:setFillColor(unpack(maskBackgroundDarkerColor))
			end
			fieldTable.mask.group:insert(maskBackground)
			fieldTable.mask:invalidate()
			fieldTable.background:addEventListener("touch", function(event)
				local circle = display.newCircle(event.x - self.x - squareX - squareWidth / 2, event.y - self.y - squareY - squareHeight / 2, 40)
				circle.anchorX = 0.5
				circle.anchorY = 0.5
				circle.fill.blendMode = {
					srcColor = "zero",
					dstColor = "oneMinusSrcAlpha"
				}
				if fieldTable.mask then
					fieldTable.mask.group:insert(circle)
					fieldTable.mask:invalidate()
				else
					circle:removeSelf()
				end
				return true
			end)
			fieldTable.group:addEventListener("touch", function()
				return false
			end)
			self.squares[squareId] = fieldTable
			squareId = squareId + 1
		end
	end
end
function ScratchView:setGrayBackground(background)
	for i = 1, 2 do
		local x = math.random(background.x, background.x + background.width)
		local y = math.random(background.y, background.y + background.height)
		x = background.x + background.width / 2
		y = background.y + background.height / 2
		Animation.show("poof", x, y)
	end
	local color = {
		ColorTools.rgb(128, 128, 128)
	}
	color[4] = 1
	local darkerColor = ColorTools.darken({
		ColorTools.rgb(128, 128, 128)
	}, 2)
	darkerColor[4] = 1
	background.fill.effect.color1 = color
	background.fill.effect.color2 = darkerColor
end
function ScratchView:draw()
	self:drawBackground()
	self:drawSquares()
	self.scratch:addEndCallback(function(won, item, fields)
		if not won then
			for i = 1, #self.squares do
				self:setGrayBackground(self.squares[i].background)
			end
			return true
		end
		for i = 1, #self.squares do
			if tableContains(fields, i) then
				local mask = self.squares[i].masks
				transition.to(self.squares[i].mask, {alpha = 0, time = 400})
				self.squares[i].mask = nil
				for j = 1, 3 do
					local x = math.random(self.squares[i].background.x, self.squares[i].background.x + self.squares[i].background.width)
					local y = math.random(self.squares[i].background.y, self.squares[i].background.y + self.squares[i].background.height)
					Animation.show("sparks1", x, y)
				end
			else
				self:setGrayBackground(self.squares[i].background)
			end
		end
	end)
end
function ScratchView.create(options)
	local newView = {}
	setmetatable(newView, ScratchView)
	newView.parent = options.parent
	newView.x = options.x
	newView.y = options.y
	newView.width = options.width
	newView.height = options.height
	newView.color = options.color
	newView.scratch = options.scratch
	return newView
end
return ScratchView
