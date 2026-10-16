-- Case Clicker PC-Windows Community Edition
-- Set up stubs package path for desktop compatibility
package.path = "./stubs/?.lua;./stubs/?/init.lua;" .. package.path

audio = require("audio")
if audio.supportsSessionProperty == true then
	audio.setSessionProperty(audio.MixMode, audio.AmbientMixMode)
end
require("functions")
require("constants")
ColorTools = require("tools.ColorTools")
PonyFont = require("tools.PonyFont")
require("tools.Animation")
Language = require("language")
Language.init()
require("game")
media = require("media")
widget = require("widget")
native = require("native")
composer = require("composer")
transition = require("transition")
graphics = require("graphics")
QualityManager = require("Quality")
json = require("json")
LoadSave = require("tools.loadsave")
system = require("system")
StatisticManager = require("managers.StatisticManager")
AchievementManager = require("managers.AchievementManager")
MissionManager = require("managers.MissionManager")
ContainerManager = require("managers.ContainerManager")
GUI = require("gui.gui")
Menu = require("gui.menu")
FontOffset = require("tools.FontOffset")
ADS = require("adverts")
NetHub = require("online.nethub")
Jackpot = require("jackpot")
RandomSkins = require("randomskins")
CloudSave = require("online.cloudsave")
GameServices = require("GameServices")
Stickers = require("Stickers")
ItemView = require("classes.ItemView")
if Game.microPayments then
	MicroPayments = require("micropayments")
end
if Game.betSystem then
	Bets = require("online.betsystem")
end
OnlineJackpots = require("online.onlinejackpots")
Raffles = require("online.raffles")
EquipmentManager = require("managers.EquipmentManager")
Upgrades = require("Upgrades")
GameInit = require("gameinit")
Analytics = require("Analytics")
if isAndroid() or isIOS() then
	facebook = require("plugin.facebook.v4a")
	facebook.init(function()
		facebook.publishInstall()
	end)
end
FontOffset.addOffset(40, "simulator", 102, 19, 16)
FontOffset.addOffset(40, "android", 194, 64, 45)
FontOffset.addOffset(120, "ios", 40, 0, 4)
local checkOfflineIncome = function()
	if Game.moneyPerSecond == 0 then
		return
	end
	if os.time() - Game.others.saveTime >= 300 then
		composer.showOverlay("overlays.offlineincome", {
			isModal = true,
			params = {}
		})
	end
end
local onlineJackpotScenes = {
	["scenes.jackpots.itemselection"] = "scenes.nethub.nethub",
	["scenes.jackpots.jackpot"] = "scenes.nethub.nethub",
	["scenes.jackpots.roomselection"] = "scenes.nethub.nethub"
}
local function onSystemEvent(event)
	if event.type == "applicationSuspend" or event.type == "applicationExit" then
		Game.save()
		GameServices.sendHighscores()
	end
	if event.type == "applicationResume" then
		if onlineJackpotScenes[composer.getSceneName("current")] then
			composer.gotoScene("scenes.nethub.nethub")
			GUI.showMessageBox("Error", "Disconnected from online jackpot server.")
			OnlineJackpots.disconnect()
		end
		checkOfflineIncome()
	end
end
local onSystemError = function(error)
	local currentScene = tostring(composer.getSceneName("current") or "unknown")
	local errorMsg = tostring(error.errorMessage or "unknown error")
	local stackTrace = tostring(error.stackTrace or "No stacktrace")
	local fullLog = string.format("[%s] Scene: %s | Error: %s\nStack:\n%s\n\n", os.date("%Y-%m-%d %H:%M:%S"), currentScene, errorMsg, stackTrace)
	print("FATAL ERROR: " .. fullLog)
	local f = io.open("error.log", "a")
	if f then
		f:write(fullLog)
		f:close()
	end
	Analytics.addError((Game.version or "???") .. " | " .. currentScene .. " | " .. errorMsg .. " | " .. stackTrace)
	GUI.showMessageBox("Error!", "Error :(")
	return true
end
local onTouch = function(event)
	if GUI.holdTimer then
		timer.cancel(GUI.holdTimer)
		GUI.holdTimer = nil
	end
end
local setDefaults = function()
	display.setDefault("anchorX", 0)
	display.setDefault("anchorY", 0)
	system.setIdleTimer(false)
	display.setStatusBar(display.HiddenStatusBar)
end
local securityCheck = function()
	-- Anti-tamper checks bypassed for PC release & developer testing
	return
end
local antiCheat = function()
	-- Anti-cheat checks bypassed for PC release & developer testing
	return false
end
function onStart()
	math.randomseed(os.time())
	setDefaults()
	GameInit.init()
	if Game.microPayments then
		MicroPayments.init()
	end
	Menu.init()
	Game.loadDefaults()
	Game.load()
	GameInit.postLoadInit()
	Menu.tryToUnlockItems()
	GUI.createBackground()
	Analytics.init()
	local adProviders = {
		AdProvider.appLovin,
		AdProvider.unityAds,
		AdProvider.vungle
	}
	ADS.init(adProviders)
	ADS.load()
	timer.performWithDelay(30000, ADS.load, -1)
	Runtime:addEventListener("system", onSystemEvent)
	Runtime:addEventListener("touch", onTouch)
	Runtime:addEventListener("unhandledError", onSystemError)

	-- Developer / Debug Menu Hotkey Listener (F1, F12, ~)
	local function onGlobalKeyEvent(event)
		if event.phase == "up" then
			local k = event.keyName
			if k == "f1" or k == "f12" or k == "`" or k == "~" or k == "grave" then
				if composer.getSceneName("overlay") == "overlays.devmenu" then
					composer.hideOverlay("fade", 150)
				else
					composer.showOverlay("overlays.devmenu", {
						isModal = true,
						params = {}
					})
				end
				return true
			end
		end
		return false
	end
	Runtime:addEventListener("key", onGlobalKeyEvent)
	Game.recalculateEquipmentWorth()
	EquipmentManager.sortItems()
	timer.performWithDelay(1000, Game.gainMoney, -1)
	timer.performWithDelay(100000, function()
		Game.save(true)
	end, -1)
	if Game.gameServices then
		timer.performWithDelay(10000, function()
			GameServices.sendHighscores()
		end)
		timer.performWithDelay(300000, function()
			GameServices.sendHighscores()
		end, -1)
	end
	composer.gotoScene("scenes.main")
	if Game.others.lastDailyRewardd ~= tonumber(os.date("%d")) then
		Menu.addAlert("Dailies")
	end
	if Game.others.lastDailyRewardd2 ~= tonumber(os.date("%d")) then
		Menu.addAlert("Dailies")
	end
	if Game.others.expRankRewardsAvailable > 0 then
		Menu.addAlert("Missions")
	end
	Menu.showRank()
	if not Game.testMode then
		checkOfflineIncome()
	end
	securityCheck()
	timer.performWithDelay(1500, antiCheat)
	Menu.updateBalanceText()
	NetHub.init()
	if Game.gameServices then
		GameServices.init()
	end
	Upgrades.securityCheck()
	Menu.updateLanguageTexts()
	if Game.beta then
		for i = 1, #Game.betaUpgrades do
			Game.buyUpgrade(Game.betaUpgrades[i], true)
		end
	end
	if Game.screenMode then
		Game.screenModeFunction()
	end
end

onStart()
