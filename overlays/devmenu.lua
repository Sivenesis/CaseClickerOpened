local composer = require("composer")
local scene = composer.newScene()

function scene:create(event)
	local sceneGroup = self.view

	-- Modal semi-transparent backdrop
	local bg = display.newRect(sceneGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
	bg.anchorX = 0
	bg.anchorY = 0
	bg:setFillColor(0, 0, 0, 0.85)
	bg.isHitTestable = true
	bg:addEventListener("touch", function() return true end)
	bg:addEventListener("tap", function()
		composer.hideOverlay("fade", 150)
		return true
	end)

	local boxW = 1140
	local boxH = 650
	local boxX = (display.safeActualContentWidth - boxW) / 2
	local boxY = (display.safeActualContentHeight - boxH) / 2

	local mainBox = GUI.createBox(sceneGroup, boxX, boxY, boxW, boxH, "DEVELOPER / DEBUG CONSOLE")
	mainBox:setFillColor(rgb(18, 24, 34))

	-- Header / subtitle
	local subTitle = display.newText({
		parent = sceneGroup,
		x = boxX + boxW / 2,
		y = boxY + 42,
		text = "Hotkey: F1 / F12 / ~  |  Runtime Cheats & Parameter Tuning",
		font = Font.default,
		fontSize = 24,
		align = "center"
	})
	subTitle.anchorX = 0.5
	subTitle:setFillColor(0.7, 0.8, 0.95, 0.8)

	-- Status text function
	local statusText = display.newText({
		parent = sceneGroup,
		x = boxX + boxW / 2,
		y = boxY + boxH - 45,
		text = "Ready. Dev options applied in real time.",
		font = Font.default,
		fontSize = 22,
		align = "center"
	})
	statusText.anchorX = 0.5
	statusText:setFillColor(unpack(Color.gold))

	local function setStatus(msg, color)
		statusText.text = msg
		statusText:setFillColor(unpack(color or Color.gold))
	end

	-- ==========================================================
	-- COLUMN 1: System & Currency (Left side: x = boxX + 30, w = 520)
	-- ==========================================================
	local col1X = boxX + 30
	local col1W = 520

	-- 1. Test Mode Toggle
	local testModeBtn
	local function updateTestModeBtn()
		local text = "Test Mode: " .. (Game.testMode and "ENABLED" or "DISABLED")
		local btnType = Game.testMode and ButtonType.green or ButtonType.red
		if testModeBtn and testModeBtn.parent then
			testModeBtn:removeSelf()
		end
		testModeBtn = GUI.createButton(sceneGroup, col1X, boxY + 70, col1W, 55, text, btnType, function()
			Game.testMode = not Game.testMode
			updateTestModeBtn()
			setStatus("Test Mode set to: " .. (Game.testMode and "ON (Free Shop, Reveal Bombs)" or "OFF"), Game.testMode and Color.green or Color.red)
			return true
		end, 32)
	end
	updateTestModeBtn()

	-- 2. Currency Cheats Header
	local cashLabel = display.newText({
		parent = sceneGroup,
		x = col1X,
		y = boxY + 140,
		text = "ADD CASH:",
		font = Font.counterstrike,
		fontSize = 28,
		align = "left"
	})
	cashLabel.anchorX = 0
	cashLabel:setFillColor(unpack(Color.gold))

	local cashBtnW = (col1W - 24) / 4
	local amounts = { 10000, 100000, 1000000, 10000000 }
	local labels = { "+$10K", "+$100K", "+$1M", "+$10M" }
	for i = 1, 4 do
		local btnX = col1X + (i - 1) * (cashBtnW + 8)
		local amt = amounts[i]
		local bType = i <= 2 and ButtonType.green or ButtonType.gold
		GUI.createButton(sceneGroup, btnX, boxY + 165, cashBtnW, 50, labels[i], bType, function()
			Game.addMoney(amt, "Dev", "Dev Cheat")
			Menu.updateBalanceText()
			setStatus("Added $" .. formatPrice(amt) .. " (Balance: $" .. formatPrice(Game.money) .. ")", Color.green)
			return true
		end, 26)
	end

	-- 3. Box & Clicker
	GUI.createButton(sceneGroup, col1X, boxY + 230, col1W, 50, "Instant Search Box Ready (100%)", ButtonType.blue, function()
		Game.searchProgress = 100
		Menu.addAlert("Cases")
		setStatus("Search progress set to 100%. Box is ready to claim!", Color.green)
		return true
	end, 30)

	-- 4. Rank Controls
	local rankBtnW = (col1W - 10) / 2
	GUI.createButton(sceneGroup, col1X, boxY + 295, rankBtnW, 50, "Rank +1", ButtonType.default, function()
		if Game.rank < 18 then
			Game.rank = Game.rank + 1
			for j = 1, #Game.ranks[Game.rank].upgrades do
				Game.unlockUpgrade(Game.ranks[Game.rank].upgrades[j])
			end
			Menu.showRank()
			setStatus("Rank increased to " .. Game.rank .. " (" .. Game.ranks[Game.rank].name .. ")", Color.gold)
		else
			setStatus("Already at maximum Rank 18 (The Global Elite)!", Color.white)
		end
		return true
	end, 28)

	GUI.createButton(sceneGroup, col1X + rankBtnW + 10, boxY + 295, rankBtnW, 50, "Max Rank (Global Elite)", ButtonType.gold, function()
		Game.rank = 18
		for r = 1, 18 do
			for j = 1, #Game.ranks[r].upgrades do
				Game.unlockUpgrade(Game.ranks[r].upgrades[j])
			end
		end
		Menu.showRank()
		setStatus("Rank set to 18 (The Global Elite)!", Color.gold)
		return true
	end, 26)

	-- 5. Unlock Upgrades & Achievements
	GUI.createButton(sceneGroup, col1X, boxY + 360, rankBtnW, 50, "Unlock All Upgrades", ButtonType.green, function()
		for key, _ in pairs(Game.upgrades) do
			Game.buyUpgrade(key, true)
		end
		Game.save()
		Menu.refreshItems()
		setStatus("All shop upgrades successfully purchased and unlocked!", Color.green)
		return true
	end, 26)

	GUI.createButton(sceneGroup, col1X + rankBtnW + 10, boxY + 360, rankBtnW, 50, "Unlock Achievements", ButtonType.green, function()
		local count = 0
		for key, ach in pairs(Game.achievements) do
			if not ach.unlocked then
				Game.unlockAchievement(key)
				count = count + 1
			end
		end
		setStatus("Unlocked " .. count .. " new achievements!", Color.green)
		return true
	end, 26)

	-- ==========================================================
	-- COLUMN 2: Items & Case Generation (Right side: x = boxX + 590, w = 520)
	-- ==========================================================
	local col2X = boxX + 590
	local col2W = 520

	GUI.createButton(sceneGroup, col2X, boxY + 70, col2W, 55, "+10 Of Every Case & Key", ButtonType.gold, function()
		for i = 1, #Game.cases do
			Game.cases[i].count = (Game.cases[i].count or 0) + 10
			Game.cases[i].unlocked = true
		end
		for i = 1, #Game.keys do
			Game.keys[i].count = (Game.keys[i].count or 0) + 10
		end
		Menu.addAlert("Cases")
		Game.save()
		setStatus("Added +10 to all cases and keys in inventory!", Color.gold)
		return true
	end, 30)

	GUI.createButton(sceneGroup, col2X, boxY + 140, col2W, 50, "Roll & Give Random Knife", ButtonType.red, function()
		composer.hideOverlay()
		Game.showKnifeDraw(true)
		return true
	end, 30)

	GUI.createButton(sceneGroup, col2X, boxY + 205, col2W, 50, "Roll & Give Random Gloves", ButtonType.purple, function()
		composer.hideOverlay()
		Game.showGloveDraw(true)
		return true
	end, 30)

	GUI.createButton(sceneGroup, col2X, boxY + 270, col2W, 50, "Give Rare StatTrak Skin (Dragon Lore / Howl)", ButtonType.gold, function()
		-- Give AWP Dragon Lore or M4A4 Howl
		local targetSkin = Game.skins[400] or Game.skins[#Game.skins]
		if targetSkin then
			Game.addItem(targetSkin, false, true, false, Quality.factorynew)
			Menu.addAlert("Equipment")
			Game.save()
			setStatus("Added StatTrak " .. targetSkin.name .. " (Factory New) to equipment!", Color.gold)
		end
		return true
	end, 26)

	GUI.createButton(sceneGroup, col2X, boxY + 335, col2W, 50, "Unlock NetHub & Jackpots", ButtonType.blue, function()
		Game.buyUpgrade("Trades", true)
		Game.buyUpgrade("Match Betting", true)
		Game.buyUpgrade("Jackpot", true)
		Game.others.nethubUnlocked = true
		Game.others.jackpotsUnlocked = true
		if NetHub and NetHub.register then
			NetHub.register()
		end
		Game.save()
		Menu.refreshItems()
		setStatus("NetHub Online, Trades, Betting, and Jackpots unlocked!", Color.green)
		return true
	end, 28)

	-- ==========================================================
	-- BOTTOM SECTION: Paid Bonus Cooldown Configuration & Reset
	-- ==========================================================
	local divY = boxY + 425
	GUI.drawHorizontalLine(sceneGroup, boxX + 20, divY, boxW - 40)

	local cdTitle = display.newText({
		parent = sceneGroup,
		x = boxX + 30,
		y = divY + 15,
		text = "PAID BONUSES COOLDOWN CONFIGURATION:",
		font = Font.counterstrike,
		fontSize = 26,
		align = "left"
	})
	cdTitle.anchorX = 0
	cdTitle:setFillColor(unpack(Color.gold))

	local cdValueText = display.newText({
		parent = sceneGroup,
		x = boxX + 30,
		y = divY + 48,
		text = "Current Cooldown: " .. Game.getBonusCooldownMinutes() .. " min  (File: bonuses_config.json)",
		font = Font.default,
		fontSize = 24,
		align = "left"
	})
	cdValueText.anchorX = 0
	cdValueText:setFillColor(0.85, 0.9, 1)

	local function updateCdDisplay()
		cdValueText.text = "Current Cooldown: " .. Game.getBonusCooldownMinutes() .. " min  (File: bonuses_config.json)"
	end

	-- Cooldown adjustment buttons
	local cdBtnW = 105
	local cdButtons = {
		{ label = "Instant (0m)", val = 0 },
		{ label = "15m", val = 15 },
		{ label = "30m", val = 30 },
		{ label = "60m (Default)", val = 60 },
		{ label = "120m", val = 120 },
	}
	for i = 1, #cdButtons do
		local btnX = boxX + 30 + (i - 1) * (cdBtnW + 8)
		local info = cdButtons[i]
		GUI.createButton(sceneGroup, btnX, divY + 80, cdBtnW, 45, info.label, ButtonType.default, function()
			Game.setBonusCooldownMinutes(info.val)
			updateCdDisplay()
			setStatus("Bonus cooldown updated to: " .. info.val .. " minutes (saved to bonuses_config.json)", Color.green)
			return true
		end, 20)
	end

	-- Reset cooldowns button
	GUI.createButton(sceneGroup, boxX + 600, divY + 80, 260, 45, "Reset All Cooldowns Now", ButtonType.green, function()
		Game.resetAllBonusCooldowns()
		setStatus("All paid bonus cooldowns cleared! All bonuses ready to claim.", Color.green)
		return true
	end, 24)

	-- Close Button
	GUI.createButton(sceneGroup, boxX + 880, divY + 80, 230, 45, "CLOSE [F1 / ESC]", ButtonType.red, function()
		composer.hideOverlay("fade", 150)
		return true
	end, 26)

	-- Key listener to close devmenu on hotkey or ESC
	local function onKeyDev(e)
		if e.phase == "up" then
			local k = e.keyName
			if k == "escape" or k == "f1" or k == "f12" or k == "`" or k == "~" or k == "grave" then
				composer.hideOverlay("fade", 150)
				Runtime:removeEventListener("key", onKeyDev)
				return true
			end
		end
		return false
	end
	Runtime:addEventListener("key", onKeyDev)
	sceneGroup._onKeyDev = onKeyDev
end

function scene:hide(event)
	if event.phase == "will" and self.view and self.view._onKeyDev then
		Runtime:removeEventListener("key", self.view._onKeyDev)
		self.view._onKeyDev = nil
	end
end

scene:addEventListener("create", scene)
scene:addEventListener("hide", scene)
return scene
