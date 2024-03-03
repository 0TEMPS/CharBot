local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/0TEMPS/CharBot/main/RayfieldUI-CharBotCustom.lua'))()

function PrintTable(tableobj)
	if typeof(tableobj) == "table" then
		print("PRNT TABLE : "..tostring(tableobj))
		for i,v in pairs(tableobj) do
			wait(0.01)
			if typeof(v) == "table" then
				print("\n\n-- // -- "..tostring(i).." TABLE -- // -- \n")
				PrintTable(v)
			else
				print(tostring(i).." = "..tostring(v))
			end
		end
	else
		warn("PrintTable Function : Object is not a table!")
	end
end

local CBD = {}

function CBD.CreateUi(Title)
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
end

function CBD.NewsTab(NewsTable)
	local News = Window:CreateTab("News")
	local Section = News:CreateSection("News and Updates regarding CharBot")

	for i,v in pairs(NewsTable.News) do
		for i2,v2 in pairs(v) do
			print(tostring(v2))
			PrintTable(v2)
			local Paragraph = News:CreateParagraph({Title = tostring(i2), Content = tostring(v2)})
		end
	end  
end

function CBD.PingTest(ResponseTable, bottomtext)
	local Status = Window:CreateTab("Status")
	local Section = Status:CreateSection("API Status")

	for i,v in pairs(ResponseTable) do
		local Label = Status:CreateLabel(tostring(i).." = "..tostring(v))
	end

	local Section = Status:CreateSection("User-Identifier")
	local Paragraph = Status:CreateParagraph({Title = "", Content = bottomtext})

end

function CBD.ClientInfo(ClientInfo)
	local Info = Window:CreateTab("Info")
	local Section = Info:CreateSection("Client Info")
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

	local Paragraph = Info:CreateParagraph({Title = "Hardware ID", Content = gethwid(), ", "})
end
function CBD.CreateCommandOutput()
	Output = Window:CreateTab("Output")
	local Section = Output:CreateSection("Output / Command Logs")

end

function CBD.Output(Text)
	local Label = Output:CreateLabel(Text)
	wait(20)
	Label:Remove()
end

function CBD.CreateBotConfigTab()
	BotConfig = Window:CreateTab("Bot Config")
end

function CBD.BotConfigSettings(BotConfigTable)
	local Section = BotConfig:CreateSection("General Settings")

	local Label = BotConfig:CreateLabel("Owner = "..BotConfigTable["General Settings"]["Owner"])

	local Paragraph = BotConfig:CreateParagraph({Title = "Approval Words", Content = table.concat(BotConfigTable["General Settings"]["Approval Words"], ", ")})

	local Paragraph = BotConfig:CreateParagraph({Title = "Disapproval Words", Content = table.concat(BotConfigTable["General Settings"]["DisapprovalWords"], ", ")})

	local Paragraph = BotConfig:CreateParagraph({Title = "Greetings", Content = table.concat(BotConfigTable["General Settings"]["Greetings"], ", ")})

	local Label = BotConfig:CreateLabel("AutoJumpWhenSitting = "..tostring(BotConfigTable["General Settings"]["AutoJumpWhenSitting"]))
	local Label = BotConfig:CreateLabel("Error-Logging = "..tostring(BotConfigTable["General Settings"]["Error-Logging"]))
	local Label = BotConfig:CreateLabel("Log-Commands = "..tostring(BotConfigTable["General Settings"]["Log-Commands"]))

	local Label = BotConfig:CreateLabel("NativeCurrency = "..tostring(BotConfigTable["General Settings"]["NativeCurrency"]))
	local Label = BotConfig:CreateLabel("CurrencySymbol = "..tostring(BotConfigTable["General Settings"]["CurrencySymbol"]))

	local Label = BotConfig:CreateLabel("PlayerLockBrickVector = "..tostring(BotConfigTable["General Settings"]["PlayerLockBrickVector"]))

	local Section = BotConfig:CreateSection("Chat Settings")

	local Label = BotConfig:CreateLabel("ChatPublicly = "..tostring(BotConfigTable["Chat Settings"].ChatPublicly))
	local Label = BotConfig:CreateLabel("ChatLoadingOutputs = "..tostring(BotConfigTable["Chat Settings"].ChatLoadingOutputs))
	local Label = BotConfig:CreateLabel("ChatStartupGreeting = "..tostring(BotConfigTable["Chat Settings"].ChatStartupGreeting))
	local Label = BotConfig:CreateLabel("ChatErrorLogs = "..tostring(BotConfigTable["Chat Settings"].ChatErrorLogs))
	local Label = BotConfig:CreateLabel("ChatPrefix = "..tostring(BotConfigTable["Chat Settings"].ChatPrefix))

	local Section = BotConfig:CreateSection("API Keys")

	local Label = BotConfig:CreateLabel("APININJA_KEY = "..tostring(BotConfigTable["API Keys"].APININJA_KEY))
	local Label = BotConfig:CreateLabel("RBLX_TRADE_CSRF = "..tostring(BotConfigTable["API Keys"].RBLX_TRADE_CSRF))


end

function CBD.CommandListTab()
	CommandList = Window:CreateTab("Command List")
end

function CBD.AddCommands(CommandTable)
	local What = CommandList:CreateSection("Command List")
	for i,v in pairs(CommandTable) do
		local info = debug.getinfo(v)
		local LabelText = ""
		
		if info and info.isvararg then
			-- If it has arguments, print them
			local args = {}
			for i = 1, info.nparams do
				args[i] = info.paramnames[i]
			end
			print("Arguments:", table.concat(args, ", "))
			LabelText = i.."("..table.concat(args, ", ")..")"
		else
			LabelText = i.."(No Arguments Required)"
		end
		
		local Label = CommandList:CreateLabel(tostring(i))
	end
end

return CBD
