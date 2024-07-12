-- // START UP \\ --
local start = os.clock()
-- // SETTINGS \\ --

ChatLogsPublic = true
ChatLoadingMessages = true

-- // SETTINGS \\ --

local RequestTime = os.date
local TotalCalls = 0
-- // VARS \\ --
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PN = Player.Name
local TPS = game:GetService("TeleportService")
local MS = game:GetService("MarketplaceService")
local HTTPS = game:GetService("HttpService")
local PFS = game:GetService("PathfindingService")
local TextChatService = game:GetService("TextChatService")
local request = (syn and syn.request) or (http and http.request) or http_request
local StartupTime = RequestTime "%I" .. ":" .. RequestTime "%M" .. RequestTime "%p"
local Place = MS:GetProductInfo(game.PlaceId).Name

local ChatServiceType = nil
local SayMessageReq = nil
local MessageIndex = nil
-- // KEYS \\ --
local APINinjaKey = "cnXsRuNZJiV42yBy4AWfBA==poI28uJMFKCryeGR"
local SIRUSKEY = "eudIVAUElUOHIEwrlZLiVQFqFIFSyuUd"

local PingTestAssets = {
	13704365741,
	13642077826,
	13277618561,
	13272083779,
	13272082846,
	13704365741,
	13642077826,
	13277618561,
	13272083779,
	13272082846
}

-- // AUTO FILL PLAYER NAMES \\ --
function findUser(strng)
	local PartialName = strng
	local foundPlayer
	local Players = game.Players:GetPlayers()
	for i = 1, #Players do
		local CurrentPlayer = Players[i]
		if string.lower(CurrentPlayer.Name):sub(1, #PartialName) == string.lower(PartialName) then
			foundPlayer = CurrentPlayer.Name
			break
		end
	end
	return foundPlayer
end

-- // CHAT FUNCTION, CHATS ARE CALLED "REPORTS" \\ --
function Report(msg)
	if ChatServiceType == "LCS" then
		if ChatLogsPublic == true then
			local args = {
				[1] = msg,
				[2] = "All"
			}

			SayMessageReq:FireServer(unpack(args))
			print(msg)
		else
			print(msg)
		end
	end
	if ChatServiceType == "TCS" then
		if ChatLogsPublic == true then
			TextChannels = TextChatService:WaitForChild("TextChannels")

			TextChannels.RBXGeneral:SendAsync(msg)
			print(msg)
		else
			print(msg)
		end
	end
end

-- // FIGURES OUT WHAT CHAT SYSTEM THE GAME IS USING \\ --
if game:FindFirstChild("TextChatService") then
	if TextChatService:FindFirstChild("TextChannels") then
		ChatServiceType = "TCS"
		Report(Place.." uses TextChatService.")
	else
		ChatServiceType = "LCS"
		SayMessageReq = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")
		Report(Place.." uses LegacyChatService.")
	end
end

-- // BASIC REQUEST FUNCTION, NO HEADERS OR DATA ONLY SUPPORTS GET REQUESTS \\ --
function Request(url, method)
	if request then
		response =
			request(
				{
					Url = url,
					Method = method
				}
			)
	end
	TotalCalls = TotalCalls + 1
	return response
end

-- // REQUEST FUNCTION FOR APININJA APIS \\ --
function RequestAPINinja(url, method)

	local headers = {
		["X-Api-Key"] = APINinjaKey
	}

	if request then
		response =
			request(
				{
					Url = url,
					Method = method,
					Headers = headers
				}
			)
	end
	TotalCalls = TotalCalls + 1
	return response
end

-- // CREATES AND LOADS THE ROLIMONS ITEM TABLE, USED TO INDEX IMFORMATION ABOUT ITEMS \\ -
local RolimonsItemTable = {}
function RolimonsValueTable()
	local response = Request("https://www.rolimons.com/itemapi/itemdetails", "GET")
	RolimonsItemTable = HTTPS:JSONDecode(response.Body)
	if ChatLoadingMessages == true then
		Report("Rolimons Value Table Loaded, table size : "..RolimonsItemTable.item_count.." items.")
	end
end
RolimonsValueTable()

-- // ABBREVATION FUNCTION, USED TO MAKE NUMBERS LARGER THAN 1,000,000 SHORT TO 1M \\ -
local abbreviations = {
	["K"] = 4,
	["M"] = 7
}
-- AbbreviateNumbers (Only used for 1M+)
function abbreviate(number)
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

-- // ADDS COMMAS TO NUMBERS LARGER THAN 1,000 \\ -
function comma_value(amount)
	local formatted = amount
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if (k == 0) then
			break
		end
	end
	return formatted
end

-- // USED FOR THE .FRIENDS COMMAND, I DIDNT WRITE THIS FUNCTION, NO CLUE HOW IT WORKS \\ -
function iterPageItems(pages)
	return coroutine.wrap(
		function()
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
		end
	)
end

-- // ROUNDS NUMBERS UP TO THE CLOESTEST WHOLE NUMBER \\ -
local function round(n)
	return math.floor(n + 0.5)
end

-- // USED FOR VERY SMALL NUMBERS, GETS THE FIRST 2 DECIMAL SPOTS AND MAKES THEM THE WHOLE NUMBER \\ -
function percentround(n)
	local Ratio = n / 1
	Ratio = math.floor(Ratio * 100 + 0.5)
	return Ratio
end

function ConvertKtoF(K)
	local f = 0

	f = tonumber(K + -273.15)
	f = f*1.8
	f = f+32

	return f
end

-- // FUNCTION USED FOR THE ORANGE DOTS THAT ARE LEFT BEHIND WHEN PATHFINDING \\ -
function Breadcrumbs(SPOT)
	local part = Instance.new("Part")
	part.Name = "PathfindingWaypoint"
	part.Shape = "Ball"
	part.Material = "Neon"
	part.Color = Color3.new(1, 0.368627, 0.00392157)
	part.Size = Vector3.new(0.6, 0.6, 0.6)
	part.Position = SPOT + Vector3.new(0, 2, 0)
	part.Anchored = true
	part.CanCollide = false
	part.Parent = game.Workspace
end

-- // FUNCTION FOR THE .MATH COMMAND, CONVERTS STRINGS INTO USEABLE NUMBER SEQUENCES \\ -
function calc_from_string (str)
	local start = tonumber(string.match(str,"%d+"))
	local operations = {["+"]=0, ["-"]=0}

	for i in string.gmatch(str,"%p%d+") do
		if string.sub(i,1,1) == "-" then
			operations["-"] -= tonumber(string.sub(i,2,string.len(i)))
		elseif string.sub(i,1,1) == "+" then
			operations["+"] += tonumber(string.sub(i,2,string.len(i)))
		end
	end

	return start+operations["+"]+operations["-"]
end

-- // THIS SETS "MESSAGEFUNCTION" WHICH IS USED TO READ THE OWNERS CHATS \\ -
if ChatServiceType == "LCS" then
	MessageFunction = Player.Chatted
elseif ChatServiceType == "TCS" then
	MessageFunction = game:GetService("TextChatService").TextChannels.RBXGeneral.MessageReceived
end

-- // THIS IS USED TO READ THE TEXT STRING FOR LCS GAMES \\ -
function GetMessageString(sstring)
	local msg = nil
	if ChatServiceType == "LCS" then
		msg = sstring
	elseif ChatServiceType == "TCS" then
		msg = sstring.Text
	end

	return msg
end


-- // ACTUAL COMMAND FUNCTION STARTS HERE \\ --


MessageFunction:Connect(
	function(msg)
		-- // FOR GAMES THAT USE LEGACYCHATSERVICE, CHECKS THE MESSAGE IS OWNED BY THE LOCAL PLAYER \\ --
		local MessageChecked = false
		if ChatServiceType == "TCS" then
			if msg.TextSource.Name == Player.Name then
				msg = GetMessageString(msg)
				MessageChecked = true
			end
		elseif ChatServiceType == "LCS" then
			MessageChecked = true
		end

		if MessageChecked == true then
			if msg == ".rj" then
				Report("Rejoining " .. Place)
				wait(1)
				TPS:Teleport(game.PlaceId, Player)
			end

			if msg:match(".ch") then
				local args = string.split(msg, " ")
				local player = args[#args]
				local suc, info = pcall(findUser(player))
				if suc == false then
					local fullplayer = findUser(player)

					if info == "attempt to call a nil value" then
						Report("Invalid username.")
					else
						local userid = Players:GetUserIdFromNameAsync(fullplayer)
						print("Searching for " .. tostring(fullplayer) .. "'s Rolimon Stats, UserID : (" .. userid .. ")")

						local response = Request("https://www.rolimons.com/api/playerassets/"..userid, "GET")

						local rolitable = HTTPS:JSONDecode(response.Body)
						local totalValue = 0
						if rolitable.success == false then
							Report("Request failed, Rolimons has no profile for player.")
						else	
							if rolitable.playerPrivacyEnabled == true then
								Report("Player inventory scan failed, private inventory.")
							else
								for i2, v2 in pairs(rolitable.playerAssets) do
									local timesran = #v2 - 1
									for i = timesran, 0, -1 do
										local item = RolimonsItemTable.items[i2]
										if item[4] == -1 then
											totalValue = totalValue + item[3]
										else
											totalValue = totalValue + item[4]
										end
									end
								end
								if #tostring(math.floor(totalValue)) >= 7 then
									Report(tostring(fullplayer) .."'s Total Value is : " .. abbreviate(totalValue))
								else
									Report(tostring(fullplayer) .. "'s Total Value is : " .. comma_value(totalValue))
								end
							end
						end
					end
				end
			end

			if msg:match(".global") then
				local args = string.split(msg, " ")
				local player = args[#args]
				local userid = Players:GetUserIdFromNameAsync(player)
				print("Searching for " .. tostring(player) .. "'s Rolimon Stats, UserID : (" .. userid .. ")")

				local response = Request("https://www.rolimons.com/api/playerassets/"..userid, "GET")
				local rolitable = HTTPS:JSONDecode(response.Body)

				local totalValue = 0
				if rolitable.success == false then
					Report("Request failed, Rolimons has no profile for player.")
				else	
					if rolitable.playerPrivacyEnabled == true then
						Report("Player inventory scan failed, private inventory.")
					else
						for i2, v2 in pairs(rolitable.playerAssets) do
							local timesran = #v2 - 1
							for i = timesran, 0, -1 do
								local item = RolimonsItemTable.items[i2]
								if item[4] == -1 then
									totalValue = totalValue + item[3]
								else
									totalValue = totalValue + item[4]
								end
							end
						end
						if #tostring(math.floor(totalValue)) >= 7 then
							Report(tostring("Rolimons values " .. player) .."'s Total Value is : " .. abbreviate(totalValue))
						else
							Report(tostring(player) .. "'s Total Value is : " .. comma_value(totalValue))
						end
					end
				end

			end

			if  msg == ".pl" then
				if ChatLogsPublic == false then
					ChatLogsPublic = true
				elseif ChatLogsPublic == true then
					ChatLogsPublic = false
				end
				Report("Public Reporting set to " .. tostring(ChatLogsPublic))
			end

			if  msg == ".act" then
				Report("Script is Active")
			end

			if  msg == ".reset" then
				Player.Character.Humanoid.Health = 0
				Report("Reseting...")
			end

			if msg == ".dex" then
				Report("Running Dex...")
				loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
			end

			if msg == ".iy" then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source",true))()
				Report("Running Infinite Yield ...")
			end

			if msg == ".rspy" then
				loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"))()
				Report("Running Remote Spy...")
			end

			if msg == ".sirus" then
				Report("Running Sirus Universal...")
				script_key= SIRUSKEY;
				loadstring(game:HttpGet('https://sirius.menu/script'))();
			end

			if msg == ".daymonth" then
				Report(
					"Today is " ..
						RequestTime "%A" ..
						" (" ..
						RequestTime "%a" ..
						"), The Month is " .. RequestTime "%B" .. " (" .. RequestTime "%b" .. ")."
				)
			end

			if msg == ".time" then
				Report("The time is " .. RequestTime "%I" .. ":" .. RequestTime "%M" .. RequestTime "%p")
			end

			if msg == ".fulldate" then
				Report(RequestTime "%x")
			end

			if msg:match(".friends") then
				local Players = game:GetService("Players")
				local args = string.split(msg, " ")
				local player = args[#args]
				local USERNAME = findUser(player)

				local userId = Players:GetUserIdFromNameAsync(USERNAME)
				local friendPages = Players:GetFriendsAsync(userId)
				local usernames = {}

				for item, _pageNo in iterPageItems(friendPages) do
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
					Report(USERNAME .. " Has no in game friends.")
					Report(USERNAME.." has "..#usernames.." friends in total.")
				else
					Report(USERNAME .. "'s in game friends, " .. table.concat(ingamefriends, ", "))
					Report(USERNAME.." has "..#usernames.." friends in total.")
				end
			end

			if msg == ".serversize" then
				local maxsize = Players.MaxPlayers
				local currentplayers = #Players:GetChildren()
				Report("Server is Currently at "..currentplayers.." out of "..maxsize.." players.")
			end

			if msg:match(".price") then
				local args = string.split(msg, " ")
				local coinname = args[#args]

				local response = Request("https://api.coingecko.com/api/v3/coins/"..coinname, "GET")

				local cointable = HTTPS:JSONDecode(response.Body)

				Report("One "..cointable.name.." is currently valued at $"..comma_value(cointable.market_data.current_price.usd).." (USD)")
			end

			if msg:match(".pathfind") then
				local args = string.split(msg, " ")
				local coinname = args[#args]
				local player = args[#args]
				local USERNAME = findUser(player)

				local target = game.Workspace[USERNAME]
				local Character = Player.Character

				local human = Character:WaitForChild("Humanoid")

				local path = PFS:CreatePath()
				path:ComputeAsync(Character.Head.Position, target.Head.Position)
				local waypoints = path:GetWaypoints()

				for i, waypoint in pairs(waypoints) do
					Breadcrumbs(waypoint.Position)
					human:MoveTo(waypoint.Position)
					human.MoveToFinished:Wait(2)
				end

				human:MoveTo(target.Head.Position)
				human.MoveToFinished:Wait(2)

				for i,v in pairs(game.Workspace:GetChildren()) do
					if v.Name == "PathfindingWaypoint" or v.Name == "Part" then
						v:Destroy()
					end
				end
			end

			if msg == ".antiafk" then
				local VirtualUser =game:service'VirtualUser'

				Players.LocalPlayer.Idled:Connect(function()
					VirtualUser:CapturedController()
					VirtualUser:ClickButton2(Vector2.new())
				end)

				Report("Anti AFK Kick Active")
			end

			if msg == ".removedots" then
				for i,v in pairs(game.Workspace:GetChildren()) do
					if v.Name == "PathfindingWaypoint" or v.Name == "Part" then
						v:Destroy()
					end
				end

				Report("Removed pathfinding waypoints.")
			end

			if msg:match(".pastname") then
				local args = string.split(msg, " ")
				local player = args[#args]
				local fullplayer = findUser(player)
				local userid = Players:GetUserIdFromNameAsync(fullplayer)
				local response = Request("https://users.roblox.com/v1/users/"..userid.."/username-history?limit=10&sortOrder=Asc", "GET")
				local pastusers = HTTPS:JSONDecode(response.Body)
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
					Report(fullplayer.." has not changed their username.")
				elseif #oldnames == 1 then
					Report(fullplayer.."'s old username is "..table.concat(oldnames,", "))
				else
					Report(fullplayer.."'s old usernames, "..table.concat(oldnames,", "))
				end


			end

			if msg:match(".outfits") then
				local args = string.split(msg, " ")
				local player = args[#args]
				local fullplayer = findUser(player)
				local userid = Players:GetUserIdFromNameAsync(fullplayer)

				local response = Request("https://avatar.roblox.com/v1/users/"..userid.."/outfits", "GET")
				local outfits = HTTPS:JSONDecode(response.Body)


				Report(tostring(fullplayer).." Has "..tostring(outfits.total).." outfits in total.")

			end

			if msg:match(".joind") then
				local args = string.split(msg, " ")
				local player = args[#args]
				local fullplayer = findUser(player)
				local joinTime = os.time() - (Players[fullplayer].AccountAge*86400)
				local joinDate = os.date("!*t", joinTime)

				Report(fullplayer.." Joined Roblox : "..joinDate.day.."/"..joinDate.month.."/"..joinDate.year)
			end

			if msg:match(".daysold") then
				local args = string.split(msg, " ")
				local player = args[#args]
				local fullplayer = findUser(player)
				local joinTime = Players[fullplayer].AccountAge

				Report(fullplayer.." Joined Roblox "..joinTime.." days ago")
			end

			if msg:match(".placevisits") then
				local args = string.split(msg, " ")
				local player = args[#args]
				local fullplayer = findUser(player)
				local userid = Players:GetUserIdFromNameAsync(fullplayer)
				local gamesUrl = "https://games.roblox.com/v2/users/"..userid.."/games?sortOrder=Asc&limit=10"
				local visitsUrl = "https://games.roblox.com/v1/games?universeIds="

				local gamesData = Request(gamesUrl, "GET")

				TotalCalls = TotalCalls + 1
				print(gamesData)
				gamesData = HTTPS:JSONDecode(gamesData.Body)
				local totalVisits = 0
				for i,v in pairs(gamesData.data) do
					local visits = v.placeVisits
					totalVisits = totalVisits + visits
				end

				Report(fullplayer.." has "..totalVisits.." visits on their profile.")

			end

			if msg:match(".limited") then
				local args = string.split(msg, " ")
				local itemshort = args[#args]
				print(itemshort)

				for i,v in pairs(RolimonsItemTable.items) do
					if v[2] == itemshort then
						local Demand = "No Assigned"

						if v[6] == 0 then
							Demand = "Terrible🗑️"
						elseif v[6] == 1 then
							Demand = "Low"
						elseif	v[6] == 2 then
							Demand = "Normal"
						elseif	v[6] == 3 then
							Demand = "High"
						elseif	v[6] == 4 then
							Demand = "Amazing💎"
						end
						local Trend = "Not assigned"
						if v[7] == 0 then
							Trend = "Lowering📉"
						elseif v[7] == 1 then
							Trend = "Unstable"
						elseif v[7] == 2 then
							Trend = "Stable"
						elseif v[7] == 3 then
							Trend = "Raising📈"
						elseif v[7] == 4 then
							Trend = "Fluctuating"
						end

						wait(0.7)
						Report(v[1].." ("..v[2]..") Currently has "..abbreviate(v[3]).." RAP.")
						wait(0.3)
						Report(v[2].." is valued at "..abbreviate(v[4]))
						Report(v[2].." has "..Demand.." demand, It's trend is "..Trend)
					end
				end

			end

			if msg:match(".liminv") then
				local args = string.split(msg, " ")
				local player = args[#args]
				local fullplayer = findUser(player)
				local userid = Players:GetUserIdFromNameAsync(fullplayer)
				print("Searching for " .. tostring(fullplayer) .. "'s Rolimon Stats ID : (" .. userid .. ")")

				local response = Request("https://www.rolimons.com/api/playerassets/" .. userid, "GET")
				local rolitable = HTTPS:JSONDecode(response.Body)
				local counter = 0
				local itemstosay = {}
				for i,v in pairs(rolitable.playerAssets) do
					if counter <= 5 then
						for i2,v2 in pairs(RolimonsItemTable.items) do
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
				if #itemstosay == 0 then
					Report(fullplayer.." has no notable items.")
				else
					Report(fullplayer.." has "..table.concat(itemstosay,", "))
				end


			end

			if msg:match(".math") then
				local args = string.split(msg, " ")
				local problem = args[#args]

				wait(0.5)
				Report(problem.." = "..calc_from_string(problem))
			end

			if msg == ".totalcalls" then
				Report(TotalCalls.." Calls preformed since "..StartupTime)
			end

			if msg:match(".isverified") then
				local args = string.split(msg, " ")
				local player = args[#args]
				local fullplayer = findUser(player)
				local userid = Players:GetUserIdFromNameAsync(fullplayer)
				local searchingid = 102611803
				local response = Request("https://inventory.roblox.com/v1/users/"..userid.."/inventory/8?pageNumber=1&itemsPerPage=250", "GET")
				local itemtable = HTTPS:JSONDecode(response.Body)
				local isverified = false
				if itemtable["errors"] ~= nil then
					Report("Failed to check "..fullplayer.."'s verified status.")
				else
					for i,v in pairs(itemtable.data) do
						if v == searchingid then
							isverified = true
						end
					end
					if isverified == false then
						Report(fullplayer.." has not verified their email.")
					elseif isverified == true then
						Report(fullplayer.." has verified their email.")
					end

				end
			end

			if msg:match(".robloxbadges") then
				local args = string.split(msg, " ")
				local player = args[#args]
				local fullplayer = findUser(player)
				local userid = Players:GetUserIdFromNameAsync(fullplayer)
				local response = Request("https://accountinformation.roblox.com/v1/users/"..userid.."/roblox-badges", "GET")
				local badgetable = HTTPS:JSONDecode(response.Body)
				local badgelist = {}
				for i,v in pairs(badgetable) do
					table.insert(badgelist,v.name)
				end
				if #badgelist == 2 then
					Report(fullplayer.." has the "..table.concat(badgelist," and ").." badges.")
				elseif #badgelist == 0 then
					Report(fullplayer.." has no roblox badges.")
				else
					Report(fullplayer.." has the "..table.concat(badgelist,", ").." badges.")
				end
			end

			if msg:match(".followers") then
				local args = string.split(msg, " ")
				local player = args[#args]
				local fullplayer = findUser(player)
				local userid = Players:GetUserIdFromNameAsync(fullplayer)

				local response = Request("https://friends.roblox.com/v1/users/"..userid.."/followers/count", "GET")
				local followertable = HTTPS:JSONDecode(response.Body)

				wait(0.5)

				Report(fullplayer.." has "..followertable.count.." Roblox followers.")
			end

			if msg:match(".userid") then
				local args = string.split(msg, " ")
				local player = args[#args]
				local fullplayer = findUser(player)
				local userid = Players:GetUserIdFromNameAsync(fullplayer)

				wait(0.5)

				Report(fullplayer.."'s UserID :  "..userid)
			end

			--WindowsPlayer, WindowsStudio, MacPlayer or MacStudio
			if msg:match(".binarytype") then
				local args = string.split(msg, " ")
				local plattype = args[#args]

				local response = Request("https://clientsettings.roblox.com/v2/client-version/"..plattype, "GET")
				local playtable = HTTPS:JSONDecode(response.Body)

				Report("Current CVU : "..playtable.clientVersionUpload)

				wait(0.5)

				Report("Current BsV : "..playtable.bootstrapperVersion)
			end

			if msg:match(".avcost") then
				local args = string.split(msg, " ")
				local player = args[#args]
				local fullplayer = findUser(player)
				local userid = Players:GetUserIdFromNameAsync(fullplayer)
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


				Report("Totaling the price of "..fullplayer.."'s avatar...")
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

				if humdesc.Head == 134082579 then
					totalcost = totalcost + 31000
				end

				if humdesc.RightLeg == 139607718 then
					totalcost = totalcost + 17000
				end 

				Report(fullplayer.."'s avatar costs an estimated "..comma_value(totalcost).." Robux.")
			end

			if msg:match(".limcount") then
				local args = string.split(msg, " ")
				local player = args[#args]
				local suc, info = pcall(findUser(player))
				if suc == false then
					local fullplayer = findUser(player)

					if info == "attempt to call a nil value" then
						Report("Invalid username.")
					else
						local userid = Players:GetUserIdFromNameAsync(fullplayer)
						print("Searching for " .. tostring(fullplayer) .. "'s Rolimon Stats, UserID : (" .. userid .. ")")

						local response = Request("https://www.rolimons.com/api/playerassets/"..userid, "GET")

						local rolitable = HTTPS:JSONDecode(response.Body)
						local totalValue = 0
						if rolitable.success == false then
							Report("Request failed, Rolimons has no profile for player.")
						else	
							if rolitable.playerPrivacyEnabled == true then
								Report("Player inventory scan failed, private inventory.")
							else
								for i,v in pairs(rolitable.playerAssets) do
									for i2,v2 in pairs(v) do
										totalValue = totalValue + 1
									end
								end
								if totalValue == 1 then
									Report(tostring(fullplayer) .. " has " ..totalValue.." limited item.")
								else
									Report(tostring(fullplayer) .. " has " ..totalValue.." limited items.")
								end
							end
						end
					end
				end
			end

			if msg:match(".copycount") then
				local args = string.split(msg, " ")
				local itemshort = args[#args]
				print(itemshort)

				for i,v in pairs(RolimonsItemTable.items) do
					if v[2] == itemshort then
						local response = Request("https://rblx.trade/api/v2/catalog/"..tostring(i).."/owners/count", "GET")
						local rolitable = HTTPS:JSONDecode(response.Body)
						for i,v in pairs(rolitable) do
							print(tostring(i),tostring(v))
						end
						Report(v[2].." has "..comma_value(rolitable.normal).." active copies, "..comma_value(rolitable.terminated).." have copies been terminated.")
						wait(0.2)
						Report(comma_value(rolitable.missing).." copies are missing, "..comma_value(rolitable.normalPremium).." are owned by Premium accounts.")
						wait(0.2)
						local totalcopies = rolitable.normal+rolitable.terminated
						Report("Estimated that "..comma_value(totalcopies).." copies currently exist.")
					end
				end
			end

			if msg:match(".lastsale") then
				local args = string.split(msg, " ")
				local itemshort = args[#args]
				print(itemshort)

				for i,v in pairs(RolimonsItemTable.items) do
					if v[2] == itemshort then
						local response = Request("https://rblx.trade/api/v2/catalog/"..tostring(i).."/sales?limit=1", "GET")
						local rolitable = HTTPS:JSONDecode(response.Body)
						local saleamount = rolitable.data[1].estimatedRobux
						if rolitable.data[1].buyerId == nil then
							if saleamount >= 1000000 then
								Report(v[2].." last sold for an estimated "..abbreviate(rolitable.data[1].estimatedRobux).." Robux to an unknown buyer.")
							else
								Report(v[2].." last sold for an estimated "..comma_value(rolitable.data[1].estimatedRobux).." Robux to an unknown buyer.")
							end
						else
							if saleamount >= 1000000 then
								Report(v[2].." last sold for an estimated "..abbreviate(rolitable.data[1].estimatedRobux).." Robux to "..Players:GetNameFromUserIdAsync(rolitable.data[1].buyerId))
							else
								Report(v[2].." last sold for an estimated "..comma_value(rolitable.data[1].estimatedRobux).." Robux to "..Players:GetNameFromUserIdAsync(rolitable.data[1].buyerId))
							end

						end

					end
				end
			end

			if msg == ".apihealth" then
				local response = Request("https://rblx.trade/api/v1/health", "GET")
				local rolitable = HTTPS:JSONDecode(response.Body)

				for i,v in pairs(rolitable.status) do
					Report("Name : "..v.name.." |  Status : "..v.status.." | Processed in "..v.durationMilliseconds.." MS")
				end
			end

			if msg == ".netversion" then
				local response = Request("https://rblx.trade/api/v1/version", "GET")
				local rolitable = HTTPS:JSONDecode(response.Body)

				Report("net = "..rolitable.net)
				wait(0.1)
				Report("netRuntime = "..rolitable.netRuntime)
				wait(0.1)
				Report("BE = "..rolitable.backend)
			end

			if msg == ".gameservers" then
				local chckd = false
				local response = Request("https://games.roblox.com/v1/games/"..tostring(game.PlaceId).."/servers/0?sortOrder=2&excludeFullGames=false&limit=100", "GET")
				local rolitable = HTTPS:JSONDecode(response.Body)

				Report(Place.." currently has "..#rolitable.data.." active servers.")
				wait(0.1)
				for i,v in pairs(rolitable.data) do
					if v.id == game.JobId then
						Report("This server's ping is "..v.ping.." with an average FPS of "..round(v.fps))
						chckd = true
					end
				end
				if chckd == false then
					Report("Could not verify information on current server.")
				end
			end

			if msg:match(".fact") then
				local response = RequestAPINinja("https://api.api-ninjas.com/v1/facts?limit=10","GET")
				local returntable = HTTPS:JSONDecode(response.Body)
				local foundfact = false

				for i,v in pairs(returntable) do
					if foundfact == false then
						if #v.fact >= 50 then

						else
							foundfact = true
							Report(v.fact)
						end
					end
				end
				if foundfact == false then
					Report("failed, fact too many characters.")
				end
			end


			if msg:match(".planet") then
				local args = string.split(msg, " ")
				local planet = args[#args]
				local response = RequestAPINinja("https://api.api-ninjas.com/v1/planets?name="..planet,"GET")
				local returntable = HTTPS:JSONDecode(response.Body)

				Report(returntable[1].name.." has a current average surface temp. of "..round(ConvertKtoF(returntable[1].temperature)).." (F) .")
				wait(0.1)
				Report("It takes "..returntable[1].name.." "..comma_value(returntable[1].period).." Earth days to orbit it's host star.")
			end

			if msg:match(".car") then
				local args = string.split(msg, " ")
				local car = args[#args]
				local response = RequestAPINinja("https://api.api-ninjas.com/v1/cars?limit=1&model="..car,"GET")
				local returntable = HTTPS:JSONDecode(response.Body)
				local carfacts = returntable[1]
				Report("The "..carfacts.make.." "..carfacts.model.." first entered production in "..carfacts.year..".")
				wait(0.1)
				Report("It has a "..carfacts.cylinders.." cylinder engine that gets "..carfacts.combination_mpg.." MPG on average.")
			end

			if msg:match(".randomword") then
				local response = RequestAPINinja("https://api.api-ninjas.com/v1/randomword","GET")
				local returntable = HTTPS:JSONDecode(response.Body)
				local randomword = returntable


				Report(randomword.word)
			end

			if msg == ".testrobloxping" then
				local TotalPingTime = os.clock()
				Report("Starting MS ping test, please wait.")

				local OSClockTable = {}
				for i,v in pairs(PingTestAssets) do
					local TimerStart = os.clock()
					local Info = MS:GetProductInfo(v).PriceInRobux
					local TimeTook = round(os.clock()-start)

					table.insert(OSClockTable,TimeTook)
				end
				local TotalTimeTook = 0

				for i,v in pairs(OSClockTable) do
					TotalTimeTook = TotalTimeTook + v
				end
				local AverageTimeToPing = TotalTimeTook/#OSClockTable

				Report("Finished pinging MS, average reponse time : "..AverageTimeToPing.." MS | Ping test took "..percentround(os.clock()-start).."0 MS to complete.")
			end

			-- END, DONT CUT BELOW
		end
	end
)
wait(0.5)
Report("Script loaded, took "..percentround(os.clock()-start).." MS.")
