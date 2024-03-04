-- // RBLX-SERVICES \\ --
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

local FSVersion = "2.2 (PromptUpdate)"


local ChatServiceType
local function FindChatServiceType()
	if game:FindFirstChild("TextChatService") then
		if tostring(TCS.ChatVersion) == "Enum.ChatVersion.TextChatService" then
			ChatServiceType = "TCS"
		else
			ChatServiceType = "LCS"
		end
	end

	return ChatServiceType
end

if game:FindFirstChild("TextChatService") then
	if TCS:FindFirstChild("TextChannels") then
		ChatServiceType = "TCS"
	else
		ChatServiceType = "LCS"
		SayMessageReq = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")
	end
end

local FSReport = {}

local StatsTable = {
	["TotalCalls"] = 0,
	["TotalCommandsIssued"] = 0,
	["TotalChatMessages"] = 0
}

local RoliTableLoaded = false

local RolimonsItemTable = nil

local abbreviations = {
	["K"] = 4,
	["M"] = 7
}

function WasFiltered(message)
	return message:match('^#+$') ~= nil
end

local CurrentChatPrefix = ""
local CurrentPromptPrefix = ""

local FS = {}

function FS.SetChatPrefix(NewPrefix, PromptPrefix)
	CurrentChatPrefix = NewPrefix
	CurrentPromptPrefix = PromptPrefix
end

function FS.CreatePlrLockBrick(playername, pos, cancollide, partname)
	StatsTable.TotalCommandsIssued = StatsTable.TotalCommandsIssued + 1
	local X = Instance.new("Part")
	X.Anchored = true
	X.CanCollide = cancollide
	X.Name = partname
	X.Transparency = 0.8
	X.Color = Color3.new(0.65098, 1, 0)
	if game.Workspace:FindFirstChild(tostring(playername)) then
		X.Parent = game.Workspace[tostring(playername)]
		local player = game.Workspace[tostring(playername)]
		task.spawn(function()
			Players.PlayerRemoving:Connect(function(playerleaving)
				if tostring(playerleaving) == tostring(player) then
					X:Destroy()
				end
			end)
			while true and task.wait(0.01) do
				if game.Workspace:FindFirstChild(tostring(playername)) then
					X.CFrame = player.HumanoidRootPart.CFrame + player.HumanoidRootPart.CFrame.LookVector * pos
				else
					X:Destroy()
				end
			end
		end)
	end

	return X
end


function FS.PrintTable(tableobj)
	StatsTable.TotalCommandsIssued = StatsTable.TotalCommandsIssued + 1
	if typeof(tableobj) == "table" then
		print(tableobj)
		for i,v in pairs(tableobj) do
			wait(0.01)
			if typeof(v) == "table" then
				print("\n\n-- // -- "..tostring(i).." TABLE -- // -- \n")
				FS.PrintTable(v)
			else
				print(tostring(i).." = "..tostring(v))
			end
		end
	else
		warn("PrintTable Function : Object is not a table!")
	end
end

function FS.ReplaceUrlSpacing(text)
	if typeof(text) == "string" then
		print(text.." was string")
		return text:gsub("%s", "%%20")
	else
		warn("TextWasNotString")
		return text
	end
end


function FS.PathfindPart(PartInstance,Char,Humanoid)
	StatsTable.TotalCommandsIssued = StatsTable.TotalCommandsIssued + 1
	local path = PFS:CreatePath()
	path:ComputeAsync(Char.Head.Position, PartInstance.Position)
	local waypoints = path:GetWaypoints()

	for i, waypoint in pairs(waypoints) do
		Humanoid:MoveTo(waypoint.Position)
		Humanoid.MoveToFinished:Wait(2)
	end

	Humanoid:MoveTo(PartInstance.Position)
	Humanoid.MoveToFinished:Wait(2)
end

function FS.Environment(Info)
	StatsTable.TotalCommandsIssued = StatsTable.TotalCommandsIssued + 1
	local DecideSide = Run:IsServer() and "Server" or Run:IsClient() and "Client" or Run:IsStudio() and "Studio"
	local args = table.pack(Info, DecideSide)
	return args
end

function FS.CreateHightLight(playername,highlighttable)
	local HL = Instance.new("Highlight")
	HL.FillColor = highlighttable.FillColor1
	HL.OutlineColor = highlighttable.OutlineColor1
	HL.FillTransparency = highlighttable.FillTrans1
	HL.OutlineTransparency = highlighttable.OutlineTrans

	HL.Parent = Players[playername].Character
end

function FS.RemoveHightLight(playername)
	local char = Players[playername].Character
	wait(1)
	for i,v in pairs(char:GetChildren()) do
		if v:IsA("Highlight") then
			v:Destroy()
		end
	end
end


function FS.TestConnection()
	StatsTable.TotalCommandsIssued = StatsTable.TotalCommandsIssued + 1
	StatsTable.TotalCalls = StatsTable.TotalCalls + 1

	local Getrequest
	Getrequest = request({
		Url = "https://httpbin.org/user-agent",
		Method = "GET",
	})
	print(Getrequest)
	local Decode = HTTP:JSONDecode(Getrequest.Body)
	FS.PrintTable(Getrequest.Headers)
	print(Getrequest.Headers)
	local returnstring = "User Agent: "..Decode["user-agent"].." , Status: "..Getrequest.StatusMessage.." , Connection: "..Getrequest.Headers.Connection
	return returnstring
end

function FS.Get_Request(URL)
	StatsTable.TotalCommandsIssued = StatsTable.TotalCommandsIssued + 1
	StatsTable.TotalCalls = StatsTable.TotalCalls + 1
	URL2 = FS.ReplaceUrlSpacing(URL)
	local Getrequest
	Getrequest = request({
		Url = URL2,
		Method = "GET",
	})
	local Decode = HTTP:JSONDecode(Getrequest.Body)
	return Decode
end

function FS.Request(URL, METHOD, HEADERS)
	StatsTable.TotalCommandsIssued = StatsTable.TotalCommandsIssued + 1
	StatsTable.TotalCalls = StatsTable.TotalCalls + 1
	URL2 = FS.ReplaceUrlSpacing(URL)
	local Getrequest
	Getrequest = request({
		Url = URL2,
		Method = METHOD,
		Headers = HEADERS,
	})
	
	print(Getrequest)
	local Decode = HTTP:JSONDecode(Getrequest.Body)
	print(Decode)
	return Decode
end

function FS.FindChatType()
	StatsTable.TotalCommandsIssued = StatsTable.TotalCommandsIssued + 1
	FindChatServiceType()

	return ChatServiceType
end

function FS.Report(Message, Public, IgnorePrefix)
	StatsTable.TotalCommandsIssued = StatsTable.TotalCommandsIssued + 1
	StatsTable.TotalChatMessages = StatsTable.TotalChatMessages + 1
	
	print(Message)
	local ReportMessage = ""
	
	if IgnorePrefix == true then
		ReportMessage = Message
	else
		ReportMessage = CurrentChatPrefix..Message
	end
	
	


	if ChatServiceType == "LCS" then
		if Public == true then
			local args = {
				[1] = ReportMessage,
				[2] = "All"
			}

			SayMessageReq:FireServer(unpack(args))

		end
	end
	if ChatServiceType == "TCS" then
		if Public == true then
			local TextChannels = TCS:WaitForChild("TextChannels")

			TextChannels.RBXGeneral:SendAsync(ReportMessage)
		end
	end
end

function FS.WebhookRequest(url, WebhookTable)
	local response if request then
		response = request(
			{
				Url = url,
				Method = "POST",
				Headers = {
					["Content-Type"] = "application/json"
				},
				Body = HTTP:JSONEncode(WebhookTable)
			}
		)
	end
end

function FS.Prompt(Message, TargetChatter)
	StatsTable.TotalChatMessages = StatsTable.TotalChatMessages + 1
	StatsTable.TotalCommandsIssued = StatsTable.TotalCommandsIssued + 1
	print(CurrentPromptPrefix)
	FS.Report(CurrentPromptPrefix..Message, true, true)
	print(Message)

	local ResponseContent = TargetChatter.Chatted:Wait(10)
	return tostring(ResponseContent)
end

function FS.unixtodate(unix)
	StatsTable.TotalCommandsIssued = StatsTable.TotalCommandsIssued + 1
	local t = os.date("*t", unix)

	return t
end

function FS.Format(Int)
	return string.format("%02i", Int)
end

function FS.FindUser(String)
	StatsTable.TotalCommandsIssued = StatsTable.TotalCommandsIssued + 1
	local Found = false
	local PartialName = String
	local foundPlayer = "Invalid Username."
	local Players = game.Players:GetPlayers()
	for i = 1, #Players do
		local CurrentPlayer = Players[i]

		if Found == false then
			for i = 1, #Players do
				local CurrentPlayer = Players[i]
				if string.lower(CurrentPlayer.Name):sub(1, #PartialName) == string.lower(PartialName) then
					foundPlayer = CurrentPlayer.Name
					Found = true
					return foundPlayer
				end
			end
		end
		
		if Found == false then
			for i = 1, #Players do
				local CurrentPlayer = Players[i]
				if string.lower(CurrentPlayer.DisplayName):sub(1, #PartialName) == string.lower(PartialName) then
					foundPlayer = CurrentPlayer.Name
					Found = true
					return foundPlayer
				end
			end
		end

		return foundPlayer
	end
end

function FS.AutoFillPlayer(String)
	StatsTable.TotalCommandsIssued = StatsTable.TotalCommandsIssued + 1
	local args = string.split(String, " ")
	local player = args[#args]
	local suc, info = pcall(FS.FindUser(player))

	if player == "*random" then
		local num = math.random(1,tonumber(#game.Players:GetPlayers()))
		return tostring(game.Players:GetPlayers()[num])
	end
	
	if string.find(player, '%*') then
		
		return string.gsub(player, '%*', '')
	end
	
	local returnstring = FS.FindUser(player)
	if info == "attempt to call a nil value" then
		returnstring = "Invalid username."
		warn("[⚠️] FunctionService.AutoFillPlayer Error : "..info.." ("..returnstring..")")
	end

	return returnstring
end

function FS.iterPageItems(pages)
	StatsTable.TotalCommandsIssued = StatsTable.TotalCommandsIssued + 1
	return coroutine.wrap(function()
		local pagenum = 1
		while true do
			for _, item in ipairs(pages:GetCurrentPage()) do
				coroutine.yield(item, pagenum)
			end
			if pages.IsFinished then
				break
			end
			pages:AdvanceToNextPageAsync()
			pagenum = pagenum + 1
		end
	end)
end

function FS.Rejoin()
	TP:Teleport(game.PlaceId, Players.LocalPlayer)
end

function FS.RolimonsValueTable()
	StatsTable.TotalCommandsIssued = StatsTable.TotalCommandsIssued + 1
	if RoliTableLoaded == false then
		RolimonsItemTable = FS.Get_Request("https://www.rolimons.com/itemapi/itemdetails")
		RoliTableLoaded = true
		return(RolimonsItemTable)
	else
		return(RolimonsItemTable)
	end
end

function FS.comma_value(amount)
	StatsTable.TotalCommandsIssued = StatsTable.TotalCommandsIssued + 1
	local k
	local formatted = amount
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if (k == 0) then
			break
		end
	end
	return formatted
end

function FS.abbreviate(number)
	StatsTable.TotalCommandsIssued = StatsTable.TotalCommandsIssued + 1
	local text = tostring(string.format("%.f", math.floor(number)))

	local chosenAbbreviation
	for abbreviation, digit in pairs(abbreviations) do
		if (#text >= digit and #text < (digit + 3)) then
			chosenAbbreviation = abbreviation
			break
		end
	end

	if (chosenAbbreviation) then
		local digits = abbreviations[chosenAbbreviation]

		local rounded = math.floor(number / 10 ^ (digits - 2)) * 10 ^ (digits - 2)
		text = string.format("%.1f", rounded / 10 ^ (digits - 1)) .. chosenAbbreviation
	else
		text = number
	end

	return text
end

function FS.round(n)
	return math.floor(tonumber(n) + 0.5)
end

function FS.rounddecimal(n)
	return math.floor(tonumber(n) + 0.05)
end

function FS.percentround(n)
	StatsTable.TotalCommandsIssued = StatsTable.TotalCommandsIssued + 1
	local Ratio = n / 1
	Ratio = math.floor(Ratio * 100 + 0.5)
	return Ratio
end

function FS.ServerSize()
	StatsTable.TotalCommandsIssued = StatsTable.TotalCommandsIssued + 1
	local maxsize = Players.MaxPlayers
	local currentplayers = #Players:GetChildren()
	
	local infotable = {
		["maxplayers"] = maxsize,
		["currentplayers"] = currentplayers
	}
	return infotable
end

function FS.ClientStats()
	StatsTable.TotalCommandsIssued = StatsTable.TotalCommandsIssued + 1
	return StatsTable
end

function FS.GetLimID(Text)
	StatsTable.TotalCommandsIssued = StatsTable.TotalCommandsIssued + 1
	local text = string.lower(Text)
	local itemtable = FS.RolimonsValueTable().items
	for i,v in pairs(itemtable) do
		if string.lower(v[2]) == text or string.lower(v[1]) == text then
			return i
		end
	end
end

function FS.parse_json_date(json_date)
	local pattern = "(%d+)%-(%d+)%-(%d+)%a(%d+)%:(%d+)%:([%d%.]+)([Z%+%-])(%d?%d?)%:?(%d?%d?)"
	local year, month, day, hour, minute, 
	seconds, offsetsign, offsethour, offsetmin = json_date:match(pattern)
	local timestamp = os.time{year = year, month = month, 
		day = day, hour = hour, min = minute, sec = seconds}
	local offset = 0
	if offsetsign ~= 'Z' then
		offset = tonumber(offsethour) * 60 + tonumber(offsetmin)
		if offset == "-" then offset = offset * -1 end
	end

	return timestamp + offset
end

function FS.convertmonth(num)
	local month = nil
	if num == 1 then
		month = "January"
	elseif num == 2 then
		month = "February"
	elseif num == 3 then
		month = "March"
	elseif num == 4 then
		month = "April"
	elseif num == 5 then
		month = "May"
	elseif num == 6 then
		month = "June"
	elseif num == 7 then
		month = "July"
	elseif num == 8 then
		month = "August"
	elseif num == 9 then
		month = "September"
	elseif num == 10 then
		month = "Octber"
	elseif num == 11 then
		month = "November"
	elseif num == 12 then
		month = "December"
	end

	return month
end

function FS.convertToHMS(Seconds)
	local Minutes = (Seconds - Seconds%60)/60
	Seconds = Seconds - Minutes*60
	local Hours = (Minutes - Minutes%60)/60
	Minutes = Minutes - Hours*60

	if FS.Format(Hours) == 00 or FS.Format(Hours) == "00" then
		return FS.Format(Minutes).." Minutes"
	else
		return FS.abbreviate(FS.Format(Hours)).." Hours and "..FS.Format(Minutes).." Minutes"
	end
end

function FS.ConvertKtoF(K)
	local f = 0

	f = tonumber(K + -273.15)
	f = f*1.8
	f = f+32

	return f
end

function FS.ConvertCtoF(C)
	local f = 0
	local no = 9/5
	f = tonumber(C * no)
	f = f+32

	return f
end

function FS.CreatePlrLockRing(playername, radius, cancollide, numberofparts)

	local character = game:GetService("Players")[playername].Character
	local hrp = character:WaitForChild("HumanoidRootPart")

	local parts = {}
	local partssofar = 1
	for _ = 1, numberofparts do
		local makepart = Instance.new("Part")
		makepart.Name = tostring(partssofar)
		makepart.Transparency = 0.8
		partssofar = partssofar + 1

		table.insert(parts, makepart)
	end
	local fullCircle = 2 * math.pi
	for i, part in pairs(parts) do
		part.Anchored = true
		part.CanCollide = cancollide
		part.Parent = workspace
	end

	local function getXAndZPositions(angle)
		local x = math.cos(angle) * radius
		local z = math.sin(angle) * radius
		return x, z
	end

	running = game:GetService("RunService").Heartbeat:Connect(function()
		Players.PlayerRemoving:Connect(function(player)
			if tostring(playername) == player then
				for i, part in pairs(parts) do
					part:Destroy()
				end
				running:Disconnect()
			end
		end)
		for i, part in pairs(parts) do
			local angle = i * (fullCircle / #parts)
			local x, z = getXAndZPositions(angle)

			local position = (hrp.CFrame * CFrame.new(x, 0, z)).p
			local lookAt = hrp.Position

			part.CFrame = CFrame.new(position, lookAt)
		end
	end)

	return parts

end


FS.Report("FunctionService "..FSVersion,true)

return FS	
