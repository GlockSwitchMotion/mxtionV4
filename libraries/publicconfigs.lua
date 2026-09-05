local publicconfigs = {}
local httpService = game:GetService('HttpService')
local players = game:GetService('Players')
local localPlayer = players.LocalPlayer or {Name = "Anonymous"}

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

-- Primary JSONBin cloud database endpoint (shared public storage)
local API_URL = "https://api.jsonbin.io/v3/b"
local BIN_ID = "66d9fb7ce41b4d34e42aa11e" -- Global Public Configs Bin ID
local MASTER_KEY = "$2a$10$T8Z.Yx7Kq9v2kF3A1hJ8u.GZ9e7f8g9h0i1j2k3l4m5n6o7p8q9r"

-- Secondary fallback open KV endpoint
local FALLBACK_URL = "https://api.myjson.online/v1/records"

publicconfigs.Cache = {}

function publicconfigs.FetchAll(filterPlaceId)
	local endpoint = API_URL .. "/" .. BIN_ID .. "/latest"
	local response = makeRequest({
		Url = endpoint,
		Method = "GET",
		Headers = {
			["X-Master-Key"] = MASTER_KEY,
			["X-Bin-Meta"] = "false"
		}
	})

	local listData = nil
	if response.StatusCode == 200 or response.StatusCode == 201 then
		local suc, decoded = pcall(function()
			return httpService:JSONDecode(response.Body)
		end)
		if suc and type(decoded) == "table" then
			if decoded.record then decoded = decoded.record end
			listData = decoded
		end
	end

	if listData then
		publicconfigs.Cache = listData
	else
		listData = publicconfigs.Cache
	end

	local filtered = {}
	for _, item in ipairs(listData) do
		if not filterPlaceId or tostring(item.place) == tostring(filterPlaceId) or item.place == "all" then
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
	local place = placeId or tostring(game.PlaceId)

	-- Fetch latest public list from cloud
	local _, _, currentList = publicconfigs.FetchAll(nil)
	currentList = currentList or {}

	local newEntry = {
		id = httpService:GenerateGUID(false),
		name = configName,
		author = author,
		place = place,
		timestamp = os.time(),
		data = profileData
	}

	-- Overwrite existing config by same author and name, or prepend new
	local updated = false
	for i, item in ipairs(currentList) do
		if item.name:lower() == configName:lower() and tostring(item.place) == tostring(place) and item.author == author then
			currentList[i] = newEntry
			updated = true
			break
		end
	end

	if not updated then
		table.insert(currentList, 1, newEntry)
	end

	-- Keep up to 100 public configs online
	if #currentList > 100 then
		table.remove(currentList, #currentList)
	end

	local jsonPayload = httpService:JSONEncode(currentList)
	local response = makeRequest({
		Url = API_URL .. "/" .. BIN_ID,
		Method = "PUT",
		Headers = {
			["Content-Type"] = "application/json",
			["X-Master-Key"] = MASTER_KEY
		},
		Body = jsonPayload
	})

	publicconfigs.Cache = currentList

	if response.StatusCode == 200 or response.StatusCode == 201 then
		return true, "Successfully published public config '" .. configName .. "' for everyone to see!"
	else
		return true, "Config saved to session public list."
	end
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
