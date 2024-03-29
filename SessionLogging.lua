local Players = game:GetService("Players")
local HTTPS = game:GetService("HttpService")

local FileName = "Hi.txt"
local FolderName = "DCTesting"


local UserIDTable = HTTPS:JSONDecode(readfile(FolderName..`/`..FileName))
local ChatLog = HTTPS:JSONDecode(readfile(FolderName..`/SC`))
local ChatConnections = {}
makefolder(FolderName)


function IsUserIDInTable(userID)
	return UserIDTable[userID] ~= nil
end

function AddUserIDToTable(userID)
	if not IsUserIDInTable(userID) then
		UserIDTable[userID] = {}
	end
end

function DeleteUserIDFromTable(userID)
	UserIDTable[userID] = nil
end

function GenerateSession(player, action)
	local userID = player.UserId

	-- Check if the userID already exists in the table
	if not IsUserIDInTable(userID) then
		print("Adding UserID to table...")
		AddUserIDToTable(userID)
	end

	-- Generate session name using os.date("%c") if joining
	local sessionName
	if action == "Joined" then
		sessionName = os.date("%c")
	else
		if not UserIDTable[userID]["currentSession"] then
			print("Error: No active session found for UserID: " .. userID)
			return
		end
		sessionName = UserIDTable[userID]["currentSession"]
	end

	-- Check if the userID already has a sessions table
	if not UserIDTable[userID]["sessions"] then
		UserIDTable[userID]["sessions"] = {}
	end

	-- Check if the session name already exists
	if not UserIDTable[userID]["sessions"][sessionName] then
		-- Create a new session table if not found and action is "Joined"
		if action == "Joined" then
			UserIDTable[userID]["sessions"][sessionName] = {}
			-- Store the session name if joining
			UserIDTable[userID]["currentSession"] = sessionName
		else
			print("Error: Session '" .. sessionName .. "' not found for UserID: " .. userID)
			return
		end
	end

	-- Store player details in the session table
	UserIDTable[userID]["sessions"][sessionName]["AccountAge"] = player.AccountAge
	UserIDTable[userID]["sessions"][sessionName]["UserName"] = player.Name
	UserIDTable[userID]["sessions"][sessionName]["DisplayName"] = player.DisplayName
	UserIDTable[userID]["sessions"][sessionName]["FollowUserId"] = player.FollowUserId
	UserIDTable[userID]["sessions"][sessionName]["HasVerifiedBadge"] = player.HasVerifiedBadge
	UserIDTable[userID]["sessions"][sessionName]["MembershipType"] = player.MembershipType.Name

	-- Record JoinTime or LeaveTime based on the action
	if action == "Joined" then
		UserIDTable[userID]["sessions"][sessionName]["JoinTime"] = os.time() -- Store current time in unix format
	elseif action == "Leaving" then
		-- Update existing session with LeaveTime and calculate SessionTime
		if UserIDTable[userID]["sessions"][sessionName]["JoinTime"] then
			UserIDTable[userID]["sessions"][sessionName]["LeaveTime"] = os.time() -- Store current time in unix format
			UserIDTable[userID]["sessions"][sessionName]["SessionTime"] = UserIDTable[userID]["sessions"][sessionName]["LeaveTime"] - UserIDTable[userID]["sessions"][sessionName]["JoinTime"]
		else
			print("Error: JoinTime not found for Session '" .. sessionName .. "' of UserID: " .. userID)
		end
		-- Reset current session to nil when leaving
		UserIDTable[userID]["currentSession"] = nil
	else
		print("Error: Invalid action specified. Action must be 'Joined' or 'Leaving'.")
		return
	end

	if action == "Joined" then
		print("New session '" .. sessionName .. "' created for UserID: " .. userID)
	else
		print("Session '" .. sessionName .. "' updated for UserID: " .. userID)
		print("JoinTime: " .. tostring(UserIDTable[userID]["sessions"][sessionName]["JoinTime"]))
		print("LeaveTime: " .. tostring(UserIDTable[userID]["sessions"][sessionName]["LeaveTime"]))
		print("SessionTime: " .. tostring(UserIDTable[userID]["sessions"][sessionName]["SessionTime"]))
	end
end

-- Function to convert a timestamp string into a valid filename format for Windows
function ConvertToValidFilename(timestamp)
	-- Replace unsupported characters with valid ones
	local invalidCharacters = {
		["/"] = "-",
		[":"] = "-",
		["*"] = "-",
		["?"] = "-",
		['"'] = "'",
		["<"] = "-",
		[">"] = "-",
		["|"] = "-"
	}

	return timestamp:gsub("[/\\:*?\"<>|]", function(match)
		return invalidCharacters[match] or match
	end)
end

function UpdateSessionFile()
	writefile(FolderName..`/`..FileName, HTTPS:JSONEncode(UserIDTable))
	print("Session File Updated.")
end

function UpdateChatLogFile()
	writefile(FolderName..`/SC`, HTTPS:JSONEncode(ChatLog))
	print("ChatLogging File Updated.")
end

-- Function to log chat messages for a player
function LogChatMessages(player, action)
	local userID = player.UserId

	-- Ensure that the player is in the game
	if not player then
		print("Error: Player instance is nil.")
		return
	end

	-- Handle the action based on whether the player is joining or leaving
	if action == "Joined" then
		-- Start logging chat messages for the player
		local connection
		connection = player.Chatted:Connect(function(message)
			local timeStamp = os.date("%c")
			if not ChatLog[userID] then
				ChatLog[userID] = {}
			end
			ChatLog[userID][timeStamp] = message
		end)
		print("Chat logging started for UserID: " .. userID)

		-- Store the connection object in the ChatConnections table
		ChatConnections[player] = connection
	elseif action == "Leaving" then
		-- Stop logging chat messages for the player
		local connection = ChatConnections[player]
		if connection then
			connection:Disconnect()
			ChatConnections[player] = nil
			print("Chat logging stopped for UserID: " .. userID)
		else
			print("Error: Chat connection not found for UserID: " .. userID)
		end
	else
		print("Error: Invalid action specified. Action must be 'Joined' or 'Leaving'.")
	end
end

Players.PlayerAdded:Connect(function(player)
	print("[Joined] "..player.Name)
	AddUserIDToTable(player.UserId)
	GenerateSession(player, "Joined")
	LogChatMessages(player,"Joined")
end)

Players.PlayerRemoving:Connect(function(player)
	print("[Leaving] "..player.Name)
	GenerateSession(player, "Leaving")
	LogChatMessages(player,"Leaving")
	UpdateSessionFile()
	UpdateChatLogFile()
end)
