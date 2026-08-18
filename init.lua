--!nocheck
local license = ... or {}
license.Key = script_key or license.Key

local cloneref = cloneref or function(ref) return ref end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local delfile = delfile or function(file)
	writefile(file, '')
end

local downloader = Instance.new('TextLabel')
downloader.Size = UDim2.new(1, 0, 0, 40)
downloader.BackgroundTransparency = 1
downloader.TextStrokeTransparency = 0
downloader.TextSize = 20
downloader.TextColor3 = Color3.new(1, 1, 1)
downloader.Font = Enum.Font.Arial
downloader.Text = 'Loading mxtionV4...'
downloader.Parent = Instance.new('ScreenGui', gethui and gethui() or cloneref(game:GetService('CoreGui')))

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
		downloader.Text = 'Downloaded: '..path:gsub('mxtionv4/', '')
	end
	return (func or readfile)(path)
end

local function wipeFolder(path)
	if not isfolder(path) then return end
	for _, file in listfiles(path) do
		if file:find('init') then continue end
		if file:find('profile') then continue end
		if isfile(file) then
			delfile(file)
		elseif isfolder(file) then
			wipeFolder(file)
		end
	end
end

-- Ensure folders exist
for _, folder in {'mxtionv4', 'mxtionv4/games', 'mxtionv4/profiles', 'mxtionv4/assets', 'mxtionv4/libraries', 'mxtionv4/guis'} do
	if not isfolder(folder) then
		makefolder(folder)
	end
end

if not shared.VapeDeveloper then
	local commit = license.Commit
	local currentCommit = isfile('mxtionv4/profiles/commit.txt') and readfile('mxtionv4/profiles/commit.txt') or ''
	local lastUpdateCheck = isfile('mxtionv4/profiles/lastupdate.txt') and tonumber(readfile('mxtionv4/profiles/lastupdate.txt')) or 0

	if not commit then
		if os.time() - lastUpdateCheck > 600 or currentCommit == '' then
			-- Use git refs API: returns ~150 bytes vs ~10KB for full commit endpoint
			local suc, res = pcall(function()
				return httpService:JSONDecode(game:HttpGet('https://api.github.com/repos/GlockSwitchMotion/mxtionV4/git/refs/heads/main'))
			end)
			if suc and type(res) == 'table' and res[1] and res[1].object and res[1].object.sha then
				commit = res[1].object.sha
				writefile('mxtionv4/profiles/lastupdate.txt', tostring(os.time()))
			end
		end
	end

	commit = commit or (currentCommit ~= '' and currentCommit or 'main')

	if commit ~= 'main' and currentCommit ~= '' and currentCommit ~= commit then
		shared.updated = currentCommit
		wipeFolder('mxtionv4')
		wipeFolder('mxtionv4/games')
		wipeFolder('mxtionv4/guis')
		wipeFolder('mxtionv4/libraries')
	end
	writefile('mxtionv4/profiles/commit.txt', commit)

	-- All core files to pre-download in parallel
	local filesToDownload = {
		'main.lua',
		'guis/new.lua',
		'games/universal.lua',
		'libraries/premium.lua',
		'libraries/hash.lua',
		'libraries/prediction.lua',
		'libraries/entity.lua',
		'libraries/drawing.lua',
		'libraries/vm.lua',
		'features.json',
		'games/'..game.PlaceId..'.lua',
	}

	-- Count how many actually need downloading
	local needed = {}
	for _, file in ipairs(filesToDownload) do
		if not isfile('mxtionv4/'..file) then
			table.insert(needed, file)
		end
	end

	local total = #needed
	if total > 0 then
		local completed = 0
		local activeDownloads = 0
		local done = Instance.new('BindableEvent')

		for _, file in ipairs(needed) do
			activeDownloads = activeDownloads + 1
			task.spawn(function()
				local path = 'mxtionv4/'..file
				local suc, res = pcall(function()
					return game:HttpGet('https://raw.githubusercontent.com/GlockSwitchMotion/mxtionV4/'..commit..'/'..file, true)
				end)
				if suc and res ~= '404: Not Found' and res ~= '' then
					if path:find('.lua') then
						res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
					end
					writefile(path, res)
				else
					if file:find('games/') then
						writefile(path, '')
					end
				end
				completed = completed + 1
				if not license.Closet then
					downloader.Text = 'Downloading files '..completed..'/'..total
				end
				activeDownloads = activeDownloads - 1
				if activeDownloads == 0 then
					done:Fire()
				end
			end)
		end

		done.Event:Wait()
		done:Destroy()
	end

	if shared.updated or #listfiles('mxtionv4/profiles') < 4 then
		shared.VapePresetInstall = function()
			local suc, req = pcall(request, {
				Url = 'https://api.github.com/repos/GlockSwitchMotion/mxtionV4/contents/profiles',
				Method = 'GET'
			})
			if not suc or req.StatusCode ~= 200 then return false end
			local body = httpService:JSONDecode(req.Body)
			if not body or typeof(body) ~= 'table' then return false end

			local presetDownloads = 0
			local installed = false
			local presetDone = Instance.new('BindableEvent')

			for _, v in body do
				if v.type == 'file' then
					presetDownloads = presetDownloads + 1
					task.spawn(function()
						local success = pcall(downloadFile, 'mxtionv4/'..({v.path:gsub(' ', '%%20')})[1])
						if success then installed = true end
						presetDownloads = presetDownloads - 1
						if presetDownloads == 0 then
							presetDone:Fire()
						end
					end)
				end
			end

			if presetDownloads > 0 then
				presetDone.Event:Wait()
			end
			presetDone:Destroy()
			return installed
		end
	end
end

downloader.Text = ''
return loadstring(downloadFile('mxtionv4/main.lua'), 'main')(license)
