local ItemView = {}
ItemView.__index = ItemView
function ItemView:getImageData()
	local type = self.item.type
	local path = "images/"
	local proportions = 0.8333333333333334
	if type == Item.skin then
		path = path .. "skins/"
		if self.item.pattern or self.item.id >= 784 then
			proportions = 0.75
		end
	elseif type == Item.sticker then
		path = path .. "stickers/"
		proportions = 1
		if self.item.id >= 588 then
			proportions = 0.75
		end
	elseif type == Item.glove then
		path = path .. "gloves/"
		proportions = 0.75
	end
	path = path .. self.item.id .. ".png"
	return {path = path, proportions = proportions}
end
function ItemView:isStatTrakAvailable()
	return Game.skins[self.item.id].statTrakAvailable
end
function ItemView:isSouvenirAvailable()
	return Game.skins[self.item.id].souvenirAvailable
end
function ItemView:draw()
	if self.image then
		self.image:removeSelf()
	end
	local imageData = self:getImageData()
	self.image = display.newImageRect(self.parent, imageData.path, self.width, self.width * imageData.proportions)
	self.image.anchorX = 0.5
	self.image.anchorY = 0.5
	self.image.x = self.x
	self.image.y = self.y
	if self.item.statTrak then
		if self:isStatTrakAvailable() then
			local imageWidth = self.width / 2
			self.statTrakImage = display.newImageRect(self.parent, "images/stattrak.png", imageWidth * Game.guiScale, imageWidth * Game.guiScale)
			self.statTrakImage.x = self.image.x + self.image.width * 0.35
			self.statTrakImage.y = self.image.y + self.image.height * 0.3
			self.statTrakImage.anchorX = 0.5
			self.statTrakImage.anchorY = 0.5
		else
			self.souvenirText = display.newText({
				parent = self.parent,
				x = self.image.x + self.image.width * 0.45,
				y = self.image.y + self.image.height * 0.3,
				text = "S",
				font = Font.counterstrike,
				fontSize = 42,
				align = "center"
			})
			self.souvenirText.anchorX = 0.5
			self.souvenirText.anchorY = 0.5
			self.souvenirText:setFillColor(unpack(Color.souvenir))
		end
	end
	return image
end
function ItemView.create(options)
	local newView = {}
	setmetatable(newView, ItemView)
	newView.item = options.item
	newView.x = options.x
	newView.y = options.y
	newView.parent = options.parent
	newView.width = options.width
	if not options.dontDraw then
		newView:draw()
	end
	return newView
end
return ItemView
