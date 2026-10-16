local composer = require("composer")
local TextSlider = require("gui.textslider")
local scene = composer.newScene()
local mainBox, slider, priceRangeText
local roomType = 1
local roomTypes = {}
local avatarImages = {}
local avatarRectangle
local function updatePriceRangeText()
	local maxPrice = "$" .. formatPrice(roomTypes[roomType].maxPrice)
	if roomTypes[roomType].maxPrice >= 5000 then
		maxPrice = "Maximum"
	end
	priceRangeText.text = Lang.jackpot.pricerange .. ": $" .. formatPrice(roomTypes[roomType].minPrice) .. " " .. Lang.jackpot.to .. " " .. maxPrice
end
local validateNickname = function(nick)
	if #nick < 3 then
		return "Your nickname needs to have at least 3 letters."
	end
	if 26 < #nick then
		return "Your nickname must have maximum 26 letters."
	end
	local match = string.match(nick, "[a-zA-Z0-9 ']+")
	if match ~= nick then
		return "Your name contains illegal characters."
	end
	return nil
end
local function updateAvatarImage()
	local actualAvatar = Game.onlineJackpot.avatar
	if not avatarImages[actualAvatar] then
		avatarImages[actualAvatar] = display.newImageRect(scene.view, "images/avatars/" .. Jackpot.botNames[actualAvatar]:lower() .. ".jpg", 411.59999999999997, 283.2)
		avatarImages[actualAvatar].anchorX = 0.5
		avatarImages[actualAvatar].x = getCenterX(mainBox)
		avatarImages[actualAvatar].y = avatarRectangle.y + 10
	end
	for _, image in pairs(avatarImages) do
		image.alpha = 0
	end
	avatarImages[actualAvatar].alpha = 1
end
function scene:create(event)
	local sceneGroup = scene.view
	roomTypes = event.params.roomTypes
	mainBox = GUI.drawMainBox(sceneGroup, "Online Jackpots @ Room Selection")
	local lastY = mainBox.y + 35
	local avatarText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = lastY,
		width = mainBox.width,
		text = "Select your avatar:",
		font = Font.counterstrike,
		fontSize = 72,
		align = "center"
	})
	avatarText.anchorX = 0.5
	FontOffset.setOffset(avatarText)
	lastY = lastY + 75
	avatarRectangle = display.newRect(sceneGroup, getCenterX(mainBox), lastY, 431.59999999999997, 303.2)
	avatarRectangle.anchorX = 0.5
	avatarRectangle:setFillColor(unpack(Color.black))
	lastY = lastY + avatarRectangle.height + 30
	lastY = lastY + 20
	local avatarSliderTexts = {}
	for i = 1, #Jackpot.botNames do
		table.insert(avatarSliderTexts, i .. " / " .. #Jackpot.botNames)
	end
	local avatarSlider = TextSlider.create(sceneGroup, mainBox.x + mainBox.width / 2 - 450, lastY, 900, 100, avatarSliderTexts, function(text, id)
		Game.onlineJackpot.avatar = id
		updateAvatarImage()
	end)
	avatarSlider:setTextId(Game.onlineJackpot.avatar)
	lastY = lastY + 140
	local roomTypeText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = lastY,
		width = mainBox.width,
		text = "Select jackpot type:",
		font = Font.counterstrike,
		fontSize = 72,
		align = "center"
	})
	roomTypeText.anchorX = 0.5
	FontOffset.setOffset(roomTypeText)
	lastY = lastY + 66
	local sliderTexts = {}
	for _, val in ipairs(roomTypes) do
		table.insert(sliderTexts, val.name)
	end
	local textSlider = TextSlider.create(sceneGroup, mainBox.x + mainBox.width / 2 - 600, lastY, 1200, 100, sliderTexts, function(text, id)
		roomType = id
		updatePriceRangeText()
		OnlineJackpots.roomType = id
	end)
	lastY = lastY + 135
	priceRangeText = display.newText({
		parent = sceneGroup,
		x = getCenterX(mainBox),
		y = lastY,
		width = mainBox.width,
		text = "-",
		font = Font.default,
		fontSize = 42,
		align = "center"
	})
	priceRangeText.anchorX = 0.5
	priceRangeText:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(priceRangeText)
	lastY = lastY + 70
	local joinRoomButton = GUI.createButton(sceneGroup, getCenterX(mainBox) - 450, lastY, 900, 110, "Join room", ButtonType.green, function(event)
		GUI.showMessageBox("Joining Room", "Please wait...", false)
		OnlineJackpots.internalChecked = false
		Game.onlineJackpot.name = NetHub.getNickname()
		if nickError then
			return GUI.showMessageBox(Lang.common.error, nickError, true, function()
				if composer.getSceneName("current") ~= "scenes.jackpots.roomselection" then
					return
				end
			end)
		end
		OnlineJackpots.joinRoom(roomType, function(success, str)
			if not success then
				return GUI.showMessageBox(Lang.common.error, str, true, function()
					if composer.getSceneName("current") ~= "scenes.jackpots.roomselection" then
						return
					end
				end)
			end
			composer.gotoScene("scenes.jackpots.jackpot")
		end)
	end, 55)
	lastY = lastY + 125
	local returnButton = GUI.createButton(sceneGroup, getCenterX(mainBox) - 450, lastY, 900, 110, "Return", ButtonType.purple, function(event)
		composer.gotoScene("scenes.nethub.nethub")
		OnlineJackpots.disconnect()
		Menu.updateItems()
	end, 55)
	updateAvatarImage()
	updatePriceRangeText()
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
	elseif phase == "did" then
		composer.removeScene("scenes.jackpots.jackpot")
		OnlineJackpots.checked = false
		OnlineJackpots.winner = nil
		OnlineJackpots.room = {}
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
