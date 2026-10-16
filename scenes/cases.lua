local TextSlider = require("gui.textslider")
local scene = composer.newScene()
local box, caseView, collectionView, capsuleView, autographView, souvenirView
local sortType = 1
local counterText, lastScroll
local casesPerRow = 3
if Game.settings.tabletMode == true then
	casesPerRow = 4
end
local function updateCounterText()
	local sum = 0
	if sortType == 1 then
		for i = 1, #Game.cases do
			sum = sum + Game.cases[i].count
		end
		counterText.text = Lang.cases.owned .. " " .. Lang.cases.cases .. ": " .. commaValue(sum)
	elseif sortType == 2 then
		for i = 1, #Game.collections do
			sum = sum + Game.collections[i].count
		end
		counterText.text = Lang.cases.owned .. " " .. Lang.cases.collections:lower() .. ": " .. commaValue(sum)
	elseif sortType == 3 then
		for i = 1, #Game.souvenirs do
			sum = sum + Game.souvenirs[i].count
		end
		counterText.text = Lang.cases.owned .. " " .. Lang.cases.souvenirs .. ": " .. commaValue(sum)
	elseif sortType == 4 then
		for i = 1, #Game.capsules do
			if not Game.capsules[i].hasAutographs then
				sum = sum + Game.capsules[i].count
			end
		end
		counterText.text = Lang.cases.owned .. " " .. Lang.cases.stickercapsules .. ": " .. commaValue(sum)
	elseif sortType == 5 then
		for i = 1, #Game.capsules do
			if Game.capsules[i].hasAutographs then
				sum = sum + Game.capsules[i].count
			end
		end
		counterText.text = Lang.cases.owned .. " " .. Lang.cases.autographcapsules .. ": " .. commaValue(sum)
	end
end
local function insertCollections()
	local tmp = {}
	for i = 1, #Game.collections do
		table.insert(tmp, {
			id = Game.collections[i].id,
			price = Game.collections[i].price
		})
	end
	table.sort(tmp, function(a, b)
		return a.price < b.price
	end)
	for i = 1, #tmp do
		collectionView:insertRow({
			params = {
				collectionId = tmp[i].id
			},
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = 220 * Game.guiScale
		})
	end
end
local function insertSouvenirs()
	local tmp = {}
	for i = 1, #Game.souvenirs do
		if Game.souvenirs[i].price then
			table.insert(tmp, {
				id = Game.souvenirs[i].id,
				price = Game.souvenirs[i].price
			})
		end
	end
	table.sort(tmp, function(a, b)
		return a.price < b.price
	end)
	for i = 1, #tmp do
		souvenirView:insertRow({
			params = {
				souvenirId = tmp[i].id
			},
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = 220 * Game.guiScale
		})
	end
end
local function insertAutographs()
	autographView:deleteAllRows()
	local tmp = {}
	for i = 1, #Game.capsules do
		if Game.capsules[i].hasAutographs then
			table.insert(tmp, {
				id = Game.capsules[i].id,
				price = Game.capsules[i].price
			})
		end
	end
	table.sort(tmp, function(a, b)
		return a.price < b.price
	end)
	for i = 1, #tmp do
		autographView:insertRow({
			params = {
				capsuleId = tmp[i].id
			},
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = 220 * Game.guiScale
		})
	end
end
local function insertCapsules()
	capsuleView:deleteAllRows()
	local tmp = {}
	for i = 1, #Game.capsules do
		if not Game.capsules[i].hasAutographs then
			table.insert(tmp, {
				id = Game.capsules[i].id,
				price = Game.capsules[i].price
			})
		end
	end
	table.sort(tmp, function(a, b)
		return a.price < b.price
	end)
	for i = 1, #tmp do
		if Game.isCapsuleUnlocked(tmp[i].id) then
			capsuleView:insertRow({
				params = {
					capsuleId = tmp[i].id
				},
				rowColor = {
					default = Color.row
				},
				lineColor = {
					0,
					0,
					0,
					0
				},
				rowHeight = 220 * Game.guiScale
			})
		end
	end
	for i = 1, #tmp do
		if not Game.isCapsuleUnlocked(tmp[i].id) then
			capsuleView:insertRow({
				params = {
					capsuleId = tmp[i].id
				},
				rowColor = {
					default = Color.row
				},
				lineColor = {
					0,
					0,
					0,
					0
				},
				rowHeight = 220 * Game.guiScale
			})
		end
	end
end
local function insertCases()
	caseView:deleteAllRows()
	local cases = {}
	local keyCases = {}
	local ownedCases = {}
	local otherCases = {}
	for _, case in ipairs(Game.cases) do
		if case.count > 0 and 0 < Game.keys[case.keyId].count then
			table.insert(keyCases, case)
		elseif case.count > 0 then
			table.insert(ownedCases, case)
		else
			table.insert(otherCases, case)
		end
	end
	table.sort(keyCases, function(a, b)
		return a.count > b.count
	end)
	table.sort(ownedCases, function(a, b)
		return a.count > b.count
	end)
	for _, case in ipairs(keyCases) do
		table.insert(cases, case)
	end
	for _, case in ipairs(ownedCases) do
		table.insert(cases, case)
	end
	for _, case in ipairs(otherCases) do
		table.insert(cases, case)
	end
	for i = 1, math.ceil(#cases / casesPerRow) do
		local params = {
			cases[(i - 1) * casesPerRow + 1].id
		}
		if cases[(i - 1) * casesPerRow + 2] then
			table.insert(params, cases[(i - 1) * casesPerRow + 2].id)
		end
		if Game.cases[(i - 1) * casesPerRow + 3] then
			table.insert(params, cases[(i - 1) * casesPerRow + 3].id)
		end
		if 4 <= casesPerRow and Game.cases[(i - 1) * casesPerRow + 4] then
			table.insert(params, cases[(i - 1) * casesPerRow + 4].id)
		end
		caseView:insertRow({
			params = params,
			rowColor = {
				default = Color.row
			},
			lineColor = {
				0,
				0,
				0,
				0
			},
			rowHeight = 410 * Game.guiScale
		})
	end
end
local sliderTexts = {
	ucfirst(Lang.cases.cases),
	ucfirst(Lang.cases.collections),
	ucfirst(Lang.cases.souvenirs),
	ucfirst(Lang.cases.stickercapsules),
	Lang.cases.autographs
}
local actualText = sliderTexts[1]
local function hideAllTableViews()
	collectionView.alpha = 0
	caseView.alpha = 0
	autographView.alpha = 0
	capsuleView.alpha = 0
	souvenirView.alpha = 0
end
local function onSliderTextChange(text)
	for i = 1, #sliderTexts do
		if text == sliderTexts[i] then
			sortType = i
		end
	end
	if sortType == 1 then
		hideAllTableViews()
		caseView.alpha = 1
		caseView:reloadData()
		updateCounterText()
	elseif sortType == 2 then
		hideAllTableViews()
		collectionView.alpha = 1
		collectionView:reloadData()
	elseif sortType == 3 then
		hideAllTableViews()
		souvenirView.alpha = 1
		souvenirView:reloadData()
	elseif sortType == 4 then
		hideAllTableViews()
		capsuleView.alpha = 1
		capsuleView:reloadData()
	elseif sortType == 5 then
		hideAllTableViews()
		autographView.alpha = 1
		autographView:reloadData()
	end
	updateCounterText()
end
local function onCapsuleRowRender(event)
	local row = event.row
	local capsuleId = row.params.capsuleId
	local capsule = Game.capsules[capsuleId]
	local background = display.newRect(row, 0, 0, row.width, row.height)
	background:setFillColor(0.4, 0.4, 0.4, 0.1)
	local image = display.newImageRect(row, "images/capsules/" .. capsule.image, 225.28 * Game.guiScale, 168.96 * Game.guiScale)
	image.y = row.height / 2
	image.anchorX = 0.5
	image.anchorY = 0.5
	image.x = row.width * 0.09
	image:addEventListener("tap", function()
		if Game.openLock then
			return
		end
		Game.showCapsuleInfo(capsule.id)
	end)
	local fontSize = 55
	if #capsule.name > 33 then
		fontSize = 37
	elseif #capsule.name > 23 then
		fontSize = 42
	elseif #capsule.name > 20 then
		fontSize = 48
	end
	local name = display.newText({
		parent = row,
		x = row.width * 0.212,
		y = 40,
		text = capsule.name,
		font = Font.counterstrike,
		fontSize = fontSize * Game.guiScale,
		align = "left"
	})
	name.anchorY = 0.5
	FontOffset.setOffset(name)
	local nextY = name.y + 40
	if capsule.subName then
		local subName = display.newText({
			parent = row,
			x = row.width * 0.212,
			y = name.y + 40,
			text = capsule.subName,
			font = Font.counterstrike,
			fontSize = 40 * Game.guiScale,
			align = "left"
		})
		subName.anchorY = 0.5
		FontOffset.setOffset(subName)
		nextY = subName.y + 40
	end
	local countText = display.newText({
		parent = row,
		x = row.width * 0.212,
		y = nextY,
		text = "Count: " .. capsule.count,
		font = Font.counterstrike,
		fontSize = 35 * Game.guiScale,
		align = "left"
	})
	countText.anchorY = 0.5
	countText:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(countText)
	GUI.drawVerticalLine(row, box.width * 0.2, 0, 220 * Game.guiScale)
	GUI.drawVerticalLine(row, box.width * 0.7, 0, 220 * Game.guiScale)
	if capsule.unlockingUpgrade and not Game.isUpgradeBought(capsule.unlockingUpgrade) then
		local shade = display.newRect(row, 0, 0, row.width, row.height)
		shade:setFillColor(0, 0, 0, 0.85)
		local notUnlockedText = display.newText({
			parent = row,
			x = row.width / 2,
			y = row.height / 2,
			text = "Not unlocked",
			font = Font.counterstrike,
			fontSize = 64 * Game.guiScale,
			align = "left"
		})
		notUnlockedText.anchorX = 0.5
		notUnlockedText.anchorY = 0.5
		notUnlockedText:setFillColor(0.75, 0.8, 1, 0.5)
		return
	end
	if capsule.count == 0 then
		local canBuy = Game.money >= capsule.price
		local buttonText = Lang.cases.buy .. " @ $" .. formatPrice(capsule.price)
		local buyButton
		if canBuy then
			buyButton = GUI.createButton(row, box.width * 0.715, 20, box.width * 0.27, 180 * Game.guiScale, buttonText, ButtonType.green, function(event)
				GUI.showAnimatedText(nil, Lang.cases.bought .. "!", event.x * (math.random(95, 105) / 100), event.y * (math.random(95, 100) / 100))
				Game.buyCapsule(capsuleId)
				if sortType == 4 then
					capsuleView:reloadData()
				else
					autographView:reloadData()
				end
				updateCounterText()
			end, 40)
		else
			buyButton = GUI.createButton(row, box.width * 0.715, 20, box.width * 0.27, 180 * Game.guiScale, buttonText, ButtonType.red, function()
			end, 40)
		end
		buyButton.anchorX = 0
		buyButton.anchorY = 0
	else
		if capsule.keyId and 0 >= Game.keys[capsule.keyId].count then
			local canBuy = Game.money >= Game.keys[capsule.keyId].price
			local buttonText = Lang.cases.buy .. " " .. Lang.cases.key .. " @ $" .. formatPrice(Game.keys[capsule.keyId].price)
			local buttonType = ButtonType.green
			if not canBuy then
				buttonType = ButtonType.red
			end
			GUI.createButton(row, box.width * 0.715, 20, box.width * 0.27, 100 * Game.guiScale, buttonText, buttonType, function(event)
				if Game.showingOverlay or not canBuy then
					if sortType == 4 then
						capsuleView:reloadData()
					else
						autographView:reloadData()
					end
					return
				end
				if Game.keys[capsule.keyId].count > 0 then
					if sortType == 4 then
						capsuleView:reloadData()
					else
						autographView:reloadData()
					end
					return
				end
				if Game.money >= Game.keys[capsule.keyId].price then
					Game.onKeyBuy()
					Game.addItem(Game.keys[capsule.keyId], false)
					Game.removeMoney(Game.keys[capsule.keyId].price, "Key", Game.keys[capsule.keyId].name)
					GUI.showAnimatedText(nil, Lang.cases.bought .. "!", event.x * (math.random(95, 105) / 100), event.y * (math.random(95, 100) / 100))
					if sortType == 4 then
						capsuleView:reloadData()
					else
						autographView:reloadData()
					end
				end
			end, 40)
		else
			GUI.createButton(row, box.width * 0.715, 20, box.width * 0.27, 100 * Game.guiScale, Lang.cases.opencapsule, ButtonType.green, function(event)
				if Game.openLock then
					return
				end
				if Game.capsules[capsuleId].count <= 0 then
					if sortType == 4 then
						capsuleView:reloadData()
					else
						autographView:reloadData()
					end
					return
				end
				Game.openLock = true
				Game.openCapsule(capsuleId)
				if sortType == 4 then
					capsuleView:reloadData()
				else
					autographView:reloadData()
				end
			end, 45)
		end
		local buttonText = Lang.cases.sell .. " @ $" .. formatPrice(capsule.sellPrice)
		Button.create(row, box.width * 0.715, 130 * Game.guiScale, box.width * 0.27, 70 * Game.guiScale, buttonText, ButtonType.green, function(event)
			if capsule.count <= 0 then
				if sortType == 4 then
					capsuleView:reloadData()
				else
					autographView:reloadData()
				end
				return true
			end
			Game.sellCapsule(capsuleId, event)
			updateCounterText()
			if sortType == 4 then
				capsuleView:reloadData()
			else
				autographView:reloadData()
			end
		end, {fontSize = 40, callbackAsHoldCallback = true})
	end
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local function onCollectionRowRender(event)
	local row = event.row
	local collection = Game.collections[row.params.collectionId]
	local background = display.newRect(row, 0, 0, row.width, row.height)
	background:setFillColor(0.4, 0.4, 0.4, 0.1)
	local image = display.newImageRect(row, "images/collections/" .. collection.image, 204.8 * Game.guiScale, 158.4 * Game.guiScale)
	image.y = row.height / 2
	image.anchorX = 0.5
	image.anchorY = 0.5
	image.x = row.width * 0.09
	image:addEventListener("tap", function()
		if Game.openLock then
			return
		end
		Game.showCollectionInfo(collection.id)
	end)
	local name = display.newText({
		parent = row,
		x = row.width * 0.212,
		y = 40,
		text = collection.name:gsub(" Collection", ""),
		font = Font.counterstrike,
		fontSize = 55 * Game.guiScale,
		align = "left"
	})
	name.anchorY = 0.5
	FontOffset.setOffset(name)
	local infoText = display.newText({
		parent = row,
		x = row.width * 0.212,
		y = name.y + 50,
		text = "Collection package",
		font = Font.counterstrike,
		fontSize = 45 * Game.guiScale,
		align = "left"
	})
	infoText.anchorY = 0.5
	infoText:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(infoText)
	local countText = display.newText({
		parent = row,
		x = row.width * 0.212,
		y = infoText.y + 40,
		text = "Count: " .. collection.count,
		font = Font.counterstrike,
		fontSize = 35 * Game.guiScale,
		align = "left"
	})
	countText.anchorY = 0.5
	countText:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(countText)
	if collection.count == 0 then
		local canBuy = Game.money >= collection.price
		local buttonText = Lang.cases.buy .. " @ $" .. formatPrice(collection.price)
		local buyButton
		if canBuy then
			buyButton = GUI.createButton(row, box.width * 0.715, 20, box.width * 0.27, 180 * Game.guiScale, buttonText, ButtonType.green, function(event)
				GUI.showAnimatedText(nil, Lang.cases.bought .. "!", event.x * (math.random(95, 105) / 100), event.y * (math.random(95, 100) / 100))
				Game.buyCollection(collection.id)
				collectionView:reloadData()
				updateCounterText()
			end, 40)
		else
			buyButton = GUI.createButton(row, box.width * 0.715, 20, box.width * 0.27, 180 * Game.guiScale, buttonText, ButtonType.red, function()
			end, 40)
		end
		buyButton.anchorX = 0
		buyButton.anchorY = 0
	else
		local openButton = GUI.createButton(row, box.width * 0.715, 20, box.width * 0.27, 100 * Game.guiScale, Lang.cases.opencollection, ButtonType.green, function(event)
			if Game.openLock then
				return
			end
			if Game.collections[collection.id].count <= 0 then
				collectionView:reloadData()
				return
			end
			Game.openLock = true
			Game.openCollection(collection.id)
		end, 45)
		local sellButton = Button.create(row, box.width * 0.715, 130 * Game.guiScale, box.width * 0.27, 70 * Game.guiScale, Lang.cases.sell .. " @ $" .. formatPrice(collection.sellPrice), ButtonType.green, function(event)
			if collection.count == 0 then
				collectionView:reloadData()
				return true
			end
			Game.sellCollection(collection.id, event)
			updateCounterText()
			collectionView:reloadData()
		end, {fontSize = 40, callbackAsHoldCallback = true})
	end
	GUI.drawVerticalLine(row, box.width * 0.2, 0, 220 * Game.guiScale)
	GUI.drawVerticalLine(row, box.width * 0.7, 0, 220 * Game.guiScale)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local function onSouvenirRowRender(event)
	local row = event.row
	local souvenirId = event.row.params.souvenirId
	local souvenir = Game.souvenirs[souvenirId]
	local background = display.newRect(row, 0, 0, row.width, row.height)
	background:setFillColor(0.4, 0.4, 0.4, 0.1)
	local image = display.newImageRect(row, "images/souvenirs/" .. souvenir.image, 204.8 * Game.guiScale, 158.4 * Game.guiScale)
	image.y = row.height / 2
	image.anchorX = 0.5
	image.anchorY = 0.5
	image.x = row.width * 0.09
	image:addEventListener("tap", function()
		if Game.openLock then
			return
		end
		Game.showSouvenirInfo(souvenir.id)
	end)
	local name = display.newText({
		parent = row,
		x = row.width * 0.212,
		y = 40,
		text = souvenir.name,
		font = Font.counterstrike,
		fontSize = 55 * Game.guiScale,
		align = "left"
	})
	name.anchorY = 0.5
	FontOffset.setOffset(name)
	local infoText = display.newText({
		parent = row,
		x = row.width * 0.212,
		y = name.y + 50,
		text = "Souvenir package",
		font = Font.counterstrike,
		fontSize = 45 * Game.guiScale,
		align = "left"
	})
	infoText.anchorY = 0.5
	infoText:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(infoText)
	local countText = display.newText({
		parent = row,
		x = row.width * 0.212,
		y = infoText.y + 40,
		text = "Count: " .. souvenir.count,
		font = Font.counterstrike,
		fontSize = 35 * Game.guiScale,
		align = "left"
	})
	countText.anchorY = 0.5
	countText:setFillColor(unpack(Color.gold))
	FontOffset.setOffset(countText)
	if souvenir.count == 0 then
		local canBuy = Game.money >= souvenir.price
		local buttonText = Lang.cases.buy .. " @ $" .. formatPrice(souvenir.price)
		local buyButton
		if canBuy then
			buyButton = GUI.createButton(row, box.width * 0.715, 20, box.width * 0.27, 180 * Game.guiScale, buttonText, ButtonType.green, function(event)
				GUI.showAnimatedText(nil, Lang.cases.bought .. "!", event.x * (math.random(95, 105) / 100), event.y * (math.random(95, 100) / 100))
				Game.buySouvenir(souvenirId)
				souvenirView:reloadData()
				updateCounterText()
			end, 40)
		else
			buyButton = GUI.createButton(row, box.width * 0.715, 20, box.width * 0.27, 180 * Game.guiScale, buttonText, ButtonType.red, function()
			end, 40)
		end
		buyButton.anchorX = 0
		buyButton.anchorY = 0
	else
		local openButton = GUI.createButton(row, box.width * 0.715, 20, box.width * 0.27, 100 * Game.guiScale, Lang.cases.openpackage, ButtonType.green, function(event)
			if Game.openLock then
				return
			end
			if Game.souvenirs[souvenirId].count <= 0 then
				souvenirView:reloadData()
				return
			end
			Game.openLock = true
			Game.openSouvenir(souvenirId)
		end, 45)
		local sellButton = Button.create(row, box.width * 0.715, 130 * Game.guiScale, box.width * 0.27, 70 * Game.guiScale, Lang.cases.sell .. " @ $" .. formatPrice(souvenir.sellPrice), ButtonType.green, function(event)
			if souvenir.count == 0 then
				souvenirView:reloadData()
				return true
			end
			Game.sellSouvenir(souvenirId, event)
			updateCounterText()
			souvenirView:reloadData()
		end, {fontSize = 40, callbackAsHoldCallback = true})
	end
	GUI.drawVerticalLine(row, box.width * 0.2, 0, 220 * Game.guiScale)
	GUI.drawVerticalLine(row, box.width * 0.7, 0, 220 * Game.guiScale)
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
local function onCaseRowRender(event)
	local row = event.row
	local cases = event.row.params
	for i = 1, casesPerRow - 1 do
		GUI.drawVerticalLine(row, row.x + row.width * (i * 1 / casesPerRow), row.x, row.height)
	end
	for i = 1, #cases do
		local case = Game.cases[cases[i]]
		local columnX = (i - 1) * (1 / casesPerRow * row.width)
		local columnWidth = 1 / casesPerRow * row.width
		local caseImageY = 25
		if case.count == 0 then
			caseImageY = 100
		end
		local caseImage = display.newImageRect(row, "images/cases/" .. case.image, 192.8 * Game.guiScale, 140.8 * Game.guiScale)
		caseImage.x = columnX + columnWidth / 2
		caseImage.y = caseImageY
		caseImage.anchorX = 0.5
		caseImage:addEventListener("tap", function()
			if Game.openLock then
				return
			end
			lastScroll = caseView:getContentPosition()
			Game.showCaseInfo(case.id)
		end)
		local name = case.name
		local fontSize = 32
		if 25 < name:len() then
			fontSize = 24
		end
		if detectSquareScreen() or Game.settings.tabletMode then
			name = name:gsub(" Case", "")
		end
		local caseName = display.newText({
			parent = row,
			x = columnX + columnWidth / 2,
			y = caseImage.y + caseImage.height + 30,
			text = name,
			font = Font.counterstrike,
			fontSize = fontSize * Game.guiScale,
			align = "center"
		})
		caseName.anchorX = 0.5
		FontOffset.setOffset(caseName)
		local ccImageXMultiplier = 1
		if case.count >= 100 then
			ccImageXMultiplier = 1.1
		elseif case.count >= 1000 then
			ccImageXMultiplier = 1.39
		elseif case.count >= 10000 then
			ccImageXMultiplier = 1.57
		elseif case.count >= 100000 then
			ccImageXMultiplier = 1.77
		end
		local caseCountImage = display.newImageRect(row, "images/casecount.png", 86.39999999999999 * Game.guiScale * ccImageXMultiplier, 54 * Game.guiScale)
		caseCountImage.x = caseImage.x + caseImage.width / 2 - 20
		caseCountImage.y = caseImageY + caseImage.height - 37
		caseCountImage.anchorX = 0.5
		local caseCountText = display.newText({
			parent = row,
			x = caseCountImage.x + 1,
			y = caseCountImage.y + caseCountImage.height / 2,
			text = case.count,
			font = Font.counterstrike,
			fontSize = fontSize * Game.guiScale,
			align = "center"
		})
		caseCountText.anchorX = 0.5
		caseCountText.anchorY = 0.5
		FontOffset.setOffset(caseCountText)
		local buttonWidthMultiplier = 0.8
		local nameFont
		if detectSquareScreen() or Game.settings.tabletMode then
			buttonWidthMultiplier = 0.94
		end
		if case.count > 0 then
			if 0 < Game.keys[case.keyId].count then
				GUI.createButton(row, columnX + columnWidth / 2 - columnWidth * buttonWidthMultiplier / 2, caseImage.y + caseImage.height + 50 + 25 * Game.guiScale, columnWidth * buttonWidthMultiplier, 80 * Game.guiScale, Lang.cases.opencase, ButtonType.default, function(event)
					if Game.openLock then
						return
					end
					if Game.showingOverlay then
						return
					end
					lastScroll = caseView:getContentPosition()
					Game.openLock = true
					Game.openCase(case.id)
					caseView:reloadData()
				end, 47)
			else
				local buttonType = ButtonType.green
				if Game.money < Game.keyCost - 1.0E-4 then
					buttonType = ButtonType.red
				end
				local button = GUI.createButton(row, columnX + columnWidth / 2 - columnWidth * buttonWidthMultiplier / 2, caseImage.y + caseImage.height + 45 + 25 * Game.guiScale, columnWidth * buttonWidthMultiplier, 80 * Game.guiScale, Lang.cases.buy .. " " .. Lang.cases.key .. " @ $" .. formatPrice(Game.keyCost), buttonType, function(event)
					if Game.showingOverlay then
						return
					end
					if Game.keys[case.keyId].count > 0 then
						caseView:reloadData()
						return
					end
					if Game.money >= Game.keyCost - 1.0E-4 then
						Game.onKeyBuy()
						Game.addItem(Game.keys[case.keyId], false)
						GUI.showAnimatedText(nil, Lang.cases.bought .. "!", event.x * (math.random(95, 105) / 100), event.y * (math.random(95, 100) / 100))
						Game.removeMoney(Game.keyCost, "Key", Game.keys[case.keyId].name)
						caseView:reloadData()
					end
				end, 40)
			end
			local sellButton = Button.create(row, columnX + columnWidth / 2 - columnWidth * buttonWidthMultiplier / 2, caseImage.y + caseImage.height + 45 + 80 * Game.guiScale + 35 * Game.guiScale, columnWidth * buttonWidthMultiplier, 60 * Game.guiScale, Lang.cases.sellfor .. " $" .. formatPrice(case.sellPrice), ButtonType.green, function(event)
				if Game.showingOverlay then
					return true
				end
				if case.count <= 0 then
					caseView:reloadData()
					return true
				end
				Game.sellCase(case.id, event)
				caseView:reloadData()
				updateCounterText()
				return false
			end, {fontSize = 40, callbackAsHoldCallback = true})
		end
		if case.count == 0 then
			local rect = display.newRect(row, columnWidth * (i - 1), 0, columnWidth + 3, row.height)
			rect:setFillColor(0, 0, 0, 0.5)
		end
	end
	GUI.drawHorizontalLine(row, 0, row.height - 7, row.width)
end
function scene:create(event)
	local sceneGroup = self.view
	box = GUI.drawMainBox(sceneGroup, "")
	counterText = display.newText({
		parent = sceneGroup,
		x = getCenterX(box),
		y = box.y - 28,
		text = "",
		font = Font.counterstrike,
		fontSize = 36,
		align = "center"
	})
	counterText.anchorX = 0.5
	counterText.anchorY = 0.5
	counterText:setFillColor(unpack(Color.lightText))
	FontOffset.setOffset(counterText)
	updateCounterText()
	caseView = widget.newTableView({
		left = box.x,
		top = box.y + 120 * Game.guiScale,
		width = box.width,
		height = box.height - 120 * Game.guiScale,
		isBounceEnabled = false,
		hideBackground = true,
		onRowRender = onCaseRowRender
	})
	collectionView = widget.newTableView({
		left = box.x,
		top = box.y + 120 * Game.guiScale,
		width = box.width,
		height = box.height - 120 * Game.guiScale,
		isBounceEnabled = false,
		hideBackground = true,
		onRowRender = onCollectionRowRender
	})
	insertCollections()
	collectionView.alpha = 0
	souvenirView = widget.newTableView({
		left = box.x,
		top = box.y + 120 * Game.guiScale,
		width = box.width,
		height = box.height - 120 * Game.guiScale,
		isBounceEnabled = false,
		hideBackground = true,
		onRowRender = onSouvenirRowRender
	})
	insertSouvenirs()
	souvenirView.alpha = 0
	capsuleView = widget.newTableView({
		left = box.x,
		top = box.y + 120 * Game.guiScale,
		width = box.width,
		height = box.height - 120 * Game.guiScale,
		isBounceEnabled = false,
		hideBackground = true,
		onRowRender = onCapsuleRowRender
	})
	insertCapsules()
	capsuleView.alpha = 0
	autographView = widget.newTableView({
		left = box.x,
		top = box.y + 120 * Game.guiScale,
		width = box.width,
		height = box.height - 120 * Game.guiScale,
		isBounceEnabled = false,
		hideBackground = true,
		onRowRender = onCapsuleRowRender
	})
	insertAutographs()
	autographView.alpha = 0
	local buttonBackground = display.newRect(sceneGroup, box.x, box.y, box.width, box.height)
	buttonBackground:setFillColor(unpack(Color.row))
	local slider = TextSlider.create(sceneGroup, box.x, box.y, box.width, 120 * Game.guiScale, sliderTexts, function(text)
		onSliderTextChange(text)
	end, 80 * Game.guiScale)
	insertCases()
	sceneGroup:insert(caseView)
	sceneGroup:insert(collectionView)
	sceneGroup:insert(capsuleView)
	sceneGroup:insert(autographView)
	sceneGroup:insert(souvenirView)
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
		updateCounterText()
		if sortType == 1 then
			insertCases()
			if lastScroll then
				caseView:scrollToY({y = lastScroll, time = 0})
				lastScroll = nil
			end
		elseif sortType == 2 then
			collectionView:reloadData()
		elseif sortType == 3 then
			souvenirView:reloadData()
		elseif sortType == 4 then
			capsuleView:reloadData()
		elseif sortType == 5 then
			autographView:reloadData()
		end
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
