local widget = require("widget")
local Option = {
	sounds = 1,
	mainScreenAnimations = 2,
	itemSellingConfirmation = 4,
	facebook = 5,
	reset = 6,
	versionInfo = 7,
	gameplayOptions = 8,
	backButton = 9,
	rate = 10,
	languages = 11,
	polish = 12,
	english = 13,
	skipDrawAnimations = 14,
	speedUpDrawAnimations = 15,
	reddit = 16,
	cloud = 17,
	cloudSave = 18,
	gameServices = 19,
	login = 20,
	syncAchievements = 21,
	achievements = 22,
	leaderboards = 23,
	explosions = 24,
	cloudLoad = 25,
	tabletMode = 26,
	equipmentQualities = 27,
	usefulLinks = 28,
	englishGroup = 29,
	polishGroup = 30,
	wiki = 31,
	tradingSubreddit = 32,
	interfaceOptions = 33,
	hawkGames = 34,
	caseClickerRPG = 35,
	restorePurchases = 36,
	equipmentScrollbar = 37,
	menuIcons = 38,
	facebookCloudSave = 39,
	skinAlbum = 40,
	stickerAlbum = 41,
	knifeAlbum = 42,
	stackItems = 43,
	equipmentCategories = 44,
	gloveAlbum = 3,
	lowEnergyMode = 45
}
local scene = composer.newScene()
local mainTable, languageTable, gameplayTable, cloudSaveTable, gameServicesTable, hiddenTable, linksTable, interfaceTable
local function addRowsToMenuTable(menuTable, rows)
	menuTable:deleteAllRows()
	for _, option in ipairs(rows) do
		local height = 180
		if option == Option.versionInfo then
			height = 350
		end
		menuTable:insertRow({
			params = {type = option},
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = height * Game.guiScale
		})
	end
end
local function addRowsToGameServicesTable()
	if GameServices.loggedIn or Game.testMode then
		addRowsToMenuTable(gameServicesTable, {
			Option.login,
			Option.achievements,
			Option.leaderboards,
			Option.cloud,
			Option.syncAchievements,
			Option.backButton
		})
	else
		addRowsToMenuTable(gameServicesTable, {
			Option.login,
			Option.backButton
		})
	end
end
local function hideTables()
	mainTable.alpha = 0
	languageTable.alpha = 0
	gameplayTable.alpha = 0
	cloudSaveTable.alpha = 0
	gameServicesTable.alpha = 0
	linksTable.alpha = 0
	hiddenTable.alpha = 0
	interfaceTable.alpha = 0
end
local getFacebookToken = function()
	if not facebook.isActive then
		GUI.showMessageBox(Lang.common.error, "Could not connect with facebook.")
		return nil
	end
	local token = facebook.getCurrentAccessToken()
	if not token then
		facebook.login(function(event)
			if event.didComplete then
				GUI.showMessageBox(Lang.common.error, "Facebook login failed.")
				return nil
			end
		end)
		return nil
	end
	CloudSave.fbToken = token.userId
	return token.userId
end
local renderSoundOption = function(row)
	Checkbox.create(row, {
		x = 57,
		y = row.height / 2,
		size = 105,
		selected = Game.settings.enableSounds,
		callback = function(state)
			if state == 1 then
				audio.setVolume(1)
				Game.settings.enableSounds = true
			else
				Game.unlockAchievement("No More Sounds")
				audio.setVolume(0)
				Game.settings.enableSounds = false
			end
		end,
		text = Lang.settings.gameplay.sounds,
		fontSize = 72 * Game.guiScale,
		textMargin = 213
	})
	GUI.drawVerticalLine(row, 220, 0, row.height)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderMainScreenAnimationOption = function(row)
	Checkbox.create(row, {
		x = 57,
		y = row.height / 2,
		size = 105,
		selected = Game.settings.enableAnimations,
		callback = function(state)
			if state == 1 then
				Game.settings.enableAnimations = true
			else
				Game.settings.enableAnimations = false
			end
		end,
		text = Lang.settings.gameplay.mainscreenanims,
		fontSize = 72 * Game.guiScale,
		textMargin = 213
	})
	GUI.drawVerticalLine(row, 220, 0, row.height)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderSpeedUpDrawAnimationsRow = function(row)
	local fontSize = 72 * Game.guiScale
	if #Lang.settings.gameplay.speedupanims > 25 then
		fontSize = 65
	end
	Checkbox.create(row, {
		x = 57,
		y = row.height / 2,
		size = 105,
		selected = Game.settings.speedUpDrawAnimations,
		callback = function(state)
			if state == 1 then
				Game.settings.speedUpDrawAnimations = true
			else
				Game.settings.speedUpDrawAnimations = false
			end
		end,
		text = Lang.settings.gameplay.speedupanims,
		fontSize = fontSize,
		textMargin = 213
	})
	GUI.drawVerticalLine(row, 220, 0, row.height)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderLowEnergyModeRow = function(row)
	Checkbox.create(row, {
		x = 57,
		y = row.height / 2,
		size = 105,
		selected = Game.settings.lowEnergyMode,
		callback = function(state)
			GUI.showConfirmationWindow("Game Restart Required", [[
Exit required
Do you want to continue?]], function()
				local path = system.pathForFile("fps.txt", system.DocumentsDirectory)
				local file = io.open(path, "w")
				local fps = 60
				if state == 1 then
					Game.settings.lowEnergyMode = true
					fps = 30
				else
					Game.settings.lowEnergyMode = false
				end
				file:write(fps)
				file:close()
				Game.save()
				if isAndroid() then
					native.requestExit()
				else
					os.exit()
				end
			end, function()
				composer.gotoScene("scenes.settings")
			end)
		end,
		text = "Low Energy Mode (30 FPS)",
		fontSize = 62,
		textMargin = 213
	})
	GUI.drawVerticalLine(row, 220, 0, row.height)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderSkipDrawAnimationOption = function(row)
	local fontSize = 72 * Game.guiScale
	if #Lang.settings.gameplay.skipdrawanims > 25 then
		fontSize = 65
	end
	Checkbox.create(row, {
		x = 57,
		y = row.height / 2,
		size = 105,
		selected = Game.settings.skipDrawAnimations,
		callback = function(state)
			if state == 1 then
				Game.settings.skipDrawAnimations = true
			else
				Game.settings.skipDrawAnimations = false
			end
		end,
		text = Lang.settings.gameplay.skipdrawanims,
		fontSize = fontSize,
		textMargin = 213
	})
	GUI.drawVerticalLine(row, 220, 0, row.height)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderConfirmItemSellingOption = function(row)
	Checkbox.create(row, {
		x = 57,
		y = row.height / 2,
		size = 105,
		selected = Game.settings.confirmItemSelling,
		callback = function(state)
			if state == 1 then
				Game.settings.confirmItemSelling = true
			else
				Game.settings.confirmItemSelling = false
			end
		end,
		text = Lang.settings.gameplay.itemsellingconfirmation,
		fontSize = 72 * Game.guiScale,
		textMargin = 213
	})
	GUI.drawVerticalLine(row, 220, 0, row.height)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderStackItemsRow = function(row)
	Checkbox.create(row, {
		x = 57,
		y = row.height / 2,
		size = 105,
		selected = Game.settings.stackEquipmentItems,
		callback = function(state)
			composer.removeScene("scenes.equipment")
			if state == 1 then
				Game.settings.stackEquipmentItems = true
			else
				Game.settings.stackEquipmentItems = false
			end
		end,
		text = Lang.settings.interface.stackEquipmentItems,
		fontSize = 72 * Game.guiScale,
		textMargin = 213
	})
	GUI.drawVerticalLine(row, 220, 0, row.height)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderEquipmentCategoriesRow = function(row)
	Checkbox.create(row, {
		x = 57,
		y = row.height / 2,
		size = 105,
		selected = Game.settings.equipmentCategories,
		callback = function(state)
			if state == 1 then
				Game.settings.equipmentCategories = true
				Game.equipmentCategories = {
					{name = "Default"},
					{name = "Locked", locked = true}
				}
				for i = 1, #Game.equipment do
					if Game.equipment[i].locked then
						Game.equipment[i].ec = 2
					else
						Game.equipment[i].ec = 1
					end
				end
			else
				Game.settings.equipmentCategories = false
				for i = 1, #Game.equipment do
					Game.equipment[i].ec = nil
				end
			end
			composer.removeScene("scenes.equipment")
		end,
		text = Lang.settings.interface.equipmentCategories,
		fontSize = 72 * Game.guiScale,
		textMargin = 213
	})
	GUI.drawVerticalLine(row, 220, 0, row.height)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderProgressResetOption = function(row)
	GUI.createButton(row, 30, 20, row.width - 60, row.height - 40, Lang.settings.gameplay.reset, ButtonType.red, function()
		GUI.showConfirmationWindow(Lang.settings.resetProgress, Lang.settings.resetProgressMessage, function()
			Game.loadDefaults()
			Menu.showRank()
			Menu.removeAlerts()
			Menu.lockItem("NetHub")
			Menu.lockItem("Jackpot")
			Menu.addAlert("Missions")
			Menu.addAlert("Dailies")
			Menu.refreshItems()
			composer.gotoScene("scenes.settings")
		end, function()
			composer.gotoScene("scenes.settings")
		end)
	end, 60)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local function renderGameplayOption(row)
	local animationsText = PonyFont.newText({
		parent = row,
		x = 270,
		y = row.height / 2,
		text = Lang.settings.gameplayoptions,
		font = BitmapFont.counterstrike,
		fontSize = 72 * Game.guiScale,
		align = "left"
	})
	animationsText.anchorY = 0.5
	local gearWheel = display.newImageRect(row, "images/gearwheel.png", 130 * Game.guiScale, 130 * Game.guiScale)
	gearWheel.x = 110
	gearWheel.y = row.height / 2
	gearWheel.anchorX = 0.5
	gearWheel.anchorY = 0.5
	GUI.drawVerticalLine(row, 220, 0, row.height)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
	row:addEventListener("tap", function()
		hideTables()
		gameplayTable.alpha = 1
		audio.play(Game.sounds.click, {
			channel = audio.findFreeChannel()
		})
		return true
	end)
end
local function renderUsefulLinksRow(row)
	local animationsText = PonyFont.newText({
		parent = row,
		x = 270,
		y = row.height / 2,
		text = Lang.settings.usefullinks,
		font = BitmapFont.counterstrike,
		fontSize = 72 * Game.guiScale,
		align = "left"
	})
	animationsText.anchorY = 0.5
	local image = display.newImageRect(row, "images/hyperlink.png", 130 * Game.guiScale, 130 * Game.guiScale)
	image.x = 110
	image.y = row.height / 2
	image.anchorX = 0.5
	image.anchorY = 0.5
	GUI.drawVerticalLine(row, 220, 0, row.height)
	row:addEventListener("tap", function()
		hideTables()
		linksTable.alpha = 1
		audio.play(Game.sounds.click, {
			channel = audio.findFreeChannel()
		})
		return true
	end)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderRateOption = function(row)
	local text = Lang.settings.rate
	if Game.googlePlayBanishment and isAndroid() then
		text = Lang.settings.update
	end
	local text = PonyFont.newText({
		parent = row,
		x = 270,
		y = row.height / 2,
		text = text,
		font = BitmapFont.counterstrike,
		fontSize = 72 * Game.guiScale,
		align = "left"
	})
	text.anchorY = 0.5
	local imageScale = 0.6
	local imageName = "googleplay.png"
	local imageWidth = 200
	local imageHeight = 200
	if Game.googlePlayBanishment and isAndroid() then
		imageName = "clickcase.png"
		imageWidth = 365
		imageHeight = 302
		imageScale = 0.4
	end
	if isIOS() then
		imageName = "appstore.png"
		imageScale = 0.9
	end
	local image = display.newImageRect(row, "images/settings/" .. imageName, imageWidth * imageScale * Game.guiScale, imageHeight * imageScale * Game.guiScale)
	image.x = 110
	image.y = row.height / 2
	image.anchorX = 0.5
	image.anchorY = 0.5
	GUI.drawVerticalLine(row, 220, 0, row.height)
	row:addEventListener("tap", function()
		if Game.googlePlayBanishment and isAndroid() then
			return system.openURL("http://caseclicker.eu/")
		end
		if isAndroid() then
			native.showPopup("appStore", {
				androidAppPackageName = "com.hawkgames.caseclicker2"
			})
		else
			native.showPopup("appStore", {iOSAppId = "1021216598"})
		end
		audio.play(Game.sounds.click, {
			channel = audio.findFreeChannel()
		})
		return true
	end)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local function renderBackButtonRow(row)
	GUI.createButton(row, 30, 20, row.width - 60, row.height - 40, Lang.settings.back, ButtonType.default, function()
		local cloudTable = false
		if cloudSaveTable.alpha == 1 then
			cloudTable = true
		end
		hideTables()
		mainTable:reloadData()
		if cloudTable and not isAndroid() then
			gameServicesTable.alpha = 1
		else
			mainTable.alpha = 1
		end
		return true
	end, 60)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local function renderVersionInfo(row)
	local firstText = Lang.settings.gameversion .. ": " .. Game.version
	local secondText = "Hawk Games"
	local firstText = PonyFont.newText({
		parent = row,
		x = row.width / 2,
		y = row.height / 2 - 10,
		text = firstText,
		font = BitmapFont.counterstrike,
		width = row.width,
		fontSize = 66 * Game.guiScale,
		align = "center"
	})
	local secondText = PonyFont.newText({
		parent = row,
		x = row.width / 2,
		y = row.height / 2 + 10,
		text = secondText,
		font = BitmapFont.counterstrike,
		width = row.width,
		fontSize = 66 * Game.guiScale,
		align = "center"
	})
	secondText:setFillColor(unpack(Color.gold))
	firstText.anchorX = 0.5
	firstText.anchorY = 1
	secondText.anchorX = 0.5
	secondText.anchorY = 0
	firstText:addEventListener("tap", function()
		Game.unlockAchievement("Secret")
		hideTables()
		hiddenTable.alpha = 1
	end)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local function renderCloudOption(row)
	local text = PonyFont.newText({
		parent = row,
		x = 270,
		y = row.height / 2,
		text = Lang.settings.gameServices.cloudSaves,
		font = BitmapFont.counterstrike,
		fontSize = 72 * Game.guiScale,
		align = "left"
	})
	text.anchorY = 0.5
	local imageName = "cloud.png"
	if isAndroid() then
		imageName = "cloud_android.png"
	end
	local image = display.newImageRect(row, "images/settings/" .. imageName, 130 * Game.guiScale, 75.4 * Game.guiScale)
	image.x = 110
	image.y = row.height / 2
	image.anchorX = 0.5
	image.anchorY = 0.5
	GUI.drawVerticalLine(row, 220, 0, row.height)
	row:addEventListener("tap", function()
		if isAndroid() and not getFacebookToken() then
			return
		end
		hideTables()
		cloudSaveTable.alpha = 1
		audio.play(Game.sounds.click, {
			channel = audio.findFreeChannel()
		})
		return true
	end)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local function renderLanguageOptionsOption(row)
	local text = PonyFont.newText({
		parent = row,
		x = 270,
		y = row.height / 2,
		text = Lang.settings.languageoptions,
		font = BitmapFont.counterstrike,
		fontSize = 72 * Game.guiScale,
		align = "left"
	})
	text.anchorY = 0.5
	local image = display.newImageRect(row, "images/settings/language.png", 150 * Game.guiScale, 150 * Game.guiScale)
	image.x = 110
	image.y = row.height / 2
	image.anchorX = 0.5
	image.anchorY = 0.5
	GUI.drawVerticalLine(row, 220, 0, row.height)
	row:addEventListener("tap", function()
		mainTable.alpha = 0
		languageTable.alpha = 1
		audio.play(Game.sounds.click, {
			channel = audio.findFreeChannel()
		})
		return true
	end)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local function renderPolishOption(row)
	local text = PonyFont.newText({
		parent = row,
		x = 270,
		y = row.height / 2,
		text = Lang.settings.language.polish,
		font = BitmapFont.counterstrike,
		fontSize = 72 * Game.guiScale,
		align = "left"
	})
	text.anchorY = 0.5
	local image = display.newImageRect(row, "images/flags/polish.png", 165 * Game.guiScale, 87 * Game.guiScale)
	image.x = 110
	image.y = row.height / 2
	image.anchorX = 0.5
	image.anchorY = 0.5
	GUI.drawVerticalLine(row, 220, 0, row.height)
	row:addEventListener("tap", function()
		Language.set(Language.polish)
		audio.play(Game.sounds.click, {
			channel = audio.findFreeChannel()
		})
		languageTable:reloadData()
		mainTable:reloadData()
		gameplayTable:reloadData()
		return true
	end)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local function renderEnglishOption(row)
	local text = PonyFont.newText({
		parent = row,
		x = 270,
		y = row.height / 2,
		text = Lang.settings.language.english,
		font = BitmapFont.counterstrike,
		fontSize = 72 * Game.guiScale,
		align = "left"
	})
	text.anchorY = 0.5
	local image = display.newImageRect(row, "images/flags/english.png", 165 * Game.guiScale, 87 * Game.guiScale)
	image.x = 110
	image.y = row.height / 2
	image.anchorX = 0.5
	image.anchorY = 0.5
	GUI.drawVerticalLine(row, 220, 0, row.height)
	row:addEventListener("tap", function()
		Language.set(Language.english)
		audio.play(Game.sounds.click, {
			channel = audio.findFreeChannel()
		})
		languageTable:reloadData()
		mainTable:reloadData()
		gameplayTable:reloadData()
		return true
	end)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local function renderGameServicesRow(row, disableTouchEvent)
	local text = ""
	if isIOS() then
		text = "Game Center"
	else
		text = "Play Games"
	end
	local text = PonyFont.newText({
		parent = row,
		x = 270,
		y = row.height / 2 - 15,
		text = text,
		font = BitmapFont.counterstrike,
		fontSize = 66,
		align = "left"
	})
	text.anchorY = 0.5
	local secondTextText = Lang.settings.gameServices.notLoggedIn
	local secondTextColor = Color.lightText
	if GameServices.loggedIn then
		secondTextColor = Color.gold
		secondTextText = GameServices.getPlayerName()
	end
	local secondText = PonyFont.newText({
		parent = row,
		x = 270,
		y = row.height / 2 + 20,
		text = secondTextText,
		font = BitmapFont.counterstrike,
		fontSize = 42,
		align = "left"
	})
	secondText.anchorY = 0.5
	secondText:setFillColor(unpack(secondTextColor))
	local imageScale = 0.6
	local imageName = "settings/playgames.png"
	if isIOS() then
		imageName = "settings/gamecenter.png"
		imageScale = 0.7
	end
	local image = display.newImageRect(row, "images/" .. imageName, 200 * imageScale * Game.guiScale, 200 * imageScale * Game.guiScale)
	image.x = 110
	image.y = row.height / 2
	image.anchorX = 0.5
	image.anchorY = 0.5
	GUI.drawVerticalLine(row, 220, 0, row.height)
	if not disableTouchEvent then
		row:addEventListener("tap", function()
			mainTable.alpha = 0
			addRowsToGameServicesTable()
			gameServicesTable.alpha = 1
			audio.play(Game.sounds.click, {
				channel = audio.findFreeChannel()
			})
			return true
		end)
	end
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local function renderLoginRow(row)
	renderGameServicesRow(row, true)
	local buttonText = Lang.settings.gameServices.login
	local buttonType = ButtonType.green
	if GameServices.loggedIn then
		buttonText = Lang.settings.gameServices.logout
		buttonType = ButtonType.red
	end
	if isAndroid() then
		GUI.createButton(row, row.width - 440, 25, 420, row.height - 50, buttonText, buttonType, function()
			if GameServices.loggedIn then
				GameServices.logout()
				addRowsToGameServicesTable()
				insertMainTableRows()
			else
				Game.showingOverlay = true
				Game.others.userInitiate = true
				GameServices.login(function()
					Game.showingOverlay = false
					if not gameServicesTable or not gameServicesTable.reloadData then
						return
					end
					addRowsToGameServicesTable()
					insertMainTableRows()
				end)
				timer.performWithDelay(2000, function()
					Game.showingOverlay = false
				end)
			end
		end, 55)
	end
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderSyncAchievementsRow = function(row)
	GUI.createButton(row, 30, 20, row.width - 60, row.height - 40, Lang.settings.gameServices.syncAchievements, ButtonType.purple, function()
		GameServices.synchronizeAchievements()
		return true
	end, 60)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderAchievementsRow = function(row)
	local text = PonyFont.newText({
		parent = row,
		x = 270,
		y = row.height / 2,
		text = Lang.settings.gameServices.achievements,
		font = BitmapFont.counterstrike,
		fontSize = 72 * Game.guiScale,
		align = "left"
	})
	text.anchorY = 0.5
	local imageScale = 0.6
	local imageName = "playachievements.png"
	if isIOS() then
		imageName = "achievements.png"
		imageScale = 0.55
	end
	local image = display.newImageRect(row, "images/settings/" .. imageName, 200 * imageScale * Game.guiScale, 200 * imageScale * Game.guiScale)
	image.x = 110
	image.y = row.height / 2
	image.anchorX = 0.5
	image.anchorY = 0.5
	GUI.drawVerticalLine(row, 220, 0, row.height)
	row:addEventListener("tap", function()
		GameServices.showAchievements()
		return true
	end)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderLeaderboardsRow = function(row)
	local text = PonyFont.newText({
		parent = row,
		x = 270,
		y = row.height / 2,
		text = Lang.settings.gameServices.leaderboards,
		font = BitmapFont.counterstrike,
		fontSize = 72 * Game.guiScale,
		align = "left"
	})
	text.anchorY = 0.5
	local imageScale = 0.6
	local imageName = "playleaderboards.png"
	if isIOS() then
		imageName = "leaderboards.png"
		imageScale = 0.6
	end
	local image = display.newImageRect(row, "images/settings/" .. imageName, 200 * imageScale * Game.guiScale, 200 * imageScale * Game.guiScale)
	image.x = 110
	image.y = row.height / 2
	image.anchorX = 0.5
	image.anchorY = 0.5
	GUI.drawVerticalLine(row, 220, 0, row.height)
	row:addEventListener("tap", function()
		GameServices.showLeaderboards()
		return true
	end)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderExplosionsOption = function(row)
	Checkbox.create(row, {
		x = 57,
		y = row.height / 2,
		size = 105,
		selected = Game.explosions,
		callback = function(state)
			if state == 1 then
				Game.explosions = true
			else
				Game.explosions = false
			end
		end,
		text = Lang.settings.explosions .. "!",
		fontSize = 72 * Game.guiScale,
		textMargin = 213
	})
	GUI.drawVerticalLine(row, 220, 0, row.height)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local function renderCloudSaveOption(row)
	GUI.createButton(row, 30, 20, row.width - 60, row.height - 40, Lang.cloudSave.saveGame, ButtonType.purple, function()
		if isAndroid() and not getFacebookToken() then
			return
		end
		GUI.showConfirmationWindow(Lang.cloudSave.notice, Lang.cloudSave.noticeMessage, function()
			composer.gotoScene("scenes.settings")
			GUI.showMessageBox(Lang.cloudSave.saving, Lang.common.pleaseWait .. "...", false)
			CloudSave.save()
		end, function()
			composer.gotoScene("scenes.settings")
		end)
		return true
	end, 60)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local function renderCloudLoadOption(row)
	GUI.createButton(row, 30, 20, row.width - 60, row.height - 40, "Load Game", ButtonType.purple, function()
		if isAndroid() and not getFacebookToken() then
			return
		end
		GUI.showConfirmationWindow(Lang.cloudSave.loadGame, Lang.cloudSave.loadGameMessage, function()
			composer.gotoScene("scenes.settings")
			GUI.showMessageBox(Lang.cloudSave.loading, Lang.common.pleaseWait .. "...", false)
			CloudSave.load()
		end, function()
			composer.gotoScene("scenes.settings")
		end)
		return true
	end, 60, {blockTime = 800})
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderTabletModeOption = function(row)
	Checkbox.create(row, {
		x = 57,
		y = row.height / 2,
		size = 105,
		selected = Game.settings.tabletMode,
		callback = function(state)
			if state == 1 then
				Game.guiScale = Game.tabletModeScale
				Game.settings.tabletMode = true
			else
				Game.guiScale = 1
				Game.settings.tabletMode = false
			end
			Menu.refreshItems()
			composer.removeHidden()
			composer.removeScene("scenes.achievements")
			composer.removeScene("scenes.settings")
			composer.gotoScene("scenes.settings")
		end,
		text = Lang.settings.gameplay.tabletmode,
		fontSize = 72 * Game.guiScale,
		textMargin = 213
	})
	GUI.drawVerticalLine(row, 220, 0, row.height)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderEquipmentQualitiesRow = function(row)
	Checkbox.create(row, {
		x = 57,
		y = row.height / 2,
		size = 105,
		selected = Game.settings.showQualityInEquipment,
		callback = function(state)
			composer.removeScene("scenes.equipment")
			if state == 1 then
				Game.settings.showQualityInEquipment = true
			else
				Game.settings.showQualityInEquipment = false
			end
		end,
		text = Lang.settings.interface.qualitiesinequipment,
		fontSize = 60,
		textMargin = 213
	})
	GUI.drawVerticalLine(row, 220, 0, row.height)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderHyperlinkOption = function(row, name, link, image, callback)
	local trigger = display.newRect(row, 0, 0, row.width, row.height)
	trigger.isHitTestable = true
	trigger.alpha = 0
	trigger:addEventListener("tap", function()
		if link then
			system.openURL(link)
		end
		if callback then
			callback()
		end
	end)
	local likeText = PonyFont.newText({
		parent = row,
		x = 270,
		y = row.height / 2 - 10,
		text = name,
		font = BitmapFont.counterstrike,
		fontSize = 72 * Game.guiScale,
		align = "left"
	})
	local image = display.newImageRect(row, image.path, image.width * Game.guiScale, image.height * Game.guiScale)
	image.x = 110
	image.y = row.height / 2
	image.anchorX = 0.5
	image.anchorY = 0.5
	GUI.drawVerticalLine(row, 220, 0, row.height)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local function renderInterfaceOptionsRow(row)
	local text = PonyFont.newText({
		parent = row,
		x = 270,
		y = row.height / 2,
		text = Lang.settings.interfaceoptions,
		font = BitmapFont.counterstrike,
		fontSize = 72 * Game.guiScale,
		align = "left"
	})
	text.anchorY = 0.5
	local image = display.newImageRect(row, "images/interface.png", 130 * Game.guiScale, 130 * Game.guiScale)
	image.x = 110
	image.y = row.height / 2
	image.anchorX = 0.5
	image.anchorY = 0.5
	GUI.drawVerticalLine(row, 220, 0, row.height)
	row:addEventListener("tap", function()
		hideTables()
		interfaceTable.alpha = 1
		audio.play(Game.sounds.click, {
			channel = audio.findFreeChannel()
		})
		return true
	end)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderRestorePurchasesOption = function(row)
	GUI.createButton(row, 30, 20, row.width - 60, row.height - 40, "Restore Purchases", ButtonType.green, function()
		MicroPayments.restore()
	end, 60, {blockTime = 1000})
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderEquipmentScrollbarRow = function(row)
	Checkbox.create(row, {
		x = 57,
		y = row.height / 2,
		size = 105,
		selected = Game.settings.equipmentScrollbar,
		callback = function(state)
			if state == 1 then
				Game.settings.equipmentScrollbar = true
			else
				Game.settings.equipmentScrollbar = false
			end
			composer.removeScene("scenes.equipment")
		end,
		text = Lang.settings.interface.showScrollbarInEquipment,
		fontSize = 67 * Game.guiScale,
		textMargin = 213
	})
	GUI.drawVerticalLine(row, 220, 0, row.height)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderSkinAlbumRow = function(row)
	local text = PonyFont.newText({
		parent = row,
		x = 270,
		y = row.height / 2,
		text = "Ultimate Skin List",
		font = BitmapFont.counterstrike,
		fontSize = 66 * Game.guiScale,
		align = "left"
	})
	text.anchorY = 0.5
	local imageScale = 0.7
	local image = display.newImageRect(row, "images/skins/117.png", 256 * imageScale * Game.guiScale, 192 * imageScale * Game.guiScale)
	image.x = 110
	image.y = row.height / 2
	image.anchorX = 0.5
	image.anchorY = 0.5
	GUI.drawVerticalLine(row, 220, 0, row.height)
	row:addEventListener("tap", function()
		GUI.showMessageBox("Loading...", "Please wait, it may take a while.", false)
		timer.performWithDelay(100, function()
			local skins = {}
			for i = 1, #Game.skins do
				Game.skins[i].statTrak = nil
				if not Game.isKnife(i) then
					table.insert(skins, Game.skins[i])
				end
			end
			local ownedSkins = {}
			for _, item in ipairs(Game.equipment) do
				if item.type == Item.skin and not Game.isKnife(item.id) then
					ownedSkins[item.id] = true
				end
			end
			composer.gotoScene("scenes.itemlist", {
				params = {
					firstText = "Ultimate Skin List",
					secondText = tableLength(ownedSkins) .. " / " .. #skins .. " skins owned",
					priceButtons = false,
					priceInfoOnClick = true,
					showOwned = true,
					ownedList = ownedSkins,
					okButtonCallback = function()
						composer.gotoScene("scenes.settings")
					end,
					items = skins
				}
			})
		end)
		return true
	end)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderKnifeAlbumRow = function(row)
	local text = PonyFont.newText({
		parent = row,
		x = 270,
		y = row.height / 2,
		text = "Ultimate Knife List",
		font = BitmapFont.counterstrike,
		fontSize = 66 * Game.guiScale,
		align = "left"
	})
	text.anchorY = 0.5
	local imageScale = 0.7
	local image = display.newImageRect(row, "images/skins/737.png", 256 * imageScale * Game.guiScale, 192 * imageScale * Game.guiScale)
	image.x = 110
	image.y = row.height / 2
	image.anchorX = 0.5
	image.anchorY = 0.5
	GUI.drawVerticalLine(row, 220, 0, row.height)
	row:addEventListener("tap", function()
		GUI.showMessageBox("Loading...", "Please wait, it may take a while.", false)
		timer.performWithDelay(100, function()
			local skins = {}
			for i = 1, #Game.skins do
				Game.skins[i].statTrak = nil
				if Game.isKnife(i) then
					if Game.skins[i].patterns then
						for j = 1, #Game.skins[i].patterns do
							table.insert(skins, {
								id = Game.skins[i].id,
								type = Item.skin,
								pattern = j
							})
						end
					else
						table.insert(skins, Game.skins[i])
					end
				end
			end
			local ownedSkins = {}
			for _, item in ipairs(Game.equipment) do
				if item.type == Item.skin and Game.isKnife(item.id) then
					if Game.skins[item.id].patterns then
						ownedSkins[item.id .. "." .. (item.pattern or 0)] = true
					else
						ownedSkins[item.id] = true
					end
				end
			end
			composer.gotoScene("scenes.itemlist", {
				params = {
					firstText = "Ultimate Knife List",
					secondText = tableLength(ownedSkins) .. " / " .. #skins .. " skins owned",
					priceButtons = false,
					priceInfoOnClick = true,
					showOwned = true,
					ownedList = ownedSkins,
					okButtonCallback = function()
						composer.gotoScene("scenes.settings")
					end,
					items = skins
				}
			})
		end)
		return true
	end)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderStickerAlbumRow = function(row)
	local text = PonyFont.newText({
		parent = row,
		x = 270,
		y = row.height / 2,
		text = "Ultimate Sticker List",
		font = BitmapFont.counterstrike,
		fontSize = 66 * Game.guiScale,
		align = "left"
	})
	text.anchorY = 0.5
	local imageScale = 0.7
	local image = display.newImageRect(row, "images/stickers/198.png", 260 * imageScale * Game.guiScale, 260 * imageScale * Game.guiScale)
	image.x = 110
	image.y = row.height / 2
	image.anchorX = 0.5
	image.anchorY = 0.5
	GUI.drawVerticalLine(row, 220, 0, row.height)
	row:addEventListener("tap", function()
		GUI.showMessageBox("Loading...", "Please wait, it may take a while.", false)
		timer.performWithDelay(100, function()
			local stickers = Game.stickers
			local ownedSkins = {}
			for _, item in ipairs(Game.equipment) do
				if item.type == Item.sticker then
					ownedSkins[item.id] = true
				end
			end
			composer.gotoScene("scenes.itemlist", {
				params = {
					firstText = "Ultimate Sticker List",
					secondText = tableLength(ownedSkins) .. " / " .. #stickers .. " stickers owned",
					priceButtons = false,
					priceInfoOnClick = true,
					showOwned = true,
					ownedList = ownedSkins,
					okButtonCallback = function()
						composer.gotoScene("scenes.settings")
					end,
					items = stickers
				}
			})
		end)
		return true
	end)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderGloveAlbumRow = function(row)
	local text = PonyFont.newText({
		parent = row,
		x = 270,
		y = row.height / 2,
		text = "Ultimate Glove List",
		font = BitmapFont.counterstrike,
		fontSize = 66 * Game.guiScale,
		align = "left"
	})
	text.anchorY = 0.5
	local imageScale = 0.7
	local image = display.newImageRect(row, "images/gloves/22.png", 256 * imageScale * Game.guiScale, 192 * imageScale * Game.guiScale)
	image.x = 110
	image.y = row.height / 2
	image.anchorX = 0.5
	image.anchorY = 0.5
	GUI.drawVerticalLine(row, 220, 0, row.height)
	row:addEventListener("tap", function()
		GUI.showMessageBox("Loading...", "Please wait, it may take a while.", false)
		timer.performWithDelay(100, function()
			local gloves = Game.gloves
			local ownedSkins = {}
			for _, item in ipairs(Game.equipment) do
				if item.type == Item.glove then
					ownedSkins[item.id] = true
				end
			end
			composer.gotoScene("scenes.itemlist", {
				params = {
					firstText = "Ultimate Glove List",
					secondText = tableLength(ownedSkins) .. " / " .. #gloves .. " gloves owned",
					priceButtons = false,
					priceInfoOnClick = true,
					showOwned = true,
					ownedList = ownedSkins,
					okButtonCallback = function()
						composer.gotoScene("scenes.settings")
					end,
					items = gloves
				}
			})
		end)
		return true
	end)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local renderCheckboxRow = function(row, defaultValue, toggleFunction, text)
	Checkbox.create(row, {
		x = 57,
		y = row.height / 2,
		size = 105,
		selected = defaultValue,
		callback = function(state)
			toggleFunction(0 < state)
		end,
		text = text,
		fontSize = 67 * Game.guiScale,
		textMargin = 213
	})
	GUI.drawVerticalLine(row, 220, 0, row.height)
end
local function onRowRender(event)
	local row = event.row
	local type = row.params.type
	if type == Option.sounds then
		renderSoundOption(row)
	elseif type == Option.mainScreenAnimations then
		renderMainScreenAnimationOption(row)
	elseif type == Option.speedUpDrawAnimations then
		renderSpeedUpDrawAnimationsRow(row)
	elseif type == Option.lowEnergyMode then
		renderLowEnergyModeRow(row)
	elseif type == Option.skipDrawAnimations then
		renderSkipDrawAnimationOption(row)
	elseif type == Option.itemSellingConfirmation then
		renderConfirmItemSellingOption(row)
	elseif type == Option.reset then
		renderProgressResetOption(row)
	elseif type == Option.restorePurchases then
		renderRestorePurchasesOption(row)
	elseif type == Option.versionInfo then
		renderVersionInfo(row)
	elseif type == Option.gameplayOptions then
		renderGameplayOption(row)
	elseif type == Option.interfaceOptions then
		renderInterfaceOptionsRow(row)
	elseif type == Option.backButton then
		renderBackButtonRow(row)
	elseif type == Option.rate then
		renderRateOption(row)
	elseif type == Option.languages then
		renderLanguageOptionsOption(row)
	elseif type == Option.polish then
		renderPolishOption(row)
	elseif type == Option.english then
		renderEnglishOption(row)
	elseif type == Option.cloud then
		renderCloudOption(row)
	elseif type == Option.gameServices then
		renderGameServicesRow(row)
	elseif type == Option.login then
		renderLoginRow(row)
	elseif type == Option.syncAchievements then
		renderSyncAchievementsRow(row)
	elseif type == Option.achievements then
		renderAchievementsRow(row)
	elseif type == Option.leaderboards then
		renderLeaderboardsRow(row)
	elseif type == Option.explosions then
		renderExplosionsOption(row)
	elseif type == Option.skinAlbum then
		renderSkinAlbumRow(row)
	elseif type == Option.knifeAlbum then
		renderKnifeAlbumRow(row)
	elseif type == Option.gloveAlbum then
		renderGloveAlbumRow(row)
	elseif type == Option.stickerAlbum then
		renderStickerAlbumRow(row)
	elseif type == Option.cloudLoad then
		renderCloudLoadOption(row)
	elseif type == Option.cloudSave then
		renderCloudSaveOption(row)
	elseif type == Option.tabletMode then
		renderTabletModeOption(row)
	elseif type == Option.equipmentQualities then
		renderEquipmentQualitiesRow(row)
	elseif type == Option.usefulLinks then
		renderUsefulLinksRow(row)
	elseif type == Option.equipmentScrollbar then
		renderEquipmentScrollbarRow(row)
	elseif type == Option.stackItems then
		renderStackItemsRow(row)
	elseif type == Option.equipmentCategories then
		renderEquipmentCategoriesRow(row)
	elseif type == Option.menuIcons then
		renderCheckboxRow(row, Game.settings.menuIcons, function(value)
			Game.settings.menuIcons = value
			Menu.refreshItems()
		end, Lang.settings.interface.showMenuIcons)
	elseif type == Option.facebook then
		renderHyperlinkOption(row, Lang.settings.fanpage, nil, {
			width = 130,
			height = 130,
			path = "images/settings/facebook.png"
		}, function()
			Game.unlockAchievement("Social Guy")
			if not system.openURL("fb://page/1588482388070015") then
				system.openURL("http://www.facebook.com/caseclicker")
			end
		end)
	elseif type == Option.reddit then
		renderHyperlinkOption(row, "/r/CaseClickers", "https://www.reddit.com/r/CaseClickers/", {
			width = 106.39999999999999,
			height = 145.6,
			path = "images/settings/reddit.png"
		})
	elseif type == Option.englishGroup then
		renderHyperlinkOption(row, Lang.settings.englishgroup, "https://www.facebook.com/groups/712197922240809", {
			width = 130,
			height = 130,
			path = "images/settings/facebook.png"
		})
	elseif type == Option.polishGroup then
		renderHyperlinkOption(row, Lang.settings.polishgroup, "https://www.facebook.com/groups/502288226624335/", {
			width = 130,
			height = 130,
			path = "images/settings/facebook.png"
		})
	elseif type == Option.wiki then
		renderHyperlinkOption(row, Lang.settings.gamewiki, "http://case-clicker.wikia.com/", {
			width = 130,
			height = 130,
			path = "images/settings/wikia.png"
		})
	elseif type == Option.tradingSubreddit then
		renderHyperlinkOption(row, Lang.settings.tradingsubreddit, "https://www.reddit.com/r/CaseClickerTrades/", {
			width = 106.39999999999999,
			height = 145.6,
			path = "images/settings/reddit.png"
		})
	elseif type == Option.caseClickerRPG then
		renderHyperlinkOption(row, "Case Clicker RPG?", nil, {
			width = 140,
			height = 140,
			path = "images/rpg.png"
		}, function()
			if not system.openURL("fb://page/809381889239577") then
				system.openURL("https://www.facebook.com/tapthemonster/")
			end
		end)
	elseif type == Option.hawkGames then
		renderHyperlinkOption(row, Lang.settings.hawkgames, nil, {
			width = 140,
			height = 140,
			path = "images/settings/hawkgames.png"
		}, function()
			Game.unlockAchievement("Social Guy")
			if not system.openURL("fb://page/552464561572526") then
				system.openURL("https://www.facebook.com/hawkgames/")
			end
		end)
	end
end
function insertMainTableRows()
	local mainTableRows = {
		Option.gameplayOptions,
		Option.interfaceOptions,
		Option.usefulLinks,
		Option.facebook,
		Option.rate,
		Option.versionInfo
	}
	mainTable:deleteAllRows()
	if Game.gameServices then
		table.insert(mainTableRows, 4, Option.gameServices)
	elseif isAndroid() and not Game.beta then
		table.insert(mainTableRows, 4, Option.cloud)
	end
	for _, option in ipairs(mainTableRows) do
		local height = 180
		if option == Option.versionInfo then
			height = 350
		end
		mainTable:insertRow({
			params = {type = option},
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = height * Game.guiScale
		})
	end
end
function scene:create(event)
	local sceneGroup = self.view
	local box = GUI.drawMainBox(sceneGroup, Lang.menu.settings)
	mainTable = widget.newTableView({
		left = box.x,
		top = box.y,
		width = box.width,
		height = box.height,
		isBounceEnabled = true,
		onRowRender = onRowRender,
		backgroundColor = {
			unpack(Color.row)
		}
	})
	sceneGroup:insert(mainTable)
	insertMainTableRows()
	local gameplayTableRows = {
		Option.backButton,
		Option.sounds,
		Option.speedUpDrawAnimations,
		Option.itemSellingConfirmation,
		Option.lowEnergyMode,
		Option.reset
	}
	if isIOS() then
		table.insert(gameplayTableRows, 6, Option.restorePurchases)
	end
	gameplayTable = widget.newTableView({
		left = box.x,
		top = box.y,
		width = box.width,
		height = box.height,
		isBounceEnabled = true,
		onRowRender = onRowRender,
		backgroundColor = {
			unpack(Color.row)
		}
	})
	sceneGroup:insert(gameplayTable)
	gameplayTable.alpha = 0
	addRowsToMenuTable(gameplayTable, gameplayTableRows)
	interfaceTable = widget.newTableView({
		left = box.x,
		top = box.y,
		width = box.width,
		height = box.height,
		isBounceEnabled = true,
		onRowRender = onRowRender,
		backgroundColor = {
			unpack(Color.row)
		}
	})
	sceneGroup:insert(interfaceTable)
	interfaceTable.alpha = 0
	local interfaceTableRows = {
		Option.backButton,
		Option.tabletMode,
		Option.mainScreenAnimations,
		Option.equipmentQualities,
		Option.equipmentScrollbar,
		Option.stackItems,
		Option.equipmentCategories
	}
	for _, option in ipairs(interfaceTableRows) do
		interfaceTable:insertRow({
			params = {type = option},
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = 180 * Game.guiScale
		})
	end
	gameServicesTable = widget.newTableView({
		left = box.x,
		top = box.y,
		width = box.width,
		height = box.height,
		isBounceEnabled = true,
		onRowRender = onRowRender,
		backgroundColor = {
			unpack(Color.row)
		}
	})
	sceneGroup:insert(gameServicesTable)
	gameServicesTable.alpha = 0
	addRowsToGameServicesTable()
	hiddenTable = widget.newTableView({
		left = box.x,
		top = box.y,
		width = box.width,
		height = box.height,
		isBounceEnabled = true,
		onRowRender = onRowRender,
		backgroundColor = {
			unpack(Color.row)
		}
	})
	sceneGroup:insert(hiddenTable)
	hiddenTable.alpha = 0
	hiddenTableRows = {
		Option.explosions,
		Option.backButton
	}
	if Game.rank >= 18 or Game.testMode then
		table.insert(hiddenTableRows, 2, Option.skinAlbum)
		table.insert(hiddenTableRows, 3, Option.knifeAlbum)
		table.insert(hiddenTableRows, 4, Option.gloveAlbum)
		table.insert(hiddenTableRows, 5, Option.stickerAlbum)
	end
	addRowsToMenuTable(hiddenTable, hiddenTableRows)
	cloudSaveTable = widget.newTableView({
		left = box.x,
		top = box.y,
		width = box.width,
		height = box.height,
		isBounceEnabled = true,
		onRowRender = onRowRender,
		backgroundColor = {
			unpack(Color.row)
		}
	})
	sceneGroup:insert(cloudSaveTable)
	cloudSaveTable.alpha = 0
	local cloudSaveTableRows = {
		Option.backButton,
		Option.cloudLoad,
		Option.cloudSave
	}
	for _, option in ipairs(cloudSaveTableRows) do
		cloudSaveTable:insertRow({
			params = {type = option},
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = 180 * Game.guiScale
		})
	end
	linksTable = widget.newTableView({
		left = box.x,
		top = box.y,
		width = box.width,
		height = box.height,
		isBounceEnabled = true,
		onRowRender = onRowRender,
		backgroundColor = {
			unpack(Color.row)
		}
	})
	sceneGroup:insert(linksTable)
	linksTable.alpha = 0
	local linksTableRows = {
		Option.backButton,
		Option.reddit,
		Option.tradingSubreddit,
		Option.englishGroup,
		Option.polishGroup,
		Option.caseClickerRPG,
		Option.hawkGames
	}
	for _, option in ipairs(linksTableRows) do
		linksTable:insertRow({
			params = {type = option},
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = 180 * Game.guiScale
		})
	end
	languageTable = widget.newTableView({
		left = box.x,
		top = box.y,
		width = box.width,
		height = box.height,
		isBounceEnabled = true,
		onRowRender = onRowRender,
		backgroundColor = {
			unpack(Color.row)
		}
	})
	sceneGroup:insert(languageTable)
	languageTable.alpha = 0
	local languageTableRows = {
		Option.backButton,
		Option.english,
		Option.polish
	}
	for _, option in ipairs(languageTableRows) do
		local height = 180
		if option == Option.versionInfo then
			height = 350
		end
		languageTable:insertRow({
			params = {type = option},
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = height * Game.guiScale
		})
	end
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
