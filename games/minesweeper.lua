Minesweeper = {
	mapSize = 3,
	roundProfit = 0,
	variants = {
		{
			name = "Easy",
			mines = 3,
			profitMultiplier = 0.33345
		},
		{
			name = "Medium",
			mines = 5,
			profitMultiplier = 1.0495
		},
		{
			name = "Hard",
			mines = 7,
			profitMultiplier = 3.5785
		}
	}
}
function Minesweeper.start()
	Game.minesweeper.started = true
	Game.minesweeper.lost = false
	Game.minesweeper.won = false
	Game.minesweeper.map = Minesweeper.createMap(Minesweeper.variants[Game.minesweeper.variant].mines)
	Game.minesweeper.shownMap = Minesweeper.createMap(0)
	Game.minesweeper.roundProfit = -Game.minesweeper.betAmount
	StatisticManager.addStatistic("minesweeperProfit", Game.minesweeper.betAmount)
	Game.roulette.ticketsToPlay = math.max(0, Game.roulette.ticketsToPlay - Game.minesweeper.betAmount)
end
function Minesweeper.endGame()
	Game.minesweeper.started = false
	Game.minesweeper.won = false
	Game.minesweeper.lost = false
	local lastBet = Game.minesweeper.betAmount
	Game.minesweeper.betAmount = 0
	if lastBet <= Game.roulette.balance then
		Game.minesweeper.betAmount = lastBet
		Game.roulette.balance = Game.roulette.balance - lastBet
	end
	Analytics.addEvent("Minesweeper:End")
end
function Minesweeper.createMap(mines)
	local map = {}
	for i = 1, Minesweeper.mapSize * Minesweeper.mapSize do
		map[i] = 0
	end
	local minesPlaced = 0
	while mines > minesPlaced do
		local i = math.random(1, Minesweeper.mapSize * Minesweeper.mapSize)
		if map[i] == 0 then
			map[i] = 1
			minesPlaced = minesPlaced + 1
		end
	end
	return map
end
function Minesweeper.hasBomb(tileId)
	return Game.minesweeper.map[tileId] > 0
end
function Minesweeper.getNextTilePrize()
	local uncoveredTiles = 0
	for _, tile in ipairs(Game.minesweeper.shownMap) do
		if 0 < tile then
			uncoveredTiles = uncoveredTiles + 1
		end
	end
	return math.floor(Game.minesweeper.betAmount * (uncoveredTiles + 1) * Minesweeper.variants[Game.minesweeper.variant].profitMultiplier)
end
function Minesweeper.checkForWin()
	local uncoveredTiles = 0
	for _, tile in ipairs(Game.minesweeper.shownMap) do
		if 0 < tile then
			uncoveredTiles = uncoveredTiles + 1
		end
	end
	if Minesweeper.mapSize * Minesweeper.mapSize - uncoveredTiles - Minesweeper.variants[Game.minesweeper.variant].mines == 0 then
		return true
	end
	return false
end
function Minesweeper.onMapClick(i)
	if Game.minesweeper.started == false or Game.minesweeper.lost or Game.minesweeper.shownMap[i] > 0 or Game.minesweeper.won then
		return 1
	end
	if Game.minesweeper.map[i] == 1 then
		Game.minesweeper.shownMap[i] = 1
		if 0 <= Game.minesweeper.roundProfit then
			Game.minesweeper.won = true
			StatisticManager.addStatistic("minesweepersWon")
		else
			Game.minesweeper.lost = true
			StatisticManager.addStatistic("minesweepersLost")
		end
		return 2
	end
	Game.minesweeper.shownMap[i] = Minesweeper.getNextTilePrize()
	Game.minesweeper.roundProfit = Game.minesweeper.roundProfit + Game.minesweeper.shownMap[i]
	StatisticManager.addStatistic("minesweeperProfit", Game.minesweeper.shownMap[i])
	Game.roulette.balance = Game.roulette.balance + Game.minesweeper.shownMap[i]
	if Minesweeper.checkForWin() then
		Game.minesweeper.won = true
		StatisticManager.addStatistic("minesweepersWon")
	end
	return 3
end
