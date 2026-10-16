local widget = require("widget")
local scene = composer.newScene()
function scene:create(event)
	local sceneGroup = self.view
	local box = GUI.drawMainBox(sceneGroup, "")
end
function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	if phase == "will" then
		Menu.show()
	elseif phase == "did" then
	end
end
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
