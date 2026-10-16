local Market = {
	server = "offline",
	offers = {},
	lastOfferAdd = 0,
	lastRefresh = 0
}

Market.offerValidator = {
	minLength = 6,
	maxLength = 100,
	regex = "[A-Za-z0-9-. !_:?,+]+"
}

local BOT_OFFERS = {
	{ name = "CS_Trader_99", offering = "AK-47 | Redline (Field-Tested)", receiving = "$14.50 or AWP Sun in Leo" },
	{ name = "Karambit_God", offering = "Karambit | Doppler (Factory New)", receiving = "Knife upgrade or high-tier Covert items" },
	{ name = "Sticker_Craftsman", offering = "M4A1-S | Guardian (Titan Katowice 2014)", receiving = "$45.00 or AK-47 Vulcan" },
	{ name = "DragonLoreFan", offering = "AWP | Asiimov (Field-Tested)", receiving = "M4A4 Asiimov or $38.00" },
	{ name = "xX_Sniper_Xx", offering = "SSG 08 | Blood in the Water (MW)", receiving = "$24.00 or 10 Case Keys" },
	{ name = "CobblestoneKing", offering = "Cobblestone Souvenir Package", receiving = "Rare Knife or Covert AWP" },
	{ name = "TradeFastMen", offering = "5x Operation Bravo Case Keys", receiving = "Any $15.00+ skin (Fast Accept)" },
	{ name = "CaseHardenedBlue", offering = "AK-47 | Case Hardened (Tier 2 Blue Gem)", receiving = "$65.00 or Flip Knife Fade" },
	{ name = "Gabe_Follower", offering = "Desert Eagle | Blaze (Factory New)", receiving = "M4A1-S Icarus Fell or $85.00" },
	{ name = "Global_Elite_88", offering = "StatTrak USP-S | Kill Confirmed (FT)", receiving = "$55.00 or Trade Up Skins" }
}

local function ensureMarketOffers()
	Game.others.offlineMarketOffers = Game.others.offlineMarketOffers or {}
	if #Game.others.offlineMarketOffers == 0 then
		for i = 1, #BOT_OFFERS do
			local b = BOT_OFFERS[i]
			table.insert(Game.others.offlineMarketOffers, {
				name = b.name,
				offering = b.offering,
				receiving = b.receiving,
				created = os.time() - (i * 900)
			})
		end
		Game.save()
	end
	Market.offers = Game.others.offlineMarketOffers
end

function Market.canAddOffer()
	return os.time() - Market.lastOfferAdd > 60
end

function Market.getOfferPrice()
	return 5 + Game.rank * 1
end

function Market.get(callback, force, silent)
	ensureMarketOffers()
	Market.lastRefresh = os.time()
	timer.performWithDelay(50, function()
		if callback then callback(true) end
	end)
end

function Market.addOffer(data, callback)
	ensureMarketOffers()
	local newOffer = {
		name = Game.others.netNick or "Player",
		offering = data.offering or "",
		receiving = data.receiving or "",
		created = os.time()
	}
	table.insert(Game.others.offlineMarketOffers, 1, newOffer)
	Market.lastOfferAdd = os.time()
	NetHub.marketOffersSinceLogin = NetHub.marketOffersSinceLogin + 1
	Market.offers = Game.others.offlineMarketOffers
	Game.save()

	timer.performWithDelay(50, function()
		if callback then callback(true) end
	end)
end

return Market
