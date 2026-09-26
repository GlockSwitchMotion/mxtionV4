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

local queue_on_teleport = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport) or function() end
local clear_teleport_queue = clear_teleport_queue or clearteleportqueue or function() end

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

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/GlockSwitchMotion/mxtionV4/'..readfile('mxtionv4/profiles/commit.txt')..'/'..select(1, path:gsub('mxtionv4/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
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

	vape:Clean(task.spawn(function()
		repeat
			pcall(vape.Save, vape)
			task.wait(10)
		until vape.Loaded == nil
	end))

	-- Aerov4-style teleport queue building & execution
	local function buildTeleportScript()
		if shared.VapeIndependent then return nil end

		local teleportScript = [[
			shared.vapereload = true
			if isfile and isfile('mxtionv4/init.lua') then
				loadstring(readfile('mxtionv4/init.lua'), 'init')(_scriptconfig)
			elseif isfile and isfile('mxtionv4/main.lua') then
				loadstring(readfile('mxtionv4/main.lua'), 'main')(_scriptconfig)
			else
				local suc, res = pcall(function()
					return game:HttpGet('https://raw.githubusercontent.com/GlockSwitchMotion/mxtionV4/'..readfile('mxtionv4/profiles/commit.txt')..'/init.lua', true)
				end)
				if suc and res and res ~= '404: Not Found' then
					if not isfile('mxtionv4/init.lua') then
						writefile('mxtionv4/init.lua', res)
					end
					loadstring(res, 'init')(_scriptconfig)
				end
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
		if vape and vape.Profile then
			shared.VapeCustomProfile = vape.Profile
		end
		if shared.VapeCustomProfile then
			teleportScript = 'shared.VapeCustomProfile = "'..shared.VapeCustomProfile..'"\n'..teleportScript
		end
		return teleportScript
	end

	local function queueTeleport()
		local scriptStr = buildTeleportScript()
		if not scriptStr then return end
		pcall(clear_teleport_queue)
		pcall(queue_on_teleport, scriptStr)
	end

	-- Run immediately on load
	queueTeleport()

	-- Hook OnTeleport listener (Aerov4 pattern)
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function(state)
		if state == Enum.TeleportState.Failed then return end
		pcall(function() vape:Save() end)
		queueTeleport()
	end))

	vape:Clean(function()
		pcall(clear_teleport_queue)
	end)

	if not shared.vapereload then
		if getgenv().mxtionrole == 'HWID MISMATCH' then
			vape:CreateNotification('mxtionV4', 'HWID MISMATCH, Go to the script panel to reset hwid', 25, 'alert')
			getgenv().mxtionrole = ''
			task.wait(0.1)
		end
		if not shared.vapereload then
			vape:CreateNotification('mxtionV4', (getgenv().mxtionname and `Authenticated as {getgenv().mxtionname} with {getgenv().mxtionrole}, ` or '').. (vape.VapeButton and 'Press the button in the top right' or 'Press '..table.concat(vape.Keybind, ' + '):upper())..' to open GUI', 5)
			task.delay(0.05 + cloneref(game:GetService('RunService')).PostSimulation:Wait(), function()
				if shared.updated then
					vape:CreateNotification('mxtionV4', `Script has updated from {shared.updated} to {readfile('mxtionv4/profiles/commit.txt'):sub(1, 7)}`, 10, 'info')
				end
			end)
		end	
	end
end

if not isfile('mxtionv4/profiles/gui.txt') then
	writefile('mxtionv4/profiles/gui.txt', 'new')
end
local gui = 'new'--readfile('mxtionv4/profiles/gui.txt')

if not isfolder('mxtionv4/assets/'..gui) then
	makefolder('mxtionv4/assets/'..gui)
end
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

if not isfile('mxtionv4/init.lua') then
	pcall(function()
		downloadFile('mxtionv4/init.lua')
	end)
end
if not isfile('mxtionv4/main.lua') then
	pcall(function()
		downloadFile('mxtionv4/main.lua')
	end)
end

if not shared.VapeIndependent then
	if not game:IsLoaded() then
		repeat task.wait() until game:IsLoaded()
	end
	loadstring(downloadFile('mxtionv4/games/universal.lua'), 'universal')(license)
	local scriptId = (game.PlaceId == 6872265039 and '6872265039') or (game.GameId == 2619619496 and '6872274481') or tostring(game.GameId)
	if isfile('mxtionv4/games/'..scriptId..'.lua') then
		loadstring(readfile('mxtionv4/games/'..scriptId..'.lua'), scriptId)(license)
	else
		if not shared.VapeDeveloper then
			local suc, res = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/GlockSwitchMotion/mxtionV4/'..readfile('mxtionv4/profiles/commit.txt')..'/games/'..scriptId..'.lua', true)
			end)
			if suc and res ~= '404: Not Found' then
				loadstring(downloadFile('mxtionv4/games/'..scriptId..'.lua'), scriptId)(license)
			end
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
