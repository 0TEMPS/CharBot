local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local CBD = {}

function CBD.CreateUi(Title, ClientInfo)
	local Window = Rayfield:CreateWindow({
		Name = Title,
		LoadingTitle = "CharBot Interface Suite",
		LoadingSubtitle = "by [💬] OQAL",
		ConfigurationSaving = {
			Enabled = true,
			FolderName = nil, -- Create a custom folder for your hub/game
			FileName = "Big Hub"
		},
		Discord = {
			Enabled = false,
			Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
			RememberJoins = true -- Set this to false to make them join the discord every time they load it up
		},
		KeySystem = false, -- Set this to true to use our key system
		KeySettings = {
			Title = "Untitled",
			Subtitle = "Key System",
			Note = "No method of obtaining the key is provided",
			FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
			SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
			GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
			Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
		}
	})
	
	local Info = Window:CreateTab("Info", 16498133093)
	local Section = Info:CreateSection("Client Info")
		print("made it")
	-- Create an array to store the order of keys
	local order = {"BotName", "BotUserID", "BotPath", "BotCharacter", "BotHumanoid", "ClientVersion", "CurrentEnvironment", "Executor", "ClientTimezone", "ClientStartTime", "RigType"}

	-- Iterate over the keys in the order array
	for i, key in ipairs(order) do
		-- Iterate over the sub-tables in ClientInfo
		for subTableName, subTable in pairs(ClientInfo["BotInfo"]) do
			-- Check if the current sub-table has the current key
			if subTable[key] then
				local Label = Info:CreateLabel(tostring(i).." = "..tostring(key)..",")
			end
		end
	end
end

return CBD
