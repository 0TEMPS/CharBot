local Rayfield = loadstring(game:HttpGet('https://pastebin.com/raw/z07Qd5CY'))()

local CBD = {}

function CBD.CreateUi(Title, ClientInfo)
	Window = Rayfield:CreateWindow({
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
	
	local Info = Window:CreateTab("Info", 16093328141)
	local Section = Info:CreateSection("Client Info")
		print("made it")
	-- Create an array to store the order of keys
	local order = {"BotName", "BotUserID", "BotHumanoid", "ClientVersion", "CurrentEnvironment", "Executor", "ClientTimezone", "ClientStartTime", "RigType"}
	
	for i,v in ipairs(order) do
		for i2,v2 in pairs(ClientInfo["BotInfo"]) do
			if v == i2 then
				local Label = Info:CreateLabel(tostring(i2).." = "..tostring(v2))
			end
		end
	end
	local Section = Info:CreateSection("Server Info")
	local order2 = {"ChatType", "PlaceID", "PlaceName", "UniverseID"}

	for i,v in ipairs(order2) do
		for i2,v2 in pairs(ClientInfo["ServerInfo"]) do
			if v == i2 then
				local Label = Info:CreateLabel(tostring(i2).." = "..tostring(v2))
			end
		end
	end
	
	
	
	
end

function CBD.PingTest(ResponseTable, bottomtext)
	local Status = Window:CreateTab("Status", 16093311060)
	local Section = Status:CreateSection("API Status")
	
	for i,v in pairs(ResponseTable) do
		local Label = Status:CreateLabel(tostring(i).." = "..tostring(v))
	end
	
	local Section = Status:CreateSection("User-Identifier")
	local Paragraph = Status:CreateParagraph({Title = "", Content = bottomtext})
	
end

return CBD
