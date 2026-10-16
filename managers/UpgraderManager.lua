local UpgraderManager = {}
local OnlineTime = require("tools.OnlineTime")
local selectedItem, upgradedItem
local upgradeCosts = {
	2,
	4,
	5,
	10,
	15,
	20,
	25,
	30,
	35,
	50,
	75,
	100,
	125,
	150,
	200,
	250,
	500,
	750,
	1000
}
function UpgraderManager.selectItem(itemId)
	upgradedItem = nil
	selectedItem = itemId
end
function UpgraderManager.getSelectedItem()
	return Game.equipment[selectedItem]
end
function UpgraderManager.deselectItem()
	selectedItem = nil
	upgradedItem = nil
end
function UpgraderManager.getUpgradedItem()
	return upgradedItem
end
function UpgraderManager.canUpgrade()
	if Game.money < UpgraderManager.getNextUpgradeCost() then
		return false
	end
	if not UpgraderManager.getSelectedItem() then
		return false
	end
	return true
end
function UpgraderManager.getNextUpgradeCost()
	local upgradeNumber = Game.others.uN
	if upgradeNumber < 1 then
		upgradeNumber = 1
	elseif upgradeNumber > #upgradeCosts then
		upgradeNumber = #upgradeCosts
	end
	return upgradeCosts[upgradeNumber]
end
function UpgraderManager.getCosResetTimeLeft(callback)
	OnlineTime.get(function(success, time)
		if not success then
			return callback(false)
		end
		local day = math.floor(time / 86400)
		if day ~= Game.others.uLD then
			Game.others.uLD = day
			Game.others.uN = 0
		end
		local nextDay = (day + 1) * 86400
		return callback(true, getRemainingTimeString(nextDay, time):gsub(" left", ""))
	end, 30)
end
function UpgraderManager.getMaxSelectedItemPrice()
	return 400
end
function UpgraderManager.getSelectedItemPrice()
	if not selectedItem or not Game.equipment[selectedItem] then
		return nil
	end
	return Game.getPrice(Game.equipment[selectedItem])
end
function UpgraderManager.getUpgradedItemPrice()
	return Game.getItemPrice(upgradedItem)
end
function UpgraderManager.upgradeItem(chance, multiplier)
	local success = chance >= math.random(1, 100)
	local itemPrice = UpgraderManager.getSelectedItemPrice()
	EquipmentManager.removeItem(selectedItem)
	local newItemPrices = {
		itemPrice * multiplier * 0.9,
		itemPrice * multiplier * 1.1
	}
	if success then
		upgradedItem = EquipmentManager.getItemWithPrice(newItemPrices[1], newItemPrices[2])
		Game.addItem(upgradedItem, false, upgradedItem.statTrak, true, {
			quality = upgradedItem.quality,
			pattern = upgradedItem.pattern
		})
		StatisticManager.addStatistic("successfulUpgrades")
		Game.others.uN = Game.others.uN + 1
	else
		StatisticManager.addStatistic("failedUpgrades")
	end
	return success
end
return UpgraderManager
