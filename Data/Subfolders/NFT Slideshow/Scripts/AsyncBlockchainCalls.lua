--[[
	Async Blockchain Calls
	v1.0
	by: DoubleA
	
	Recycled code from the Async Token Loader by standardcombo.
	
	Loads blockchain tokens and sets images to tokens.
	Handles error cases and retries in case of error.
	
	Uses a queue for requests handled by an asynchronous Task.
	Also uses pcall to handle Blockchain request errors.
	
	----------
	API
	----------
	
	IsSettingImage()
	
	SetImageToToken(image, token, callbackFunction)
	
	IsLoadingToken()
	
	LoadTokens(blockchainFunction, blockchainParameters, callbackFunction)
]]

local API = {}

local RETRIES = 20
local ERROR_WAIT = 3

local imageQueue = {}
local imageTask = nil

local tokenQueue = {}
local tokenTask = nil

function API.IsSettingImage()
	return imageTask ~= nil
end

function API.IsLoadingToken()
	return tokenTask ~= nil
end

function API.SetImageToToken(image, token)
	-- Setup request data for setting image to token
	local request = {image = image, token = token}
	table.insert(imageQueue, request)
	
	if not imageTask then
		imageTask = Task.Spawn(ImageRunner)
	end
end

function ImageRunner()
	while #imageQueue > 0 do
		local request = imageQueue[1]
		table.remove(imageQueue, 1)
		
		local image = request.image
		local token = request.token
		local callbackFunction = request.callbackFunction
		
		for i = 1, RETRIES do
			local status, err = pcall(function()
				image:SetBlockchainToken(token)
			end)
			if status then
				break
			end
			warn("Blockchain error. Probably rate limit reached. Trying again in "..ERROR_WAIT.." seconds.")
			Task.Wait(ERROR_WAIT)
		end
	end
	imageTask = nil
end

function API.LoadTokens(blockchainFunction, blockchainParameters, callbackFunction)
	-- Setup request data for blockchain loading
	local request = {blockchainFunction = blockchainFunction, blockchainParameters = blockchainParameters, callbackFunction = callbackFunction}
	table.insert(tokenQueue, request)
	
	if not tokenTask then
		tokenTask = Task.Spawn(TokenRunner)
	end
end


function TokenRunner()
	while #tokenQueue > 0 do
		local request = tokenQueue[1]
		table.remove(tokenQueue, 1)
		
		local blockchainFunction = request.blockchainFunction
		local blockchainParameters = request.blockchainParameters
		local callbackFunction = request.callbackFunction
		
		local resultingTokens = {}
		local collection = nil
		
		for i = 1, RETRIES do
			pcall(function()
				collection = blockchainFunction(table.unpack(blockchainParameters))
			end)
			if collection then
				break
			end
			warn("Blockchain error. Probably rate limit reached. Trying again in "..ERROR_WAIT.." seconds.")
			Task.Wait(ERROR_WAIT)
		end
		
		while collection do
			local tokens = collection:GetResults()
		
			for _,t in ipairs(tokens) do
				table.insert(resultingTokens, t)
			end
			
			if collection.hasMoreResults then
				collection = collection:GetMoreResults()
			
				Task.Wait() -- Wait a frame. Give the CPU breathing room
			else
				collection = nil
			end
		end

		callbackFunction(resultingTokens)
	end
	tokenTask = nil
end

return API