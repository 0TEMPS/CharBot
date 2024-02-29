--[=[ CHAR-BOT
	2/20/2024 CharBot 5.1 Krampus Build
CHAR-BOT ]=] 

-- Version

_G.BotConfig = {
	["General Settings"] = {
		-- // -- // -- // -- 
		["Owner"] = "00temps",
		-- // -- // -- // -- 
		["Approval Words"] = {
			"yes","yea","sure","yeah","true","y","ye","confirm" -- Words that the bot should take as "Yes".
		},
		-- // -- // -- // -- 
		["DisapprovalWords"] = {
			"no","nope","don't","false","pass","deny","n" -- word that the bot should take as "No".
		},
		-- // -- // -- // -- 
		["Greetings"] = {
			"Have a nice day!","Nice to meet you!" -- Words or Phrases that the bot can use as greetings.
		},
		-- // -- // -- // -- 
		["AutoJumpWhenSitting"] = true, 
		-- // -- // -- // -- 
		["Error-Logging"] = true, 
		-- // -- // -- // -- 
		["Log-Commands"] = true,
		-- // -- // -- // -- 
		["SendToDiscord"] = true, 
		-- // -- // -- // -- 
		["NativeCurrency"] = "USD", 
		["CurrencySymbol"] = "$", -- keep in mind some currency symbols will get # by roblox.
		-- // -- // -- // -- 
		["PlayerLockBrickVector"] = Vector3.new(-3,0,5), -- How far or close the bot will follow the owner.
		-- // -- // -- // -- 
		["OwnerHighlight"] = { -- Color and transparency of the owner highlight effect
			FillColor1 = Color3.new(0, 1, 0.933333),
			OutlineColor1 = Color3.new(0, 1, 0),
			FillTrans1 = 0.75,
			OutlineTrans = 0,
		},
		-- // -- // -- // -- 
		["TargetHighlight"] = { -- Color and transparency of the target highlight effect
			FillColor1 = Color3.new(0, 0.866667, 1),
			OutlineColor1 = Color3.new(1, 0, 0.0156863),
			FillTrans1 = 0.75,
			OutlineTrans = 0,
		},
	},
	-- // -- // -- // -- 
	["Chat Settings"] = {
		ChatPublicly = true, -- Bot will chat responses in the roblox chat, when disabled responses will be printed to the bot's console.
		ChatLoadingOutputs = true, -- Bot will chat loading messages in the roblox chat.
		ChatStartupGreeting = true, -- Bot will greet the player on startup.
		ChatErrorLogs = true, -- Bot chat error logs when errors are caught. (Only works if error logging is enabled)
		ChatPrefix = "[💬] "

	},
	-- // -- // -- // -- 
	["API Keys"] = {
		APININJA_KEY = "JlqHW95ZeE38VnjxRVrbzpMuUGUf1USGgqssQPag",
		DISCORD_WEBHOOK = "",
		RBLX_TRADE_SESS = ""
	},
	-- // -- // -- // -- 
	-- // DEBUG SETTINGS \\ --
	["PT-MS-Assets"] = {
		13704365741,13642077826,13277618561,13272083779,13272082846,13704365741,13642077826,13277618561,13272083779,13272082846
	},
}

loadstring(game:HttpGet("https://raw.githubusercontent.com/0TEMPS/CharBot/main/CharBotBasic.lua"))()
