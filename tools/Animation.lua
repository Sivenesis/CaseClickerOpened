Animation = {}
Animations = {
	sparks1 = {
		size = 300,
		cols = 6,
		rows = 2,
		scale = 0.6
	},
	poof = {
		size = 300,
		cols = 4,
		rows = 3,
		time = 500,
		scale = 0.8
	},
	explosion = {
		size = 300,
		cols = 4,
		rows = 3,
		scale = 1.2
	}
}
local animationSheets = {}
function Animation.show(name, x, y, options)
	local anim = Animations[name]
	local options = options or {}
	if not animationSheets[name] then
		animationSheets[name] = graphics.newImageSheet("images/animations/" .. name .. ".png", {
			width = anim.size,
			height = anim.size,
			numFrames = anim.cols * anim.rows
		})
	end
	local sequenceData = {
		name = name,
		start = 1,
		count = anim.cols * anim.rows,
		time = options.time or anim.time or 500,
		loopCount = 1,
		loopDirection = "forward"
	}
	if options.infinite then
		sequenceData.loopCount = 0
	end
	local sprite = display.newSprite(animationSheets[name], sequenceData)
	if options.parent then
		options.parent:insert(sprite)
	end
	sprite.anchorX = 0.5
	sprite.anchorY = 0.5
	sprite.x = x
	sprite.y = y
	sprite:rotate(math.random(1, 360))
	local baseScale = options.scale or 1
	local scale = baseScale * ((100 + math.random(80, 120)) / 100)
	sprite.xScale = scale * (anim.scale or 1)
	sprite.yScale = scale * (anim.scale or 1)
	if anim.fadeOutStart then
		timer.performWithDelay(anim.fadeOutStart, function()
			transition.to(sprite, {
				alpha = 0,
				time = sequenceData.time - 5 - anim.fadeOutStart
			})
		end)
	end
	sprite:play()
	if not options.infinite then
		sprite:addEventListener("sprite", function(event)
			if event.phase == "ended" then
				sprite:removeSelf()
			end
		end)
	end
	return sprite
end
