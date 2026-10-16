local Validator = {
	server = "http://caseclickerinappval-env.us-east-2.elasticbeanstalk.com/validate/caseclicker/",
	points = 0
}
local base64 = require("tools.base64")
local callback, func
local function networkListener(event)
	if event.isError then
		if func then
			func(false, {
				text = Lang.common.connectionError .. "."
			})
			func = nil
		end
		return
	end
	local response = event.response
	if not response then
		if func then
			func(false)
			func = nil
		end
		return
	end
	if func then
		func(true, response)
		func = nil
	end
end
local function prepareAppleReceipt(receipt)
	receipt = receipt:sub(2, -2)
	receipt = receipt:gsub(" ", "")
	local ascii = ""
	local l = receipt:len()
	for i = 1, l, 2 do
		local hex = receipt:sub(i, i + 1)
		local dec = tonumber(hex, 16)
		if dec then
			local char = string.char(dec)
			ascii = ascii .. char
		end
	end
	local b64encode = base64.encode(ascii)
	return b64encode
end
function Validator.validate(transaction, callback)
	function func(success, response)
		if not success or not response then
			return callback(false, true)
		end
		if response == "error" then
			return callback(false)
		elseif response == "valid" then
			return callback(true)
		end
		return callback(false, true)
	end
	local platform = "google"
	if isIOS() then
		platform = "apple"
	end
	local token = transaction.token or transaction.receipt
	if isIOS() then
		token = prepareAppleReceipt(token)
	end
	local params = {
		body = "receipt=" .. token .. "&platform=" .. platform .. "&productId=" .. transaction.productIdentifier
	}
	local URL = Validator.server
	network.request(URL, "POST", networkListener, params)
end
return Validator
