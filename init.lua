local license = ... or {}
if shared.vape then shared.vape:Uninject() end
pcall(function() setfpscap(240) end) -- unlock FPS cap
license.Key = license.Key or '_key'

local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil and res ~= ''
end

-- AUTO UPDATE LOGIC (Cached commit lookup)
local function getLatestCommit()
	if shared.mxtion_checked and isfile("mxtionv4/profiles/commit.txt") then
		return readfile("mxtionv4/profiles/commit.txt")
	end
	
	local suc, res = pcall(function()
		return game:HttpGet("https://api.github.com/repos/GlockSwitchMotion/mxtionV4/commits/main")
	end)
	if suc and res then
		local sha = res:match('"sha":"(.-)"')
		if sha then 
			shared.mxtion_checked = true
			return sha 
		end
	end
	return isfile("mxtionv4/profiles/commit.txt") and readfile("mxtionv4/profiles/commit.txt") or "main"
end

local function handleUpdates()
	local latestCommit = getLatestCommit()
	local currentCommit = isfile("mxtionv4/profiles/commit.txt") and readfile("mxtionv4/profiles/commit.txt") or ""
	
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

local vape
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local cloneref = cloneref or function(obj) return obj end
local playersService = cloneref(game:GetService('Players'))
local httpService = cloneref(game:GetService("HttpService"))

local function downloadFile(path, func)
	if not isfile(path) then
		local commit = (isfile('mxtionv4/profiles/commit.txt') and readfile('mxtionv4/profiles/commit.txt')) or 'main'
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/GlockSwitchMotion/mxtionV4/'..commit..'/'..select(1, path:gsub('mxtionv4/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res or "Not Found")
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
			local commit = (isfile('mxtionv4/profiles/commit.txt') and readfile('mxtionv4/profiles/commit.txt')) or 'main'
			local teleportScript = [[
				shared.vapereload = true
				if shared.VapeDeveloper then
					loadstring(readfile('mxtionv4/main.lua'), 'main')(_scriptconfig)
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/GlockSwitchMotion/mxtionV4/]]..commit..[[/init.lua', true), 'init')(_scriptconfig)
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
			if shared.updated and isfile('mxtionv4/profiles/commit.txt') then
				vape:CreateNotification('mxtionV4', `Script has updated from {shared.updated} to {readfile('mxtionv4/profiles/commit.txt'):sub(1, 7)}`, 10, 'info')
			end
		end)
	end
end

if not isfile('mxtionv4/profiles/gui.txt') then
	writefile('mxtionv4/profiles/gui.txt', 'new')
end
local gui = 'new'

if not isfolder('mxtionv4/assets/'..gui) then
	makefolder('mxtionv4/assets/'..gui)
end

-- ⚡ LOAD MAIN GUI
vape = loadstring(downloadFile('mxtionv4/guis/'..gui..'.lua'), 'gui')(license)
shared.vape = vape
shared.vapesmooth = false
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
		game.Loaded:Wait()
	end
	
	-- ⚡ LOAD UNIVERSAL MODULES
	loadstring(downloadFile('mxtionv4/games/universal.lua'), 'universal')(license)
	
	-- ⚡ LOAD PLACE GAME SCRIPT IF CACHED
	if isfile('mxtionv4/games/'..game.PlaceId..'.lua') then
		pcall(function()
			loadstring(readfile('mxtionv4/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(license)
		end)
	else
		task.spawn(function()
			local commit = (isfile('mxtionv4/profiles/commit.txt') and readfile('mxtionv4/profiles/commit.txt')) or 'main'
			local suc, res = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/GlockSwitchMotion/mxtionV4/'..commit..'/games/'..game.PlaceId..'.lua', true)
			end)
			if suc and res and res ~= '404: Not Found' then
				writefile('mxtionv4/games/'..game.PlaceId..'.lua', res)
				pcall(function()
					loadstring(res, tostring(game.PlaceId))(license)
				end)
			end
		end)
	end
	
	-- ⚡ LOAD SAVED CONFIG IMMEDIATELY
	finishLoading()
	
	-- ⚡ LOAD BACKGROUND LIBRARIES
	task.spawn(function()
		pcall(function()
			loadstring(downloadFile('mxtionv4/libraries/premium.lua'), 'premium')(license)
		end)
		pcall(function()
			local publib = loadstring(downloadFile('mxtionv4/libraries/publicconfigs.lua'), 'publicconfigs')(license)
			if publib and vape then
				vape.Libraries = vape.Libraries or {}
				vape.Libraries.publicconfigs = publib
			end
		end)
	end)
else
	vape.Init = finishLoading
	return vape
end
