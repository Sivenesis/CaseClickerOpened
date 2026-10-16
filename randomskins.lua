local RandomSkins = {}
local sceneGroup = display.newGroup()
local showing = false
local skinImage
local toShow = false
local disabledScenes = {
	["scenes.jackpots.roomselection"] = true,
	["scenes.nethub.chat"] = true,
	["scenes.draw"] = true,
	["overlays.scratch"] = true
}
function RandomSkins.init()
	timer.performWithDelay(30000, function()
		if disabledScenes[composer.getSceneName("current")] or disabledScenes[composer.getSceneName("overlay")] then
			return
		end
		local mainScreen = false
		if composer.getSceneName("current") and composer.getSceneName("current") == "scenes.main" then
			mainScreen = true
		end
		if not showing then
			if os.time() - Game.others.lastRandomSkin >= 1200 and math.random(1, 100) <= 4 or toShow then
				RandomSkins.show(mainScreen)
				toShow = false
			end
			return
		end
		sceneGroup:toFront()
	end, -1)
end
function RandomSkins.hide()
	if not skinImage or showing == false then
		return
	end
	transition.fadeOut(skinImage, {
		time = 300,
		onComplete = function()
			if skinImage and skinImage.removeSelf then
				skinImage:removeSelf()
			end
		end
	})
	showing = false
	toShow = true
end
function RandomSkins.show(mainScreen)
	if showing then
		return false
	end
	local skin
	while true do
		local statTrak = false
		local id = math.random(1, #Game.skins)
		if math.random(1, 8) <= 2 and (Game.skins[id].statTrakAvailable or Game.skins[id].souvenirAvailable) then
			statTrak = true
		end
		local item = {
			id = id,
			quality = math.random(1, 5),
			statTrak = statTrak
		}
		local price = Game.getItemPrice(item)
		if 0.1 < price and price <= 2.8 + math.min(Game.rank, 100) * 0.25 then
			skin = item
			break
		end
	end
	showing = true
	skinImage = display.newImageRect(sceneGroup, "images/skins/" .. skin.id .. ".png", 144, 120)
	skinImage.x = math.random(0, display.safeActualContentWidth - 144)
	if mainScreen then
		skinImage.y = math.random(display.safeActualContentHeight * 0.5, display.safeActualContentHeight - 144)
	else
		skinImage.y = math.random(0, display.safeActualContentHeight - 144)
	end
	skinImage.alpha = 0
	transition.fadeIn(skinImage, {time = 300})
	skinImage:toFront()
	Game.others.lastRandomSkin = os.time()
	skinImage:addEventListener("tap", function(event)
		if disabledScenes[composer.getSceneName("current")] then
			return true
		end
		skinImage:removeSelf()
		Game.addItem(Game.skins[skin.id], true, skin.statTrak, true, {
			quality = skin.quality
		})
		Game.unlockAchievement("Random Item")
		showing = false
		return true
	end)
	return true
end
return RandomSkins
