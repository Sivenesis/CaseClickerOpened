local network = require("network")
local CloudSave = {
	version = 1,
	server = "http://127.0.0.1:8080/cloud/" -- Original Hawk Games backend (defunct)
}
local func
local function networkListener(event)
	if event.isError then
		if func then
			func(false, {
				text = Lang.common.connectionError .. "."
			})
			func = nil
		end
		return
	end
	local response = json.decode(event.response)
	if not response then
		if func then
			func(false)
			func = nil
		end
		return
	end
	if func then
		func(true, response)
		func = nil
	end
end
local function getPlayerID()
	local playerID = ""
	if isAndroid() then
		playerID = playerID .. "f"
	else
		playerID = playerID .. "i"
	end
	if isAndroid() then
		playerID = playerID .. (CloudSave.fbToken or "")
	else
		playerID = playerID .. (GameServices.player.id or "")
	end
	return playerID
end
local loadCallback = function(success, response)
	if not success or response and response.error then
		local text = Lang.cloudSave.couldNotLoadGame .. "."
		if response and response.text then
			text = response.text
		end
		return GUI.showMessageBox(Lang.common.error, text)
	end
	Game.loadDefaults()
	Game.load({data = response})
	Game.others.netId = "0"
	NetHub.reset()
	Menu.tryToUnlockItems()
	Menu.refreshItems()
	Menu.showRank()
	GameInit.postLoadInit()
	return GUI.showMessageBox(Lang.common.success, Lang.cloudSave.gameLoaded .. ".")
end
local function saveCallback(success, response)
	if not success or response and response.error then
		local text = Lang.cloudSave.couldNotSaveGame .. "."
		if response and response.text then
			text = response.text
		end
		return GUI.showMessageBox(Lang.common.error, text)
	end
	return GUI.showMessageBox(Lang.common.success, response.text or Lang.cloudSave.gameSavedSuccessfully .. " (" .. getPlayerID() .. ").")
end
local getServicesName = function()
	if isAndroid() then
		return "Google Play Games"
	end
	return "Game Center"
end
function CloudSave.load()
	func = loadCallback
	local URL = CloudSave.server .. "load/" .. getPlayerID()
	network.request(URL, "POST", networkListener)
	Analytics.addEvent("Cloud Save:Load")
end
function CloudSave.save()
	local URL = CloudSave.server .. "save/" .. getPlayerID()
	if isIOS() then
		if not GameServices.player.id and not Game.testMode then
			return GUI.showMessageBox(Lang.common.error, Lang.cloudSave.couldNotSaveGame2:gsub("{1}", getServicesName()) .. ".")
		end
	elseif not CloudSave.fbToken then
		return GUI.showMessageBox(Lang.common.error, Lang.cloudSave.couldNotSaveGame2:gsub("{1}", "Facebook"))
	end
	func = saveCallback
	Game.save(false, {filename = "cloud.dat", cloudSave = true})
	network.upload(URL, "POST", networkListener, "cloud.dat", system.DocumentsDirectory, "text/plain")
	Analytics.addEvent("Cloud Save:Save")
end
return CloudSave
