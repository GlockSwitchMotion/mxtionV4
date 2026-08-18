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

-- Intercept and cache the commit hash in memory to bypass disk read/write delays entirely
local commitCache
local oldreadfile = readfile
local oldwritefile = writefile
local env = getgenv and getgenv() or shared

env.readfile = function(file, ...)
	if file == 'mxtionv4/profiles/commit.txt' then
		if not commitCache then
			commitCache = isfile('mxtionv4/profiles/commit.txt') and oldreadfile('mxtionv4/profiles/commit.txt') or 'main'
		end
		return commitCache
	end
	return oldreadfile(file, ...)
end

env.writefile = function(file, content, ...)
	if file == 'mxtionv4/profiles/commit.txt' then
		commitCache = content
	end
	return oldwritefile(file, content, ...)
end

-- Hook game:HttpGet to transparently route raw.githubusercontent.com files through jsDelivr's fast global CDN
local oldHttpGet
local oldNamecall

local function cdnUrlResolve(url)
	if type(url) == 'string' and url:find('raw.githubusercontent.com') then
		return url:gsub('https://raw.githubusercontent.com/([^/]+)/([^/]+)/([^/]+)/(.+)', 'https://cdn.jsdelivr.net/gh/%1/%2@%3/%4')
	end
	return url
end

if hookfunction then
	pcall(function()
		oldHttpGet = hookfunction(game.HttpGet, function(self, url, ...)
			local resolvedUrl = cdnUrlResolve(url)
			if resolvedUrl ~= url then
				local suc, res = pcall(oldHttpGet, self, resolvedUrl, ...)
				if suc and res and res ~= '404: Not Found' and res ~= '' then
					return res
				end
			end
			return oldHttpGet(self, url, ...)
		end)
	end)
end

if hookmetamethod then
	pcall(function()
		oldNamecall = hookmetamethod(game, '__namecall', function(self, ...)
			local method = getnamecallmethod()
			if method == 'HttpGet' then
				local url = ...
				local resolvedUrl = cdnUrlResolve(url)
				if resolvedUrl ~= url then
					setnamecallmethod('HttpGet')
					local suc, res = pcall(oldNamecall, self, resolvedUrl, select(2, ...))
					if suc and res and res ~= '404: Not Found' and res ~= '' then
						return res
					end
				end
			end
			return oldNamecall(self, ...)
		end)
	end)
end

local downloader = Instance.new('TextLabel')
downloader.Size = UDim2.new(1, 0, 0, 40)
downloader.BackgroundTransparency = 1
downloader.TextStrokeTransparency = 0
downloader.TextSize = 20
downloader.TextColor3 = Color3.new(1, 1, 1)
downloader.Font = Enum.Font.Arial
downloader.Text = 'Downloading files 0/100'
downloader.Parent = Instance.new('ScreenGui', gethui and gethui() or cloneref(game:GetService('CoreGui')))

local downloadCount = 0
local function setDownloadProgress()
	downloadCount = math.min(downloadCount + 1, 100)
	downloader.Text = 'Downloading files '..downloadCount..'/100'
end

local commitCache
local function getCommit()
	if not commitCache then
		commitCache = isfile('mxtionv4/profiles/commit.txt') and readfile('mxtionv4/profiles/commit.txt') or 'main'
	end
	return commitCache
end

local function downloadFile(path, func)
	if not isfile(path) then
		if not license.Closet then
			setDownloadProgress()
		end
		local commit = getCommit()
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/GlockSwitchMotion/mxtionV4/'..commit..'/'..select(1, path:gsub('mxtionv4/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
		downloader.Text = ''
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


local activeGui = isfile('mxtionv4/profiles/gui.txt') and readfile('mxtionv4/profiles/gui.txt') or 'new'
for _, folder in {'mxtionv4', 'mxtionv4/games', 'mxtionv4/profiles', 'mxtionv4/assets', 'mxtionv4/libraries', 'mxtionv4/guis', 'mxtionv4/assets/'..activeGui} do
	if not isfolder(folder) then
		setDownloadProgress()
		makefolder(folder)
	end
end

	if not shared.VapeDeveloper then
		local commit = license.Commit
		local currentCommit = isfile('mxtionv4/profiles/commit.txt') and readfile('mxtionv4/profiles/commit.txt') or ''
		local lastUpdateCheck = isfile('mxtionv4/profiles/lastupdate.txt') and tonumber(readfile('mxtionv4/profiles/lastupdate.txt')) or 0
		
		if not commit then
			if os.time() - lastUpdateCheck > 3600 or currentCommit == '' then
				local suc, res = pcall(function() 
					-- Use Github API for faster response instead of scraping HTML
					return cloneref(game:GetService("HttpService")):JSONDecode(game:HttpGet('https://api.github.com/repos/GlockSwitchMotion/mxtionV4/commits/main'))
				end)
				if suc and type(res) == "table" and res.sha then
					commit = res.sha
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
		commitCache = commit

		-- Parallel core asset pre-downloader to maximize speed & minimize connection roundtrips
		local filesToDownload = {
			'main.lua',
			'guis/'..activeGui..'.lua',
			'games/universal.lua',
			'libraries/premium.lua',
			'libraries/hash.lua',
			'libraries/prediction.lua',
			'libraries/entity.lua',
			'libraries/drawing.lua',
			'libraries/vm.lua',
			'features.json',
			'games/'..game.PlaceId..'.lua'
		}

		local guiAssets = {
			new = {
				'assets/new/add.png', 'assets/new/alert.png', 'assets/new/allowedicon.png', 'assets/new/allowedtab.png',
				'assets/new/arrowmodule.png', 'assets/new/back.png', 'assets/new/bind.png', 'assets/new/bindbkg.png',
				'assets/new/blatanticon.png', 'assets/new/blockedicon.png', 'assets/new/blockedtab.png', 'assets/new/blur.png',
				'assets/new/blurnotif.png', 'assets/new/close.png', 'assets/new/closemini.png', 'assets/new/colorpreview.png',
				'assets/new/combaticon.png', 'assets/new/customsettings.png', 'assets/new/discord.png', 'assets/new/dots.png',
				'assets/new/edit.png', 'assets/new/expandicon.png', 'assets/new/expandright.png', 'assets/new/expandup.png',
				'assets/new/friendstab.png', 'assets/new/guisettings.png', 'assets/new/guislider.png', 'assets/new/guisliderrain.png',
				'assets/new/guiv4.png', 'assets/new/guivape.png', 'assets/new/info.png', 'assets/new/inventoryicon.png',
				'assets/new/legit.png', 'assets/new/legittab.png', 'assets/new/miniicon.png', 'assets/new/notification.png',
				'assets/new/overlaysicon.png', 'assets/new/overlaystab.png', 'assets/new/pin.png', 'assets/new/profileworld.png',
				'assets/new/radaricon.png', 'assets/new/rainbow_1.png', 'assets/new/rainbow_2.png', 'assets/new/rainbow_3.png',
				'assets/new/rainbow_4.png', 'assets/new/range.png', 'assets/new/rangearrow.png', 'assets/new/rendericon.png',
				'assets/new/rendertab.png', 'assets/new/search.png', 'assets/new/targetinfoicon.png', 'assets/new/targetnpc1.png',
				'assets/new/targetnpc2.png', 'assets/new/targetplayers1.png', 'assets/new/targetplayers2.png', 'assets/new/targetstab.png',
				'assets/new/textguiicon.png', 'assets/new/textv4.png', 'assets/new/textvape.png', 'assets/new/utilityicon.png',
				'assets/new/vape.png', 'assets/new/warning.png', 'assets/new/worldicon.png'
			},
			old = {
				'assets/old/barlogo.png', 'assets/old/blatanticon.png', 'assets/old/checkbox.png', 'assets/old/combaticon.png',
				'assets/old/friendsicon.png', 'assets/old/guiicon.png', 'assets/old/info.png', 'assets/old/pin.png',
				'assets/old/rendericon.png', 'assets/old/search.png', 'assets/old/settingsicon.png', 'assets/old/targetinfoicon.png',
				'assets/old/textguiicon.png', 'assets/old/textv4.png', 'assets/old/textvape.png', 'assets/old/utilityicon.png',
				'assets/old/worldicon.png'
			},
			rise = {
				'assets/rise/Icon-1.ttf', 'assets/rise/Icon-3.ttf', 'assets/rise/productsans.json',
				'assets/rise/SF-Pro-Rounded-Light.otf', 'assets/rise/SF-Pro-Rounded-Medium.otf',
				'assets/rise/SF-Pro-Rounded-Regular.otf', 'assets/rise/slice.png'
			},
			wurst = {
				'assets/wurst/triangle.png', 'assets/wurst/wurst_128.png'
			},
			liquidbounce = {
				'assets/liquidbounce/Inter-Light.ttf', 'assets/liquidbounce/Inter-Medium.ttf',
				'assets/liquidbounce/Inter-Regular.ttf', 'assets/liquidbounce/logo.png',
				'assets/liquidbounce/textgui.png'
			}
		}

		local assets = guiAssets[activeGui]
		if assets then
			for _, asset in ipairs(assets) do
				table.insert(filesToDownload, asset)
			end
		end

		local activeDownloads = 0
		local totalToDownload = 0
		for _, file in ipairs(filesToDownload) do
			if not isfile('mxtionv4/'..file) then
				totalToDownload = totalToDownload + 1
			end
		end

		if totalToDownload > 0 then
			local completed = 0
			for _, file in ipairs(filesToDownload) do
				local path = 'mxtionv4/'..file
				if not isfile(path) then
					activeDownloads = activeDownloads + 1
					task.spawn(function()
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
							downloader.Text = 'Downloading files '..completed..'/'..totalToDownload
						end
						activeDownloads = activeDownloads - 1
					end)
				end
			end
			while activeDownloads > 0 do
				task.wait()
			end
		end

		if shared.updated or #listfiles('mxtionv4/profiles') < 4 then
			shared.VapePresetInstall = function()
				local suc, req = pcall(request, {
					Url = 'https://api.github.com/repos/GlockSwitchMotion/mxtionV4/contents/profiles',
					Method = 'GET'
				})
				if not suc or req.StatusCode ~= 200 then return false end
				local body = cloneref(game:GetService('HttpService')):JSONDecode(req.Body)
				if not body or typeof(body) ~= 'table' then return false end
				
				local presetDownloads = 0
				local installed = false
				for _, v in body do
					if v.type == 'file' then
						presetDownloads = presetDownloads + 1
						task.spawn(function()
							local success = pcall(downloadFile, 'mxtionv4/'.. ({v.path:gsub(' ', '%%20')})[1])
							if success then
								installed = true
							end
							presetDownloads = presetDownloads - 1
						end)
					end
				end
				while presetDownloads > 0 do
					task.wait()
				end
				return installed
			end
		end
	end

	downloader.Text = ''
	return loadstring(downloadFile('mxtionv4/main.lua'), 'main')(license)

