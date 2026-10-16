local JackpotProtocol = require("net.JackpotProtocol")
local OnlineJackpots = {
	ip = "127.0.0.1", -- Original Hawk Games backend (defunct)
	port = 7259,
	roomType = 1,
	initialized = false,
	checked = false,
	internalChecked = false
}
function OnlineJackpots.enter(successCallback)
	composer.gotoScene("scenes.jackpot")
	if successCallback then
		successCallback()
	end
end
function OnlineJackpots.init()
	if OnlineJackpots.initialized then
		return
	end
	OnlineJackpots.initialized = true
	OnlineJackpots.registerCallbacks()
end
function OnlineJackpots.isConnected()
	return JackpotProtocol.connection:isActive()
end
function OnlineJackpots.registerCallbacks()
	JackpotProtocol.registerOnCloseEvent(function()
		composer.gotoScene("scenes.nethub.nethub")
		GUI.showMessageBox(Lang.common.connectionError, Lang.onlineJackpots.disconnectMessage .. ".")
	end)
	JackpotProtocol.registerCallback(IncomingJackpotPacket.timeChange, function(newTime)
		if not OnlineJackpots.room then
			return false
		end
		OnlineJackpots.room.endTime = newTime
		return true
	end)
	JackpotProtocol.registerCallback(IncomingJackpotPacket.shutdown, function()
		composer.gotoScene("scenes.nethub.nethub")
		if OnlineJackpots.room and OnlineJackpots.playerItems and #OnlineJackpots.playerItems > 0 and not OnlineJackpots.checked then
			local items = OnlineJackpots.playerItems
			for _, item in ipairs(items) do
				Game.addItem(item, false, item.statTrak, false, {
					pattern = item.pattern,
					name = item.n,
					quality = item.quality,
					stickers = item.stickers,
					highlight = true,
					disableAchievements = true,
					disableMissions = true
				})
			end
			if hideTextInput then
				hideTextInput()
			end
			composer.showOverlay("scenes.itemlist", {
				params = {
					firstText = Lang.onlineJackpots.serverIsGoingDown,
					secondText = Lang.onlineJackpots.itemsReturned .. ":",
					items = items
				}
			})
			return
		end
		OnlineJackpots.disconnect()
		GUI.showMessageBox(Lang.common.information, Lang.onlineJackpots.serverIsGoingDownMessage .. ".")
		return true
	end)
	JackpotProtocol.registerCallback(IncomingJackpotPacket.itemsAdd, function(player, items)
		if not OnlineJackpots.room or not OnlineJackpots.room.players then
			return false
		end
		if not OnlineJackpots.room.players[player.id] then
			OnlineJackpots.room.players[player.id] = player
		end
		OnlineJackpots.internalAddItems(items)
	end)
	JackpotProtocol.registerCallback(IncomingJackpotPacket.newItems, function(items)
		for _, item in ipairs(items) do
			Game.addItem(item, false, item.statTrak, false, {
				pattern = item.pattern,
				quality = item.quality,
				stickers = item.stickers,
				highlight = true,
				disableAchievements = true,
				disableMissions = true
			})
		end
		if composer.getSceneName("current") ~= "scenes.jackpots.roomselection" then
			return
		end
		hideTextInput()
		composer.showOverlay("scenes.itemlist", {
			params = {
				firstText = Lang.onlineJackpots.jackpotWon .. "!",
				secondText = Lang.onlineJackpots.newItems .. ":",
				items = items,
				okButtonCallback = function()
					showTextInput()
				end
			}
		})
	end)
	JackpotProtocol.registerCallback(IncomingJackpotPacket.disconnect, function(message)
		JackpotProtocol.connection.onCloseCallback = nil
		composer.gotoScene("scenes.nethub.nethub")
		GUI.showMessageBox(Lang.common.error, message)
	end)
end
function OnlineJackpots.connect()
	OnlineJackpots.registerCallbacks()
	return JackpotProtocol.init(OnlineJackpots.ip, OnlineJackpots.port)
end
function OnlineJackpots.login(loginCallback)
	JackpotProtocol.registerCallback(IncomingJackpotPacket.login, function(success, playerId, serverTimestamp, roomTypes, message)
		if success then
			OnlineJackpots.playerId = playerId
			OnlineJackpots.roomTypes = roomTypes
			OnlineJackpots.timeDiff = serverTimestamp + 1 - os.time()
		else
			JackpotProtocol.registerOnCloseEvent(nil)
		end
		loginCallback(success, roomTypes, message)
	end)
	JackpotProtocol.login()
end
function OnlineJackpots.joinRoom(roomType, joinCallback)
	JackpotProtocol.registerCallback(IncomingJackpotPacket.join, function(success, str, roomData)
		if success then
			OnlineJackpots.setRoom(roomData)
		end
		joinCallback(success, str)
	end)
	JackpotProtocol.joinRoom(roomType)
end
function OnlineJackpots.addItems(items)
	local itemTable = {}
	for _, eqId in ipairs(items) do
		local eqItem = Game.equipment[eqId]
		table.insert(itemTable, {
			pattern = eqItem.pattern,
			n = eqItem.n,
			id = eqItem.id,
			stickers = eqItem.stickers,
			statTrak = eqItem.statTrak,
			quality = eqItem.quality,
			player = OnlineJackpots.playerId,
			type = Item.skin
		})
	end
	JackpotProtocol.registerCallback(IncomingJackpotPacket.success, function(success, msg)
		if success then
			OnlineJackpots.internalAddItems(itemTable)
		else
			EquipmentManager.returnItems(itemTable)
			GUI.showMessageBox(Lang.common.error, msg)
		end
		JackpotProtocol.removeCallback(IncomingJackpotPacket.success)
	end)
	JackpotProtocol.addItems(items)
	EquipmentManager.removeItems(items)
end
function OnlineJackpots.setItemsAddCallback(callback)
	OnlineJackpots.itemsAddCallback = callback
end
function OnlineJackpots.addItem(item)
	local localItem = {
		pattern = item.pattern,
		n = item.n,
		id = item.id,
		type = Item.skin,
		stickers = item.stickers,
		statTrak = item.statTrak,
		quality = item.quality,
		player = item.player
	}
	local itemPrice = Game.getItemPrice(localItem)
	if item.player == OnlineJackpots.playerId then
		table.insert(OnlineJackpots.playerItems, localItem)
		OnlineJackpots.playerItemsWorth = OnlineJackpots.playerItemsWorth + itemPrice
	else
		table.insert(OnlineJackpots.otherItems, localItem)
	end
	if not OnlineJackpots.playingPlayers[item.player] then
		OnlineJackpots.playingPlayers[item.player] = true
		OnlineJackpots.playingPlayersCount = OnlineJackpots.playingPlayersCount + 1
	end
	table.insert(OnlineJackpots.items, localItem)
	OnlineJackpots.totalWorth = OnlineJackpots.totalWorth + itemPrice
	OnlineJackpots.winChance = math.floor(OnlineJackpots.playerItemsWorth / OnlineJackpots.totalWorth * 10000) / 100
end
function OnlineJackpots.getWinner()
	return OnlineJackpots.room.players[OnlineJackpots.winner]
end
function OnlineJackpots.internalAddItems(items)
	for _, item in ipairs(items) do
		OnlineJackpots.addItem(item)
	end
	if OnlineJackpots.itemsAddCallback then
		OnlineJackpots.itemsAddCallback(items)
	end
end
function OnlineJackpots.updateVariables()
	OnlineJackpots.playerItems = {}
	OnlineJackpots.otherItems = {}
	OnlineJackpots.items = {}
	OnlineJackpots.playingPlayersCount = 0
	OnlineJackpots.totalWorth = 0
	OnlineJackpots.playerItemsWorth = 0
	OnlineJackpots.playingPlayers = {}
	for _, item in ipairs(OnlineJackpots.room.items) do
		OnlineJackpots.addItem(item)
	end
	if OnlineJackpots.totalWorth == 0 then
		OnlineJackpots.winChance = 0
	else
		OnlineJackpots.winChance = math.floor(OnlineJackpots.playerItemsWorth / OnlineJackpots.totalWorth * 10000) / 100
	end
end
function OnlineJackpots.registerJackpotEndCallback()
	JackpotProtocol.registerCallback(IncomingJackpotPacket.jackpotEnd, function(winner)
		if not OnlineJackpots.room then
			return false
		end
		OnlineJackpots.winner = winner
		return true
	end)
end
function OnlineJackpots.postDraw(win)
	Game.save()
end
function OnlineJackpots.check()
	if not OnlineJackpots.winner or OnlineJackpots.internalChecked then
		return
	end
	OnlineJackpots.internalChecked = true
	local playerWon = false
	if OnlineJackpots.winner == OnlineJackpots.playerId then
		playerWon = true
		Analytics.addEvent("Online Jackpot:Win")
	else
		Analytics.addEvent("Online Jackpot:Lose")
	end
	Game.lastDrawParams = {
		jackpotDraw = true,
		onlineJackpotDraw = true,
		win = playerWon,
		okButtonCallback = function()
			RandomSkins.hide()
			composer.gotoScene("scenes.jackpots.roomselection")
		end,
		postDrawCallback = function()
			OnlineJackpots.postDraw(playerWon)
		end
	}
	composer.gotoScene("scenes.draw", {
		effect = "fade",
		time = 0,
		params = {
			jackpotDraw = true,
			onlineJackpotDraw = true,
			win = playerWon,
			okButtonCallback = function()
				RandomSkins.hide()
				composer.gotoScene("scenes.jackpots.roomselection")
			end,
			postDrawCallback = function()
				OnlineJackpots.postDraw(playerWon)
			end
		}
	})
	if 0 < #OnlineJackpots.playerItems then
		StatisticManager.addStatistic("onlineJackpotsPlayed")
	end
	if playerWon then
		StatisticManager.addStatistic("onlineJackpotsWon")
		for _, item in ipairs(OnlineJackpots.playerItems) do
			Game.addItem(item, false, item.statTrak, false, {
				pattern = item.pattern,
				stickers = item.stickers,
				name = item.n,
				quality = item.quality,
				highlight = false,
				disableAchievements = true,
				disableMissions = true
			})
		end
		for _, item in ipairs(OnlineJackpots.otherItems) do
			StatisticManager.addStatistic("moneyWonInOnlineJackpots", Game.getItemPrice(item))
			Game.addItem(item, false, item.statTrak, false, {
				pattern = item.pattern,
				stickers = item.stickers,
				name = item.n,
				quality = item.quality,
				disableAchievements = true,
				disableMissions = true
			})
		end
	else
		if 0 < #OnlineJackpots.playerItems then
			StatisticManager.addStatistic("onlineJackpotsLost")
		end
		for _, item in ipairs(OnlineJackpots.playerItems) do
			StatisticManager.addStatistic("moneyLostInOnlineJackpots", Game.getItemPrice(item))
		end
	end
	Game.recalculateEquipmentWorth()
	function OnlineJackpots.okButtonCallback()
		OnlineJackpots.internalChecked = false
		OnlineJackpots.checked = true
		composer.gotoScene("scenes.jackpots.jackpot")
		if playerWon then
			local itemList = {}
			for _, item in ipairs(OnlineJackpots.items) do
				if item.id == Skin.M4A4_howl and item.type == Item.skin then
					Game.unlockAchievement("The Howl is Mine!")
				end
				table.insert(itemList, item)
			end
			table.sort(itemList, function(a, b)
				return Game.getItemPrice(a) > Game.getItemPrice(b)
			end)
			composer.showOverlay("scenes.itemlist", {
				params = {
					firstText = Lang.onlineJackpots.jackpotWon .. "!",
					secondText = Lang.onlineJackpots.newItems .. ":",
					items = itemList
				}
			})
		end
	end
end
function OnlineJackpots.setRoom(room)
	OnlineJackpots.room = room
	OnlineJackpots.updateVariables()
end
function OnlineJackpots.getWinChance(playerId)
	if playerId then
		local totalWorth = 0
		for _, item in ipairs(OnlineJackpots.items) do
			if item.player == playerId then
				totalWorth = totalWorth + Game.getItemPrice(item)
			end
		end
		if totalWorth == 0 then
			return 0
		else
			return math.floor(totalWorth / OnlineJackpots.totalWorth * 10000) / 100
		end
	else
		return OnlineJackpots.winChance
	end
end
function OnlineJackpots.getItemLimit()
	return OnlineJackpots.room.itemLimit
end
function OnlineJackpots.getPlayerItems()
	return OnlineJackpots.playerItems
end
function OnlineJackpots.getItemsWorth(playerItems)
	if playerItems then
		return OnlineJackpots.playerItemsWorth
	else
		return OnlineJackpots.totalWorth
	end
end
function OnlineJackpots.getPlayersOnline()
	return tableLength(OnlineJackpots.room.players)
end
function OnlineJackpots.getPlayingPlayers()
	return OnlineJackpots.playingPlayersCount
end
function OnlineJackpots.getTimeLeft()
	return math.max(0, OnlineJackpots.room.endTime - os.time() - OnlineJackpots.timeDiff + 3)
end
function OnlineJackpots.getItemCount()
	return #OnlineJackpots.items
end
function OnlineJackpots.disconnect()
	JackpotProtocol.disconnect()
end
function OnlineJackpots.exitRoom()
	JackpotProtocol.exitRoom(OnlineJackpots.room.uid)
end
return OnlineJackpots
