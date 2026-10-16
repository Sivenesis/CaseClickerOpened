ColorTools = {}
function ColorTools.rgb(r, g, b)
	return r / 255, g / 255, b / 255
end
function ColorTools.lighten(color, value)
	local value = value or 2
	return {
		math.min(color[1] * value, 255),
		math.min(color[2] * value, 255),
		math.min(color[3] * value, 255)
	}
end
function ColorTools.darken(color, value)
	local value = value or 2
	return {
		math.max(color[1] / value, 0),
		math.max(color[2] / value, 0),
		math.max(color[3] / value, 0)
	}
end
return ColorTools
