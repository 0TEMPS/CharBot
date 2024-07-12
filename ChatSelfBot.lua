local HTTP = game:GetService("HttpService")

function ReplaceUrlSpacing(text)
	if typeof(text) == "string" then
		print(text.." was string")
		return text:gsub("%s", "%%20")
	else
		warn("TextWasNotString")
		return text
	end
end


function Request(URL, METHOD, HEADERS)
	
	local URL2 = ReplaceUrlSpacing(URL)
	print("FS.REQUEST DATA: "..URL2.."/"..METHOD.."/"..HEADERS)
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

local headers = {
	["X-Api-Key"] = "oFIQeqkCboqHggF2M0WkVbKxyIZ9v27K9I7KnU97"
}

local PlanetInfo = Request("https://api.api-ninjas.com/v1/planets?name=mars","GET",headers)



