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
	for i =1 , #ClientInfo["BotInfo"] do
		print(tostring(ClientInfo["BotInfo"][i]))
		print(tostring(ClientInfo["BotInfo"][i].Name))
		local Label = Info:CreateLabel(tostring(ClientInfo["BotInfo"][i]).." = "..tostring(ClientInfo["BotInfo"][i].Name)..",") --->>  bla,  bla2, bla3
	end
	wait(0.3)
	for i =1 , #ClientInfo["ServerInfo"] do
		local Label = Info:CreateLabel(tostring(ClientInfo["BotInfo"][i]).." = "..tostring(ClientInfo["BotInfo"][i].Name)..",") --->>  bla,  bla2, bla3
	end
end

return CBD
