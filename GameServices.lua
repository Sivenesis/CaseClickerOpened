local gameNetwork = require("gameNetwork")
local GameServices = {
	loggedIn = false,
	initialized = false,
	player = {}
}
local loginCallbackFunc
local leaderboards = {
	moneyRecord = {
		playId = "CgkI5ZG_k94FEAIQxAE",
		appStoreId = "moneyrecord",
		getActualValue = function()
			local moneyRecord = StatisticManager.getStatistic("moneyRecord")
			if isAndroid() then
				return tonumber(moneyRecord * 1000000)
			else
				return tonumber(moneyRecord * 100)
			end
		end,
		canBeSubmitted = function()
			return StatisticManager.getStatistic("moneyRecord") > Game.others.lastMoneyRecordSent
		end,
		onSubmit = function()
			Game.others.lastMoneyRecordSent = StatisticManager.getStatistic("moneyRecord")
		end
	},
	skinsWorth = {
		playId = "CgkI5ZG_k94FEAIQwgE",
		appStoreId = "skinsworth",
		getActualValue = function()
			local skinsWorth = StatisticManager.getStatistic("skinsWorth")
			if isAndroid() then
				return tonumber(skinsWorth * 1000000)
			else
				return tonumber(skinsWorth * 100)
			end
		end,
		canBeSubmitted = function()
			return StatisticManager.getStatistic("skinsWorth") > Game.others.lastSkinWorthSent
		end,
		onSubmit = function()
			Game.others.lastSkinWorthSent = StatisticManager.getStatistic("skinsWorth")
		end
	},
	openedBoxes = {
		playId = "CgkI5ZG_k94FEAIQwAE",
		appStoreId = "openedboxes",
		getActualValue = function()
			return tonumber(StatisticManager.getStatistic("openedBoxes"))
		end,
		canBeSubmitted = function()
			return StatisticManager.getStatistic("openedBoxes") > Game.others.lastOpenedBoxesSent
		end,
		onSubmit = function()
			Game.others.lastOpenedBoxesSent = StatisticManager.getStatistic("openedBoxes")
		end
	},
	equipmentCount = {
		playId = "CgkI5ZG_k94FEAIQwQE",
		appStoreId = "equipmentcount",
		getActualValue = function()
			return #Game.equipment
		end,
		canBeSubmitted = function()
			return #Game.equipment > Game.others.lastEquipmentCountSent
		end,
		onSubmit = function()
			Game.others.lastEquipmentCountSent = #Game.equipment
		end
	}
}
local function loadLocalPlayerCallback(event)
	GameServices.player.name = event.data.alias or "Unknown"
	GameServices.player.id = event.data.playerID
	local lastScene
	if composer.getSceneName("current") == "scenes.achievements" or composer.getSceneName("current") == "scenes.statistics" then
		lastScene = composer.getSceneName("current")
	end
	composer.removeScene("scenes.achievements")
	composer.removeScene("scenes.statistics")
	if lastScene then
		composer.gotoScene(lastScene)
	end
	Game.achievementChange = true
	GameServices.loggedIn = true
	GameServices.sendHighscores()
	if loginCallbackFunc then
		loginCallbackFunc()
		loginCallbackFunc = nil
	end
end
local function gpgsLoginCallback(event)
	gameNetwork.request("loadLocalPlayer", {listener = loadLocalPlayerCallback})
	return true
end
local function gpgsInitCallback(event)
	GameServices.initialized = true
	local userInitiated = Game.others.userInitiate
	gameNetwork.request("login", {
		userInitiated = Game.others.userInitiate,
		listener = gpgsLoginCallback
	})
	Game.others.userInitiate = false
end
function GameServices.login(loginCallback)
	if not Game.gameServices then
		return false
	end
	if not isMobile() then
		GameServices.player.name = "Player"
		GameServices.player.id = "local_pc_player"
		GameServices.loggedIn = true
		if loginCallback then loginCallback() end
		return true
	end
	if GameServices.loggedIn == true then
		return true
	end
	loginCallbackFunc = loginCallback
	if isAndroid() then
		if GameServices.initialized then
			gpgsInitCallback()
		else
			gameNetwork.init("google", gpgsInitCallback)
		end
	else
		gameNetwork.init("gamecenter", gpgsLoginCallback)
	end
	return true
end
function GameServices.showLeaderboards()
	if not GameServices.loggedIn or not Game.gameServices then
		return false
	end
	if isAndroid() then
		gameNetwork.show("leaderboards")
	else
		gameNetwork.show("leaderboards", {
			leaderboard = {timeScope = "AllTime"}
		})
	end
end
function GameServices.sendHighscores()
	if not GameServices.loggedIn or not Game.gameServices then
		return false
	end
	for key, board in pairs(leaderboards) do
		if board.canBeSubmitted() then
			local category = board.playId
			if isIOS() then
				category = board.appStoreId
			end
			gameNetwork.request("setHighScore", {
				localPlayerScore = {
					category = category,
					value = board.getActualValue()
				}
			})
			board.onSubmit()
		end
	end
end
function GameServices.getPlayerName()
	return GameServices.player.name or ""
end
function GameServices.init()
	GameServices.login()
end
function GameServices.logout()
	gameNetwork.request("logout")
	GameServices.loggedIn = false
	composer.removeScene("scenes.achievements")
	composer.removeScene("scenes.statistics")
	Game.achievementChange = true
end
function GameServices.unlockAchievement(name)
	if not GameServices.loggedIn or not Game.gameServices then
		return false
	end
	local achievementId
	if isAndroid() then
		achievementId = Game.achievements[name].playGameServicesId
	else
		achievementId = Game.achievements[name].appStoreId
	end
	if not achievementId then
		return false
	end
	gameNetwork.request("unlockAchievement", {
		achievement = {
			identifier = achievementId,
			percentComplete = 100,
			showsCompletionBanner = false
		},
		listener = achievementRequestCallback
	})
	return true
end
function GameServices.synchronizeAchievements()
	if not GameServices.loggedIn or not Game.gameServices then
		return false
	end
	for key, achievement in pairs(Game.achievements) do
		if achievement.unlocked then
			GameServices.unlockAchievement(key)
		end
	end
end
function GameServices.showAchievements()
	if not GameServices.loggedIn or not Game.gameServices then
		return false
	end
	gameNetwork.show("achievements")
	return true
end
return GameServices
