local license = ... or {}
repeat task.wait() until game:IsLoaded()
if shared.vape then shared.vape:Uninject() end
license.Key = license.Key or '_key'

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
local httpService = cloneref(game:GetService('HttpService'))

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
			teleportConfig = teleportConfig:gsub('":true', '=true'):gsub('{"', '{')
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
			vape:CreateNotification('mxtionV4', (getgenv().mxtionname and `Authenticated as {getgenv().mxtionname} with {getgenv().mxtionrole}, ` or '')..(vape.VapeButton and 'Press the button in the top right' or 'Press '..table.concat(vape.Keybind, ' + '):upper())..' to open GUI', 5)
			task.delay(0.05 + cloneref(game:GetService('RunService')).PostSimulation:Wait(), function()
				if shared.updated then
					vape:CreateNotification('mxtionV4', `Script has updated from {shared.updated} to {readfile('mxtionv4/profiles/commit.txt')}`, 10, 'info')
				end
			end)
		end
	end
end

-- Setup gui profile
if not isfile('mxtionv4/profiles/gui.txt') then
	writefile('mxtionv4/profiles/gui.txt', 'new')
end
local gui = 'new'

if not isfolder('mxtionv4/assets/'..gui) then
	makefolder('mxtionv4/assets/'..gui)
end

-- hookmetamethod has no vape dependency, set it up immediately while downloads run
if hookmetamethod and not getgenv().run then
	getgenv().run = true
	local old; old = hookmetamethod(game, '__namecall', function(self, Remote, ...)
		if not checkcaller() and getnamecallmethod() == 'FireServer' then
			if typeof(Remote) == 'Instance' and Remote.Name == 'TabFreezeAnticheat_ClientToServerReport' then
				return
			end
		end
		return old(self, Remote, ...)
	end)
end

if not shared.VapeIndependent then
	-- Parallel download all 4 files simultaneously
	local guiSource, universalSource, premiumSource, gameSource
	local placeFile = 'mxtionv4/games/'..game.PlaceId..'.lua'
	local pending = 4
	local done = Instance.new('BindableEvent')

	local function onDone()
		pending = pending - 1
		if pending == 0 then
			done:Fire()
		end
	end

	-- GUI library
	task.spawn(function()
		guiSource = downloadFile('mxtionv4/guis/'..gui..'.lua')
		onDone()
	end)

	-- Universal game script
	task.spawn(function()
		universalSource = downloadFile('mxtionv4/games/universal.lua')
		onDone()
	end)

	-- Premium library
	task.spawn(function()
		premiumSource = downloadFile('mxtionv4/libraries/premium.lua')
		onDone()
	end)

	-- PlaceId specific game script
	task.spawn(function()
		if isfile(placeFile) then
			-- Already cached, just read it
			gameSource = readfile(placeFile)
		elseif not shared.VapeDeveloper then
			local suc, res = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/GlockSwitchMotion/mxtionV4/'..readfile('mxtionv4/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true)
			end)
			if suc and res ~= '404: Not Found' then
				-- Write directly from res, no second HttpGet
				writefile(placeFile, '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res)
				gameSource = res
			else
				-- Cache blank so we skip this HTTP call next injection
				writefile(placeFile, '')
			end
		end
		onDone()
	end)

	-- Wait for all 4 to finish, then execute in correct dependency order
	done.Event:Wait()
	done:Destroy()

	vape = loadstring(guiSource, 'gui')(license)
	shared.vape = vape
	shared.vapesmooth = false
	_G.vape = vape
	getgenv().used_init = true

	loadstring(universalSource, 'universal')(license)

	if gameSource and gameSource ~= '' then
		loadstring(gameSource, tostring(game.PlaceId))(license)
	end

	loadstring(premiumSource, 'premium')(license)
	finishLoading()
else
	-- VapeIndependent mode: load gui only then hand off
	vape = loadstring(downloadFile('mxtionv4/guis/'..gui..'.lua'), 'gui')(license)
	shared.vape = vape
	shared.vapesmooth = false
	_G.vape = vape
	getgenv().used_init = true
	vape.Init = finishLoading
	return vape
end
