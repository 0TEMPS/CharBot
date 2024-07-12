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

local headers = {
	["X-Api-Key"] = "JlqHW95ZeE38VnjxRVrbzpMuUGUf1USGgqssQPag"
}

local PlanetInfo = Request("https://api.api-ninjas.com/v1/planets?name=mars","GET",headers)



