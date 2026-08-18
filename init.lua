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
downloader.Text = 'Downloading files 0/100'
downloader.Parent = Instance.new('ScreenGui', gethui and gethui() or cloneref(game:GetService('CoreGui')))

local downloadCount = 0
local function setDownloadProgress()
	downloadCount = math.min(downloadCount + 1, 100)
	downloader.Text = 'Downloading files '..downloadCount..'/100'
end

local function downloadFile(path, func)
	if not isfile(path) then
		if not license.Closet then
			setDownloadProgress()
		end
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


for _, folder in {'mxtionv4', 'mxtionv4/games', 'mxtionv4/profiles', 'mxtionv4/assets', 'mxtionv4/libraries', 'mxtionv4/guis'} do
	if not isfolder(folder) then
		setDownloadProgress()
		makefolder(folder)
	end
end

if not shared.VapeDeveloper then
	local commit = license.Commit
	if not commit then
		local _, subbed = pcall(function() 
			return game:HttpGet('https://github.com/GlockSwitchMotion/mxtionV4') 
		end)
		local commitIdx = subbed and type(subbed) == 'string' and subbed:find('currentOid')
		commit = commitIdx and subbed:sub(commitIdx + 13, commitIdx + 52) or nil
		commit = commit and #commit == 40 and commit or nil
	end
	
	commit = commit or (isfile('mxtionv4/profiles/commit.txt') and readfile('mxtionv4/profiles/commit.txt') or 'main')
	if commit == 'main' or (isfile('mxtionv4/profiles/commit.txt') and readfile('mxtionv4/profiles/commit.txt') or '') ~= commit then
		if commit ~= 'main' and isfile('mxtionv4/profiles/commit.txt') then
			shared.updated = readfile('mxtionv4/profiles/commit.txt')
		end
		wipeFolder('mxtionv4')
		wipeFolder('mxtionv4/games')
		wipeFolder('mxtionv4/guis')
		wipeFolder('mxtionv4/libraries')
	end
	writefile('mxtionv4/profiles/commit.txt', commit)
	if shared.updated or #listfiles('mxtionv4/profiles') < 4 then
		shared.VapePresetInstall = function()
			local suc, req = pcall(request, {
				Url = 'https://api.github.com/repos/GlockSwitchMotion/mxtionV4/contents/profiles',
				Method = 'GET'
			})
			if not suc or req.StatusCode ~= 200 then return false end
			local body = cloneref(game:GetService('HttpService')):JSONDecode(req.Body)
			if not body or typeof(body) ~= 'table' then return false end
			local installed = false
			for _, v in body do
				if v.type == 'file' and pcall(downloadFile, 'mxtionv4/'.. ({v.path:gsub(' ', '%%20')})[1]) then
					installed = true
				end
			end
			return installed
		end
	end
end

downloader.Text = ''
return loadstring(downloadFile('mxtionv4/main.lua'), 'main')(license)
