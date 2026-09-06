local publicconfigs = {}
local httpService = game:GetService('HttpService')
local players = game:GetService('Players')
local localPlayer = players.LocalPlayer or {Name = "Anonymous"}

-- YOUR 24/7 CLOUDFLARE WORKER API (always online, no external dependencies)
local API_BASE = "https://broken-glitter-fc5d.motionv4.workers.dev"

local req = (syn and syn.request) or (http and http.request) or http_request or request or (fluxus and fluxus.request)

local function makeRequest(options)
	if req then
		local suc, res = pcall(req, options)
		if suc and res then return res end
	end
	if options.Method == "GET" and game.HttpGet then
		local suc, res = pcall(function()
			return game:HttpGet(options.Url, true)
		end)
		if suc then
			return {StatusCode = 200, Body = res}
		end
	end
	return {StatusCode = 500, Body = "Request failed"}
end

publicconfigs.Cache = {}

function publicconfigs.FetchAll(filterPlaceId)
	local response = makeRequest({
		Url = API_BASE .. "/configs",
		Method = "GET",
		Headers = {
			["Content-Type"] = "application/json"
		}
	})

	local listData = nil
	if response.StatusCode == 200 or response.StatusCode == 201 then
		local suc, decoded = pcall(function()
			return httpService:JSONDecode(response.Body)
		end)
		if suc and type(decoded) == "table" then
			listData = decoded.configs or decoded
		end
	end

	if listData then
		publicconfigs.Cache = listData
	else
		listData = publicconfigs.Cache
	end

	local filtered = {}
	for _, item in ipairs(listData) do
		if not filterPlaceId or tostring(item.game) == tostring(filterPlaceId) or item.game == "Universal" then
			table.insert(filtered, item)
		end
	end
	return true, filtered, listData
end

function publicconfigs.Upload(configName, placeId, profileData, authorName)
	if not configName or configName == "" then
		return false, "Config name cannot be empty!"
	end

	local author = authorName or (localPlayer and localPlayer.Name) or "Anonymous"
	local place = tostring(placeId or game.PlaceId)

	local dataStr
	if type(profileData) == "table" then
		dataStr = httpService:JSONEncode(profileData)
	else
		dataStr = tostring(profileData or "{}")
	end

	local payload = httpService:JSONEncode({
		name = configName,
		author = author,
		description = "Uploaded from MxtionV4",
		game = place,
		data = dataStr
	})

	local response = makeRequest({
		Url = API_BASE .. "/configs",
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = payload
	})

	if response.StatusCode == 200 or response.StatusCode == 201 then
		local suc, decoded = pcall(function()
			return httpService:JSONDecode(response.Body)
		end)
		if suc and decoded and decoded.success then
			return true, "Successfully published '" .. configName .. "' to the public cloud!"
		end
	end

	return false, "Upload failed (status " .. tostring(response.StatusCode) .. "). Check your internet connection."
end

function publicconfigs.Download(configEntry, mainapi)
	if not configEntry or not configEntry.data then
		return false, "Invalid config data"
	end

	local configName = configEntry.name or "PublicConfig"
	local placeStr = mainapi and mainapi.Place or tostring(game.PlaceId)
	local filename = "mxtionv4/profiles/" .. configName .. placeStr .. ".txt"

	local dataStr
	if type(configEntry.data) == "table" then
		dataStr = httpService:JSONEncode(configEntry.data)
	else
		dataStr = tostring(configEntry.data)
	end

	local suc, err = pcall(function()
		if not isfolder("mxtionv4/profiles") then
			makefolder("mxtionv4/profiles")
		end
		writefile(filename, dataStr)
	end)

	if not suc then
		return false, "Failed to write profile file: " .. tostring(err)
	end

	if mainapi and mainapi.Profiles then
		local exists = false
		for _, v in ipairs(mainapi.Profiles) do
			if v and v.Name == configName then
				exists = true
				break
			end
		end
		if not exists then
			table.insert(mainapi.Profiles, {Name = configName, Bind = {}})
		end
	end

	return true, configName
end

return publicconfigs
