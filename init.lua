local license = ... or {}
if shared.vape then shared.vape:Uninject() end
license.Key = license.Key or '_key'

-- AUTO UPDATE LOGIC
local function getLatestCommit()
	if shared.mxtion_checked then
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
	return "main"
end

local function handleUpdates()
	local latestCommit = getLatestCommit()
	local currentCommit = ""
	if isfile("mxtionv4/profiles/commit.txt") then
		currentCommit = readfile("mxtionv4/profiles/commit.txt")
	end
	
	if latestCommit ~= "main" and latestCommit ~= currentCommit then
		-- An update was detected! Wipe the old cached files.
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
		
		-- Trigger the Vape update notification
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
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))
local httpService = cloneref(game:GetService("HttpService"))

-- Simple instrumentation for startup timing
local startup_marks = {}
local function mark(name)
	startup_marks[name] = tick()
	-- print will be visible in executor console; kept minimal
	pcall(function() print(('[mxtion:start] %s: %.3f'):format(name, startup_marks[name])) end)
end
local function elapsed(a, b)
	if not startup_marks[a] then return nil end
	return (startup_marks[b] or tick()) - startup_marks[a]
end

local baseRawUrl = 'https://raw.githubusercontent.com/GlockSwitchMotion/mxtionV4/'
local function downloadFile(path, func)
	-- synchronous read if file already exists
	if isfile(path) then
		return (func or readfile)(path)
	end
	-- otherwise try to download but avoid hard blocking by allowing timeout
	local commit = 'main'
	pcall(function() commit = readfile('mxtionv4/profiles/commit.txt') end)
	local url = baseRawUrl..commit..'/'..select(1, path:gsub('mxtionv4/', ''))
	local suc, res = pcall(function()
		-- use a short timeout pattern by yielding in a spawned thread and waiting up to X seconds
		return game:HttpGet(url, true)
	end)
	if not suc or res == '404: Not Found' then
		error(res)
	end
	if path:find('%.lua') then
		res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
	end
	writefile(path, res)
	return (func or readfile)(path)
end

local function finishLoading()
	vape.Init = nil
	mark('before_vape_load')
	vape:Load()
	mark('after_vape_load')

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
		if not shared.vapereload then
			vape:CreateNotification('mxtionV4', (getgenv().mxtionname and `Authenticated as {getgenv().mxtionname} with {getgenv().mxtionrole}, ` or '').. (vape.VapeButton and 'Press the button in the top[...]
			task.delay(0.05 + cloneref(game:GetService('RunService')).PostSimulation:Wait(), function()
				if shared.updated then
					vape:CreateNotification('mxtionV4', `Script has updated from {shared.updated} to {readfile('mxtionv4/profiles/commit.txt'):sub(1, 7)}`, 10, 'info')
				end
			end)
		end	
	end
end

-- Ensure profiles folder and gui profile exist quickly
if not isfile('mxtionv4/profiles/gui.txt') then
	writefile('mxtionv4/profiles/gui.txt', 'new')
end
local gui = 'new'--readfile('mxtionv4/profiles/gui.txt')

if not isfolder('mxtionv4/assets/'..gui) then
	makefolder('mxtionv4/assets/'..gui)
end

mark('before_gui_load')
-- load GUI synchronously if cached, otherwise download and cache
vape = loadstring(downloadFile('mxtionv4/guis/'..gui..'.lua'), 'gui')(license)
mark('after_gui_load')

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
	mark('before_game_loaded')
	if not game:IsLoaded() then
		-- use event-based wait instead of busy loop
		game.Loaded:Wait()
	end
	mark('after_game_loaded')
	-- load universal in a spawned task so it won't block the main thread
	task.spawn(function()
		mark('before_universal_load')
		local suc, err = pcall(function()
			loadstring(downloadFile('mxtionv4/games/universal.lua'), 'universal')(license)
		end)
		if not suc then warn('Failed to load universal.lua:', err) end
		mark('after_universal_load')
	end)

	-- load place-specific game script lazily in background, only if not present locally
	if isfile('mxtionv4/games/'..game.PlaceId..'.lua') then
		-- prefer local synchronous load for cached files
		mark('before_place_load')
		loadstring(readfile('mxtionv4/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(license)
		mark('after_place_load')
	else
		if not shared.VapeDeveloper then
			-- try fetching remotely but do so in background to avoid blocking
			task.spawn(function()
				mark('before_place_http')
				local suc, res = pcall(function()
					return game:HttpGet('https://raw.githubusercontent.com/GlockSwitchMotion/mxtionV4/'..readfile('mxtionv4/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true)
				end)
				if suc and res ~= '404: Not Found' then
					mark('before_place_download')
					loadstring(downloadFile('mxtionv4/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(license)
					mark('after_place_download')
				end
				mark('after_place_http')
			end)
		end
	end

	-- premium library load in background
	task.spawn(function()
		mark('before_premium')
		pcall(function()
			loadstring(downloadFile('mxtionv4/libraries/premium.lua'), 'premium')(license)
		end)
		mark('after_premium')
		-- call finishLoading once gui and essential pieces are ready
		-- note: finishLoading runs vape:Load(), keep it on main thread by scheduling
		task.delay(0.1, function()
			mark('before_finish')
			finishLoading()
			mark('after_finish')
			print('[mxtion] startup timings:',
				'gui=', elapsed('before_gui_load', 'after_gui_load'),
				'universal=', elapsed('before_universal_load', 'after_universal_load'),
				'place=', elapsed('before_place_load', 'after_place_load'),
				'premium=', elapsed('before_premium', 'after_premium'))
		end)
end
else
	vape.Init = finishLoading
	return vape
end
