function sleep(nMilliseconds)
	local nStartTime = system.getTimer()
	local nEndTime = nStartTime + nMilliseconds
	while true do
		if nEndTime <= system.getTimer() then
			break
		end
	end
end
function ucfirst(str)
	return (str:gsub("^%l", string.upper))
end
function getCenterX(object)
	return object.x + object.width / 2
end
function getCenterY(object)
	return object.y + object.height / 2
end
function choose(tab)
	return tab[math.random(#tab)]
end
function var_dump(value, depth, key)
	local linePrefix = ""
	local spaces = ""
	if key ~= nil then
		linePrefix = "[" .. key .. "] = "
	end
	if depth == nil then
		depth = 0
	else
		depth = depth + 1
		for i = 1, depth do
			spaces = spaces .. "  "
		end
	end
	if type(value) == "table" then
		mTable = getmetatable(value)
		if mTable == nil then
			print(spaces .. linePrefix .. "(table) ")
		else
			print(spaces .. "(metatable) ")
			value = mTable
		end
		for tableKey, tableValue in pairs(value) do
			var_dump(tableValue, depth, tableKey)
		end
	elseif type(value) == "function" or type(value) == "thread" or type(value) == "userdata" or value == nil then
		print(spaces .. tostring(value))
	else
		print(spaces .. linePrefix .. "(" .. type(value) .. ") " .. tostring(value))
	end
end
function tableLength(T)
	local count = 0
	for _ in pairs(T) do
		count = count + 1
	end
	return count
end
function rgb(r, g, b)
	return r / 255, g / 255, b / 255
end
function commaValue(amount)
	local formatted = amount
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then
			break
		end
	end
	return formatted
end
function round(val, decimal)
	if decimal then
		return math.floor(val * 10 ^ decimal + 0.5) / 10 ^ decimal
	else
		return math.floor(val + 0.5)
	end
end
function formatPrice(amount)
	local str_amount, formatted, famount, remain
	decimal = 2
	famount = math.abs(round(amount, decimal))
	famount = math.floor(famount)
	remain = round(math.abs(amount) - famount, 2)
	formatted = commaValue(famount)
	remain = string.sub(tostring(remain), 3)
	formatted = formatted .. "." .. remain .. string.rep("0", decimal - string.len(remain))
	return formatted
end
function pairsByKeys(t, f)
	local a = {}
	for n in pairs(t) do
		table.insert(a, n)
	end
	table.sort(a, f)
	local i = 0
	local function iter()
		i = i + 1
		if a[i] == nil then
			return nil
		else
			return a[i], t[a[i]]
		end
	end
	return iter
end
function getWeekDay()
	return tonumber(os.date("%w"))
end
function string.split(str)
	local t = {}
	return not str:gsub("%w+", function(s)
		table.insert(t, s)
		return ""
	end):find("%S") and t or {}
end
function string.trim(str)
	return str:gsub("^%s*(.-)%s*$", "%1")
end
function string.explode(str, sep, limit)
	if type(sep) ~= "string" then
		return {}
	end
	local i, pos, tmp, t = 0, 1, "", {}
	for s, e in function()
		return string.find(str, sep, pos)
	end, nil, nil do
		tmp = str:sub(pos, s - 1):trim()
		table.insert(t, tmp)
		pos = e + 1
		i = i + 1
		if limit ~= nil and i == limit then
			break
		end
	end
	tmp = str:sub(pos):trim()
	table.insert(t, tmp)
	return t
end
function tableContains(tab, value)
	for _, val in ipairs(tab) do
		if val == value then
			return true
		end
	end
	return false
end
function isIOS()
	return system.getInfo("platformName") == "iPhone OS" or system.getInfo("platformName") == "Mac OS X"
end
function isMobile()
	return system.getInfo("platformName") ~= "Win" and system.getInfo("platformName") ~= "Mac OS X"
end
function isAndroid()
	return system.getInfo("platformName") == "Android"
end
function isSimulator()
	return system.getInfo("environment") == "simulator"
end
function getOSID()
	if isAndroid() then
		return 1
	else
		return 2
	end
end
function shuffleTable(tab)
	local new = {}
	while 0 < #tab do
		local pos = math.random(1, #tab)
		table.insert(new, tab[pos])
		table.remove(tab, pos)
	end
	return new
end
function calculateSkinsPerRow(tableWidth)
	return math.max(3, math.floor(tableWidth * 0.9 / (345 * Game.guiScale)))
end
function detectSquareScreen()
	return math.min(display.safeActualContentWidth, display.safeActualContentHeight) / math.max(display.safeActualContentWidth, display.safeActualContentHeight) > 0.7
end
function isTablet()
	if isAndroid() then
		return false
	elseif system.getInfo("model") == "iPad" then
		return true
	else
		return false
	end
end
display.pixelWidth = display.contentScaleX
display.pixelHeight = display.contentScaleY
function display.getNearestHorizontalPixel(pixel)
	local pod = display.pixelWidth
	return math.floor(pixel / pod) * pod
end
function display.getNearestVerticalPixel(pixel)
	local pod = display.pixelHeight
	return math.floor(pixel / pod) * pod
end
function getTimeElapsedString(time)
	local timeDiff = os.time() - time
	if timeDiff < 5 then
		return "just now"
	end
	local timeUnit, amount
	if timeDiff < 60 then
		amount = timeDiff - timeDiff % 5
		timeUnit = "second"
	elseif timeDiff < 3600 then
		amount = math.round((timeDiff - timeDiff % 60) / 60)
		timeUnit = "minute"
	elseif timeDiff < 86400 then
		amount = math.round((timeDiff - timeDiff % 3600) / 3600)
		timeUnit = "hour"
	else
		amount = math.round((timeDiff - timeDiff % 86400) / 86400)
		timeUnit = "day"
	end
	local s = ""
	if 1 < amount then
		s = "s"
	end
	return amount .. " " .. timeUnit .. s .. " ago"
end
function getRemainingTimeString(time, actualTime)
	local actualTime = actualTime or os.time()
	local timeDiff = time - actualTime
	if timeDiff <= 0 then
		return "Done!"
	elseif timeDiff <= 10 then
		return "Less than 10 seconds"
	end
	local timeUnit, amount
	if timeDiff < 60 then
		amount = timeDiff - timeDiff % 5
		timeUnit = "second"
	elseif timeDiff < 3600 then
		amount = math.round((timeDiff - timeDiff % 60) / 60)
		timeUnit = "minute"
	elseif timeDiff < 86400 then
		amount = math.round((timeDiff - timeDiff % 3600) / 3600)
		timeUnit = "hour"
	else
		amount = math.round((timeDiff - timeDiff % 86400) / 86400)
		timeUnit = "day"
	end
	local s = ""
	if 1 < amount then
		s = "s"
	end
	return amount .. " " .. timeUnit .. s .. " left"
end
function display.shake(shakeObject)
	local initialX = shakeObject.x
	for i = 6, 1, -1 do
		timer.performWithDelay((6 - i) * 60, function()
			local newPos = initialX + i * 5
			if i % 2 == 0 then
				newPos = initialX + i * -5
			end
			if i == 1 then
				newPos = initialX
			end
			transition.to(shakeObject, {time = 59, x = newPos})
		end)
	end
end
function transition.changeColor(displayObj, params)
	local startColor = params.startColor or displayObj.fillColor or {
		ColorTools.rgb(0, 0, 0)
	}
	local length = params.time or 300
	local startTime = system.getTimer()
	local easingFunc = params.transition or easing.linear
	local function colorInterpolate(a, b, i, t)
		colourTable = {
			easingFunc(i, t, a[1], b[1] - a[1]),
			easingFunc(i, t, a[2], b[2] - a[2]),
			easingFunc(i, t, a[3], b[3] - a[3])
		}
		if b[4] and a[4] then
			easingFunc(i, t, a[4], b[4] - a[4])
		end
		return colourTable
	end
	function displayObj.runFunc(event)
		local runTime = system.getTimer()
		if runTime < startTime + length then
			displayObj:setFillColor(unpack(colorInterpolate(startColor, params.endColor, runTime - startTime, length)))
		else
			displayObj:setFillColor(unpack(params.endColor))
			Runtime:removeEventListener("enterFrame", displayObj.runFunc)
			displayObj.fillColor = params.endColor
		end
	end
	Runtime:addEventListener("enterFrame", displayObj.runFunc)
end
function transition.changeNumber(obj, params)
	local startNumber = params.startNumber or obj.actualValue or 0
	local startTime = system.getTimer()
	local length = params.time or 300
	local endNumber = params.endNumber
	if startNumber == endNumber then
		return true
	end
	obj.actualValue = endNumber
	if obj.runFunc then
		Runtime:removeEventListener("enterFrame", obj.runFunc)
		obj.runFunc = nil
	end
	function obj.runFunc(event)
		local runTime = system.getTimer()
		if runTime > startTime + length then
			Runtime:removeEventListener("enterFrame", obj.runFunc)
			obj.text = endNumber .. params.suffix or ""
			obj.runFunc = nil
		else
			local percent = (runTime - startTime) / length
			local value = startNumber + (endNumber - startNumber) * percent
			obj.text = math.round(value) .. params.suffix or ""
		end
	end
	Runtime:addEventListener("enterFrame", obj.runFunc)
end
