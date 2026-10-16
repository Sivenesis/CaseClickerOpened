local Stickers = {}
function Stickers.addToSkin(stickerId, skinId)
	local skin = Game.equipment[skinId]
	local sticker = Game.equipment[stickerId]
	if not skin.stickers then
		skin.stickers = {}
	end
	table.insert(skin.stickers, sticker.id)
	table.remove(Game.equipment, stickerId)
end
function Stickers.serialize(stickers)
	if not stickers then
		return ""
	end
	if #stickers == 0 then
		return ""
	end
	local str = ""
	for i = 1, math.min(4, #stickers) do
		if 1 < i then
			str = str .. "-"
		end
		str = str .. stickers[i]
	end
	return str
end
function Stickers.deserialize(stickerString)
	if not stickerString or #stickerString == 0 then
		return nil
	end
	local stickerList = string.explode(stickerString, "-")
	for i = 1, #stickerList do
		stickerList[i] = tonumber(stickerList[i])
	end
	if stickerList[1] == 0 and stickerList[2] == 0 and stickerList[3] == 0 then
		return nil
	end
	return stickerList
end
function Stickers.getStickerImageDimensions(id)
	if id <= 587 then
		return {width = 260, height = 260}
	else
		return {width = 256, height = 192}
	end
end
return Stickers
