local ADS = {
	cache = {lastSave = 0, adAvailable = false}
}
local ad = require("ads")
local availableAd, rewardFunc, appLovin, unityAds
local providers = {
	vungle = false,
	appLovin = false,
	admob = false,
	unityAds = false
}
function ADS.vungleAdListener(event)
	return true
end
function ADS.admobAdListener(event)
	if event.phase == "shown" then
		if rewardFunc then
			rewardFunc()
			rewardFunc = nil
		end
		Game.others.lastAdWatch = os.time()
	end
end
function ADS.appLovinAdListener(event)
	if event.phase == "displayed" then
		if rewardFunc then
			rewardFunc()
			rewardFunc = nil
		end
		Game.others.lastAdWatch = os.time()
		print("AD displayed")
	end
end
function ADS.unityAdsAdListener(event)
	if event.phase == "completed" then
		if rewardFunc then
			rewardFunc()
			rewardFunc = nil
		end
		Game.others.lastAdWatch = os.time()
		print("AD displayed")
	end
	return true
end
function ADS.init(providerTable)
	if not isMobile() then
		return false
	end
	for i = 1, #providerTable do
		if providerTable[i] == AdProvider.vungle then
			providers.vungle = true
		elseif providerTable[i] == AdProvider.appLovin then
			providers.appLovin = true
		elseif providerTable[i] == AdProvider.admob then
			providers.admob = true
		elseif providerTable[i] == AdProvider.unityAds then
			providers.unityAds = true
		end
	end
	if providers.admob then
		if isAndroid() then
			ad.init("admob", "ca-app-pub-1241820889739638/3252518306", ADS.admobAdListener)
		else
			ad.init("admob", "ca-app-pub-1241820889739638/9286069100", ADS.admobAdListener)
		end
	end
	if providers.appLovin then
		appLovin = require("plugin.applovin")
		appLovin.init(ADS.appLovinAdListener, {
			sdkKey = "p0LvONAhKtRTw2-B45E7scMfoZOr420t3LnRky82pZWkbVvga8pQl95XkUMoXMfahR0PO8SBizwJSp-2yoThyT",
			verboseLogging = false
		})
	end
	if providers.unityAds then
		unityAds = require("plugin.unityads")
		local gameId = "1278767"
		if isAndroid() then
			gameId = "1278768"
		end
		unityAds.init(ADS.unityAdsAdListener, {gameId = gameId})
	end
	if providers.vungle then
		if isAndroid() then
			ad.init("vungle", "5569b8727aa76b575d0000a1", ADS.vungleAdListener)
		else
			ad.init("vungle", "HXJRVKU3BE.com.hawkgames.caseclicker", ADS.vungleAdListener)
		end
	end
end
function ADS.load()
	if not isMobile() then
		return false
	end
	if providers.appLovin then
		if not appLovin.isLoaded("interstitial") then
			appLovin.load("interstitial")
		else
			return true
		end
	end
	if providers.admob then
		ad:setCurrentProvider("admob")
		if not ad.isLoaded("interstitial") then
			print("Loading AdMob ad...")
			ad.load("interstitial", {testMode = false})
		else
			print("AdMob ad loaded.")
		end
	end
end
function ADS.isAvailable(cacheLoad)
	if not isMobile() then
		return true
	end
	if cacheLoad and system.getTimer() - ADS.cache.lastSave < 200 then
		print("Getting from cache: " .. system.getTimer() - ADS.cache.lastSave)
		return ADS.cache.adAvailable
	end
	ADS.cache.lastSave = system.getTimer()
	if providers.appLovin and appLovin.isLoaded("interstitial") then
		availableAd = AdProvider.appLovin
		ADS.cache.adAvailable = true
		return true
	end
	if providers.vungle then
		ad:setCurrentProvider("vungle")
		if ad.isAdAvailable() then
			availableAd = AdProvider.vungle
			ADS.cache.adAvailable = true
			return true
		end
	end
	if providers.admob then
		ad:setCurrentProvider("admob")
		if ad.isLoaded("interstitial") then
			availableAd = AdProvider.admob
			ADS.cache.adAvailable = true
			return true
		end
	end
	availableAd = nil
	ADS.cache.adAvailable = false
	return false
end
function ADS.showVungleAd()
	if not providers.vungle then
		return false
	end
	ad:setCurrentProvider("vungle")
	if not ad.isAdAvailable() then
		return false
	end
	ad.show("interstitial", {isBackButtonEnabled = true})
	Game.others.lastAdWatch = os.time()
	return true
end
function ADS.showAdMobAd()
	if not providers.admob then
		return false
	end
	ad:setCurrentProvider("admob")
	if not ad.isLoaded("interstitial") then
		return false
	end
	ad.show("interstitial", {testMode = false})
	Game.others.lastAdWatch = os.time()
	return true
end
function ADS.removeRewardFunction()
	rewardFunc = nil
end
function ADS.showAd(rewardFunction)
	rewardFunc = rewardFunction
	if not isMobile() then
		timer.performWithDelay(300, function()
			if rewardFunc then
				rewardFunc()
				rewardFunc = nil
				Game.others.lastAdWatch = os.time()
				StatisticManager.addStatistic("watchedAds")
			end
		end)
		return true
	end
	if not availableAd then
		return false
	end
	if unityAds and unityAds.isLoaded("rewardedVideo") then
		print("Showing UnityAds AD...")
		unityAds.show("rewardedVideo")
		StatisticManager.addStatistic("watchedAds")
		Analytics.addEvent("Ad Watch:UnityADS")
		return true
	end
	if availableAd == AdProvider.appLovin then
		print("Showing AppLovin AD...")
		appLovin.show("interstitial")
		StatisticManager.addStatistic("watchedAds")
		Analytics.addEvent("Ad Watch:Applovin")
		return true
	end
	if availableAd == AdProvider.vungle then
		print("Showing Vungle AD...")
		ad:setCurrentProvider("vungle")
		ad.show("interstitial", {isBackButtonEnabled = false})
		Analytics.addEvent("Ad Watch:Vungle")
		timer.performWithDelay(1500, function()
			if rewardFunc then
				rewardFunc()
				rewardFunc = nil
				Game.others.lastAdWatch = os.time()
				StatisticManager.addStatistic("watchedAds")
			end
		end)
		return true
	end
	if providers.admob and availableAd == AdProvider.admob then
		print("Showing AdMob AD...")
		ad:setCurrentProvider("admob")
		ad.show("interstitial", {testMode = false})
		StatisticManager.addStatistic("watchedAds")
		Analytics.addEvent("Ad Watch:AdMob")
		return true
	end
end
return ADS
