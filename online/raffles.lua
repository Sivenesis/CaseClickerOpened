local Raffles = {
	server = "offline",
	points = 0
}

function Raffles.connect(successCallback)
	Game.others.rafflePoints = Game.others.rafflePoints or 20
	Raffles.points = Game.others.rafflePoints

	timer.performWithDelay(50, function()
		composer.gotoScene("scenes.nethub.raffles", {
			params = {
				day = tonumber(os.date("%j")) or 1,
				pointLimit = 100
			}
		})
		if successCallback then
			successCallback()
		end
	end)
end

function Raffles.addPoints(points, successFunc)
	points = tonumber(points) or 0
	Raffles.points = (Raffles.points or 0) + points
	Game.others.rafflePoints = Raffles.points
	Game.save()

	GUI.showMessageBox(Lang.common.success, Lang.raffles.pointsAddSuccess)
	if successFunc then
		successFunc()
	end
end

function Raffles.usePoints(points, successFunc)
	points = tonumber(points) or 0
	Raffles.points = math.max(0, (Raffles.points or 0) - points)
	Game.others.rafflePoints = Raffles.points
	Game.save()

	if successFunc then
		successFunc()
	end
end

return Raffles
