local QualityManager = {}
function QualityManager.getFloatByQuality(quality)
	if quality == Quality.factorynew then
		return math.random(0, 700) / 10000
	elseif quality == Quality.minimalwear then
		return math.random(701, 1500) / 10000
	elseif quality == Quality.fieldtested then
		return math.random(1501, 3800) / 10000
	elseif quality == Quality.wellworn then
		return math.random(3801, 4500) / 10000
	else
		return math.random(4501, 10000) / 10000
	end
	return 0.5
end
function QualityManager.getQualityByFloat(float)
	if float <= 0.07 then
		return Quality.factorynew
	elseif float <= 0.15 then
		return Quality.minimalwear
	elseif float <= 0.38 then
		return Quality.fieldtested
	elseif float < 0.45 then
		return Quality.wellworn
	else
		return Quality.battlescared
	end
	return QualityManager.factorynew
end
function QualityManager.floatToInt(float)
	return float / 10000
end
function QualityManager.intToFloat(int)
	return int * 10000
end
function QualityManager.getRandomQuality(item)
	local quality = Quality.battlescarred
	local randTest = math.random(0, 100)
	if randTest <= 13 then
		quality = Quality.factorynew
	elseif randTest <= 27 then
		quality = Quality.minimalwear
	elseif randTest <= 54 then
		quality = Quality.fieldtested
	elseif randTest <= 74 then
		quality = Quality.wellworn
	end
	if item.disabledQualities then
		for _, disabledQuality in ipairs(item.disabledQualities) do
			if disabledQuality == quality then
				return QualityManager.getRandomQuality(item)
			end
		end
	end
	return quality
end
function QualityManager.getRandomFloat(item)
	return QualityManager.getFloatByQuality(QualityManager.getRandomQuality(item))
end
return QualityManager
