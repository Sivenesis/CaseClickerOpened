local itemSearch = {}
itemSearch.__index = itemSearch
local firstImage = {
	name = "icons/magnifier.png",
	width = 67.5,
	height = 65.25
}
local secondImage = {
	name = "icons/magnifier2.png",
	width = firstImage.width,
	height = firstImage.height
}
function itemSearch:drawButton(sceneGroup, x, y, width, height)
	self.button = Button.create(sceneGroup, x, y, width, height, nil, ButtonType.default, function(event)
		return self:onButtonClick()
	end, {image = firstImage})
	return self.button
end
function itemSearch:setOnChangeCallback(callback)
	self.onChangeCallback = callback
end
function itemSearch:onButtonClick(button)
	if self.searchString then
		self.searchString = nil
		self:onChangeCallback()
		self.button:setImage(firstImage)
		return true
	end
	composer.showOverlay("overlays.textinput", {
		effect = "fade",
		time = 300,
		params = {
			title = "Item Search",
			text = "Search for items:",
			callback = function(text)
				if text == "" or not text then
					self.searchString = nil
					self:onChangeCallback()
					return true
				end
				self.button:setImage(secondImage)
				GUI.showMessageBox("Searching", "Please wait...", false)
				self.searchString = text
				timer.performWithDelay(100, function()
					self:onChangeCallback()
				end)
				composer.hideOverlay("fade", 300)
			end,
			buttonText = "Search"
		}
	})
	return true
end
function itemSearch:isAllowed(itemName)
	if not self.searchString then
		return true
	end
	if itemName:lower():find(self.searchString:lower()) then
		return true
	end
	return false
end
function itemSearch.create()
	local newSearch = {}
	setmetatable(newSearch, itemSearch)
	return newSearch
end
return itemSearch
