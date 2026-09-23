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
		-- also clear cached main.lua so it re-downloads on update
		pcall(function() if isfile("mxtionv4/main.lua") then delfile("mxtionv4/main.lua") end end)
		
		if not isfolder("mxtionv4/profiles") then makefolder("mxtionv4/profiles") end
		writefile("mxtionv4/profiles/commit.txt", latestCommit)
		
		if currentCommit ~= "" and currentCommit ~= "main" then
			shared.updated = currentCommit:sub(1, 7)
		end
	end
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

-- Ensure base folders exist
for _, folder in {'mxtionv4', 'mxtionv4/games', 'mxtionv4/profiles', 'mxtionv4/assets', 'mxtionv4/libraries', 'mxtionv4/guis'} do
	if not isfolder(folder) then makefolder(folder) end
end

if not shared.vapereload then
	handleUpdates()
end

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

-- Cache main.lua to disk just like libraries/games
-- On teleport reinject it reads from disk — no network request needed
downloadFile('mxtionv4/main.lua')

local REINJECT_URL = 'https://raw.githubusercontent.com/GlockSwitchMotion/mxtionV4/refs/heads/main/init.lua'

local function finishLoading()
	vape.Init = nil
	vape:Load()

	local function buildTeleportScript()
		if shared.VapeIndependent then return nil end
		local keyStr = tostring(license.Key or '_key')
		local s = 'shared.vapereload = true\n'
		if shared.VapeDeveloper then s = 'shared.VapeDeveloper = true\n'..s end
		if shared.VapeCustomProfile then s = 'shared.VapeCustomProfile = "'..shared.VapeCustomProfile..'"\n'..s end
		-- Read from cached disk file — falls back to URL if file is missing
		s = s..'local ok, src = pcall(readfile, "mxtionv4/main.lua")\n'
		s = s..'loadstring(ok and src or game:HttpGet("'..REINJECT_URL..'", true), "main")({Key="'..keyStr..'"})'
		return s
	end

	local function queueTeleport()
		local script = buildTeleportScript()
		if not script then return end
		pcall(clear_teleport_queue)
		pcall(queue_on_teleport, script)
	end

	queueTeleport()

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

if not shared.VapeIndependent then
	if not game:IsLoaded() then
		repeat task.wait() until game:IsLoaded()
	end
	loadstring(downloadFile('mxtionv4/games/universal.lua'), 'universal')(license)
	if isfile('mxtionv4/games/'..game.PlaceId..'.lua') then
		loadstring(readfile('mxtionv4/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(license)
	else
		if not shared.VapeDeveloper then
			local suc, res = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/GlockSwitchMotion/mxtionV4/'..readfile('mxtionv4/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true)
			end)
			if suc and res ~= '404: Not Found' then
				loadstring(downloadFile('mxtionv4/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(license)
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
