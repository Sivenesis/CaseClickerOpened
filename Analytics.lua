local Analytics = {}
local GameAnalytics = require("plugin.gameanalytics_v2")
local keys = {
	gameKey = "",
	secretKey = ""
}
local cachedResourceEvents = {
	["Main|Money Tap"] = {
		getValueToSend = function()
			return Game.clickMoneyGain * 100
		end,
		valueNotSend = 0
	},
	["Main|Money Per Second"] = {
		getValueToSend = function()
			return Game.moneyPerSecond * 240
		end,
		valueNotSend = 0
	}
}
function Analytics.configure()
	GameAnalytics.configureBuild(Game.version)
	if Game.testMode then
		GameAnalytics.setEnabledInfoLog(true)
		GameAnalytics.setEnabledVerboseLog(true)
	end
	GameAnalytics.configureAvailableResourceCurrencies({"Money", "Tickets"})
	GameAnalytics.configureAvailableResourceItemTypes({
		"Skin",
		"Sticker",
		"Glove",
		"Other",
		"Case",
		"Capsule",
		"Collection",
		"Souvenir",
		"IAP",
		"Achievement",
		"Main",
		"Promo Code",
		"Key",
		"Shop",
		"Upgrade"
	})
end
function Analytics.setProgress(status, firstValue, secondValue, thirdValue)
	GameAnalytics.addProgressionEvent({
		progressionStatus = status,
		progression01 = firstValue,
		progression02 = secondValue,
		progression03 = thirdValue
	})
end
function Analytics.addEvent(eventId, value)
	GameAnalytics.addDesignEvent({eventId = eventId, value = value})
end
function Analytics.addError(message)
	GameAnalytics.addErrorEvent({severity = "Error", message = message})
end
function Analytics.addInAppPurchase(data)
	if isIOS() then
		data.autoFetchReceipt = true
		data.receipt = nil
	end
	GameAnalytics.addBusinessEvent(data)
end
function Analytics.addResource(data)
	data.flowType = "Source"
	local cachedEvent = cachedResourceEvents[data.itemType .. "|" .. data.itemId]
	if cachedEvent then
		cachedEvent.valueNotSend = cachedEvent.valueNotSend + data.amount
		if cachedEvent.valueNotSend > cachedEvent.getValueToSend() then
			cachedEvent.valueNotSend = 0
			GameAnalytics.addResourceEvent(data)
		end
		return true
	end
	GameAnalytics.addResourceEvent(data)
end
function Analytics.removeResource(data)
	data.flowType = "Sink"
	GameAnalytics.addResourceEvent(data)
end
function Analytics.init()
	Analytics.configure()
	GameAnalytics.initialize({
		gameKey = keys.gameKey,
		gameSecret = keys.secretKey
	})
end
if isSimulator() or not isMobile() then
	local ret = {}
	for k, v in pairs(Analytics) do
		ret[k] = function()
			return true
		end
	end
	return ret
end
return Analytics
