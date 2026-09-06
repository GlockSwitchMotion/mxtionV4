local license = ... or {}
if shared.vape then shared.vape:Uninject() end
license.Key = license.Key or '_key'

local API_BASE = "https://broken-glitter-fc5d.motionv4.workers.dev"
local GITHUB_RAW = "https://raw.githubusercontent.com/GlockSwitchMotion/mxtionV4/"

local httpService = cloneref and cloneref(game:GetService("HttpService")) or game:GetService("HttpService")
local playersService = cloneref and cloneref(game:GetService('Players')) or game:GetService('Players')
local queue_on_teleport = queue_on_teleport or function() end

local req = (syn and syn.request) or (http and http.request) or http_request or request or (fluxus and fluxus.request)
local function fastHttp(url)
	if req then
		local suc, res = pcall(req, { Url = url, Method = "GET" })
		if suc and res and (res.StatusCode == 200 or res.StatusCode == 201) then
			return res.Body
		end
	end
	if game.HttpGet then
		local suc, res = pcall(function() return game:HttpGet(url, true) end)
		if suc and res and res ~= '404: Not Found' then
			return res
		end
	end
	return nil
end

-- ⚡ FAST COMMIT CHECK (Cloudflare Edge Cache -> fallback to GitHub)
local function getLatestCommit()
	if shared.mxtion_checked then
		return isfile("mxtionv4/profiles/commit.txt") and readfile("mxtionv4/profiles/commit.txt") or "main"
	end

	-- Try high-speed Cloudflare version endpoint first (~10ms)
	local res = fastHttp(API_BASE .. "/version")
	if res then
		local suc, dec = pcall(function() return httpService:JSONDecode(res) end)
		if suc and dec and dec.sha then
			shared.mxtion_checked = true
			return dec.sha
		end
	end

	-- Fallback to GitHub API
	local gh = fastHttp("https://api.github.com/repos/GlockSwitchMotion/mxtionV4/commits/main")
	if gh then
		local sha = gh:match('"sha":"(.-)"')
		if sha then
			shared.mxtion_checked = true
			return sha
		end
	end

	return "main"
end

local function handleUpdates()
	local latestCommit = getLatestCommit()
	local currentCommit = ""
	if isfile("mxtionv4/profiles/commit.txt") then
		currentCommit = readfile("mxtionv4/profiles/commit.txt")
	end
	
	if latestCommit ~= "main" and latestCommit ~= currentCommit then
		local function clearFolder(path)
			if isfolder(path) then
				for _, file in listfiles(path) do
					if file:find(".lua") and isfile(file) then
						delfile(file)
					end
				end
			end
		end
		clearFolder("mxtionv4/guis")
		clearFolder("mxtionv4/games")
		clearFolder("mxtionv4/libraries")
		
		if not isfolder("mxtionv4/profiles") then makefolder("mxtionv4/profiles") end
		writefile("mxtionv4/profiles/commit.txt", latestCommit)
		
		if currentCommit ~= "" and currentCommit ~= "main" then
			shared.updated = currentCommit:sub(1, 7)
		end
	end
end

if not shared.vapereload then
	handleUpdates()
end

local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil and res ~= ''
end

-- ⚡ 1-REQUEST BUNDLE DOWNLOADER (Cloudflare Edge)
local function ensureBundle()
	local commit = (isfile("mxtionv4/profiles/commit.txt") and readfile("mxtionv4/profiles/commit.txt")) or "main"
	local needDownload = not isfile("mxtionv4/guis/new.lua") 
		or not isfile("mxtionv4/games/universal.lua") 
		or not isfile("mxtionv4/libraries/premium.lua") 
		or not isfile("mxtionv4/libraries/publicconfigs.lua")

	if needDownload then
		-- Fetch all required files in 1 instant bundle request from Cloudflare Edge
		local bundleRes = fastHttp(API_BASE .. "/bundle?commit=" .. commit .. "&place=" .. tostring(game.PlaceId))
		if bundleRes then
			local suc, dec = pcall(function() return httpService:JSONDecode(bundleRes) end)
			if suc and dec and dec.bundle then
				for filePath, content in pairs(dec.bundle) do
					local fullPath = "mxtionv4/" .. filePath
					local folder = fullPath:match("(.+)/[^/]+$")
					if folder and not isfolder(folder) then
						makefolder(folder)
					end
					local fileContent = content
					if filePath:find(".lua") then
						fileContent = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n' .. content
					end
					writefile(fullPath, fileContent)
				end
				return true
			end
		end
	end
	return false
end

-- Ensure all folders exist
for _, f in ipairs({"mxtionv4", "mxtionv4/guis", "mxtionv4/games", "mxtionv4/libraries", "mxtionv4/profiles", "mxtionv4/assets/new"}) do
	if not isfolder(f) then makefolder(f) end
end

-- Pre-fill cache via bundle in 1 request if needed
ensureBundle()

local vape
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end

local function downloadFile(path, func)
	if not isfile(path) then
		local commit = (isfile("mxtionv4/profiles/commit.txt") and readfile("mxtionv4/profiles/commit.txt")) or "main"
		local subPath = select(1, path:gsub('mxtionv4/', ''))
		
		-- Try Cloudflare edge cache first, fallback to GitHub Raw
		local res = fastHttp(API_BASE .. "/file/" .. subPath .. "?commit=" .. commit)
		if not res then
			res = fastHttp(GITHUB_RAW .. commit .. '/' .. subPath)
		end
		
		if not res or res == '404: Not Found' then
			error("Failed to download: " .. path)
		end
		
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function finishLoading()
	vape.Init = nil
	vape:Load()

	local teleportedServers
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.VapeIndependent) then
			teleportedServers = true
			local teleportScript = [[
				shared.vapereload = true
				if shared.VapeDeveloper then
					loadstring(readfile('mxtionv4/main.lua'), 'main')(_scriptconfig)
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/GlockSwitchMotion/mxtionV4/'..readfile('mxtionv4/profiles/commit.txt')..'/init.lua', true), 'init')(_scriptconfig)
				end
			]]
			local teleportConfig = httpService:JSONEncode(license)
			teleportConfig = teleportConfig:gsub('":true', "=true"):gsub('{"', '{')
			teleportConfig = teleportConfig:gsub(',"', ','):gsub('":', '=')
			teleportConfig = teleportConfig:gsub('%[', '{'):gsub('%]', '}')
			teleportScript = teleportScript:gsub('_key', tostring(license.Key or '_key'))
			teleportScript = teleportScript:gsub('_scriptconfig', teleportConfig)
			if shared.VapeDeveloper then
				teleportScript = 'shared.VapeDeveloper = true\n'..teleportScript
			end
			if shared.VapeCustomProfile then
				teleportScript = 'shared.VapeCustomProfile = "'..shared.VapeCustomProfile..'"\n'..teleportScript
			end
			vape:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.vapereload then
		if getgenv().mxtionrole == 'HWID MISMATCH' then
			vape:CreateNotification('mxtionV4', 'HWID MISMATCH, Go to the script panel to reset hwid', 25, 'alert')
			getgenv().mxtionrole = ''
			task.wait(0.1)
		end
		vape:CreateNotification('mxtionV4', (getgenv().mxtionname and `Authenticated as {getgenv().mxtionname} with {getgenv().mxtionrole}, ` or '').. (vape.VapeButton and 'Press the button in the top right' or 'Press '..table.concat(vape.Keybind, ' + '):upper())..' to open GUI', 5)
		task.delay(0.05 + cloneref(game:GetService('RunService')).PostSimulation:Wait(), function()
			if shared.updated then
				vape:CreateNotification('mxtionV4', `Script has updated from {shared.updated} to {readfile('mxtionv4/profiles/commit.txt'):sub(1, 7)}`, 10, 'info')
			end
		end)
	end
end

if not isfile('mxtionv4/profiles/gui.txt') then
	writefile('mxtionv4/profiles/gui.txt', 'new')
end
local gui = 'new'

vape = loadstring(downloadFile('mxtionv4/guis/'..gui..'.lua'), 'gui')(license)
shared.vape = vape
shared.vapesmooth = true
_G.vape = vape
getgenv().used_init = true

if hookmetamethod and not getgenv().run then
	getgenv().run = true
	local old; old = hookmetamethod(game, '__namecall', function(self, Remote, ...)
		if not checkcaller() and getnamecallmethod() == 'FireServer' then
			if typeof(Remote) == "Instance" and Remote.Name == 'TabFreezeAnticheat_ClientToServerReport' then
				return
			end
		end
		return old(self, Remote, ...)
	end)
end

if not shared.VapeIndependent then
	if not game:IsLoaded() then
		repeat task.wait() until game:IsLoaded()
	end
	loadstring(downloadFile('mxtionv4/games/universal.lua'), 'universal')(license)
	
	if isfile('mxtionv4/games/'..game.PlaceId..'.lua') then
		loadstring(readfile('mxtionv4/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(license)
	else
		if not shared.VapeDeveloper then
			pcall(function()
				loadstring(downloadFile('mxtionv4/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(license)
			end)
		end
	end
	
	loadstring(downloadFile('mxtionv4/libraries/premium.lua'), 'premium')(license)
	pcall(function()
		local publib = loadstring(downloadFile('mxtionv4/libraries/publicconfigs.lua'), 'publicconfigs')(license)
		if publib and vape then
			vape.Libraries = vape.Libraries or {}
			vape.Libraries.publicconfigs = publib
		end
	end)
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end
