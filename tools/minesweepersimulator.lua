if not Minesweeper then
	require("games.minesweeper")
end
local simulationTickets = 1000
local simulateGame = function(variant, tickets)
	local mines = variant.mines
	local map = Minesweeper.createMap(mines)
	local profit = -tickets
	local uncoveredTiles = 0
	local uncoveredMap = Minesweeper.createMap(0)
	while true do
		local x, y = 0
		while true do
			x = math.random(1, Minesweeper.mapSize)
			y = math.random(1, Minesweeper.mapSize)
			if uncoveredMap[x][y] == 0 then
				break
			end
		end
		uncoveredMap[x][y] = 1
		if map[x][y] == 1 then
			return profit
		end
		uncoveredTiles = uncoveredTiles + 1
		local tilePrize = tickets * uncoveredTiles * variant.profitMultiplier
		profit = profit + tilePrize
	end
end
local function simulateMinesweeper()
	print("======================================")
	print("Simulating Minesweeper...")
	print("Map size: " .. Minesweeper.mapSize .. "x" .. Minesweeper.mapSize)
	print("Simulating with " .. simulationTickets .. " tickets")
	for _, variant in ipairs(Minesweeper.variants) do
		print("======================================")
		print("Variant with " .. variant.mines .. " mines")
		local totalProfit = 0
		for i = 1, 300000 do
			totalProfit = totalProfit + simulateGame(variant, simulationTickets)
		end
		print("Profit: " .. totalProfit / 300000)
	end
end
simulateMinesweeper()
