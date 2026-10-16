local M = {}
local offsets = {
	simulator = {},
	ios = {},
	android = {}
}
local deviceTypeAlert = false
local deviceType
if "simulator" == system.getInfo("environment") then
	deviceType = "simulator"
elseif string.sub(system.getInfo("model"), 1, 2) == "iP" then
	deviceType = "ios"
else
	deviceType = "android"
end
local copyTable = function(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end
local function nearestAvailableFontSize(size)
	if offsets[deviceType][size] then
		return size
	end
	local gap, nearestSize
	for fontSize, v in pairs(offsets[deviceType]) do
		local diff = math.abs(fontSize - size)
		if gap == nil or gap > diff then
			gap, nearestSize = diff, fontSize
		end
	end
	if not offsets[deviceType][nearestSize] then
		return nil
	end
	offsets[deviceType][size] = copyTable(offsets[deviceType][nearestSize])
	offsets[deviceType][size].copiedFrom = nearestSize
	return nearestSize
end
local function calcOffset(height, fontSize, anchorX, anchorY)
	if anchorY == 0 then
		return -math.floor(height * offsets[deviceType][fontSize].top)
	elseif anchorY == 1 then
		return math.floor(height * offsets[deviceType][fontSize].bottom)
	else
		local blankPxAbove = math.floor(height * offsets[deviceType][fontSize].top)
		local blankPxBottom = math.floor(height * offsets[deviceType][fontSize].bottom)
		return math.floor(-(blankPxAbove / 2) + blankPxBottom / 2)
	end
end
function M.setOffset(textObject)
	local yOffset, actualHeight
	local anchorX = textObject.anchorX
	local anchorY = textObject.anchorY
	local height = textObject.height
	local fontSize = nearestAvailableFontSize(textObject.size)
	if not fontSize then
		if not deviceTypeAlert then
			deviceTypeAlert = true
		end
		yOffset = 0
		actualHeight = height
	else
		yOffset = calcOffset(height, fontSize, anchorX, anchorY)
		local blankPxAbove = math.floor(height * offsets[deviceType][fontSize].top)
		local blankPxBottom = math.floor(height * offsets[deviceType][fontSize].bottom)
		actualHeight = height - blankPxAbove - blankPxBottom
	end
	textObject.anchorX = anchorX
	textObject.anchorY = anchorY
	textObject.x = textObject.x
	textObject.y = textObject.y + yOffset
	textObject.actualY = y
	textObject.actualHeight = actualHeight
	return yOffset
end
function M.addOffset(size, device, height, topOffset, bottomOffset)
	local device = string.lower(device)
	if not offsets[device] then
		local alert = native.showAlert("WARNING", "Device not recognized when adding an offset, ignored", {"OK"})
		return false
	end
	offsets[device][size] = {
		top = topOffset / height,
		bottom = bottomOffset / height
	}
	return true
end
function M.getOffset(height, size, anchorX, anchorY)
	return calcOffset(height, size, anchorX, anchorY)
end
return M
