local OnlineTime = {}
local lastRefresh, lastTime
local servers = {
	{
		URL = "http://caseclicker.eu/time",
		offset = -3600
	},
	{
		URL = "http://api.timezonedb.com/v2/list-time-zone?key=4ZRWFQZG4CS0&format=json&by=zone&zone=Europe/London",
		json = true
	}
}
function OnlineTime.get(callback, minimumInterval)
	if lastRefresh and minimumInterval > os.time() - lastRefresh then
		return callback(true, lastTime)
	end
	local server = choose(servers)
	network.request(server.URL, "GET", function(event)
		if event.isError or not event.response then
			return callback(false)
		end
		local currentTime = os.time()
		if server.json then
			local response = json.decode(event.response)
			if not response or response.status ~= "OK" or not response.zones[1] then
				return callback(false)
			end
			currentTime = tonumber(response.zones[1].timestamp)
		else
			currentTime = tonumber(event.response)
		end
		if not currentTime then
			return callback(false)
		end
		if server.offset then
			currentTime = currentTime - server.offset
		end
		lastRefresh = os.time()
		lastTime = currentTime
		return callback(true, currentTime)
	end)
end
return OnlineTime
