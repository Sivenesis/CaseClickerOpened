local Upgrades = {}
function Upgrades.unlockNewUpgrades()
	local moneyClicks = StatisticManager.getStatistic("moneyClicks")
	if 10000 <= moneyClicks then
		Game.unlockUpgrade("Golden Tap Power I")
	end
	if 50000 <= moneyClicks then
		Game.unlockUpgrade("Golden Tap Power II")
	end
	if 100000 <= moneyClicks then
		Game.unlockUpgrade("Golden Tap Power III")
	end
	if 200000 <= moneyClicks then
		Game.unlockUpgrade("Golden Tap Power IV")
	end
	if 350000 <= moneyClicks then
		Game.unlockUpgrade("Golden Tap Power V")
	end
	if 500000 <= moneyClicks then
		Game.unlockUpgrade("Golden Tap Power VI")
	end
	if Game.isUpgradeBought("Golden Offline Income IV") then
		Game.unlockUpgrade("Golden Offline Income V")
	end
	if Game.isUpgradeBought("Golden Offline Income VI") then
		Game.unlockUpgrade("Golden Offline Income VII")
	end
	if Game.isUpgradeBought("Trades") then
		Game.unlockUpgrade("Match Betting")
	end
	if Game.isUpgradeBought("Satellite IV") then
		Game.unlockUpgrade("Satellite V")
	end
end
function Upgrades.getBoughtUpgradesCount()
	local count = 0
	for _, upgrade in pairs(Game.upgrades) do
		if upgrade.bought then
			count = count + 1
		end
	end
	return count
end
function Upgrades.getUnlockedUpgradesCount()
	local count = 0
	for _, upgrade in pairs(Game.upgrades) do
		if upgrade.unlocked then
			count = count + 1
		end
	end
	return count
end
function Upgrades.securityCheck()
	-- Bypassed for PC release & developer testing
end
return Upgrades
