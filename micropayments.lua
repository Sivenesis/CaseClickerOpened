local store = require("store")
local validator = require("MicropaymentValidator")
if store.target == "google" then
	store = require("plugin.google.iap.v3")
end
local MicroPayments = {
	restoredPurchases = 0,
	toValidate = {}
}
local productsLoaded = false
local actualProduct
local products = {
	["100bonus"] = {
		name = "Money bonus",
		androidId = "moneybonus",
		consumable = true,
		rewardFunction = function()
			Game.addMoney(500, "IAP", "Money Bonus")
			GUI.showInfoBox("Item bought:", "Money bonus", InfoBoxType.coin)
			Game.save()
		end
	},
	randomknife = {
		name = "Random Knife",
		androidId = "randomknife",
		consumable = true,
		rewardFunction = function()
			GUI.showInfoBox("Item bought:", "Random Knife", InfoBoxType.coin)
			Game.showKnifeDraw(true)
		end
	},
	randomgloves = {
		name = "Random Gloves",
		androidId = "randomgloves",
		consumable = true,
		rewardFunction = function()
			GUI.showInfoBox("Item bought:", "Random Gloves", InfoBoxType.coin)
			Game.showGloveDraw(true)
		end
	},
	["50randomcases"] = {
		name = "50 Random Cases",
		androidId = "50randomcases",
		consumable = true,
		rewardFunction = function()
			GUI.showInfoBox("Item bought:", "50 Random Cases", InfoBoxType.coin)
			for i = 1, 50 do
				Game.addItem(choose(Game.cases), false)
			end
			Menu.addAlert("Cases")
		end
	},
	mps = {
		name = "More Money per Second",
		appleId = "mps2",
		androidId = "mmps",
		consumable = true,
		rewardFunction = function()
			GUI.showInfoBox("Item bought:", "More Money per Second", InfoBoxType.coin)
			Game.moneyPerSecond = Game.moneyPerSecond + 0.025
			Game.others.mpsBought = true
			Game.save()
		end
	},
	nethub = {
		name = "NetHub",
		androidId = "nethub",
		consumable = true,
		iosConsumable = false,
		rewardFunction = function()
			GUI.showInfoBox("Item bought:", "NetHub", InfoBoxType.coin)
			Game.buyUpgrade("Trades", true)
			Game.buyUpgrade("Match Betting", true)
			Game.save()
		end
	},
	jackpots = {
		name = "Jackpots",
		androidId = "jackpots",
		consumable = true,
		iosConsumable = false,
		rewardFunction = function()
			GUI.showInfoBox("Item bought:", "Jackpots", InfoBoxType.coin)
			Game.buyUpgrade("Jackpot", true)
			Game.save()
		end
	},
	nethub2 = {
		name = "NetHub",
		androidId = "nethub",
		consumable = true,
		iosConsumable = false,
		rewardFunction = function()
			GUI.showInfoBox("Item bought:", "NetHub", InfoBoxType.coin)
			Game.buyUpgrade("Trades", true)
			Game.buyUpgrade("Match Betting", true)
			Game.save()
		end
	},
	jackpots2 = {
		name = "Jackpots",
		androidId = "jackpots",
		consumable = true,
		iosConsumable = false,
		rewardFunction = function()
			GUI.showInfoBox("Item bought:", "Jackpots", InfoBoxType.coin)
			Game.buyUpgrade("Jackpot", true)
			Game.save()
		end
	}
}
function MicroPayments.onPurchase(transaction)
	GUI.showMessageBox("Validating", "Please wait...", false)
	local product = actualProduct
	product.bought = true
	if product.consumable and isAndroid() then
		store.consumePurchase(transaction.productIdentifier, MicroPayments.listener)
		product.bought = false
	end
	if product.iosConsumable and isIOS() then
		product.bought = false
	end
	validator.validate(transaction, function(success, errorText)
		if not success then
			if connectionError then
				table.insert(MicroPayments.toValidate, {
					token = transaction.token or transaction.receipt,
					productIdentifier = transaction.productIdentifier
				})
				return GUI.showMessageBox("Error", "Connection Error")
			end
			return GUI.showMessageBox("Error", "Invalid transaction")
		end
		product.rewardFunction()
		Analytics.addInAppPurchase({
			currency = "USD",
			itemType = "IAP",
			itemId = transaction.productIdentifier or "",
			receipt = transaction.receipt or ""
		})
		if composer.getSceneName("overlay") then
			composer.hideOverlay()
		end
	end)
end
function MicroPayments.listener(event)
	if not event.transaction then
		return
	end
	local transaction = event.transaction
	if transaction.state == "failed" then
		GUI.showInfoBox("Error:", "Transaction failed.")
	elseif transaction.state == "purchased" then
		if not actualProduct then
			return false
		end
		MicroPayments.onPurchase(transaction)
	elseif transaction.state == "restored" then
		actualProduct = MicroPayments.getProductByIdentifier(event.transaction.productIdentifier)
		if isAndroid() then
			if actualProduct then
				actualProduct.rewardFunction()
				actualProduct.bought = true
				MicroPayments.restoredPurchases = MicroPayments.restoredPurchases + 1
			end
		else
			actualProduct.rewardFunction()
			actualProduct.bought = true
			MicroPayments.restoredPurchases = MicroPayments.restoredPurchases + 1
		end
	end
	if isIOS() then
		store.finishTransaction(transaction)
	end
end
function MicroPayments.getProductByIdentifier(identifier)
	if isAndroid() then
		for _, product in pairs(products) do
			if product.androidId == identifier then
				return product
			end
		end
	else
		return products[identifier]
	end
	return nil
end
function MicroPayments.restore()
	MicroPayments.restoredPurchases = 0
	GUI.showMessageBox(Lang.settings.restoringPurchases, "Please wait...", false)
	store.restore()
	timer.performWithDelay(3000, function()
		if MicroPayments.restoredPurchases == 0 then
			GUI.showMessageBox(Lang.common.success, Lang.settings.noPurchasesToRestore)
		else
			GUI.showMessageBox(Lang.common.success, Lang.settings.restoredPurchases:gsub("{1}", MicroPayments.restoredPurchases))
		end
	end)
end
local function loadGoogleProducts()
	if productsLoaded or not store.isActive then
		return
	end
	local productList = {}
	for key, val in pairs(products) do
		val.bought = false
		table.insert(productList, key)
		if val.consumable then
			store.consumePurchase(val.androidId, MicroPayments.listener)
		end
	end
	store.loadProducts(productList, MicroPayments.listener)
	productsLoaded = true
	print("Loaded...")
end
function MicroPayments.createPayment(productName)
	if isIOS() and not store.canMakePurchases then
		GUI.showMessageBox(Lang.others.purchasesDisabled, Lang.others.purchasesDisableMsg)
		return
	end
	actualProduct = products[productName]
	local name = productName
	if isIOS() then
		if actualProduct.appleId then
			name = actualProduct.appleId
		end
		store.purchase({name})
	elseif isAndroid() then
		store.purchase(actualProduct.androidId)
	end
end
function MicroPayments.canBuy(productId)
	return products[productId].bought
end
function MicroPayments.validateTransactions()
	if #MicroPayments.toValidate == 0 then
		return false
	end
	if composer.getSceneName("overlay") or composer.getSceneName("current") == "scenes.draw" then
		return false
	end
	local transaction = MicroPayments.toValidate[1]
	local product = MicroPayments.getProductByIdentifier(transaction.productIdentifier)
	validator.validate(transaction, function(success, errorText)
		if not success then
			if not connectionError then
				table.remove(MicroPayments.toValidate, 1)
			end
			return false
		end
		product.rewardFunction()
		Analytics.addInAppPurchase({
			currency = "USD",
			itemType = "IAP",
			itemId = transaction.productIdentifier or "",
			receipt = transaction.receipt or ""
		})
		table.remove(MicroPayments.toValidate, 1)
		if composer.getSceneName("overlay") then
			composer.hideOverlay()
		end
		Game.save()
	end)
	return true
end
function MicroPayments.save(saveTable)
	saveTable.micropayments = MicroPayments.toValidate
end
function MicroPayments.load(loadTable)
	if not loadTable.micropayments then
		return true
	end
	MicroPayments.toValidate = loadTable.micropayments
end
function MicroPayments.init()
	if not isMobile() then
		print("Not mobile...")
		return
	end
	if isIOS() then
		store.init("apple", MicroPayments.listener)
	else
		store.init("google", MicroPayments.listener)
		print("Google payments init...")
		timer.performWithDelay(500, function()
			loadGoogleProducts()
		end, 8)
	end
	timer.performWithDelay(12000, MicroPayments.validateTransactions)
	timer.performWithDelay(45000, MicroPayments.validateTransactions, -1)
end
return MicroPayments
