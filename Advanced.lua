--[=[ CHAR-BOT
	2/20/2024 CharBot 5.1 Krampus Build
CHAR-BOT ]=] 

-- Version

local VersionName = "Char-Bot (OQAL)"
local VersionNumber = "5.3.7 (Release)"

local StartupClock = os.clock()
local ClientTimeData = os.date

local RequestTime = os.date
local StartupTime = RequestTime "%I" .. ":" .. RequestTime "%M" .. RequestTime "%p"

-- Rpblox Services
local CoreGui = game:GetService("CoreGui")
local HTTP = game:GetService("HttpService")
local Players = game:GetService("Players")
local Run = game:GetService("RunService")
local STATS = game:GetService("Stats")
local TP = game:GetService("TeleportService")
local TCS = game:GetService("TextChatService")
local LogService = game:GetService("LogService")
local PFS = game:GetService("PathfindingService")
local UGS = game:GetService("UserGameSettings")
local MS = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")


local ClientInfo = {
	["BotInfo"] = {
		BotName = Players.LocalPlayer.Name,
		BotUserID = Players.LocalPlayer.UserId,
		BotPath = Players.LocalPlayer,
		BotCharacter = Players.LocalPlayer.Character,
		BotHumanoid = Players.LocalPlayer.Character.Humanoid,

		HWID = gethwid(),

		ClientVersion = version(),
		CurrentEnvironment = nil,
		Executor = identifyexecutor(),

		ClientTimezone = ClientTimeData "%Z",
		ClientStartTime = os.time(),

		RigType = Players.LocalPlayer.Character.Humanoid.RigType,
		ValidAPINinjaKey = false




	},
	["ServerInfo"] = {
		ChatType = nil,
		PlaceID = game.PlaceId,
		PlaceName = MS:GetProductInfo(game.PlaceId).Name,
		UniverseID = nil,
	},
}

if _G.BotConfig["API Keys"].APININJA_KEY == "" or _G.BotConfig["API Keys"].APININJA_KEY == "KEY-HERE" then
else
	ClientInfo.BotInfo.ValidAPINinjaKey = true
end

local Log = {}
Log[ClientInfo["BotInfo"].BotPath] = tick()

makefolder("CharBot")

local Player = ClientInfo["BotInfo"].BotPath
local Character = ClientInfo["BotInfo"].BotCharacter
local Humanoid = ClientInfo["BotInfo"].BotHumanoid

local CLP = _G.BotConfig["Chat Settings"].ChatPublicly
local CLO = _G.BotConfig["Chat Settings"].ChatLoadingOutputs
local CEL = _G.BotConfig["Chat Settings"].ChatErrorLogs

local Owner = _G.BotConfig["General Settings"]["OwnerHighlight"]

local HLTable = _G.BotConfig["General Settings"]["OwnerHighlight"]
local TargetHLTable = _G.BotConfig["General Settings"]["OwnerHighlight"]

local Greetings = _G.BotConfig["General Settings"].Greetings
local Currency = string.lower(_G.BotConfig["General Settings"].NativeCurrency)
local CurrencySymbol = _G.BotConfig["General Settings"].CurrencySymbol

local ApprovalWords = _G.BotConfig["General Settings"]["Approval Words"]
local DisapprovalWords = _G.BotConfig["General Settings"].DisapprovalWords

local CurrentOwner = _G.BotConfig["General Settings"].Owner
local AutoJumpWhenSitting = _G.BotConfig["General Settings"].AutoJumpWhenSitting

local CommandOwnershipList = {}

local LastCommandIssuedby = CurrentOwner

table.insert(CommandOwnershipList, CurrentOwner)

local FS = loadstring(game:HttpGet("https://raw.githubusercontent.com/0TEMPS/CharBot/main/FunctionService.lua"))()

FS.Report("Starting "..VersionName.." V"..VersionNumber,CLO)
wait(0.2)
FS.Report("FunctionService API Loaded.",CLO)

print("https://apis.roblox.com/universes/v1/places/"..tostring(ClientInfo["ServerInfo"].PlaceID).."/universe")
local UniverseRequest = FS.Get_Request("https://apis.roblox.com/universes/v1/places/"..tostring(ClientInfo["ServerInfo"].PlaceID).."/universe")
ClientInfo["ServerInfo"].UniverseID = UniverseRequest.universeId

local unixdate = FS.unixtodate(ClientInfo.BotInfo.ClientStartTime)
ClientInfo.BotInfo.ClientStartTime = FS.convertmonth(unixdate.month).." "..unixdate.day..", "..unixdate.year.." @ "..unixdate.hour..":"..unixdate.min..":"..unixdate.sec
local Place = MS:GetProductInfo(game.PlaceId).Name

local CBD = loadstring(game:HttpGet("https://raw.githubusercontent.com/0TEMPS/CharBot/main/CharBotDisplay.lua"))()
CBD.CreateUi("[💬] OQAL: "..VersionName.." V"..VersionNumber, ClientInfo)
CBD.CreateCommandOutput()

if _G.BotConfig["General Settings"]["Error-Logging"] == true then
	local function onMessageOut(message, messageType)
		if tostring(messageType) == "Enum.MessageType.MessageError" then
			FS.Report("[🔴] "..message,CEL)
		end
	end

	FS.Report("Error logging enabled, errors will be reported.",CLO)
	LogService.MessageOut:Connect(onMessageOut)
elseif _G.BotConfig["General Settings"]["Error-Logging"] == false then
	FS.Report("Error logging disabled, skipping checks.",CLO)
end

if _G.BotConfig["General Settings"]["Log-Commands"] == true then
	local function onMessageOut(message, messageType)
		local output = coroutine.wrap(function()
			CBD.Output(message)
		end)
		output()
	end

	LogService.MessageOut:Connect(onMessageOut)
end

local Variables = {
	CurrentOwner = "UNKNOWN",
	CurrentTarget = "UNKNOWN",
	KeepOrbit = "UNKNOWN",
	debounce = false,
	CurrentlyWalkingToOwner = nil,
	NewOwner = game.Workspace:FindFirstChild(_G.BotConfig["General Settings"].Owner),
	ChatSpyActive = false
}

local RolimonsItemTable = FS.RolimonsValueTable()
FS.Report("Rolimons value table loaded, "..tostring(RolimonsItemTable.item_count).." items updated.", CLO)


ClientInfo["ServerInfo"].ChatType = FS.FindChatType()
if ClientInfo["ServerInfo"].ChatType == "LCS" then
	MessageFunction = Player.Chatted
elseif ClientInfo["ServerInfo"].ChatType == "TCS" then
	MessageFunction = game:GetService("TextChatService"):WaitForChild("TextChannels"):WaitForChild("RBXGeneral").MessageReceived
end

CBD.ClientInfo(ClientInfo)

CBD.NewsTab(FS.Get_Request("https://raw.githubusercontent.com/0TEMPS/CharBot/main/News.json"))

local parttowalktoo = nil

local stopbang = false

function WearingLimiteds(Playername)
	local userid = Players:GetUserIdFromNameAsync(Playername)
	local humdesc = Players:GetHumanoidDescriptionFromUserId(userid)
	local idtable = {
		["FaceIDs"] = string.split(humdesc.Face,","),
		["Hats"] = string.split(humdesc.HatAccessory,","),
		["Hairs"] = string.split(humdesc.HairAccessory,","),
		["BackHat"] = string.split(humdesc.BackAccessory,","),
		["FrontHat"] = string.split(humdesc.FrontAccessory,","),
		["FaceHat"] = string.split(humdesc.FaceAccessory,","),
		["WaistHat"] = string.split(humdesc.WaistAccessory,","),
		["NeckHat"] = string.split(humdesc.NeckAccessory,","),
		["ShoulderHat"] = string.split(humdesc.ShouldersAccessory,","),
	}

	local foundlim = false
	FS.Report("Searching for limiteds on "..Playername.."'s avatar...",CLP)
	local totalcost = 0
	for i,v in pairs(idtable) do
		for i2,v2 in pairs(v) do
			wait(0.2)
			if v2 == 0 or v2 == nil or v2 == "" or v2 == "0" then
			else

				local ItemInfo = MS:GetProductInfo(tonumber(v2))

				if ItemInfo.IsLimited == true or ItemInfo.IsLimitedUnique == true then
					print("Found a limited item, Reporting...")
					local iteminfo = RolimonsItemTable.items[v2]

					if iteminfo[3] >= 1000000 or iteminfo[4] >= 1000000 then
						FS.Report(Playername.." is wearing "..iteminfo[1].." ("..iteminfo[2]..").",CLP)

					else
						FS.Report(Playername.." is wearing "..iteminfo[1].." ("..iteminfo[2]..").",CLP)

					end
					foundlim = true
				end
			end
		end
	end
	if foundlim == false then
		FS.Report("No limited items found on "..Playername.."'s avatar.",CLP)
	end
end

function LimitedInv(Playername)

	if Playername == "Invalid username." then
		FS.Report("Invalid username.",CLP)
	else
		local userid = Players:GetUserIdFromNameAsync(Playername)
		print("Searching for " .. tostring(Playername) .. "'s Rolimon Stats ID : (" .. userid .. ")",CLP)

		local rolitable = FS.Get_Request("https://api.rolimons.com/players/v1/playerassets/" .. userid)
		local counter = 0
		local itemstosay = {}
		for i,v in pairs(rolitable.playerAssets) do
			if counter <= 5 then
				for i2,v2 in pairs(FS.RolimonsValueTable().items) do
					if i2 == i then
						print("Found! "..i2)
						if v2[2] == "" then

						else
							if v2[3] >= 2500 then
								counter = counter + 1
								if v2[2] == "BIH" then -- to avoid tags lol
								else
									table.insert(itemstosay,v2[2])
								end
							end
						end
						wait(0.1)
					end
				end
			end
		end
		local totalValue = 0
		for i,v in pairs(rolitable.playerAssets) do
			for i2,v2 in pairs(v) do
				totalValue = totalValue + 1
			end
		end

		if #itemstosay == 0 then
			FS.Report(Playername.." has no notable items.",CLP)
		else
			FS.Report(Playername.." has "..table.concat(itemstosay,", "),CLP)
		end
		wait(0.2)
		if totalValue == 1 then
			FS.Report(tostring(Playername) .. " has " ..totalValue.." limited item.",CLP)
		else
			FS.Report(tostring(Playername) .. " has " ..totalValue.." limiteds in total.",CLP)
		end

		return rolitable
	end
end

function SetOwner(NewOwner)
	CurrentlyWalkingToOwner = true

	FS.CreatePlrLockBrick(tostring(NewOwner), _G.BotConfig["General Settings"].PlayerLockBrickVector, false, "TargetPart")
	local ownerchar = game.Workspace:FindFirstChild(tostring(NewOwner))
	if ownerchar then
		if ownerchar:FindFirstChild("TargetPart") then
			wait(1)
			coroutine.wrap(function()
				while true do
					local parttowalktoo = ownerchar:WaitForChild("TargetPart")
					FS.PathfindPart(parttowalktoo, Character, Humanoid)
					wait(0.01)

					if CurrentlyWalkingToOwner == false then
						break
					end
				end
			end)()
		end
	end
end

function WalkTooTarget(TargetPart, returntoowner, MessageToSay, playerwhoissuedcommand)
	FS.Report("Target "..tostring(TargetPart).." found, attempting to walk there...",CLP)

	FS.CreatePlrLockBrick(TargetPart, _G.BotConfig["General Settings"].PlayerLockBrickVector, false, "TestPFPart")
	local targetchar = game.Workspace:FindFirstChild(tostring(TargetPart))
	if targetchar then
		if targetchar:FindFirstChild("TestPFPart") then
			CurrentlyWalkingToOwner = false
			wait(0.5)
			local parttowalktoo = targetchar:WaitForChild("TestPFPart")
			FS.PathfindPart(parttowalktoo, Character, Humanoid)
			wait(2)		
			if returntoowner == true then
				FS.Report(MessageToSay,CLP)
				wait(2)
				SetOwner(playerwhoissuedcommand)
				wait(1)
				parttowalktoo:Destroy()
			end
		end
	end
end


function AutoJumpIfSat()
	coroutine.wrap(function()
		while true do
			if AutoJumpWhenSitting == true then
				if Humanoid.Sit == true then
					Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end
			wait(0.5)
		end
	end)()
end

function onChatted(p,msg)
	if Variables.ChatSpyActive == true then

		Config = {
			enabled = true,
			spyOnMyself = false,
			public = true,
			publicItalics = true
		}

		PrivateProperties = {
			Color = Color3.fromRGB(0,255,255); 
			Font = Enum.Font.SourceSansBold;
			TextSize = 18;
		}

		local saymsg = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")
		local getmsg = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("OnMessageDoneFiltering")
		local instance = (_G.chatSpyInstance or 0) + 1
		_G.chatSpyInstance = instance

		local StarterGui = game:GetService("StarterGui")

		if _G.chatSpyInstance == instance then
			if p==Player and msg:lower():sub(1,4)=="/spy" then
				Config.enabled = not Config.enabled
				wait(0.3)
				PrivateProperties.Text = "{SPY "..(Config.enabled and "EN" or "DIS").."ABLED}"
				StarterGui:SetCore("ChatMakeSystemMessage", PrivateProperties)
			elseif Config.enabled and (Config.spyOnMyself==true or p~=Player) then
				msg = msg:gsub("[\n\r]",''):gsub("\t",' '):gsub("[ ]+",' ')
				local hidden = true
				local conn = getmsg.OnClientEvent:Connect(function(packet,channel)
					if packet.SpeakerUserId==p.UserId and packet.Message==msg:sub(#msg-#packet.Message+1) and (channel=="All" or (channel=="Team" and Config.public==false and Players[packet.FromSpeaker].Team==Player.Team)) then
						hidden = false
					end
				end)
				wait(1)
				conn:Disconnect()
				if hidden and Config.enabled then
					if Config.public then
						FS.Report("{SPY} [".. p.Name .."]: "..msg,CLP)
					end
				end
			end
		end

	end
end


local ResponseTable = {
	["https://httpbin.org"] = "UNKNOWN",
	["https://api.api-ninjas.com"] = "UNKNOWN",
	["https://www.rolimons.com"] = "UNKNOWN",
	["https://rblx.trade"] = "UNKNOWN",
	["https://games.roblox.com"] = "UNKNOWN",
}

function PingTest()
	local Getrequest
	Getrequest = request({
		Url = "https://httpbin.org/user-agent",
		Method = "GET",
	})

	if Getrequest.Success == true then
		ResponseTable["https://httpbin.org"] = "<font color='#05e338'>CONNECTED</font>"
	else
		ResponseTable["https://httpbin.org"] = "<font color='#e30505'>UNABLE TO CONNECT</font>"
	end
	wait(0.3)
	local headers = {
		["X-Api-Key"] = _G.BotConfig["API Keys"].APININJA_KEY
	}

	if ClientInfo.BotInfo.ValidAPINinjaKey == false then
		ResponseTable["https://api.api-ninjas.com"] = "<font color='#e30505'>UNABLE TO CONNECT (INVAID KEY)</font>"
	else

		local Getrequest
		Getrequest = request({
			Url = "https://api.api-ninjas.com/v1/facts?limit=1",
			Method = "GET",
			Headers = headers
		})

		if Getrequest.Success == true then
			ResponseTable["https://api.api-ninjas.com"] = "<font color='#05e338'>CONNECTED</font>"
		else
			ResponseTable["https://api.api-ninjas.com"] = "<font color='#e30505'>UNABLE TO CONNECT</font>"
		end
	end
	wait(0.3)
	local Getrequest
	Getrequest = request({
		Url = "https://api.rolimons.com/players/v1/playerassets/2626177908",
		Method = "GET",
	})

	if Getrequest.Success == true then
		ResponseTable["https://www.rolimons.com"] = "<font color='#05e338'>CONNECTED</font>"
	else
		ResponseTable["https://www.rolimons.com"] = "<font color='#e30505'>UNABLE TO CONNECT</font>"
	end
	wait(0.3)
	local Getrequest
	Getrequest = request({
		Url = "https://rblx.trade",
		Method = "GET",
	})

	if Getrequest.Success == true then
		ResponseTable["https://rblx.trade"] = "<font color='#05e338'>CONNECTED (CSRF Support Not Implemented yet)</font>"
	else
		ResponseTable["https://rblx.trade"] = "<font color='#e30505'>UNABLE TO CONNECT</font>"
	end
	wait(0.3)
	local Getrequest
	Getrequest = request({
		Url = "https://roblox.com",
		Method = "GET",
	})

	if Getrequest.Success == true then
		ResponseTable["https://games.roblox.com"] = "<font color='#05e338'>CONNECTED</font>"
	else
		ResponseTable["https://games.roblox.com"] = "<font color='#e30505'>UNABLE TO CONNECT</font>"
	end
	wait(0.3)
	CBD.PingTest(ResponseTable, FS.TestConnection())
end

SetOwner(CurrentOwner)



FS.Report(FS.TestConnection(),CLO)

local OwnerPlayerInstance = Players:FindFirstChild(CurrentOwner)
local OwnerCharacter = OwnerPlayerInstance.Character

FS.CreateHightLight(tostring(_G.BotConfig["General Settings"]["Owner"]), _G.BotConfig["General Settings"].OwnerHighlight)


local CommandsTable = {
	[".act"] = function()
		FS.Report(VersionName.." (V"..VersionNumber..") is Active.",CLP)
	end,

	[".say"] = function(Arg)
		if string.sub(Arg, 1, 4) == ".say" then
			local textToSay = string.sub(Arg, 6)
			FS.Report(textToSay,CLP)
		end
	end,


	[".testhttps"] = function()
		FS.Report(FS.TestConnection(),CLP)
	end,

	[".printlocalinfo"] = function()
		FS.PrintTable(ClientInfo)
	end,

	[".chatpublic"] = function()
		if CLP == true then
			CLP = false

		elseif CLP == false then
			CLP = true
		end

		FS.Report("Chat Logging has been set to "..tostring(CLP),CLP)
	end,

	[".rejoin"] = function()
		FS.Report("Rejoining "..Place.."...",CLP)
		wait(0.5)
		FS.Rejoin()
	end,

	[".checkenv"] = function()
		local Env = FS.Environment()
		FS.Report("Executor : "..identifyexecutor(),CLP)
		FS.Report("Client Version : "..version(),false)

		print(FS.Environment()[1])
	end,

	[".testerrorlogging"] = function()
		FS.Report("Attempting to cause error...",CLP)
		wait(0.9)
		Player.Color = "Red"

	end,

	[".follow"] = function(Arg)
		CurrentlyWalkingToOwner = false
		if string.sub(Arg, 1, 7) == ".follow" then
			local PlayerName = string.sub(Arg, 9)
			local AutoFilledName = FS.AutoFillPlayer(PlayerName)
			if AutoFilledName == "Invalid Username." then
				FS.Report("Invalid Username, couldn't find "..PlayerName,CLP)
			else
				CurrentlyWalkingToOwner = false
				wait(1)
				FS.Report("Attempting to follow "..AutoFilledName.."...",CLP)
				SetOwner(AutoFilledName)
			end		 
		end

	end,

	[".return"] = function(Arg)
		FS.Report("Returning to owner...",CLP)
		SetOwner(Owner)	
	end,


	[".toggleCWTO"] = function(Arg)
		FS.Report("Attempting change CWTO status...",CLP)

		wait(1)

		if CurrentlyWalkingToOwner == true then
			CurrentlyWalkingToOwner = false

		elseif CurrentlyWalkingToOwner == false then
			CurrentlyWalkingToOwner = true
		end

		FS.Report("CWTO has been set to "..tostring(CurrentlyWalkingToOwner),CLP)

		if CurrentlyWalkingToOwner == true then
			SetOwner(_G.BotConfig["General Settings"].Owner)
		end
	end,

	[".time"] = function()
		wait(0.5)
		FS.Report("Today is " ..RequestTime "%A" .." (" ..RequestTime "%a" .."), The Month is " ..RequestTime "%B".. " (" .. RequestTime "%b" .. ").",CLP)
		wait(0.1)
		FS.Report("The time is " .. RequestTime "%I" .. ":" .. RequestTime "%M" .. RequestTime "%p".." ("..RequestTime "%Z"..")",CLP)
		wait(0.1)
		FS.Report("The date is "..RequestTime "%x",CLP)
	end,

	[".locate"] = function(Arg)
		if string.sub(Arg, 1, 7) == ".locate" then
			local PlayerName = string.sub(Arg, 9)
			local AutoFilledName = FS.AutoFillPlayer(PlayerName)
			if AutoFilledName == "Invalid Username." then
				FS.Report("Invalid Username, couldn't find "..PlayerName,CLP)
			else
				WalkTooTarget(AutoFilledName, true, "Found "..tostring(PlayerName)..", returning to ".._G.BotConfig["General Settings"].Owner, LastCommandIssuedby)
			end	
		end
	end,

	[".jump"] = function()
		Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end,

	[".autojump"] = function()
		if AutoJumpWhenSitting == true then
			AutoJumpWhenSitting = false
		elseif AutoJumpWhenSitting == false then
			AutoJumpWhenSitting = true
		end

		FS.Report("AutoJump when sitting has been set to "..tostring(AutoJumpWhenSitting),CLP)
	end,

	[".friends"] = function(Arg)
		if string.sub(Arg, 1, 8) == ".friends" then
			local PlayerName = string.sub(Arg, 10)
			local AutoFilledName = FS.AutoFillPlayer(PlayerName)
			if AutoFilledName == "Invalid Username." then
				print(AutoFilledName)
				FS.Report("Invalid Username, couldn't find "..PlayerName,CLP)
			else
				local userId = Players:GetUserIdFromNameAsync(AutoFilledName)
				local friendPages = Players:GetFriendsAsync(userId)
				local usernames = {}

				for item, _pageNo in FS.iterPageItems(friendPages) do
					table.insert(usernames, item.Username)
				end
				local ingamefriends = {}

				for i, v in pairs(usernames) do
					if Players:FindFirstChild(v) == nil then

					else
						table.insert(ingamefriends, v)
					end
				end

				if #ingamefriends == 0 then
					FS.Report(AutoFilledName .. " Has no in game friends.",CLP)
					FS.Report(AutoFilledName.." has "..#usernames.." friends in total.",CLP)
				else
					FS.Report(AutoFilledName .. "'s in game friends, " .. table.concat(ingamefriends, ", "),CLP)
					FS.Report(AutoFilledName.." has "..#usernames.." friends in total.",CLP)
				end
			end

			return
		end	
	end,

	[".userid"] = function(Arg)
		if string.sub(Arg, 1, 7) == ".userid" then
			local PlayerName = string.sub(Arg, 9)
			local AutoFilledName = FS.AutoFillPlayer(PlayerName)
			if AutoFilledName == "Invalid Username." then
				print(AutoFilledName)
				FS.Report("Invalid Username, couldn't find "..PlayerName,CLP)
			else
				local userId = Players:GetUserIdFromNameAsync(AutoFilledName)
				FS.Report(AutoFilledName.."'s UserId is "..userId,CLP)
			end	
		end
	end,

	[".followers"] = function(Arg)
		if string.sub(Arg, 1, 10) == ".followers" then
			local PlayerName = string.sub(Arg, 12)
			local AutoFilledName = FS.AutoFillPlayer(PlayerName)
			if AutoFilledName == "Invalid Username." then
				print(AutoFilledName)
				FS.Report("Invalid Username, couldn't find "..PlayerName,CLP)
			else
				local userId = Players:GetUserIdFromNameAsync(AutoFilledName)
				local following = FS.Get_Request("https://friends.roblox.com/v1/users/"..userId.."/followers/count")

				FS.Report(AutoFilledName.." has "..following.count.." ROBLOX followers.",CLP)
			end	
		end
	end,

	[".outfits"] = function(Arg)
		if string.sub(Arg, 1, 8) == ".outfits" then
			local PlayerName = string.sub(Arg, 10)
			local AutoFilledName = FS.AutoFillPlayer(PlayerName)
			if AutoFilledName == "Invalid Username." then
				print(AutoFilledName)
				FS.Report("Invalid Username, couldn't find "..PlayerName,CLP)
			else
				local userid = Players:GetUserIdFromNameAsync(AutoFilledName)

				local response = FS.Get_Request("https://avatar.roblox.com/v1/users/"..userid.."/outfits")


				FS.Report(tostring(AutoFilledName).." Has "..tostring(response.total).." outfits in total.",CLP)

			end
		end
	end,

	[".avcost"] = function(Arg)
		if string.sub(Arg, 1, 7) == ".avcost" then
			local PlayerName = string.sub(Arg, 9)
			local AutoFilledName = FS.AutoFillPlayer(PlayerName)
			if AutoFilledName == "Invalid Username." then
				print(AutoFilledName)
				FS.Report("Invalid Username, couldn't find "..PlayerName,CLP)
			else
				local userid = Players:GetUserIdFromNameAsync(AutoFilledName)
				local humdesc = Players:GetHumanoidDescriptionFromUserId(userid)
				local idtable = {
					["FaceIDs"] = string.split(humdesc.Face,","),
					["ShirtID"] = string.split(humdesc.Shirt,","),
					["PantsID"] = string.split(humdesc.Pants,","),
					["Head"] = string.split(humdesc.Head,","),
					["Hats"] = string.split(humdesc.HatAccessory,","),
					["Hairs"] = string.split(humdesc.HairAccessory,","),
					["T-Shirt"] = string.split(humdesc.GraphicTShirt,","),
					["BackHat"] = string.split(humdesc.BackAccessory,","),
					["FrontHat"] = string.split(humdesc.FrontAccessory,","),
					["FaceHat"] = string.split(humdesc.FaceAccessory,","),
					["WaistHat"] = string.split(humdesc.WaistAccessory,","),
					["NeckHat"] = string.split(humdesc.NeckAccessory,","),
					["ShoulderHat"] = string.split(humdesc.ShouldersAccessory,","),
				}


				FS.Report("Totaling the price of "..AutoFilledName.."'s avatar...",CLP)
				local totalcost = 0
				for i,v in pairs(idtable) do
					for i2,v2 in pairs(v) do
						wait(0.2)
						if v2 == 0 or v2 == nil or v2 == "" or v2 == "0" then
						else

							local ItemInfo = MS:GetProductInfo(tonumber(v2))

							if ItemInfo.IsLimited == true or ItemInfo.IsLimitedUnique == true then
								totalcost = totalcost + RolimonsItemTable.items[v2][3]
							else
								if ItemInfo.PriceInRobux == nil then
								else
									totalcost = totalcost + ItemInfo.PriceInRobux
								end
							end
						end
					end
				end

				if humdesc.Head == 15093053680 then
					totalcost = totalcost + 31000
				end

				if humdesc.RightLeg == 139607718 then
					totalcost = totalcost + 17000
				end 

				if totalcost >= 1000000 then
					FS.Report(AutoFilledName.."'s avatar costs an estimated "..FS.abbreviate(totalcost).." Robux.",CLP)
				else
					FS.Report(AutoFilledName.."'s avatar costs an estimated "..FS.comma_value(totalcost).." Robux.",CLP)
				end
			end
		end
	end,

	[".joind"] = function(Arg)
		if string.sub(Arg, 1, 6) == ".joind" then
			local PlayerName = string.sub(Arg, 8)
			local AutoFilledName = FS.AutoFillPlayer(PlayerName)
			if AutoFilledName == "Invalid Username." then
				print(AutoFilledName)
				FS.Report("Invalid Username, couldn't find "..PlayerName,CLP)
			else
				local Plr = Players[AutoFilledName]
				local joinTime = os.time() - (Plr.AccountAge*86400)
				local joinDate = os.date("!*t", joinTime)
				wait(0.3)
				FS.Report(AutoFilledName.." joined Roblox on  "..joinDate.month.."/"..joinDate.day.."/"..joinDate.year,CLP)
				local ageindays = Players[AutoFilledName].AccountAge

				FS.Report(AutoFilledName.."'s account is "..ageindays.." days old.",CLP)
			end	
		end
	end,

	[".pastusers"] = function(Arg)
		if string.sub(Arg, 1, 10) == ".pastusers" then
			local PlayerName = string.sub(Arg, 12)
			local AutoFilledName = FS.AutoFillPlayer(PlayerName)
			if AutoFilledName == "Invalid Username." then
				print(AutoFilledName)
				FS.Report("Invalid Username, couldn't find "..PlayerName,CLP)
			else
				local userid = Players:GetUserIdFromNameAsync(AutoFilledName)
				local pastusers = FS.Get_Request("https://users.roblox.com/v1/users/"..userid.."/username-history?limit=10&sortOrder=Asc")
				local maxcount = 0
				if #pastusers.data >= 2 then
					maxcount = 2
				elseif #pastusers.data < 2 then
					maxcount = #pastusers.data
				end
				local oldnames = {}
				local currentcount = 0
				for i,v in pairs(pastusers.data) do
					if currentcount > maxcount then

					else
						currentcount = currentcount + 1
						table.insert(oldnames,v.name)
					end
				end
				if #oldnames == 0 then
					FS.Report(AutoFilledName.." has not changed their username.",CLP)
				elseif #oldnames == 1 then
					FS.Report(AutoFilledName.."'s old username is "..table.concat(oldnames,", "),CLP)
				else
					FS.Report(AutoFilledName.."'s old usernames, "..table.concat(oldnames,", "),CLP)
				end
			end	
		end
	end,

	[".gameservers"] = function()
		local chckd = false
		local gameservertable = FS.Get_Request("https://games.roblox.com/v1/games/"..tostring(game.PlaceId).."/servers/0?sortOrder=2&excludeFullGames=false&limit=100")

		FS.Report(Place.." currently has "..#gameservertable.data.." active servers.",CLP)
		wait(0.1)
		for i,v in pairs(gameservertable.data) do
			if v.id == game.JobId then
				FS.Report("This server's ping is "..v.ping.." with an average FPS of "..FS.round(v.fps),CLP)
				chckd = true
			end
		end
		if chckd == false then
			FS.Report("Could not verify information on current server.",CLP)
		end
	end,

	[".crypto"] = function(Arg)
		if string.sub(Arg, 1, 7) == ".crypto" then
			local CoinName = string.sub(Arg, 9)

			local CoinInfo = FS.Get_Request("https://api.coingecko.com/api/v3/coins/"..CoinName)

			local CurrentPrice = CoinInfo.market_data.current_price[Currency]
			local DailyHigh = CoinInfo.market_data.high_24h[Currency]
			local DailyLow = CoinInfo.market_data.low_24h[Currency]

			local modifierword = "n"

			local CoinTitle = CoinInfo.localization.en

			local CurrencyUpper = string.upper(Currency)

			if CoinInfo.market_data.price_change_percentage_7d > 0 then
				modifierword = "rose"
			else
				modifierword = "dropped"
			end
			FS.Report("One "..CoinTitle.." is currently valued at "..CurrencySymbol..FS.comma_value(CurrentPrice).." ("..CurrencyUpper..")",CLP)
			wait(0.2)
			FS.Report("Today it peaked at "..CurrencySymbol..FS.abbreviate(DailyHigh).." and hit its lowest at "..CurrencySymbol..FS.abbreviate(CurrentPrice),CLP)
			wait(0.2)
			FS.Report("This week "..CoinTitle.." "..modifierword.." in value by "..FS.round(CoinInfo.market_data.price_change_percentage_7d).."%.", CLP)
		end
	end,

	[".greet"] = function(Arg)
		if string.sub(Arg, 1, 6) == ".greet" then
			local PlayerName = string.sub(Arg, 8)

			local AutoFilledName = FS.AutoFillPlayer(PlayerName)
			if AutoFilledName == "Invalid Username." then
				FS.Report("Invalid Username, couldn't find "..PlayerName,CLP)
			else
				local GreetingMessage = nil

				if RequestTime "%p" == "AM" then
					GreetingMessage = "🌅 Good Morning"
				elseif RequestTime "%p" == "PM" and tonumber(RequestTime "%I") <= 6 then
					GreetingMessage = "☀️ Good Afternoon"
				elseif RequestTime "%p" == "PM" and tonumber(RequestTime "%I") >= 7 then
					GreetingMessage = "🌙 Good Evening"
				end

				WalkTooTarget(AutoFilledName, true, GreetingMessage.." "..tostring(AutoFilledName)..". "..Greetings[math.random(1,#Greetings)], LastCommandIssuedby)
			end	
		end
	end,

	[".tell"] = function(Arg)
		if string.sub(Arg, 1, 5) == ".tell" then
			local PlayerName = string.sub(Arg, 7)

			local AutoFilledName = FS.AutoFillPlayer(PlayerName)
			if AutoFilledName == "Invalid Username." then
				FS.Report("Invalid Username, couldn't find "..PlayerName,CLP)
			else
				local Prompt = FS.Prompt("What Should I tell "..AutoFilledName.."?",game:GetService("Players"):FindFirstChild(LastCommandIssuedby))

				WalkTooTarget(AutoFilledName, true, Prompt, LastCommandIssuedby)
			end	
		end
	end,

	[".serversize"] = function()
		local servertable = FS.ServerSize()

		local percent = servertable.currentplayers/servertable.maxplayers * 100
		FS.Report("Server currently has "..servertable.currentplayers.." out of "..servertable.maxplayers.." players ("..FS.round(percent).."% full)",CLP)
	end,

	[".rateavatar"] = function(Arg)
		if string.sub(Arg, 1, 11) == ".rateavatar" then
			local PlayerName = string.sub(Arg, 13)

			local AutoFilledName = FS.AutoFillPlayer(PlayerName)
			if AutoFilledName == "Invalid Username." then
				FS.Report("Invalid Username, couldn't find "..PlayerName,CLP)
			else

				local userid = Players:GetUserIdFromNameAsync(AutoFilledName)
				local humdesc = Players:GetHumanoidDescriptionFromUserId(userid)
				local Rating = math.random(1,10)
				local hats = {
					["Hats"] = string.split(humdesc.HatAccessory,",")
				}
				if hats["Hats"][1] == nil or hats["Hats"][1] == "" then
				else
					local hatnum = math.random(1,#hats["Hats"])
					local hatname = MS:GetProductInfo(hats["Hats"][hatnum]).Name
					if Rating >= 5 then
						FS.Report("I like their "..hatname,CLP)
					else
						FS.Report("I hate their "..hatname,CLP)
					end
					wait(0.5)

				end
				FS.Report("I'll give "..AutoFilledName.." a "..Rating.." out of 10.",CLP)

			end	
		end
	end,

	[".clientstats"] = function()
		local StatsTable = FS.ClientStats()
		wait(0.2)
		FS.Report("Current Session Runtime is : "..FS.convertToHMS(tick() - Log[Player]),CLP)
		wait(0.2)
		FS.Report(StatsTable.TotalCalls.." requests have been sent.",CLP)
		wait(0.2)
		FS.Report(StatsTable.TotalChatMessages.." Chat Messages have been sent.",CLP)
		wait(0.2)
		FS.Report("FunctionService has been referenced "..FS.abbreviate(StatsTable.TotalCommandsIssued).." times.",CLP)
	end,

	[".planet"] = function(Arg)
		if string.sub(Arg, 1, 7) == ".planet" then

			local headers = {
				["X-Api-Key"] = _G.BotConfig["API Keys"].APININJA_KEY
			}

			local PlanetName = string.sub(Arg, 9)

			local PlanetInfo = FS.Request("https://api.api-ninjas.com/v1/planets?name="..PlanetName,"GET",headers)
			FS.Report(PlanetInfo[1].name.." has a current average surface temp. of "..FS.round(FS.ConvertKtoF(PlanetInfo[1].temperature)).." (F) .",CLP)
			wait(0.1)
			FS.Report("It takes "..PlanetInfo[1].name.." "..FS.comma_value(PlanetInfo[1].period).." Earth days to orbit it's host star.",CLP)

		end
	end,

	[".randomword"] = function()

		local headers = {
			["X-Api-Key"] = _G.BotConfig["API Keys"].APININJA_KEY
		}

		local RandomWord = FS.Request("https://api.api-ninjas.com/v1/randomword","GET",headers)

		FS.PrintTable(RandomWord)
		FS.Report(RandomWord.word,CLP)
	end,

	[".commodity"] = function(Arg)
		if string.sub(Arg, 1, 10) == ".commodity" then

			local headers = {
				["X-Api-Key"] = _G.BotConfig["API Keys"].APININJA_KEY
			}

			local CommodityName = string.sub(Arg, 12)

			local CommodityInfo = FS.Request("https://api.api-ninjas.com/v1/commodityprice?ticker="..CommodityName,"GET",headers)
			FS.PrintTable(CommodityInfo)


			if CommodityInfo["error"] ~= nil then
				FS.Report(CommodityInfo["error"],CLP)

			else
				FS.Report(CommodityInfo[1].name.." are currently valued at "..CurrencySymbol..CommodityInfo[1].price,CLP)
				wait(0.1)
			end 
		end
	end,

	[".dance"] = function()

		if ClientInfo.ChatType == "LCS" then
			FS.Report(".dance only works on games that use TCS, this game is using LCS.", CLP)
		else
			local DanceNumber = math.random(1,3)

			FS.Report("/e dance"..DanceNumber, true, true)
		end
	end,

	[".console"] = function()

		if ClientInfo.ChatType == "LCS" then
			FS.Report(".console only works on games that use TCS, this game is using LCS.", CLP)
		else

			FS.Report("/console", true, true)
		end
	end,

	[".stock"] = function(Arg)
		if string.sub(Arg, 1, 6) == ".stock" then


			local headers = {
				["X-Api-Key"] = _G.BotConfig["API Keys"].APININJA_KEY
			}

			local StockName = string.sub(Arg, 8)

			local StockInfo = FS.Request("https://api.api-ninjas.com/v1/stockprice?ticker="..StockName,"GET",headers)

			if StockInfo["error"] ~= nil then
				FS.Report(StockInfo["error"],CLP)

			else

				FS.Report(StockInfo.name.." ("..StockInfo.ticker..") is currently valued at "..CurrencySymbol..StockInfo.price.." per share on the "..StockInfo.exchange.." exchange.",CLP)
			end 
		end
	end,

	[".city"] = function(Arg)
		if string.sub(Arg, 1, 5) == ".city" then


			local headers = {
				["X-Api-Key"] = _G.BotConfig["API Keys"].APININJA_KEY
			}

			local CityName = string.sub(Arg, 7)



			print("https://api.api-ninjas.com/v1/city?name="..CityName)
			local CityInfo = FS.Request("https://api.api-ninjas.com/v1/city?name="..CityName,"GET",headers)

			if CityInfo["error"] ~= nil then
				FS.Report(CityInfo["error"],CLP)

			else

				FS.Report(CityInfo[1].name.." is located in "..CityInfo[1].country..", it has an estimated population of  "..FS.abbreviate(CityInfo[1].population).." people.",CLP)
			end 
		end
	end,

	[".weather"] = function(Arg)
		if string.sub(Arg, 1, 8) == ".weather" then


			local headers = {
				["X-Api-Key"] = _G.BotConfig["API Keys"].APININJA_KEY
			}

			local CityName = string.sub(Arg, 10)

			local WeatherInfo = FS.Request("https://api.api-ninjas.com/v1/weather?city="..CityName,"GET",headers)

			if WeatherInfo["error"] ~= nil then
				FS.Report(WeatherInfo["error"],CLP)

			else

				local maxtemp = FS.ConvertCtoF(WeatherInfo.max_temp)
				local mintemp = FS.ConvertCtoF(WeatherInfo.min_temp)

				local currenttemp = FS.ConvertCtoF(WeatherInfo.temp)

				if currenttemp >= 65 then
					modifierword = "warm"
				else
					modifierword = "cold"
				end
				FS.Report("Today the weather in "..CityName.." is "..modifierword.." with a current temperature of "..currenttemp.."°F",CLP)
				wait(0.3)
				FS.Report("Today will have a high of "..FS.round(maxtemp).."°F and a low of "..FS.round(mintemp).."°F",CLP)
			end 
		end
	end,

	[".rhyme"] = function(Arg)
		if string.sub(Arg, 1, 6) == ".rhyme" then


			local headers = {
				["X-Api-Key"] = _G.BotConfig["API Keys"].APININJA_KEY
			}

			local RhymeWord = string.sub(Arg, 8)

			local RhymeInfo = FS.Request("https://api.api-ninjas.com/v1/rhyme?word="..RhymeWord,"GET",headers)
			FS.PrintTable(RhymeInfo)
			if RhymeInfo["error"] ~= nil then
				FS.Report(RhymeInfo["error"],CLP)

			else
				FS.Report("I've found "..#RhymeInfo.." words that rhyme with "..RhymeWord,CLP)

				if #RhymeInfo > 0 then
					wait(0.3)
					FS.Report("Some words that rhyme with "..RhymeWord.." are "..RhymeInfo[math.random(1,#RhymeInfo)]..", "..RhymeInfo[math.random(1,#RhymeInfo)]..", "..RhymeInfo[math.random(1,#RhymeInfo)].." and "..RhymeInfo[math.random(1,#RhymeInfo)],CLP)

				end
			end 
		end
	end,

	[".define"] = function(Arg)
		if string.sub(Arg, 1, 7) == ".define" then


			local headers = {
				["X-Api-Key"] = _G.BotConfig["API Keys"].APININJA_KEY
			}

			local RhymeWord = string.sub(Arg, 9)
			local DefineInfo = FS.Request("https://api.api-ninjas.com/v1/dictionary?word="..RhymeWord,"GET",headers)
			FS.PrintTable(DefineInfo)
			if DefineInfo["error"] ~= nil then
				FS.Report(DefineInfo["error"],CLP)

			else

				local Def = DefineInfo.definition
				local NewDef = Def:sub(1,110)
				FS.Report(RhymeWord.." is defined as...",CLP)
				wait(0.3)
				FS.Report(NewDef,CLP)
			end 
		end
	end,

	[".headless"] = function(Arg)
		if string.sub(Arg, 1, 9) == ".headless" then
			local PlayerName = string.sub(Arg, 11)
			local AutoFilledName = FS.AutoFillPlayer(PlayerName)
			if AutoFilledName == "Invalid Username." then
				print(AutoFilledName)
				FS.Report("Invalid Username, couldn't find "..PlayerName,CLP)
			else
				local userid = Players:GetUserIdFromNameAsync(AutoFilledName)
				local humdesc = Players:GetHumanoidDescriptionFromUserId(userid)

				local modifierword = "is not"
				if humdesc.Head == 15093053680 then
					modifierword = "is"
				end

				FS.Report(AutoFilledName.." "..modifierword.." wearing Headless.",CLP)
			end
		end

	end,

	[".togglechatspy"] = function()
		if ClientInfo.ServerInfo.ChatType == "LCS" then
			if Variables.ChatSpyActive == false then
				Variables.ChatSpyActive = true
			elseif Variables.ChatSpyActive == true then
				Variables.ChatSpyActive = false
			end

			FS.Report("Chat Spy has been set to "..tostring(Variables.ChatSpyActive),CLP)
		elseif ClientInfo.ServerInfo.ChatType == "TCS" then
			FS.Report("This game uses TCS, Char-Bot is unable to read private messages.",CLP)
		end
	end,

	[".chatspy"] = function(Arg)
		if string.sub(Arg, 1, 8) == ".chatspy" then
			local PlayerName = string.sub(Arg, 10)
			local AutoFilledName = FS.AutoFillPlayer(PlayerName)
			if AutoFilledName == "Invalid Username." then
				print(AutoFilledName)
				FS.Report("Invalid Username, couldn't find "..PlayerName,CLP)
			else

				if ClientInfo.ServerInfo.ChatType == "TCS" then
					FS.Report("This game uses TCS, Char-Bot is unable to read private messages.",CLP)
				else
					FS.Report("Attempting to ChatSpy "..AutoFilledName,CLP)
					Players[AutoFilledName].Chatted:connect(function(msg)
						print("dewtected this")
						onChatted(Players[AutoFilledName], msg)
					end)
				end
			end
		end
	end,

	[".credits"] = function()
		FS.Report("CharBot was created by 00temps.",CLP)
		wait(0.3)
	end,

	[".addcmdownership"] = function(Arg)
		if string.sub(Arg, 1, 16) == ".addcmdownership" then
			local PlayerName = string.sub(Arg, 18)
			local AutoFilledName = FS.AutoFillPlayer(PlayerName)
			if AutoFilledName == "Invalid Username." then
				print(AutoFilledName)
				FS.Report("Invalid Username, couldn't find "..PlayerName,CLP)
			else
				if table.find(CommandOwnershipList, AutoFilledName) then
					FS.Report(AutoFilledName.." Already has command ownership!",CLP)
				else
					table.insert(CommandOwnershipList, AutoFilledName)
					FS.Report(AutoFilledName.." has been added to the command ownership list.",CLP)
				end
			end
		end
	end,

	[".removecmdownership"] = function(Arg)
		if string.sub(Arg, 1, 19) == ".removecmdownership" then
			local PlayerName = string.sub(Arg, 21)
			local AutoFilledName = FS.AutoFillPlayer(PlayerName)
			if AutoFilledName == "Invalid Username." then
				print(AutoFilledName)
				FS.Report("Invalid Username, couldn't find "..PlayerName,CLP)
			else
				if table.find(CommandOwnershipList, AutoFilledName) then
					table.remove(CommandOwnershipList, AutoFilledName)
					FS.Report(AutoFilledName.." has been removed from the command ownership list.",CLP)
				else
					FS.Report(AutoFilledName.." Does not have command ownership.",CLP)
				end
			end
		end
	end,


	[".trendingcrypto"] = function()
		local CoinInfo = FS.Get_Request("https://api.coingecko.com/api/v3/search/trending")
		local CoinsList = CoinInfo.coins

		local Coin1 = CoinsList[1].item
		local Coin1Data = Coin1.data

		local CoinPrice = tostring(Coin1Data.price):gsub("%$", "")
		print(CoinPrice)
		if tonumber(CoinPrice) < 1 then
			if tonumber(CoinPrice) > 0 then
				CoinPrice = tostring(math.floor(CoinPrice * 100) / 100)
			end
		end
		FS.Report("The #1 trending crypto today was "..Coin1.name.." ("..Coin1.symbol.."), it is currently valued at about "..CurrencySymbol..FS.comma_value(CoinPrice).." and is ranked #"..Coin1.market_cap_rank.." in market cap.",CLP)

		wait(0.3)

		local Question1 = FS.Prompt("Want me to find information about any of the other top 14 trending cryptos?",game:GetService("Players"):FindFirstChild(LastCommandIssuedby))
		if table.find(ApprovalWords,string.lower(Question1)) then
			local Question2 = FS.Prompt("Which Number? (1-14)",game:GetService("Players"):FindFirstChild(LastCommandIssuedby))
			if table.find(DisapprovalWords,string.lower(Question2)) then
			else
				local Coin1 = CoinsList[tonumber(Question2)].item
				local Coin1Data = Coin1.data

				local CoinPrice = tostring(Coin1Data.price):gsub("%$", "")
				print(CoinPrice)
				if tonumber(CoinPrice) < 1 then
					if tonumber(CoinPrice) > 0 then
						CoinPrice = tostring(math.floor(CoinPrice * 100) / 100)
					end
				end
				FS.Report("The #"..Question2.." trending crypto today was "..Coin1.name.." ("..Coin1.symbol.."), it is currently valued at about ".._G.BotConfig["General Settings"].CurrencySymbol..FS.comma_value(CoinPrice).." and is ranked #"..Coin1.market_cap_rank.." in market cap.",CLP)


			end
		end
	end,

	[".globalcryptodata"] = function()
		local MarketData = FS.Get_Request("https://api.coingecko.com/api/v3/global")

		local Data = MarketData.data

		local MarketCap = Data.market_cap_change_percentage_24h_usd

		local modifierword = "risen "

		if MarketCap < 0 then
			modifierword = "dropped by "
		end

		FS.Report("There are currently "..FS.comma_value(Data.active_cryptocurrencies).." active cryptocurrencies, the crypto market has "..modifierword..FS.rounddecimal(MarketCap).."% in the past 24 hours.",CLP)
	end,


	-- Rolimons Commands

	[".rolival"] = function(Arg)
		if string.sub(Arg, 1, 8) == ".rolival" then
			local PlayerName = string.sub(Arg, 10)

			local AutoFilledName = FS.AutoFillPlayer(PlayerName)
			if AutoFilledName == "Invalid Username." then
				FS.Report("Invalid Username, couldn't find "..PlayerName,CLP)
			else
				local userid = Players:GetUserIdFromNameAsync(AutoFilledName)

				print("\nSearching for " .. tostring(AutoFilledName) .. "'s Rolimon Stats, UserID : (" .. userid .. ")")

				local RoliTable = FS.Get_Request("https://api.rolimons.com/players/v1/playerassets/"..userid)
				local totalValue = 0
				if RoliTable.success == false then
					FS.Report("Request failed, Rolimons has no profile for "..AutoFilledName,CLP)
				else	
					if RoliTable.playerPrivacyEnabled == true then
						FS.Report("Player inventory scan failed, "..AutoFilledName.." has a private inventory",CLP)
						wait(0.2)
						local Prompt = FS.Prompt("Want to search their avatar for limiteds instead?",game:GetService("Players"):FindFirstChild(LastCommandIssuedby))

						if table.find(ApprovalWords,string.lower(Prompt)) then
							WearingLimiteds(AutoFilledName)
						end
					else
						for i2, v2 in pairs(RoliTable.playerAssets) do
							local timesran = #v2 - 1
							for i = timesran, 0, -1 do
								local item = FS.RolimonsValueTable().items[i2]
								if item[4] == -1 then
									totalValue = totalValue + item[3]
								else
									totalValue = totalValue + item[4]
								end
							end
						end
						if #tostring(math.floor(totalValue)) >= 7 then
							FS.Report(tostring(AutoFilledName) .."'s Total Value is : " .. FS.abbreviate(totalValue),CLP)
							wait(0.1)
							local Prompt = FS.Prompt("Do you want more information on this players assets?",game:GetService("Players"):FindFirstChild(LastCommandIssuedby))

							if table.find(ApprovalWords,string.lower(Prompt)) then
								LimitedInv(AutoFilledName)
							end
						else
							FS.Report(tostring(AutoFilledName) .. "'s Total Value is : " .. FS.comma_value(totalValue),CLP)
							wait(0.1)
							local Prompt = FS.Prompt("Do you want more information on this players assets?",game:GetService("Players"):FindFirstChild(LastCommandIssuedby))

							if table.find(ApprovalWords,string.lower(Prompt)) then
								LimitedInv(AutoFilledName)
							end
						end
					end
				end
			end	
		end
	end,

	[".wearinglims"] = function(Arg)
		if string.sub(Arg, 1, 12) == ".wearinglims" then
			local PlayerName = string.sub(Arg, 14)

			local AutoFilledName = FS.AutoFillPlayer(PlayerName)
			if AutoFilledName == "Invalid Username." then
				FS.Report("Invalid Username, couldn't find "..PlayerName,CLP)
			else
				WearingLimiteds(AutoFilledName)
			end	
		end
	end,

	[".salestats"] = function(Arg)
		if string.sub(Arg, 1, 10) == ".salestats" then
			local ItemArg = string.sub(Arg, 12)
			local itemshort = FS.GetLimID(ItemArg)

			local StatsTable = FS.Get_Request("https://rblx.trade/api/v2/catalog/"..itemshort.."/sales/statistics")
			local ItemInfoTable = FS.Get_Request("https://rblx.trade/api/v2/catalog/"..itemshort.."/info")

			FS.Report(ItemInfoTable.name.." has sold "..FS.comma_value(StatsTable.data[1].totalSales).." times this week, total Robux value of these sales is "..FS.abbreviate(StatsTable.data[1].totalRobux)..".",CLP)
			wait(0.1)
			FS.Report("this month it sold "..FS.comma_value(StatsTable.data[2].totalSales).." times, total Robux value of these sales is "..FS.abbreviate(StatsTable.data[2].totalRobux)..".",CLP)

		end	
	end,

	[".lastsale"] = function(Arg)
		if string.sub(Arg, 1, 9) == ".lastsale" then
			local ItemArg = string.sub(Arg, 11)
			local itemshort = FS.GetLimID(ItemArg)

			for i,v in pairs(FS.RolimonsValueTable().items) do
				if i == itemshort then
					local rolitable = FS.Get_Request("https://rblx.trade/api/v2/catalog/"..tostring(i).."/sales?limit=1")
					local saleamount = rolitable.data[1].estimatedRobux
					if rolitable.data[1].buyerId == nil then

						local isosaletime = rolitable.data[1].createdAt
						local unixtime = string.format('%d', FS.parse_json_date(tostring(isosaletime)))
						local unixdate = FS.unixtodate(unixtime)
						local secondssincesale = os.time() + -tonumber(unixtime)

						if saleamount >= 1000000 then
							FS.Report(v[1].." last sold for an estimated "..FS.abbreviate(rolitable.data[1].estimatedRobux).." Robux to an unknown buyer.",CLP)
							wait(0.2)
							FS.Report("Sale Occured "..FS.convertToHMS(secondssincesale).." ago on "..FS.convertmonth(unixdate.month).." "..unixdate.day..", "..unixdate.year,CLP)
							wait(0.8)
							local Prompt = FS.Prompt("Want me to find more sales data for the item?",game:GetService("Players"):FindFirstChild(LastCommandIssuedby))

							if table.find(ApprovalWords,string.lower(Prompt)) then
								local StatsTable = FS.Get_Request("https://rblx.trade/api/v2/catalog/"..itemshort.."/sales/statistics")
								local ItemInfoTable = FS.Get_Request("https://rblx.trade/api/v2/catalog/"..itemshort.."/info")
								FS.Report(ItemInfoTable.name.." has sold "..FS.comma_value(StatsTable.data[1].totalSales).." times this week, total Robux value of these sales is "..FS.abbreviate(StatsTable.data[1].totalRobux)..".",CLP)
								wait(0.1)
								FS.Report("this month it sold "..FS.comma_value(StatsTable.data[2].totalSales).." times, total Robux value of these sales is "..FS.abbreviate(StatsTable.data[2].totalRobux)..".",CLP)

							end
						else

							FS.Report(v[1].." last sold for an estimated "..FS.comma_value(rolitable.data[1].estimatedRobux).." Robux to an unknown buyer.",CLP)
							wait(0.2)
							FS.Report("Sale Occured "..FS.convertToHMS(secondssincesale).." ago on "..FS.convertmonth(unixdate.month).." "..unixdate.day..", "..unixdate.year,CLP)
							wait(0.8)
							local Prompt = FS.Prompt("Want me to find more sales data for the item?",game:GetService("Players"):FindFirstChild(LastCommandIssuedby))

							if table.find(ApprovalWords,string.lower(Prompt)) then
								local StatsTable = FS.Get_Request("https://rblx.trade/api/v2/catalog/"..itemshort.."/sales/statistics")
								local ItemInfoTable = FS.Get_Request("https://rblx.trade/api/v2/catalog/"..itemshort.."/info")
								FS.Report(ItemInfoTable.name.." has sold "..FS.comma_value(StatsTable.data[1].totalSales).." times this week, total Robux value of these sales is "..FS.abbreviate(StatsTable.data[1].totalRobux)..".",CLP)
								wait(0.1)
								FS.Report("this month it sold "..FS.comma_value(StatsTable.data[2].totalSales).." times, total Robux value of these sales is "..FS.abbreviate(StatsTable.data[2].totalRobux)..".",CLP)

							end
						end
					else

						local isosaletime = rolitable.data[1].createdAt
						local unixtime = string.format('%d', FS.parse_json_date(tostring(isosaletime)))
						local unixdate = FS.unixtodate(unixtime)
						local secondssincesale = os.time() + -tonumber(unixtime)

						if saleamount >= 1000000 then
							FS.Report(v[1].." last sold for an estimated "..FS.abbreviate(rolitable.data[1].estimatedRobux).." Robux to "..Players:GetNameFromUserIdAsync(rolitable.data[1].buyerId),CLP)
							wait(0.1)
							FS.Report("Sale Occured "..FS.convertToHMS(secondssincesale).." ago on "..FS.convertmonth(unixdate.month).." "..unixdate.day..", "..unixdate.year,CLP)
						else
							FS.Report(v[1].." last sold for an estimated "..FS.comma_value(rolitable.data[1].estimatedRobux).." Robux to "..Players:GetNameFromUserIdAsync(rolitable.data[1].buyerId),CLP)
							wait(0.1)
							FS.Report("Sale Occured "..FS.convertToHMS(secondssincesale).." ago on "..FS.convertmonth(unixdate.month).." "..unixdate.day..", "..unixdate.year,CLP)
						end

					end
				end
			end

		end	
	end,

	[".limited"] = function(Arg)
		if string.sub(Arg, 1, 8) == ".limited" then
			local ItemArg = string.sub(Arg, 10)
			local itemshort = FS.GetLimID(ItemArg)
			for i,v in pairs(FS.RolimonsValueTable().items) do
				if i == itemshort then
					local Demand = "No Assigned"

					if v[6] == 0 then
						Demand = "Terrible 🗑️"
					elseif v[6] == 1 then
						Demand = "Low"
					elseif	v[6] == 2 then
						Demand = "Normal"
					elseif	v[6] == 3 then
						Demand = "High"
					elseif	v[6] == 4 then
						Demand = "Amazing 💎"
					end
					local Trend = "Not assigned"
					if v[7] == 0 then
						Trend = "Lowering 📉"
					elseif v[7] == 1 then
						Trend = "Unstable"
					elseif v[7] == 2 then
						Trend = "Stable"
					elseif v[7] == 3 then
						Trend = "Raising 📈"
					elseif v[7] == 4 then
						Trend = "Fluctuating"
					end

					wait(0.7)
					FS.Report(v[1].." ("..v[2]..") Currently has "..FS.abbreviate(v[3]).." RAP.",CLP)
					wait(0.3)
					FS.Report(v[2].." is valued at "..FS.abbreviate(v[4]).." by Rolimons",CLP)
					FS.Report(v[2].." has "..Demand.." demand, It's trend is "..Trend..".",CLP)
				end
			end

		end	
	end,

	[".inv"] = function(Arg)
		if string.sub(Arg, 1, 4) == ".inv" then
			local PlayerArg = string.sub(Arg, 6)

			local AutoFilledName = FS.AutoFillPlayer(PlayerArg)
			if PlayerArg == "Invalid username." then
				FS.Report("Invalid username.",CLP)
			else
				LimitedInv(AutoFilledName)
				wait(0.5)
				local Prompt = FS.Prompt("Want me to find more details on any of their items?",game:GetService("Players"):FindFirstChild(LastCommandIssuedby))

				if table.find(DisapprovalWords,string.lower(Prompt)) then
				else
					local ItemID = FS.GetLimID(Prompt)
					print(ItemID)
					local UserID = Players:GetUserIdFromNameAsync(AutoFilledName)
					print(UserID)
					local ItemTable = FS.Get_Request("https://rblx.trade/api/v2/users/"..UserID.."/inventory?allowRefresh=false")

					if ItemTable["error"] ~= nil then
						FS.Report("Request Failed, Reason : "..ItemTable["error"].code,CLP)

					else

						FS.PrintTable(ItemTable)
						FS.PrintTable(ItemTable.inventory)
						local TableNumber = 0
						local TargetUAID
						local AlreadyGotInfo = false
						for i,v in pairs(ItemTable.inventory) do
							TableNumber = TableNumber + 1
							if tostring(ItemTable.inventory[TableNumber].assetId) == tostring(ItemID) then
								print("Found the UAID for "..AutoFilledName.."'s "..ItemTable.inventory[TableNumber].name.." : "..ItemTable.inventory[TableNumber].uaid)
								TargetUAID = ItemTable.inventory[TableNumber].uaid
								if AlreadyGotInfo == false then
									AlreadyGotInfo = true

									local UAIDTable = FS.Get_Request("https://rblx.trade/api/v2/user-asset/"..TargetUAID.."/ownership-history")

									local NumberOfOwners = #UAIDTable

									FS.Report(AutoFilledName.."'s "..ItemTable.inventory[TableNumber].name.." has been owned by "..NumberOfOwners.." on record.")
									wait(0.3)
									FS.Report("It looks like they obtained the item on "..UAIDTable[0].instanceId.updatedAt)
								end
							end
						end
					end
				end
			end
		end	
	end,

	-- file system commands

	[".folderstatus"] = function(Arg)
		if isfolder("CharBot") == true then
			FS.Report("CharBot workspace folder is valid.",CLP)
		else
			FS.Report("Unable to find CharBot workspace folder, creating one now.",CLP)
			makefolder("CharBot")
		end
	end,

	[".listfiles"] = function(Arg)
		local numberchatted = 0
		for i,v in pairs(listfiles("CharBot")) do
			numberchatted = numberchatted + 1

			if numberchatted > 3 then
				print(tostring(v))
			else
				FS.Report(tostring(v),CLP)
			end
		end
	end,

	[".readfile"] = function(Arg)
		if string.sub(Arg, 1, 9) == ".readfile" then
			local FileName = string.sub(Arg, 11)

			local success, response = pcall(function()
				contents = readfile("Charbot/"..FileName)
				print(contents)
			end)

			if success then
				print("file content collected, reporting..")
				FS.Report("Charbot/"..FileName.." : "..contents,CLP)
			end
		end
	end,

	[".writefile"] = function(Arg)
		if string.sub(Arg, 1, 10) == ".writefile" then
			local FileName = string.sub(Arg, 12)

			local Prompt = FS.Prompt("What should I write to the file?",game:GetService("Players"):FindFirstChild(LastCommandIssuedby))

			local success, response = pcall(function()
				writefile("Charbot/"..FileName,Prompt)
				print(FileName)
				print(Prompt)
			end)

			if success then
				print("if success true")
				FS.Report("Charbot/"..FileName.." : Writen successfully",CLP)
			end
		end
	end,

	[".deletefile"] = function(Arg)
		if string.sub(Arg, 1, 11) == ".deletefile" then
			local FileName = string.sub(Arg, 13)

			if isfile("CharBot/"..FileName) == true then
				local Prompt = FS.Prompt("Are you sure you want to delete "..FileName.."?",game:GetService("Players"):FindFirstChild(LastCommandIssuedby))

				if table.find(ApprovalWords, Prompt) then
					delfile("CharBot/"..FileName)
					wait(0.5)
					FS.Report("Deleted ".."CharBot/"..FileName,CLP)
				end
			else
				FS.Report("Couldn't find ".."CharBot/"..FileName,CLP)
			end

		end
	end,

	[".exefile"] = function(Arg)
		if string.sub(Arg, 1, 8) == ".exefile" then
			local FileName = string.sub(Arg, 10)

			if isfile("CharBot/"..FileName) == true then
				local Prompt = FS.Prompt("Are you sure you want to execute "..FileName.."?",game:GetService("Players"):FindFirstChild(LastCommandIssuedby))

				if table.find(ApprovalWords, Prompt) then
					loadfile("CharBot/"..FileName)
					wait(0.5)
					FS.Report("executing ".."CharBot/"..FileName,CLP)
				end
			else
				FS.Report("Couldn't find ".."CharBot/"..FileName,CLP)
			end

		end
	end,

	[".bang"] = function(Arg)
		if string.sub(Arg, 1, 5) == ".bang" then
			local PlayerArg = string.sub(Arg, 7)
			CurrentlyWalkingToOwner = false
			local AutoFilledName = FS.AutoFillPlayer(PlayerArg)
			if PlayerArg == "Invalid username." then
				FS.Report("Invalid username.",CLP)
			else
				stopbang = false
				local brick1 = FS.CreatePlrLockBrick(AutoFilledName, Vector3.new(0,0,0), false, "BangPart1")
				wait(1)
				local brick2 = FS.CreatePlrLockBrick(AutoFilledName, Vector3.new(0,5,0), false, "BangPart2")
				SetOwner(AutoFilledName)
				while true do

					FS.PathfindPart(brick1, Character, Humanoid)
					wait(0.01)
					FS.PathfindPart(brick2, Character, Humanoid)

					if stopbang == true then
						brick1:Destroy()
						brick2:Destroy()
						break
					end
				end
			end
		end
	end,

	[".stopbang"] = function()
		stopbang = true
		CurrentlyWalkingToOwner = false
	end,

	[".bring"] = function()
		stopbang = true

		CurrentlyWalkingToOwner = false
		wait(0.5)
		local OwnerHRP = Players:FindFirstChild(tostring(LastCommandIssuedby))
		OwnerHRP = OwnerHRP.Character.HumanoidRootPart

		Character.HumanoidRootPart.CFrame = OwnerHRP.CFrame
		
		wait(0.5)
		
		SetOwner(LastCommandIssuedby)
	end,


}

function PrintCommandList()
	for i,v in pairs(CommandsTable) do
		print(i)
	end
end

function ChatFromOwnerDetect(msg, player)
	print("[➡️] "..msg)
	local CommandIssued = false
	for CMI,CMV in pairs(CommandsTable) do
		if CommandIssued == false then
			if string.find(msg, "%"..CMI) then
				CommandIssued = true
				LastCommandIssuedby = player
				CMV(msg)
			end
		end
	end
end

for _,p in ipairs(Players:GetPlayers()) do
	p.Chatted:Connect(function(msg)
		if table.find(CommandOwnershipList, tostring(p)) then
			ChatFromOwnerDetect(msg, tostring(p))
		end
	end)
end

Players.PlayerAdded:Connect(function(p)
	p.Chatted:Connect(function(msg)
		if table.find(CommandOwnershipList, tostring(p)) then
			ChatFromOwnerDetect(msg, tostring(p))
		end
	end)
end)

AutoJumpIfSat()
CBD.CreateBotConfigTab()
wait(0.1)
CBD.BotConfigSettings(_G.BotConfig)

CBD.CommandListTab()
CBD.AddCommands(CommandsTable)
local TotalCmds = 0
for i,v in pairs(CommandsTable) do
	TotalCmds = TotalCmds + 1
end
local CustomTotalCmds = 0
FS.Report(TotalCmds.." Commands Loaded.",CLO )



PingTest()
