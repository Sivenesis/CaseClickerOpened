local json = require("json")
local crypto = require("crypto")
local M = {}
local floor = math.floor
local tostring = tostring
local table_insert = table.insert
local function decimalToBase85(num)
	local base = 85
	local final = {}
	while 0 < num do
		table_insert(final, 1, num % base)
		num = floor(num / base)
	end
	while #final < 5 do
		table_insert(final, 1, 0)
	end
	return final
end
local base85ToDecimal = function(b85)
	local base = 85
	local l = #b85
	local final = 0
	for i = l, 1, -1 do
		local digit = b85[i]
		local val = digit * base ^ (l - i)
		final = final + val
	end
	return final
end
local function decimalToBinary(num)
	local base = 2
	local bits = 8
	local final = ""
	while 0 < num do
		final = "" .. num % base .. final
		num = floor(num / base)
	end
	local l = final:len()
	if l == 0 then
		final = "0" .. final
	end
	while final:len() % 8 ~= 0 do
		final = "0" .. final
	end
	return final
end
local binaryToDecimal = function(bin)
	local base = 2
	local l = bin:len()
	local final = 0
	for i = l, 1, -1 do
		local digit = bin:sub(i, i)
		local val = digit * base ^ (l - i)
		final = final + val
	end
	return final
end
local function encode(substr)
	local l = substr:len()
	local combine = ""
	for i = 1, l do
		local char = substr:sub(i, i)
		local byte = char:byte()
		local bin = decimalToBinary(byte)
		combine = combine .. bin
	end
	local num = binaryToDecimal(combine)
	local b85 = decimalToBase85(num)
	local final = ""
	for i = 1, #b85 do
		local char = tostring(b85[i] + 33)
		final = final .. char:char()
	end
	if final == "!!!!!" then
		final = "z"
	end
	return final
end
local function decode(substr)
	local final = ""
	local l = substr:len()
	local combine = {}
	for i = 1, l do
		local char = substr:sub(i, i)
		local byte = char:byte()
		byte = byte - 33
		combine[i] = byte
	end
	local num = base85ToDecimal(combine)
	local bin = decimalToBinary(num)
	while bin:len() < 32 do
		bin = "0" .. bin
	end
	local l = bin:len()
	local split = 8
	for i = 1, l, split do
		local sub = bin:sub(i, i + split - 1)
		local byte = binaryToDecimal(sub)
		local char = tostring(byte):char()
		final = final .. char
	end
	return final
end
local function ascii_encode(str)
	local final = ""
	local noOfZeros = 0
	while str:len() % 4 ~= 0 do
		noOfZeros = noOfZeros + 1
		str = str .. "\000"
	end
	local l = str:len()
	for i = 1, l, 4 do
		local sub = str:sub(i, i + 3)
		final = final .. encode(sub)
	end
	final = final:sub(1, -noOfZeros - 1)
	final = "<~" .. final .. "~>"
	return final
end
local function ascii_decode(str)
	local final = ""
	str = str:sub(3, -3)
	str = str:gsub("z", "!!!!!")
	local c = 5
	local noOfZeros = 0
	while str:len() % c ~= 0 do
		noOfZeros = noOfZeros + 1
		str = str .. "u"
	end
	local l = str:len()
	for i = 1, l, c do
		local sub = str:sub(i, i + c - 1)
		final = final .. decode(sub)
	end
	final = final:sub(1, -noOfZeros - 1)
	return final
end
local Rot = function(t)
	local byte_a, byte_A = string.byte("a"), string.byte("A")
	return (string.gsub(t, "[%a]", function(char)
		local offset = char < "a" and byte_A or byte_a
		local b = string.byte(char) - offset
		b = math.mod(b + 13, 26) + offset
		return string.char(b)
	end))
end
local function scramble(t)
	return string.reverse(ascii_encode(json.encode(t)))
end
local function unscramble(t)
	return json.decode(ascii_decode(string.reverse(t)))
end
local function addHash(t)
	return string.reverse(crypto.digest(crypto.sha512, t)) .. t
end
local function validateHash(t)
	if string.reverse(string.sub(t, 1, 128)) == crypto.digest(crypto.sha512, string.sub(t, 129)) then
		return false
	else
		return true
	end
end
function M:encode(t, filename)
	return addHash(scramble(t))
end
function M:load(filename)
	local path = system.pathForFile(filename, system.DocumentsDirectory)
	local contents = ""
	local t = {}
	local file = io.open(path, "r")
	if file then
		local contents = file:read("*a")
		t = unscramble(contents)
		io.close(file)
		return t, validateHash(contents)
	end
	return nil, nil
end
return M
