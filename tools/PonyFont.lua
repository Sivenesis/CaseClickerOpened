local M = {}
M.cache = {}
local addPropertyUpdate = function(obj)
	local t = {}
	t.raw = obj
	local mt = {
		__index = function(_, k)
			if k == "raw" then
				return rawget(t, "raw")
			end
			if type(obj[k]) == "function" and k ~= "runFunc" then
				return function(...)
					arg[1] = obj
					obj[k](unpack(arg))
				end
			else
				return obj[k]
			end
		end,
		__newindex = function(tb, k, v)
			if not obj.dispatchEvent then
				return false
			end
			local event = {
				name = "propertyUpdate",
				target = tb,
				key = k,
				value = v
			}
			obj:dispatchEvent(event)
			obj[k] = v
		end
	}
	setmetatable(t, mt)
	return t
end
local parseFilename = function(filename)
	return string.match(filename, "(.-)([^\\/]-%.?([^%.\\/]*))$")
end
local extract = function(s, p)
	return string.match(s, p), string.gsub(s, p, "", 1)
end
function M.newText(options)
	options = options or {}
	local function loadFont(name)
		local path, filename, ext = parseFilename(name)
		local font = {
			info = {},
			spritesheets = {},
			sprites = {},
			chars = {},
			kernings = {}
		}
		local contents = io.lines(system.pathForFile(path .. filename, system.ResourceDirectory))
		for line in contents, nil, nil do
			local t = {}
			local tag
			tag, line = extract(line, "^%s*([%a_]+)%s*")
			while string.len(line) > 0 do
				local k, v
				k, line = extract(line, "^([%a_]+)=")
				if not k then
					break
				end
				v, line = extract(line, "^\"([^\"]*)\"%s*")
				if not v then
					v, line = extract(line, "^([^%s]*)%s*")
				end
				if not v then
					break
				end
				t[k] = v
			end
			if tag == "info" or tag == "common" then
				for k, v in pairs(t) do
					font.info[k] = v
				end
			elseif tag == "page" then
				font.spritesheets[1 + t.id] = {
					file = t.file,
					frames = {}
				}
			elseif tag == "char" then
				if tonumber(t.id) > 255 then
					t.letter = string.char(255)
				else
					t.letter = string.char(t.id)
				end
				font.chars[t.letter] = {}
				for k, v in pairs(t) do
					font.chars[t.letter][k] = v
				end
				if 0 < 0 + font.chars[t.letter].width and 0 < 0 + font.chars[t.letter].height then
					font.spritesheets[1 + t.page].frames[#font.spritesheets[1 + t.page].frames + 1] = {
						x = 0 + t.x,
						y = 0 + t.y,
						width = 0 + t.width,
						height = 0 + t.height
					}
					font.sprites[t.letter] = {
						spritesheet = 1 + t.page,
						frame = #font.spritesheets[1 + t.page].frames
					}
				end
			elseif tag == "kerning" then
				font.kernings[string.char(t.first) .. string.char(t.second)] = 0 + t.amount
			end
		end
		for k, v in pairs(font.spritesheets) do
			font.spritesheets[k].sheet = graphics.newImageSheet(path .. v.file, v)
		end
		for k, v in pairs(font.sprites) do
			font.sprites[k].frame = v.frame
		end
		return font
	end
	local instance = options.parent and display.newGroup() or display.newGroup()
	if options.parent then
		options.parent:insert(instance)
		instance.anchorChildren = true
	end
	local fontFile
	for size, font in pairsByKeys(options.font) do
		fontFile = font
		if size >= options.fontSize then
			break
		end
	end
	if not M.cache[fontFile] then
		M.cache[fontFile] = loadFont(fontFile)
	end
	instance.bitmapFont = M.cache[fontFile]
	function instance:anchor()
		local w, h = self._width or self.width, self.height
		local x, y = self.anchorX or 0.5, self.anchorY or 0.5
		for i = self.numChildren, 1, -1 do
			if self[i]._x and self[i]._y then
				self[i].x = self[i]._x
				self[i].y = self[i]._y
				self[i]:translate(-w * x, -h * y)
			end
		end
	end
	function instance:justify(align)
		if not self._width and not self.forceAlign then
			return false
		end
		local letter = self[1]
		if not letter then
			return false
		end
		align = self.align or "left"
		local x = 0
		local last = 1
		local lastX = letter.x
		local w = self._width or self.width
		local newLine = false
		for i = 1, self.numChildren do
			if self[i]._x and self[i]._y then
				x = self[i].x + self[i].width
				if lastX > x or i == self.numChildren then
					local diff = w - lastX
					if align == "right" then
						diff = diff - w / 2
					elseif align == "center" then
						if newLine then
							diff = diff * 0.5 - self[i - 1].width / 2
						else
							diff = diff * 0.5
						end
					else
						diff = 0
					end
					for j = last, i - (i == self.numChildren and 0 or 1) do
						self[j]:translate(diff, 0)
						self[j]._x = self[j].x
						self[i].xScale = self[i]._xScale
						self[i].yScale = self[i]._yScale
					end
					last = i
					if i < self.numChildren then
						newLine = true
					end
				end
				lastX = x - self[i].width / 2
			end
		end
	end
	function instance:setColor()
		if not self.color or not self.numChildren then
			return true
		end
		for i = 1, self.numChildren do
			if self.colorChars and self.colorChars[i] then
				self[i]:setFillColor(unpack(Color.gold))
			else
				self[i]:setFillColor(unpack(self.color))
			end
		end
	end
	function instance:render()
		local text = tostring(self.text)
		local font = self.bitmapFont
		local info = font.info
		local scale = self.fontSize / info.size
		self.forceAlign = nil
		for i = self.numChildren, 1, -1 do
			display.remove(self[i])
		end
		local x, y = 0, 0
		local last = ""
		local lastWord = 0
		local function kern(x, pair)
			if font.kernings[pair] then
				x = x + font.kernings[pair]
			end
			return x
		end
		if text and text:find("{") then
			self.colorChars = {}
			local color = false
			local actualChar = 1
			for i = 1, text:len() do
				if text:sub(i, i) ~= " " and text:sub(i, i) ~= "}" and text:sub(i, i) ~= "{" then
					actualChar = actualChar + 1
				end
				if text:sub(i, i) == "{" then
					color = true
				elseif text:sub(i + 1, i + 1) == "}" then
					color = false
				end
				if color then
					self.colorChars[actualChar] = true
				end
			end
			text = text:gsub("{", "")
			text = text:gsub("}", "")
		end
		if text then
			for letter in string.gmatch(text .. "\n", "(.)") do
				if letter == "\n" then
					x = 0
					y = y + (self.lineSpacing or info.lineHeight * scale)
					self.forceAlign = true
				elseif font.chars[letter] then
					if 0 < tonumber(font.chars[letter].width) and 0 < tonumber(font.chars[letter].height) then
						local glyph = display.newImage(font.spritesheets[font.sprites[letter].spritesheet].sheet, font.sprites[letter].frame)
						x = kern(x, last .. letter)
						glyph.anchorX, glyph.anchorY = 0, 0
						glyph.xScale = scale
						glyph.yScale = scale
						glyph.x = scale * (font.chars[letter].xoffset + x)
						glyph.y = scale * (font.chars[letter].yoffset + y)
						glyph._x = glyph.x
						glyph._y = glyph.y
						glyph._xScale = glyph.xScale
						glyph._yScale = glyph.yScale
						glyph.chr = letter
						last = letter
						lastWord = lastWord + 1
						self:insert(glyph)
					elseif letter == " " then
						lastWord = 0
					end
					x = x + font.chars[letter].xadvance
					if self._width and x * scale > self._width then
						x = 0
						y = y + (self.lineSpacing or info.lineHeight * scale)
						for i = self.numChildren - lastWord + 1, self.numChildren do
							local glyph = self[i]
							local wrapped = glyph.chr
							x = kern(x, last .. wrapped)
							glyph.x = scale * (font.chars[wrapped].xoffset + x)
							glyph.y = scale * (font.chars[wrapped].yoffset + y)
							glyph.xScale = scale
							glyph.yScale = scale
							glyph._x = glyph.x
							glyph._y = glyph.y
							x = x + font.chars[wrapped].xadvance
							last = wrapped
						end
					end
				end
			end
		end
		self:anchor()
		self:justify()
		self:setColor()
	end
	instance = addPropertyUpdate(instance)
	function instance:propertyUpdate(event)
		if event.key == "text" then
			self.text = event.value
			self:render()
		elseif event.key == "anchorX" then
			self.anchorX = event.value
			self:anchor()
		elseif event.key == "anchorY" then
			self.anchorY = event.value
			self:anchor()
		elseif event.key == "align" then
			self.align = event.value
			self:justify()
		elseif event.key == "fontSize" then
			self.fontSize = event.value
			self:render()
		elseif event.key == "width" then
			self._width = event.value
			self:render()
		elseif event.key == "x" then
			self._x = event.value
			self.x = self._x
		elseif event.key == "y" then
			self._y = event.value
			self.y = self._y
		end
	end
	function instance:finalize(event)
		self:removeEventListener("propertyUpdate")
	end
	function instance:setFillColor(r, g, b)
		self.color = {
			r,
			g,
			b
		}
		self:setColor()
	end
	instance.align = options.align or "left"
	instance.fontSize = options.fontSize or 24
	instance.size = instance.fontSize
	instance.x = options.x or 0
	instance.y = options.y or 0
	instance._x, instance._y = instance.x, instance.y
	instance._width = options.width
	instance.text = options.text
	instance.lineSpacing = options.lineSpacing
	instance:render()
	instance:addEventListener("propertyUpdate")
	instance:addEventListener("finalize")
	return instance
end
return M
