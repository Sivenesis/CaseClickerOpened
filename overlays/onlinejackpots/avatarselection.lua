local composer = require("composer")
local TextSlider = require("gui.textslider")
local scene = composer.newScene()
local mainBox, slider
local roomType = 1
local roomTypes = {}
local avatarImages = {}
local avatarRectangle
local function drawMainBox(sceneGroup)
	mainBox = GUI.createBox(sceneGroup, display.safeActualContentWidth * 0.1, display.safeActualContentHeight * 0.17, display.safeActualContentWidth * 0.8, display.safeActualContentHeight * 0.6, "Avatar selection")
	mainBox:setFillColor(rgb(22, 30, 40))
	return mainBox
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
	local background = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	background:setFillColor(0, 0, 0, 0.8)
	background:addEventListener("touch", function()
		return true
	end)
	background:addEventListener("tap", function()
		return true
	end)
	local mainBox = drawMainBox(sceneGroup)
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
	lastY = lastY + 110
	local closeButton = Button.create(sceneGroup, getCenterX(mainBox) - 450, lastY, 900, 110, "Select", ButtonType.green, function(event)
		composer.hideOverlay("fade", 250)
	end, {fontSize = 55})
	updateAvatarImage()
end
function scene:show(event)
	local phase = event.phase
	if phase == "will" then
		Game.showingOverlay = true
	elseif phase == "did" then
	end
end
function scene:hide(event)
	local phase = event.phase
	if phase == "will" then
		Game.showingOverlay = false
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
return scene
