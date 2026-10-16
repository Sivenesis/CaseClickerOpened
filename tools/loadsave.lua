local M = {}
local base64 = require("tools.base64")
local LuaFileSystem = require("lfs")
local _defaultLocation = system.DocumentsDirectory
local _realDefaultLocation = _defaultLocation
local _validLocations = {
	[system.DocumentsDirectory] = true,
	[system.CachesDirectory] = true,
	[system.TemporaryDirectory] = true
}
local planeteTable = {
	[1] = "01101000",
	[2] = "01100001",
	[3] = "01101011",
	[4] = "01100011",
	[5] = "01110110",
	[6] = "01111000",
	[7] = "01110001",
	[8] = "01111010",
	[9] = "01110000",
	[10] = "01101101"
}
function M.loadCheckFile()
	local path = system.pathForFile("planetes", system.DocumentsDirectory)
	local contents = ""
	local file = io.open(path, "r")
	if file then
		local contents = file:read("*a")
		io.close(file)
		os.remove(path)
		for key, val in ipairs(planeteTable) do
			if val == contents then
				return key
			end
		end
	end
	return 0
end
function M.saveCheckFile(saveSlot)
	local path = system.pathForFile("planetes", system.DocumentsDirectory)
	local file = io.open(path, "w")
	if file then
		file:write(planeteTable[saveSlot])
		io.close(file)
		return true
	else
		return false
	end
end
function M.saveTable(t, filename, location)
	if location and not _validLocations[location] then
		error("Attempted to save a table to an invalid location", 2)
	else
		location = location or _defaultLocation
	end
	local path = system.pathForFile(filename, location)
	local file = io.open(path, "w")
	if file then
		local contents = json.encode(t)
		file:write(contents)
		io.close(file)
		return true
	else
		return false
	end
end
function M.loadTable(filename, location)
	if location and not _validLocations[location] then
		error("Attempted to load a table from an invalid location", 2)
	else
		location = location or _defaultLocation
	end
	local path = system.pathForFile(filename, location)
	local contents = ""
	local file = io.open(path, "r")
	if file then
		local contents = file:read("*a")
		if filename:sub(1, 2) == "cs" then
			contents = base64.decode(contents)
		end
		contents = json.decode(contents)
		io.close(file)
		return contents
	end
	return nil
end
function M.changeDefault(location)
	if location and not location then
		error("Attempted to change the default location to an invalid location", 2)
	else
		location = location or _realDefaultLocation
	end
	_defaultLocation = location
	return true
end
function M.print_r(t)
	local print_r_cache = {}
	local function sub_print_r(t, indent)
		if print_r_cache[tostring(t)] then
			print(indent .. "*" .. tostring(t))
		else
			print_r_cache[tostring(t)] = true
			if type(t) == "table" then
				for pos, val in pairs(t) do
					if type(val) == "table" then
						print(indent .. "[" .. pos .. "] => " .. tostring(t) .. " {")
						sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8))
						print(indent .. string.rep(" ", string.len(pos) + 6) .. "}")
					elseif type(val) == "string" then
						print(indent .. "[" .. pos .. "] => \"" .. val .. "\"")
					else
						print(indent .. "[" .. pos .. "] => " .. tostring(val))
					end
				end
			else
				print(indent .. tostring(t))
			end
		end
	end
	if type(t) == "table" then
		print(tostring(t) .. " {")
		sub_print_r(t, "  ")
		print("}")
	else
		sub_print_r(t, "  ")
	end
	print()
end
M.printTable = M.print_r
return M
