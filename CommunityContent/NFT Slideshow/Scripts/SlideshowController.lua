--[[
-----------------
-----------------
-----------------

Package Name: NFT Slideshow
Version: 1.2
Author: DoubleA

-----------------
-----------------
-----------------

Description:

The script will load NFTs at the start. It also detects if the UI needs updating or has been interacted with.
There is also a trigger that will display the screen space UI container.

See README for more information.

-----------------
-----------------
-----------------

]]--

--API References
local ASYNC_BLOCKCHAIN = require(script:GetCustomProperty("AsyncBlockchain"))

--Asset References
local IMAGE_TEMPLATE = script:GetCustomProperty("ImageTemplate")
local TWEEN_SCROLL = script:GetCustomProperty("TweenScroll")

--Object References
local COMPONENT_ROOT = script:GetCustomProperty("ComponentRoot"):WaitForObject()
local SCREEN_UICONTAINER = script:GetCustomProperty("ScreenUIContainer"):WaitForObject()
local CLOSE_BUTTON = script:GetCustomProperty("CloseButton"):WaitForObject()
local TRIGGER = script:GetCustomProperty("Trigger"):WaitForObject()
local FIRST_BUTTON = script:GetCustomProperty("First"):WaitForObject()
local PREVIOUS_BUTTON = script:GetCustomProperty("Previous"):WaitForObject()
local INDEX_TEXT = script:GetCustomProperty("Index"):WaitForObject()
local NEXT_BUTTON = script:GetCustomProperty("Next"):WaitForObject()
local LAST_BUTTON = script:GetCustomProperty("Last"):WaitForObject()
local TITLE_TEXT = script:GetCustomProperty("TitleText"):WaitForObject()
local TITLE_WORLD_TEXT = script:GetCustomProperty("TitleWorldText"):WaitForObject()

--UI Panel Object References
local PANELS = {
	script:GetCustomProperty("ScreenScrollPanel"):WaitForObject(),
	script:GetCustomProperty("WorldImagePanel"):WaitForObject()
}

--Component Root Custom Properties
local TITLE = COMPONENT_ROOT:GetCustomProperty("Title")
local USE_LOCAL_PLAYER = COMPONENT_ROOT:GetCustomProperty("UseLocalPlayer")
local CONTRACT_ADDRESSES = COMPONENT_ROOT:GetCustomProperty("ContractAddresses")
local OWNER_ADDRESSES = COMPONENT_ROOT:GetCustomProperty("OwnerAddresses")
local TOKEN_IDS = COMPONENT_ROOT:GetCustomProperty("TokenIds")
local DISABLE_TRIGGER = COMPONENT_ROOT:GetCustomProperty("DisableTrigger")

--Constants
local LOCAL_PLAYER = Game.GetLocalPlayer()

--Variables
local isOverlapping = false
local imageAmount = 0
local imageIndex = 0
local tweenTask = nil

-- nil SetPanelTween(UIPanel, int)
-- Will create a tween animation to move the panel to display the current image
-- Uses custom properties on panel
local function SetPanelTween(panel, targetIndex)
	local PANEL_OFFSET = panel:GetCustomProperty("PanelOffset") or 0
	local IMAGE_SIZE = panel:GetCustomProperty("ImageSize") or 800
	local IMAGE_OFFSET = panel:GetCustomProperty("ImageOffset") or 0
	local SCROLL_SPEED = panel:GetCustomProperty("ScrollSpeed")	or 0

	local start = panel.x
	local target = PANEL_OFFSET - (targetIndex - 1) * (IMAGE_SIZE + IMAGE_OFFSET)
	
	if SCROLL_SPEED <= 0 then
		panel.x = target
		return
	end
	
	if tweenTask then tweenTask:Cancel() end

	tweenTask = Task.Spawn(function()
		local t = 0
		local lastT = time()
		while true do
			t = t + (time() - lastT)
			
			if t > SCROLL_SPEED and tweenTask then
				panel.x = target
				tweenTask:Cancel()
				tweenTask = nil
			end
			
			local val = TWEEN_SCROLL:GetValue(t / SCROLL_SPEED)
			panel.x = start + (target - start) * val
			
			lastT = time()
			Task.Wait()
		end
	end)
end

-- nil UpdateUI()
-- Sanitizes the image index and updates any UI dependant on the new index
local function UpdateUI()
	if imageAmount == 0 then
		imageIndex = 0
	end
	
	if imageIndex == 0 and imageAmount > 0 then
		imageIndex = 1
	end
	
	if imageIndex > imageAmount then
		imageIndex = imageAmount
	end
	
	FIRST_BUTTON.isInteractable = imageIndex > 1
	PREVIOUS_BUTTON.isInteractable = imageIndex > 1
	NEXT_BUTTON.isInteractable = imageIndex > 0 and imageIndex < imageAmount
	LAST_BUTTON.isInteractable = imageIndex > 0 and imageIndex < imageAmount
	
	INDEX_TEXT.text = tostring(imageIndex) .. " / " .. tostring(imageAmount)
	
	if imageIndex > 0 then
		for _, panel in ipairs(PANELS) do
			SetPanelTween(panel, imageIndex)
		end
	end
end

-- Array<String> TrimSplit(String)
-- Splits a string using a comma as delimeter and trims the shiteshapce from the results 
local function TrimSplit(str)
	local spl = {CoreString.Split(str, {delimiters = ",", removeEmptyResults = true})}
	local result = {}
	for _,i in ipairs(spl) do
		table.insert(result, CoreString.Trim(i))
	end
	return result
end

-- nil CreateImages()
-- Once the tokens are loaded, add token images to the panels
local function CreateImages(tokens)
	for _, panel in ipairs(PANELS) do
		local IMAGE_SIZE = panel:GetCustomProperty("ImageSize") or 800
		local IMAGE_OFFSET = panel:GetCustomProperty("ImageOffset") or 0
		for i, token in ipairs(tokens) do
			local x = (imageAmount + i - 1) * (IMAGE_SIZE + IMAGE_OFFSET)
			local image = World.SpawnAsset(IMAGE_TEMPLATE, {parent = panel})
			image.x = x
			image.width = IMAGE_SIZE
			image.height = IMAGE_SIZE
			ASYNC_BLOCKCHAIN.SetImageToToken(image, token)
		end
		panel.width = (imageAmount + #tokens) * (IMAGE_SIZE + IMAGE_OFFSET)
	end
	imageAmount = imageAmount + #tokens
	UpdateUI()
end

-- Array<BlockchainWallet> LoadWallets(Player)
-- Loads all wallets from a player
local function LoadWallets(player)
	local resultingWallets = {}

	local walletCollection, status, error = Blockchain.GetWalletsForPlayer(player)

	if status == BlockchainWalletResultCode.SUCCESS then
		while walletCollection do
			local wallets = walletCollection:GetResults()

			for _, wallet in ipairs(wallets) do
				table.insert(resultingWallets, wallet)
			end

			if walletCollection.hasMoreResults then
				walletCollection = walletCollection:GetMoreResults()
				
				Task.Wait() -- Wait a frame. Give the CPU breathing room
			else
				walletCollection = nil
			end
		end
	end

	return resultingWallets
end

-- nil LoadTokens()
-- Loads all tokens using asynch API and custom property for filters
local function LoadTokens()
	local contracts = TrimSplit(CONTRACT_ADDRESSES)
	local owners = TrimSplit(OWNER_ADDRESSES)
	local ids = TrimSplit(TOKEN_IDS)
	
	if USE_LOCAL_PLAYER or #owners > 0 then
		for _, owner in ipairs(owners) do
			if #contracts > 0 then
				for _, contract in ipairs(contracts) do
					local params = {owner, {contractAddress = contract, tokenIds = #ids > 0 and ids or nil}}
					ASYNC_BLOCKCHAIN.LoadTokens(Blockchain.GetTokensForOwner, params, CreateImages)
				end
			else
				local params = #ids > 0 and {owner, {tokenIds = ids}} or {owner}
				ASYNC_BLOCKCHAIN.LoadTokens(Blockchain.GetTokensForOwner, params, CreateImages)
			end
		end
		if USE_LOCAL_PLAYER then
			Task.Spawn(function()
				local wallets = LoadWallets(LOCAL_PLAYER)
				for _, wallet in ipairs(wallets) do
					if #contracts > 0 then
						for _, contract in ipairs(contracts) do
							local params = {wallet.address, {contractAddress = contract, tokenIds = #ids > 0 and ids or nil}}
							ASYNC_BLOCKCHAIN.LoadTokens(Blockchain.GetTokensForOwner, params, CreateImages)
						end
					else
						local params = #ids > 0 and {wallet.address, {tokenIds = ids}} or {wallet.address}
						ASYNC_BLOCKCHAIN.LoadTokens(Blockchain.GetTokensForOwner, params, CreateImages)
					end
				end
			end)
		end
	else
		for _, contract in ipairs(contracts) do
			local params = #ids > 0 and {contract, {tokenIds = ids}} or {contract}
			ASYNC_BLOCKCHAIN.LoadTokens(Blockchain.GetTokens, params, CreateImages)
		end
	end
end

-- nil SetUIVisibility(Bool)
-- Set the visibility of the cursor and Screen Space UI Container
local function SetUIVisibility(isVisible)
	UI.SetCursorVisible(isVisible)
	UI.SetCanCursorInteractWithUI(isVisible)
	SCREEN_UICONTAINER.visibility = isVisible and Visibility.FORCE_ON or Visibility.FORCE_OFF
end

-- nil SetTitleText(String)
-- Set the text of the World and Screen Title
local function SetTitleText(text)
	TITLE_TEXT.text = text
	TITLE_WORLD_TEXT.text = text
end

--Trigger events
function OnBeginOverlap(trigger, other)
	if other:IsA("Player") then
		TRIGGER.isInteractable = true
		isOverlapping = true
	end
end

function OnEndOverlap(trigger, other)
	if other:IsA("Player") then
		TRIGGER.isInteractable = false
		isOverlapping = false
		SetUIVisibility(false)
	end
end

function OnInteracted(trigger, other)
	if other:IsA("Player") then
		TRIGGER.isInteractable = false
		SetUIVisibility(true)
	end
end

--Button Events
function OnCloseButtonClicked(button)
	SetUIVisibility(false)
	if isOverlapping then
		TRIGGER.isInteractable = true
	end
end

local function OnFirstButtonClick(button)  
	imageIndex = 1
	UpdateUI()
end

local function OnPreviousButtonClick(button)  
	imageIndex = imageIndex - 1
	UpdateUI()
end

local function OnNextButtonClick(button)  
	imageIndex = imageIndex + 1
	UpdateUI()
end

local function OnLastButtonClick(button)  
	imageIndex = imageAmount
	UpdateUI()
end

--Connect events to handler functions
if DISABLE_TRIGGER then
	TRIGGER.isInteractable = false
else
	TRIGGER.beginOverlapEvent:Connect(OnBeginOverlap)
	TRIGGER.endOverlapEvent:Connect(OnEndOverlap)
	TRIGGER.interactedEvent:Connect(OnInteracted)
end

CLOSE_BUTTON.clickedEvent:Connect(OnCloseButtonClicked)
FIRST_BUTTON.pressedEvent:Connect(OnFirstButtonClick)
PREVIOUS_BUTTON.pressedEvent:Connect(OnPreviousButtonClick)
NEXT_BUTTON.pressedEvent:Connect(OnNextButtonClick)
LAST_BUTTON.pressedEvent:Connect(OnLastButtonClick)

--Initial Function Calls
SetTitleText(TITLE)
UpdateUI()
SetUIVisibility(false)
LoadTokens()