--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.
local license = ...
local mainapi = {
	Categories = {},
	GUIColor = {
		Hue = 0.46,
		Sat = 0.96,
		Value = 0.52
	},
	HeldKeybinds = {},
	Keybind = {'RightShift'},
	Loaded = false,
	Libraries = {},
	Modules = {},
	Place = game.PlaceId,
	Profile = 'default',
	Profiles = {},
	RainbowSpeed = {Value = 1},
	RainbowUpdateSpeed = {Value = 60},
	RainbowTable = {},
	SaveCache = {},
	Scale = {Value = 1},
	ThreadFix = setthreadidentity and true or false,
	ToggleNotifications = {},
	Version = '4.18',
	Windows = {}
}

local cloneref = cloneref or function(obj)
	return obj
end
local tweenService = cloneref(game:GetService('TweenService'))
local inputService = cloneref(game:GetService('UserInputService'))
local textService = cloneref(game:GetService('TextService'))
local guiService = cloneref(game:GetService('GuiService'))
local runService = cloneref(game:GetService('RunService'))
local httpService = cloneref(game:GetService('HttpService'))

local fontsize = Instance.new('GetTextBoundsParams')
fontsize.Width = math.huge
local notifications
local assetfunction = getcustomasset
local getcustomasset
local clickgui
local scaledgui
local toolblur
local tooltip
local scale
local gui

local color = {}
local tween = {
	tweens = {},
	tweenstwo = {}
}
local uipallet = {
	Main = Color3.fromRGB(9, 8, 7),
	Text = Color3.fromRGB(200, 200, 200),
	Font = Font.fromEnum(Enum.Font.Arial),
	FontSemiBold = Font.fromEnum(Enum.Font.Arial, Enum.FontWeight.SemiBold),
	Tween = TweenInfo.new(0.16, Enum.EasingStyle.Linear)
}

local getcustomassets = {
	['mxtionv4/assets/new/add.png'] = 'rbxassetid://14368300605',
	['mxtionv4/assets/new/alert.png'] = 'rbxassetid://14368301329',
	['mxtionv4/assets/new/allowedicon.png'] = 'rbxassetid://14368302000',
	['mxtionv4/assets/new/allowedtab.png'] = 'rbxassetid://14368302875',
	['mxtionv4/assets/new/arrowmodule.png'] = 'rbxassetid://14473354880',
	['mxtionv4/assets/new/back.png'] = 'rbxassetid://14368303894',
	['mxtionv4/assets/new/bind.png'] = 'rbxassetid://14368304734',
	['mxtionv4/assets/new/bindbkg.png'] = 'rbxassetid://14368305655',
	['mxtionv4/assets/new/blatanticon.png'] = 'rbxassetid://14368306745',
	['mxtionv4/assets/new/blockedicon.png'] = 'rbxassetid://14385669108',
	['mxtionv4/assets/new/blockedtab.png'] = 'rbxassetid://14385672881',
	['mxtionv4/assets/new/blur.png'] = 'rbxassetid://14898786664',
	['mxtionv4/assets/new/blurnotif.png'] = 'rbxassetid://16738720137',
	['mxtionv4/assets/new/close.png'] = 'rbxassetid://14368309446',
	['mxtionv4/assets/new/closemini.png'] = 'rbxassetid://14368310467',
	['mxtionv4/assets/new/colorpreview.png'] = 'rbxassetid://14368311578',
	['mxtionv4/assets/new/combaticon.png'] = 'rbxassetid://14368312652',
	['mxtionv4/assets/new/customsettings.png'] = 'rbxassetid://14403726449',
	['mxtionv4/assets/new/discord.png'] = '',
	['mxtionv4/assets/new/dots.png'] = 'rbxassetid://14368314459',
	['mxtionv4/assets/new/edit.png'] = 'rbxassetid://14368315443',
	['mxtionv4/assets/new/expandicon.png'] = 'rbxassetid://14368353032',
	['mxtionv4/assets/new/expandright.png'] = 'rbxassetid://14368316544',
	['mxtionv4/assets/new/expandup.png'] = 'rbxassetid://14368317595',
	['mxtionv4/assets/new/friendstab.png'] = 'rbxassetid://14397462778',
	['mxtionv4/assets/new/guisettings.png'] = 'rbxassetid://14368318994',
	['mxtionv4/assets/new/guislider.png'] = 'rbxassetid://14368320020',
	['mxtionv4/assets/new/guisliderrain.png'] = 'rbxassetid://14368321228',
	['mxtionv4/assets/new/guiv4.png'] = 'rbxassetid://138935172340460',
	['mxtionv4/assets/new/guivape.png'] = 'rbxassetid://108672093407887',
	['mxtionv4/assets/new/info.png'] = 'rbxassetid://14368324807',
	['mxtionv4/assets/new/inventoryicon.png'] = 'rbxassetid://14928011633',
	['mxtionv4/assets/new/legit.png'] = 'rbxassetid://14425650534',
	['mxtionv4/assets/new/legittab.png'] = 'rbxassetid://14426740825',
	['mxtionv4/assets/new/miniicon.png'] = 'rbxassetid://14368326029',
	['mxtionv4/assets/new/notification.png'] = 'rbxassetid://16738721069',
	['mxtionv4/assets/new/overlaysicon.png'] = 'rbxassetid://14368339581',
	['mxtionv4/assets/new/overlaystab.png'] = 'rbxassetid://14397380433',
	['mxtionv4/assets/new/pin.png'] = 'rbxassetid://14368342301',
	['mxtionv4/assets/new/profilesicon.png'] = 'rbxassetid://14397465323',
	['mxtionv4/assets/new/radaricon.png'] = 'rbxassetid://14368343291',
	['mxtionv4/assets/new/rainbow_1.png'] = 'rbxassetid://14368344374',
	['mxtionv4/assets/new/rainbow_2.png'] = 'rbxassetid://14368345149',
	['mxtionv4/assets/new/rainbow_3.png'] = 'rbxassetid://14368345840',
	['mxtionv4/assets/new/rainbow_4.png'] = 'rbxassetid://14368346696',
	['mxtionv4/assets/new/range.png'] = 'rbxassetid://14368347435',
	['mxtionv4/assets/new/rangearrow.png'] = 'rbxassetid://14368348640',
	['mxtionv4/assets/new/rendericon.png'] = 'rbxassetid://14368350193',
	['mxtionv4/assets/new/rendertab.png'] = 'rbxassetid://14397373458',
	['mxtionv4/assets/new/search.png'] = 'rbxassetid://14425646684',
	['mxtionv4/assets/new/targetinfoicon.png'] = 'rbxassetid://14368354234',
	['mxtionv4/assets/new/targetnpc1.png'] = 'rbxassetid://14497400332',
	['mxtionv4/assets/new/targetnpc2.png'] = 'rbxassetid://14497402744',
	['mxtionv4/assets/new/targetplayers1.png'] = 'rbxassetid://14497396015',
	['mxtionv4/assets/new/targetplayers2.png'] = 'rbxassetid://14497397862',
	['mxtionv4/assets/new/targetstab.png'] = 'rbxassetid://14497393895',
	['mxtionv4/assets/new/textguiicon.png'] = 'rbxassetid://14368355456',
	['mxtionv4/assets/new/textv4.png'] = 'rbxassetid://138935172340460',
	['mxtionv4/assets/new/textvape.png'] = 'rbxassetid://108672093407887',
	['mxtionv4/assets/new/utilityicon.png'] = 'rbxassetid://14368359107',
	['mxtionv4/assets/new/vape.png'] = 'rbxassetid://108672093407887',
	['mxtionv4/assets/new/warning.png'] = 'rbxassetid://14368361552',
	['mxtionv4/assets/new/worldicon.png'] = 'rbxassetid://14368362492'
}

local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end

local getfontsize = function(text, size, font)
	fontsize.Text = text
	fontsize.Size = size
	if typeof(font) == 'Font' then
		fontsize.Font = font
	end
	return textService:GetTextBoundsAsync(fontsize)
end

local function addBlur(parent, notif)
	local blur = Instance.new('ImageLabel')
	blur.Name = 'Blur'
	blur.Size = UDim2.new(1, 89, 1, 52)
	blur.Position = UDim2.fromOffset(-48, -31)
	blur.BackgroundTransparency = 1
	blur.Image = getcustomasset('mxtionv4/assets/new/'..(notif and 'blurnotif' or 'blur')..'.png')
	blur.ScaleType = Enum.ScaleType.Slice
	blur.SliceCenter = Rect.new(52, 31, 261, 502)
	blur.Parent = parent

	return blur
end

local function addCorner(parent, radius)
	local corner = Instance.new('UICorner')
	corner.CornerRadius = radius or UDim.new(0, 5)
	corner.Parent = parent

	return corner
end

local function addCloseButton(parent, offset)
	local close = Instance.new('ImageButton')
	close.Name = 'Close'
	close.Size = UDim2.fromOffset(24, 24)
	close.Position = UDim2.new(1, -35, 0, offset or 9)
	close.BackgroundColor3 = Color3.new(1, 1, 1)
	close.BackgroundTransparency = 1
	close.AutoButtonColor = false
	close.Image = getcustomasset('mxtionv4/assets/new/close.png')
	close.ImageColor3 = color.Light(uipallet.Text, 0.2)
	close.ImageTransparency = 0.5
	close.Parent = parent
	addCorner(close, UDim.new(1, 0))

	close.MouseEnter:Connect(function()
		close.ImageTransparency = 0.3
		tween:Tween(close, uipallet.Tween, {
			BackgroundTransparency = 0.6
		})
	end)
	close.MouseLeave:Connect(function()
		close.ImageTransparency = 0.5
		tween:Tween(close, uipallet.Tween, {
			BackgroundTransparency = 1
		})
	end)

	return close
end

local function addMaid(object)
	object.Connections = {}
	function object:Clean(callback)
		if typeof(callback) == 'Instance' then
			table.insert(self.Connections, {
				Disconnect = function()
					callback:ClearAllChildren()
					callback:Destroy()
				end
			})
		elseif type(callback) == 'function' then
			table.insert(self.Connections, {
				Disconnect = callback
			})
		else
			table.insert(self.Connections, callback)
		end
	end
end

local function addTooltip(gui, text)
	if not text then return end

	local function tooltipMoved(x, y)
		local right = x + 16 + tooltip.Size.X.Offset > (scale.Scale * 1920)
		tooltip.Position = UDim2.fromOffset(
			(right and x - (tooltip.Size.X.Offset * scale.Scale) - 16 or x + 16) / scale.Scale,
			((y + 11) - (tooltip.Size.Y.Offset / 2)) / scale.Scale
		)
		tooltip.Visible = toolblur.Visible
	end

	gui.MouseEnter:Connect(function(x, y)
		local tooltipSize = getfontsize(text, tooltip.TextSize, uipallet.Font)
		tooltip.Size = UDim2.fromOffset(tooltipSize.X + 10, tooltipSize.Y + 10)
		tooltip.Text = text
		tooltipMoved(x, y)
	end)
	gui.MouseMoved:Connect(tooltipMoved)
	gui.MouseLeave:Connect(function()
		tooltip.Visible = false
	end)
end

local function checkKeybinds(compare, target, key)
	if type(target) == 'table' then
		if table.find(target, key) then
			for i, v in target do
				if not table.find(compare, v) then
					return false
				end
			end
			return true
		end
	end

	return false
end

local function createDownloader(text)
	if mainapi.Loaded ~= true then
		local downloader = mainapi.Downloader
		if not downloader then
			downloader = Instance.new('TextLabel')
			downloader.Size = UDim2.new(1, 0, 0, 40)
			downloader.BackgroundTransparency = 1
			downloader.TextStrokeTransparency = 0
			downloader.TextSize = 20
			downloader.TextColor3 = Color3.new(1, 1, 1)
			downloader.FontFace = uipallet.Font
			downloader.Parent = mainapi.gui
			mainapi.Downloader = downloader
		end
		mainapi.DownloadCount = math.min((mainapi.DownloadCount or 0) + 1, 100)
		downloader.Text = 'Downloading files '..mainapi.DownloadCount..'/100'
	end
end

local function createMobileButton(buttonapi, position)
	local heldbutton = false
	local button = Instance.new('TextButton')
	button.Size = UDim2.fromOffset(40, 40)
	button.Position = UDim2.fromOffset(position.X, position.Y)
	button.AnchorPoint = Vector2.new(0.5, 0.5)
	button.BackgroundColor3 = buttonapi.Enabled and Color3.new(0, 0.7, 0) or Color3.new()
	button.BackgroundTransparency = 0.5
	button.Text = buttonapi.Name
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true
	button.Font = Enum.Font.Gotham
	button.Parent = mainapi.gui
	local buttonconstraint = Instance.new('UITextSizeConstraint')
	buttonconstraint.MaxTextSize = 16
	buttonconstraint.Parent = button
	addCorner(button, UDim.new(1, 0))

	button.MouseButton1Down:Connect(function()
		heldbutton = true
		local holdtime, holdpos = tick(), inputService:GetMouseLocation()
		repeat
			heldbutton = (inputService:GetMouseLocation() - holdpos).Magnitude < 6
			task.wait()
		until (tick() - holdtime) > 1 or not heldbutton
		if heldbutton then
			buttonapi.Bind = {}
			button:Destroy()
		end
	end)
	button.MouseButton1Up:Connect(function()
		heldbutton = false
	end)
	button.MouseButton1Click:Connect(function()
		buttonapi:Toggle()
		button.BackgroundColor3 = buttonapi.Enabled and Color3.new(0, 0.7, 0) or Color3.new()
	end)

	buttonapi.Bind = {Button = button}
end

local function downloadFile(path, func)
	if not isfile(path) then
		createDownloader(path)
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

getcustomasset = assetfunction and function(path)
	if isfile(path) then
		return assetfunction(path)
	end
	pcall(function()
		downloadFile(path)
	end)
	if isfile(path) then
		return assetfunction(path)
	end
	return getcustomassets[path] or ''
end or function(path)
	return getcustomassets[path] or ''
end

local function getTableSize(tab)
	local ind = 0
	for _ in tab do ind += 1 end
	return ind
end

local function loopClean(tab)
	for i, v in tab do
		if type(v) == 'table' then
			loopClean(v)
		end
		tab[i] = nil
	end
end

local function loadJson(path)
	local suc, res = pcall(function()
		return httpService:JSONDecode(readfile(path))
	end)
	return suc and type(res) == 'table' and res or nil
end

local function loadFeatures()
	local suc, res = pcall(downloadFile, 'mxtionv4/features.json')
	if not suc or type(res) ~= 'string' then return nil end

	local decoded, payload = pcall(function()
		return httpService:JSONDecode(res)
	end)
	return decoded and type(payload) == 'table' and payload or nil
end

local featureTags
local function getFeatureTag(name)
	if not featureTags then
		featureTags = {}
		local features = loadFeatures()
		for tag, key in {updated = 'updated', new = 'added'} do
			local list = features and features[key]
			if type(list) == 'table' then
				for _, module in list do
					if type(module) == 'string' then
						featureTags[module] = tag
					end
				end
			end
		end
	end
	return featureTags[name]
end

local function makeDraggable(gui, window)
	gui.InputBegan:Connect(function(inputObj)
		if window and not window.Visible then return end
		if
			(inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch)
			and (inputObj.Position.Y - gui.AbsolutePosition.Y < 40 or window)
		then
			local dragPosition = Vector2.new(
				gui.AbsolutePosition.X - inputObj.Position.X,
				gui.AbsolutePosition.Y - inputObj.Position.Y + guiService:GetGuiInset().Y
			) / scale.Scale

			local changed = inputService.InputChanged:Connect(function(input)
				if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
					local position = input.Position
					if inputService:IsKeyDown(Enum.KeyCode.LeftShift) then
						dragPosition = (dragPosition // 3) * 3
						position = (position // 3) * 3
					end
					gui.Position = UDim2.fromOffset((position.X / scale.Scale) + dragPosition.X, (position.Y / scale.Scale) + dragPosition.Y)
				end
			end)

			local ended
			ended = inputObj.Changed:Connect(function()
				if inputObj.UserInputState == Enum.UserInputState.End then
					if changed then
						changed:Disconnect()
					end
					if ended then
						ended:Disconnect()
					end
				end
			end)
		end
	end)
end

local function randomString()
	local array = {}
	for i = 1, math.random(10, 100) do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

local function removeTags(str)
	str = str:gsub('<br%s*/>', '\n')
	return str:gsub('<[^<>]->', '')
end

do
	local res = isfile('mxtionv4/profiles/color.txt') and loadJson('mxtionv4/profiles/color.txt')
	if res then
		uipallet.Main = res.Main and Color3.fromRGB(unpack(res.Main)) or uipallet.Main
		uipallet.Text = res.Text and Color3.fromRGB(unpack(res.Text)) or uipallet.Text
		uipallet.Font = res.Font and Font.new(
			res.Font:find('rbxasset') and res.Font
			or string.format('rbxasset://fonts/families/%s.json', res.Font)
		) or uipallet.Font
		uipallet.FontSemiBold = Font.new(uipallet.Font.Family, Enum.FontWeight.SemiBold)
	end
	fontsize.Font = uipallet.Font
end

do
	function color.Dark(col, num)
		local h, s, v = col:ToHSV()
		return Color3.fromHSV(h, s, math.clamp(select(3, uipallet.Main:ToHSV()) > 0.5 and v + num or v - num, 0, 1))
	end

	function color.Light(col, num)
		local h, s, v = col:ToHSV()
		return Color3.fromHSV(h, s, math.clamp(select(3, uipallet.Main:ToHSV()) > 0.5 and v - num or v + num, 0, 1))
	end

	function mainapi:Color(h)
		local s = 0.75 + (0.15 * math.min(h / 0.03, 1))
		if h > 0.57 then
			s = 0.9 - (0.4 * math.min((h - 0.57) / 0.09, 1))
		end
		if h > 0.66 then
			s = 0.5 + (0.4 * math.min((h - 0.66) / 0.16, 1))
		end
		if h > 0.87 then
			s = 0.9 - (0.15 * math.min((h - 0.87) / 0.13, 1))
		end
		return h, s, 1
	end

	function mainapi:TextColor(h, s, v)
		if v >= 0.7 and (s < 0.6 or h > 0.04 and h < 0.56) then
			return Color3.new(0.19, 0.19, 0.19)
		end
		return Color3.new(1, 1, 1)
	end
end

do
	function tween:Tween(obj, tweeninfo, goal, tab)
		tab = tab or self.tweens
		if tab[obj] then
			tab[obj]:Cancel()
			tab[obj] = nil
		end

		if obj.Parent and obj.Visible then
			tab[obj] = tweenService:Create(obj, tweeninfo, goal)
			tab[obj].Completed:Once(function()
				if tab then
					tab[obj] = nil
					tab = nil
				end
			end)
			tab[obj]:Play()
		else
			for i, v in goal do
				obj[i] = v
			end
		end
	end

	function tween:Cancel(obj)
		if self.tweens[obj] then
			self.tweens[obj]:Cancel()
			self.tweens[obj] = nil
		end
	end
end

mainapi.Libraries = {
	addBlur = addBlur,
	addCloseButton = addCloseButton,
	addCorner = addCorner,
	color = color,
	getcustomasset = getcustomasset,
	getfontsize = getfontsize,
	makeDraggable = makeDraggable,
	tween = tween,
	uipallet = uipallet,
}

local components
components = {
	Button = function(optionsettings, children, api)
		local button = Instance.new('TextButton')
		button.Name = optionsettings.Name..'Button'
		button.Size = UDim2.new(1, 0, 0, 31)
		button.LayoutOrder = optionsettings.LayoutOrder or 0
		button.BackgroundColor3 = color.Dark(children.BackgroundColor3, optionsettings.Darker and 0.02 or 0)
		button.BorderSizePixel = 0
		button.AutoButtonColor = false
		button.Visible = optionsettings.Visible == nil or optionsettings.Visible
		button.Text = ''
		button.BackgroundTransparency = 1
		button.Parent = children
		addTooltip(button, optionsettings.Tooltip)
		local bkg = Instance.new('Frame')
		bkg.Size = UDim2.fromOffset(200, 27)
		bkg.Position = UDim2.fromOffset(10, 2)
		bkg.BackgroundColor3 = color.Light(uipallet.Main, 0.05)
		bkg.Parent = button
		addCorner(bkg)
		local label = Instance.new('TextLabel')
		label.Size = UDim2.new(1, -4, 1, -4)
		label.Position = UDim2.fromOffset(2, 2)
		label.BackgroundColor3 = uipallet.Main
		label.Text = optionsettings.Name
		label.TextColor3 = color.Dark(uipallet.Text, 0.16)
		label.TextSize = 14
		label.FontFace = uipallet.Font
		label.Parent = bkg
		addCorner(label, UDim.new(0, 4))
		optionsettings.Function = optionsettings.Function or function() end
		
		button.MouseEnter:Connect(function()
			tween:Tween(bkg, uipallet.Tween, {
				BackgroundColor3 = color.Light(uipallet.Main, 0.0875)
			})
		end)
		button.MouseLeave:Connect(function()
			tween:Tween(bkg, uipallet.Tween, {
				BackgroundColor3 = color.Light(uipallet.Main, 0.05)
			})
		end)
		button.MouseButton1Click:Connect(optionsettings.Function)
	end,
	ColorSlider = function(optionsettings, children, api)
		local optionapi = {
			Type = 'ColorSlider',
			Hue = optionsettings.DefaultHue or 0.44,
			Sat = optionsettings.DefaultSat or 1,
			Value = optionsettings.DefaultValue or 1,
			Opacity = optionsettings.DefaultOpacity or 1,
			Rainbow = false,
			Index = 0
		}
		
		local function createSlider(name, gradientColor)
			local slider = Instance.new('TextButton')
			slider.Name = optionsettings.Name..'Slider'..name
			slider.Size = UDim2.new(1, 0, 0, 50)
			slider.BackgroundColor3 = color.Dark(children.BackgroundColor3, optionsettings.Darker and 0.02 or 0)
			slider.BorderSizePixel = 0
			slider.AutoButtonColor = false
			slider.Visible = false
			slider.Text = ''
			slider.Parent = children
			local title = Instance.new('TextLabel')
			title.Name = 'Title'
			title.Size = UDim2.fromOffset(60, 30)
			title.Position = UDim2.fromOffset(10, 2)
			title.BackgroundTransparency = 1
			title.Text = name
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.TextColor3 = color.Dark(uipallet.Text, 0.16)
			title.TextSize = 11
			title.FontFace = uipallet.Font
			title.Parent = slider
			local bkg = Instance.new('Frame')
			bkg.Name = 'Slider'
			bkg.Size = UDim2.new(1, -20, 0, 2)
			bkg.Position = UDim2.fromOffset(10, 37)
			bkg.BackgroundColor3 = Color3.new(1, 1, 1)
			bkg.BorderSizePixel = 0
			bkg.Parent = slider
			local gradient = Instance.new('UIGradient')
			gradient.Color = gradientColor
			gradient.Parent = bkg
			local fill = bkg:Clone()
			fill.Name = 'Fill'
			fill.Size = UDim2.fromScale(math.clamp(name == 'Saturation' and optionapi.Sat or name == 'Vibrance' and optionapi.Value or optionapi.Opacity, 0.04, 0.96), 1)
			fill.Position = UDim2.new()
			fill.BackgroundTransparency = 1
			fill.Parent = bkg
			local knobholder = Instance.new('Frame')
			knobholder.Name = 'Knob'
			knobholder.Size = UDim2.fromOffset(24, 4)
			knobholder.Position = UDim2.fromScale(1, 0.5)
			knobholder.AnchorPoint = Vector2.new(0.5, 0.5)
			knobholder.BackgroundColor3 = slider.BackgroundColor3
			knobholder.BorderSizePixel = 0
			knobholder.Parent = fill
			local knob = Instance.new('Frame')
			knob.Name = 'Knob'
			knob.Size = UDim2.fromOffset(14, 14)
			knob.Position = UDim2.fromScale(0.5, 0.5)
			knob.AnchorPoint = Vector2.new(0.5, 0.5)
			knob.BackgroundColor3 = uipallet.Text
			knob.Parent = knobholder
			addCorner(knob, UDim.new(1, 0))
		
			slider.InputBegan:Connect(function(inputObj)
				if
					(inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch)
					and (inputObj.Position.Y - slider.AbsolutePosition.Y) > (20 * scale.Scale)
				then
					local changed = inputService.InputChanged:Connect(function(input)
						if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
							optionapi:SetValue(nil, name == 'Saturation' and math.clamp((input.Position.X - bkg.AbsolutePosition.X) / bkg.AbsoluteSize.X, 0, 1) or nil, name == 'Vibrance' and math.clamp((input.Position.X - bkg.AbsolutePosition.X) / bkg.AbsoluteSize.X, 0, 1) or nil, name == 'Opacity' and math.clamp((input.Position.X - bkg.AbsolutePosition.X) / bkg.AbsoluteSize.X, 0, 1) or nil)
						end
					end)
		
					local ended
					ended = inputObj.Changed:Connect(function()
						if inputObj.UserInputState == Enum.UserInputState.End then
							if changed then changed:Disconnect() end
							if ended then ended:Disconnect() end
						end
					end)
				end
			end)
			slider.MouseEnter:Connect(function()
				tween:Tween(knob, uipallet.Tween, {
					Size = UDim2.fromOffset(16, 16)
				})
			end)
			slider.MouseLeave:Connect(function()
				tween:Tween(knob, uipallet.Tween, {
					Size = UDim2.fromOffset(14, 14)
				})
			end)
		
			return slider
		end
		
		local slider = Instance.new('TextButton')
		slider.Name = optionsettings.Name..'Slider'
		slider.Size = UDim2.new(1, 0, 0, 50)
		slider.BackgroundColor3 = color.Dark(children.BackgroundColor3, optionsettings.Darker and 0.02 or 0)
		slider.BorderSizePixel = 0
		slider.AutoButtonColor = false
		slider.Visible = optionsettings.Visible == nil or optionsettings.Visible
		slider.Text = ''
		slider.Parent = children
		addTooltip(slider, optionsettings.Tooltip)
		local title = Instance.new('TextLabel')
		title.Name = 'Title'
		title.Size = UDim2.fromOffset(60, 30)
		title.Position = UDim2.fromOffset(10, 2)
		title.BackgroundTransparency = 1
		title.Text = optionsettings.Name
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.TextColor3 = color.Dark(uipallet.Text, 0.16)
		title.TextSize = 11
		title.FontFace = uipallet.Font
		title.Parent = slider
		local valuebox = Instance.new('TextBox')
		valuebox.Name = 'Box'
		valuebox.Size = UDim2.fromOffset(60, 15)
		valuebox.Position = UDim2.new(1, -69, 0, 9)
		valuebox.BackgroundTransparency = 1
		valuebox.Visible = false
		valuebox.Text = ''
		valuebox.TextXAlignment = Enum.TextXAlignment.Right
		valuebox.TextColor3 = color.Dark(uipallet.Text, 0.16)
		valuebox.TextSize = 11
		valuebox.FontFace = uipallet.Font
		valuebox.ClearTextOnFocus = true
		valuebox.Parent = slider
		local bkg = Instance.new('Frame')
		bkg.Name = 'Slider'
		bkg.Size = UDim2.new(1, -20, 0, 2)
		bkg.Position = UDim2.fromOffset(10, 39)
		bkg.BackgroundColor3 = Color3.new(1, 1, 1)
		bkg.BorderSizePixel = 0
		bkg.Parent = slider
		local rainbowTable = {}
		for i = 0, 1, 0.1 do
			table.insert(rainbowTable, ColorSequenceKeypoint.new(i, Color3.fromHSV(i, 1, 1)))
		end
		local gradient = Instance.new('UIGradient')
		gradient.Color = ColorSequence.new(rainbowTable)
		gradient.Parent = bkg
		local fill = bkg:Clone()
		fill.Name = 'Fill'
		fill.Size = UDim2.fromScale(math.clamp(optionapi.Hue, 0.04, 0.96), 1)
		fill.Position = UDim2.new()
		fill.BackgroundTransparency = 1
		fill.Parent = bkg
		local preview = Instance.new('ImageButton')
		preview.Name = 'Preview'
		preview.Size = UDim2.fromOffset(12, 12)
		preview.Position = UDim2.new(1, -22, 0, 10)
		preview.BackgroundTransparency = 1
		preview.Image = getcustomasset('mxtionv4/assets/new/colorpreview.png')
		preview.ImageColor3 = Color3.fromHSV(optionapi.Hue, optionapi.Sat, optionapi.Value)
		preview.ImageTransparency = 1 - optionapi.Opacity
		preview.Parent = slider
		local expandbutton = Instance.new('TextButton')
		expandbutton.Name = 'Expand'
		expandbutton.Size = UDim2.fromOffset(17, 13)
		expandbutton.Position = UDim2.new(0, textService:GetTextSize(title.Text, title.TextSize, title.Font, Vector2.new(1000, 1000)).X + 11, 0, 7)
		expandbutton.BackgroundTransparency = 1
		expandbutton.Text = ''
		expandbutton.Parent = slider
		local expand = Instance.new('ImageLabel')
		expand.Name = 'Expand'
		expand.Size = UDim2.fromOffset(9, 5)
		expand.Position = UDim2.fromOffset(4, 4)
		expand.BackgroundTransparency = 1
		expand.Image = getcustomasset('mxtionv4/assets/new/expandicon.png')
		expand.ImageColor3 = color.Dark(uipallet.Text, 0.43)
		expand.Parent = expandbutton
		local rainbow = Instance.new('TextButton')
		rainbow.Name = 'Rainbow'
		rainbow.Size = UDim2.fromOffset(12, 12)
		rainbow.Position = UDim2.new(1, -42, 0, 10)
		rainbow.BackgroundTransparency = 1
		rainbow.Text = ''
		rainbow.Parent = slider
		local rainbow1 = Instance.new('ImageLabel')
		rainbow1.Size = UDim2.fromOffset(12, 12)
		rainbow1.BackgroundTransparency = 1
		rainbow1.Image = getcustomasset('mxtionv4/assets/new/rainbow_1.png')
		rainbow1.ImageColor3 = color.Light(uipallet.Main, 0.37)
		rainbow1.Parent = rainbow
		local rainbow2 = rainbow1:Clone()
		rainbow2.Image = getcustomasset('mxtionv4/assets/new/rainbow_2.png')
		rainbow2.Parent = rainbow
		local rainbow3 = rainbow1:Clone()
		rainbow3.Image = getcustomasset('mxtionv4/assets/new/rainbow_3.png')
		rainbow3.Parent = rainbow
		local rainbow4 = rainbow1:Clone()
		rainbow4.Image = getcustomasset('mxtionv4/assets/new/rainbow_4.png')
		rainbow4.Parent = rainbow
		local knobholder = Instance.new('Frame')
		knobholder.Name = 'Knob'
		knobholder.Size = UDim2.fromOffset(24, 4)
		knobholder.Position = UDim2.fromScale(1, 0.5)
		knobholder.AnchorPoint = Vector2.new(0.5, 0.5)
		knobholder.BackgroundColor3 = slider.BackgroundColor3
		knobholder.BorderSizePixel = 0
		knobholder.Parent = fill
		local knob = Instance.new('Frame')
		knob.Name = 'Knob'
		knob.Size = UDim2.fromOffset(14, 14)
		knob.Position = UDim2.fromScale(0.5, 0.5)
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.BackgroundColor3 = uipallet.Text
		knob.Parent = knobholder
		addCorner(knob, UDim.new(1, 0))
		optionsettings.Function = optionsettings.Function or function() end
		local satSlider = createSlider('Saturation', ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, optionapi.Value)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(optionapi.Hue, 1, optionapi.Value))
		}))
		local vibSlider = createSlider('Vibrance', ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(optionapi.Hue, optionapi.Sat, 1))
		}))
		local opSlider = createSlider('Opacity', ColorSequence.new({
			ColorSequenceKeypoint.new(0, color.Dark(uipallet.Main, 0.02)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(optionapi.Hue, optionapi.Sat, optionapi.Value))
		}))
		
		function optionapi:Save(tab)
			tab[optionsettings.Name] = {
				Hue = self.Hue,
				Sat = self.Sat,
				Value = self.Value,
				Opacity = self.Opacity,
				Rainbow = self.Rainbow
			}
		end
		
		function optionapi:Load(tab)
			if tab.Rainbow ~= self.Rainbow then
				self:Toggle()
			end
			if self.Hue ~= tab.Hue or self.Sat ~= tab.Sat or self.Value ~= tab.Value or self.Opacity ~= tab.Opacity then
				self:SetValue(tab.Hue, tab.Sat, tab.Value, tab.Opacity)
			end
		end
		
		function optionapi:SetValue(h, s, v, o)
			self.Hue = h or self.Hue
			self.Sat = s or self.Sat
			self.Value = v or self.Value
			self.Opacity = o or self.Opacity
			preview.ImageColor3 = Color3.fromHSV(self.Hue, self.Sat, self.Value)
			preview.ImageTransparency = 1 - self.Opacity
			satSlider.Slider.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, self.Value)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, 1, self.Value))
			})
			vibSlider.Slider.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, self.Sat, 1))
			})
			opSlider.Slider.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, color.Dark(uipallet.Main, 0.02)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, self.Sat, self.Value))
			})
		
			if self.Rainbow then
				fill.Size = UDim2.fromScale(math.clamp(self.Hue, 0.04, 0.96), 1)
			else
				tween:Tween(fill, uipallet.Tween, {
					Size = UDim2.fromScale(math.clamp(self.Hue, 0.04, 0.96), 1)
				})
			end
		
			if s then
				tween:Tween(satSlider.Slider.Fill, uipallet.Tween, {
					Size = UDim2.fromScale(math.clamp(self.Sat, 0.04, 0.96), 1)
				})
			end
			if v then
				tween:Tween(vibSlider.Slider.Fill, uipallet.Tween, {
					Size = UDim2.fromScale(math.clamp(self.Value, 0.04, 0.96), 1)
				})
			end
			if o then
				tween:Tween(opSlider.Slider.Fill, uipallet.Tween, {
					Size = UDim2.fromScale(math.clamp(self.Opacity, 0.04, 0.96), 1)
				})
			end
		
			optionsettings.Function(self.Hue, self.Sat, self.Value, self.Opacity)
		end
		
		function optionapi:Toggle()
			self.Rainbow = not self.Rainbow
			if self.Rainbow then
				table.insert(mainapi.RainbowTable, self)
				rainbow1.ImageColor3 = Color3.fromRGB(5, 127, 100)
				task.delay(0.1, function()
					if not self.Rainbow then return end
					rainbow2.ImageColor3 = Color3.fromRGB(228, 125, 43)
					task.delay(0.1, function()
						if not self.Rainbow then return end
						rainbow3.ImageColor3 = Color3.fromRGB(225, 46, 52)
					end)
				end)
			else
				local ind = table.find(mainapi.RainbowTable, self)
				if ind then
					table.remove(mainapi.RainbowTable, ind)
				end
				rainbow3.ImageColor3 = color.Light(uipallet.Main, 0.37)
				task.delay(0.1, function()
					if self.Rainbow then return end
					rainbow2.ImageColor3 = color.Light(uipallet.Main, 0.37)
					task.delay(0.1, function()
						if self.Rainbow then return end
						rainbow1.ImageColor3 = color.Light(uipallet.Main, 0.37)
					end)
				end)
			end
		end
		
		local doubleClick = tick()
		preview.MouseButton1Click:Connect(function()
			preview.Visible = false
			valuebox.Visible = true
			valuebox:CaptureFocus()
			local text = Color3.fromHSV(optionapi.Hue, optionapi.Sat, optionapi.Value)
			valuebox.Text = math.round(text.R * 255)..', '..math.round(text.G * 255)..', '..math.round(text.B * 255)
		end)
		slider.InputBegan:Connect(function(inputObj)
			if
				(inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch)
				and (inputObj.Position.Y - slider.AbsolutePosition.Y) > (20 * scale.Scale)
			then
				if doubleClick > tick() then
					optionapi:Toggle()
				end
				doubleClick = tick() + 0.3
				local changed = inputService.InputChanged:Connect(function(input)
					if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
						optionapi:SetValue(math.clamp((input.Position.X - bkg.AbsolutePosition.X) / bkg.AbsoluteSize.X, 0, 1))
					end
				end)
		
				local ended
				ended = inputObj.Changed:Connect(function()
					if inputObj.UserInputState == Enum.UserInputState.End then
						if changed then
							changed:Disconnect()
						end
						if ended then
							ended:Disconnect()
						end
					end
				end)
			end
		end)
		slider.MouseEnter:Connect(function()
			tween:Tween(knob, uipallet.Tween, {
				Size = UDim2.fromOffset(16, 16)
			})
		end)
		slider.MouseLeave:Connect(function()
			tween:Tween(knob, uipallet.Tween, {
				Size = UDim2.fromOffset(14, 14)
			})
		end)
		slider:GetPropertyChangedSignal('Visible'):Connect(function()
			satSlider.Visible = expand.Rotation == 180 and slider.Visible
			vibSlider.Visible = satSlider.Visible
			opSlider.Visible = satSlider.Visible
		end)
		expandbutton.MouseEnter:Connect(function()
			expand.ImageColor3 = color.Dark(uipallet.Text, 0.16)
		end)
		expandbutton.MouseLeave:Connect(function()
			expand.ImageColor3 = color.Dark(uipallet.Text, 0.43)
		end)
		expandbutton.MouseButton1Click:Connect(function()
			satSlider.Visible = not satSlider.Visible
			vibSlider.Visible = satSlider.Visible
			opSlider.Visible = satSlider.Visible
			expand.Rotation = satSlider.Visible and 180 or 0
		end)
		rainbow.MouseButton1Click:Connect(function()
			optionapi:Toggle()
		end)
		valuebox.FocusLost:Connect(function(enter)
			preview.Visible = true
			valuebox.Visible = false
			if enter then
				local commas = valuebox.Text:split(',')
				local suc, res = pcall(function()
					return tonumber(commas[1]) and Color3.fromRGB(tonumber(commas[1]), tonumber(commas[2]), tonumber(commas[3])) or Color3.fromHex(valuebox.Text)
				end)
				if suc then
					if optionapi.Rainbow then
						optionapi:Toggle()
					end
					optionapi:SetValue(res:ToHSV())
				end
			end
		end)
		
		optionapi.Object = slider
		api.Options[optionsettings.Name] = optionapi
		
		return optionapi
	end,
	Dropdown = function(optionsettings, children, api)
		local optionapi = {
			Type = 'Dropdown',
			Value = optionsettings.List[1] or 'None',
			Default = optionsettings.Default or optionsettings.List[1] or 'None',
			List = optionsettings.List,
			Index = 0
		}
		
		local dropdown = Instance.new('TextButton')
		dropdown.Name = optionsettings.Name..'Dropdown'
		dropdown.Size = UDim2.new(1, 0, 0, 40)
		dropdown.LayoutOrder = optionsettings.LayoutOrder or 0
		dropdown.BackgroundColor3 = color.Dark(children.BackgroundColor3, optionsettings.Darker and 0.02 or 0)
		dropdown.BorderSizePixel = 0
		dropdown.AutoButtonColor = false
		dropdown.Visible = optionsettings.Visible == nil or optionsettings.Visible
		dropdown.Text = ''
		dropdown.Parent = children
		addTooltip(dropdown, optionsettings.Tooltip or optionsettings.Name)
		local bkg = Instance.new('Frame')
		bkg.Name = 'BKG'
		bkg.Size = UDim2.new(1, -20, 1, -9)
		bkg.Position = UDim2.fromOffset(10, 4)
		bkg.BackgroundColor3 = color.Light(uipallet.Main, 0.034)
		bkg.Parent = dropdown
		addCorner(bkg, UDim.new(0, 6))
		local button = Instance.new('TextButton')
		button.Name = 'Dropdown'
		button.Size = UDim2.new(1, -2, 1, -2)
		button.Position = UDim2.fromOffset(1, 1)
		button.BackgroundColor3 = uipallet.Main
		button.AutoButtonColor = false
		button.Text = ''
		button.Parent = bkg
		local title = Instance.new('TextLabel')
		title.Name = 'Title'
		title.Size = UDim2.new(1, 0, 0, 29)
		title.BackgroundTransparency = 1
		title.Text = '         '..optionsettings.Name..' - '..optionapi.Value
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.TextColor3 = color.Dark(uipallet.Text, 0.16)
		title.TextSize = 13
		title.TextTruncate = Enum.TextTruncate.AtEnd
		title.FontFace = uipallet.Font
		title.Parent = button
		addCorner(button, UDim.new(0, 6))
		local arrow = Instance.new('ImageLabel')
		arrow.Name = 'Arrow'
		arrow.Size = UDim2.fromOffset(4, 8)
		arrow.Position = UDim2.new(1, -17, 0, 11)
		arrow.BackgroundTransparency = 1
		arrow.Image = getcustomasset('mxtionv4/assets/new/expandright.png')
		arrow.ImageColor3 = Color3.fromRGB(140, 140, 140)
		arrow.Rotation = 90
		arrow.Parent = button
		optionsettings.Function = optionsettings.Function or function() end
		local dropdownchildren
		
		function optionapi:Save(tab)
			tab[optionsettings.Name] = {Value = self.Value}
		end
		
		function optionapi:Load(tab)
			if self.Value ~= tab.Value then
				self:SetValue(tab.Value)
			end
		end
		
		function optionapi:Change(list)
			optionsettings.List = list or {}
			self.List = optionsettings.List
			if not table.find(optionsettings.List, self.Value) then
				self:SetValue(self.Value)
			end
		end
		
		function optionapi:SetValue(val, mouse)
			self.Value = table.find(optionsettings.List, val) and val or optionsettings.List[1] or 'None'
			title.Text = '         '..optionsettings.Name..' - '..self.Value
			if dropdownchildren then
				arrow.Rotation = 90
				dropdownchildren:Destroy()
				dropdownchildren = nil
				dropdown.Size = UDim2.new(1, 0, 0, 40)
			end
			optionsettings.Function(self.Value, mouse)
		end
		
		button.MouseButton1Click:Connect(function()
			if not dropdownchildren then
				arrow.Rotation = 270
				dropdown.Size = UDim2.new(1, 0, 0, 40 + (#optionsettings.List - 1) * 26)
				dropdownchildren = Instance.new('Frame')
				dropdownchildren.Name = 'Children'
				dropdownchildren.Size = UDim2.new(1, 0, 0, (#optionsettings.List - 1) * 26)
				dropdownchildren.Position = UDim2.fromOffset(0, 27)
				dropdownchildren.BackgroundTransparency = 1
				dropdownchildren.Parent = button
				local ind = 0
				for _, v in optionsettings.List do
					if v == optionapi.Value then continue end
					local dropdownoption = Instance.new('TextButton')
					dropdownoption.Name = v..'Option'
					dropdownoption.Size = UDim2.new(1, 0, 0, 26)
					dropdownoption.Position = UDim2.fromOffset(0, ind * 26)
					dropdownoption.BackgroundColor3 = uipallet.Main
					dropdownoption.BorderSizePixel = 0
					dropdownoption.AutoButtonColor = false
					dropdownoption.Text = '         '..v
					dropdownoption.TextXAlignment = Enum.TextXAlignment.Left
					dropdownoption.TextColor3 = color.Dark(uipallet.Text, 0.16)
					dropdownoption.TextSize = 13
					dropdownoption.TextTruncate = Enum.TextTruncate.AtEnd
					dropdownoption.FontFace = uipallet.Font
					dropdownoption.Parent = dropdownchildren
					dropdownoption.MouseEnter:Connect(function()
						tween:Tween(dropdownoption, uipallet.Tween, {
							BackgroundColor3 = color.Light(uipallet.Main, 0.02)
						})
					end)
					dropdownoption.MouseLeave:Connect(function()
						tween:Tween(dropdownoption, uipallet.Tween, {
							BackgroundColor3 = uipallet.Main
						})
					end)
					dropdownoption.MouseButton1Click:Connect(function()
						optionapi:SetValue(v, true)
					end)
					ind += 1
				end
			else
				optionapi:SetValue(optionapi.Value, true)
			end
		end)
		dropdown.MouseEnter:Connect(function()
			tween:Tween(bkg, uipallet.Tween, {
				BackgroundColor3 = color.Light(uipallet.Main, 0.0875)
			})
		end)
		dropdown.MouseLeave:Connect(function()
			tween:Tween(bkg, uipallet.Tween, {
				BackgroundColor3 = color.Light(uipallet.Main, 0.034)
			})
		end)
		
		optionapi.Object = dropdown
		api.Options[optionsettings.Name] = optionapi
		
		return optionapi
	end,
	Font = function(optionsettings, children, api)
		local fonts = {
			optionsettings.Blacklist,
			'Custom'
		}
		for _, v in Enum.Font:GetEnumItems() do
			if not table.find(fonts, v.Name) then
				table.insert(fonts, v.Name)
			end
		end
		
		local optionapi = {Value = Font.fromEnum(Enum.Font[fonts[1]])}
		local fontdropdown
		local fontbox
		optionsettings.Function = optionsettings.Function or function() end
		
		fontdropdown = components.Dropdown({
			Name = optionsettings.Name,
			List = fonts,
			Function = function(val)
				fontbox.Object.Visible = val == 'Custom' and fontdropdown.Object.Visible
				if val ~= 'Custom' then
					optionapi.Value = Font.fromEnum(Enum.Font[val])
					optionsettings.Function(optionapi.Value)
				else
					pcall(function()
						optionapi.Value = Font.fromId(tonumber(fontbox.Value))
					end)
					optionsettings.Function(optionapi.Value)
				end
			end,
			Darker = optionsettings.Darker,
			Visible = optionsettings.Visible
		}, children, api)
		optionapi.Object = fontdropdown.Object
		fontbox = components.TextBox({
			Name = optionsettings.Name..' Asset',
			Placeholder = 'font (rbxasset)',
			Function = function()
				if fontdropdown.Value == 'Custom' then
					pcall(function()
						optionapi.Value = Font.fromId(tonumber(fontbox.Value))
					end)
					optionsettings.Function(optionapi.Value)
				end
			end,
			Visible = false,
			Darker = true
		}, children, api)
		
		fontdropdown.Object:GetPropertyChangedSignal('Visible'):Connect(function()
			fontbox.Object.Visible = fontdropdown.Object.Visible and fontdropdown.Value == 'Custom'
		end)
		
		return optionapi
	end,
	Slider = function(optionsettings, children, api)
		local optionapi = {
			Type = 'Slider',
			Value = optionsettings.Default or optionsettings.Min,
			Default = optionsettings.Default or optionsettings.Min,
			Min = optionsettings.Min,
			Max = optionsettings.Max,
			Decimal = optionsettings.Decimal or 1,
			Suffix = optionsettings.Suffix,
			Index = getTableSize(api.Options)
		}
		
		local slider = Instance.new('TextButton')
		slider.Name = optionsettings.Name..'Slider'
		slider.Size = UDim2.new(1, 0, 0, 50)
		slider.BackgroundColor3 = color.Dark(children.BackgroundColor3, optionsettings.Darker and 0.02 or 0)
		slider.BorderSizePixel = 0
		slider.AutoButtonColor = false
		slider.Visible = optionsettings.Visible == nil or optionsettings.Visible
		slider.Text = ''
		slider.Parent = children
		addTooltip(slider, optionsettings.Tooltip)
		local title = Instance.new('TextLabel')
		title.Name = 'Title'
		title.Size = UDim2.fromOffset(60, 30)
		title.Position = UDim2.fromOffset(10, 2)
		title.BackgroundTransparency = 1
		title.Text = optionsettings.Name
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.TextColor3 = color.Dark(uipallet.Text, 0.16)
		title.TextSize = 11
		title.FontFace = uipallet.Font
		title.Parent = slider
		local valuebutton = Instance.new('TextButton')
		valuebutton.Name = 'Value'
		valuebutton.Size = UDim2.fromOffset(60, 15)
		valuebutton.Position = UDim2.new(1, -69, 0, 9)
		valuebutton.BackgroundTransparency = 1
		valuebutton.Text = optionapi.Value..(optionsettings.Suffix and ' '..(type(optionsettings.Suffix) == 'function' and optionsettings.Suffix(optionapi.Value) or optionsettings.Suffix) or '')
		valuebutton.TextXAlignment = Enum.TextXAlignment.Right
		valuebutton.TextColor3 = color.Dark(uipallet.Text, 0.16)
		valuebutton.TextSize = 11
		valuebutton.FontFace = uipallet.Font
		valuebutton.Parent = slider
		local valuebox = Instance.new('TextBox')
		valuebox.Name = 'Box'
		valuebox.Size = valuebutton.Size
		valuebox.Position = valuebutton.Position
		valuebox.BackgroundTransparency = 1
		valuebox.Visible = false
		valuebox.Text = optionapi.Value
		valuebox.TextXAlignment = Enum.TextXAlignment.Right
		valuebox.TextColor3 = color.Dark(uipallet.Text, 0.16)
		valuebox.TextSize = 11
		valuebox.FontFace = uipallet.Font
		valuebox.ClearTextOnFocus = false
		valuebox.Parent = slider
		local bkg = Instance.new('Frame')
		bkg.Name = 'Slider'
		bkg.Size = UDim2.new(1, -20, 0, 2)
		bkg.Position = UDim2.fromOffset(10, 37)
		bkg.BackgroundColor3 = color.Light(uipallet.Main, 0.034)
		bkg.BorderSizePixel = 0
		bkg.Parent = slider
		local fill = bkg:Clone()
		fill.Name = 'Fill'
		fill.Size = UDim2.fromScale(math.clamp((optionapi.Value - optionsettings.Min) / optionsettings.Max, 0.04, 0.96), 1)
		fill.Position = UDim2.new()
		fill.BackgroundColor3 = Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value)
		fill.Parent = bkg
		local knobholder = Instance.new('Frame')
		knobholder.Name = 'Knob'
		knobholder.Size = UDim2.fromOffset(24, 4)
		knobholder.Position = UDim2.fromScale(1, 0.5)
		knobholder.AnchorPoint = Vector2.new(0.5, 0.5)
		knobholder.BackgroundColor3 = slider.BackgroundColor3
		knobholder.BorderSizePixel = 0
		knobholder.Parent = fill
		local knob = Instance.new('Frame')
		knob.Name = 'Knob'
		knob.Size = UDim2.fromOffset(14, 14)
		knob.Position = UDim2.fromScale(0.5, 0.5)
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.BackgroundColor3 = Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value)
		knob.Parent = knobholder
		addCorner(knob, UDim.new(1, 0))
		optionsettings.Function = optionsettings.Function or function() end
		optionsettings.Decimal = optionsettings.Decimal or 1
		
		function optionapi:Save(tab)
			tab[optionsettings.Name] = {
				Value = self.Value,
				Max = self.Max
			}
		end
		
		function optionapi:Load(tab)
			local newval = tab.Value == tab.Max and tab.Max ~= self.Max and self.Max or tab.Value
			if self.Value ~= newval then
				self:SetValue(newval, nil, true)
			end
		end
		
		function optionapi:Color(hue, sat, val, rainbowcheck)
			fill.BackgroundColor3 = rainbowcheck and Color3.fromHSV(mainapi:Color((hue - (self.Index * 0.075)) % 1)) or Color3.fromHSV(hue, sat, val)
			knob.BackgroundColor3 = fill.BackgroundColor3
		end
		
		function optionapi:SetValue(value, pos, final)
			if tonumber(value) == math.huge or value ~= value then return end
			local check = self.Value ~= value
			self.Value = value
			tween:Tween(fill, uipallet.Tween, {
				Size = UDim2.fromScale(math.clamp(pos or math.clamp(value / optionsettings.Max, 0, 1), 0.04, 0.96), 1)
			})
			valuebutton.Text = self.Value..(optionsettings.Suffix and ' '..(type(optionsettings.Suffix) == 'function' and optionsettings.Suffix(self.Value) or optionsettings.Suffix) or '')
			if check or final then
				optionsettings.Function(value, final)
			end
		end
		
		slider.InputBegan:Connect(function(inputObj)
			if
				(inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch)
				and (inputObj.Position.Y - slider.AbsolutePosition.Y) > (20 * scale.Scale)
			then
				local newPosition = math.clamp((inputObj.Position.X - bkg.AbsolutePosition.X) / bkg.AbsoluteSize.X, 0, 1)
				optionapi:SetValue(math.floor((optionsettings.Min + (optionsettings.Max - optionsettings.Min) * newPosition) * optionsettings.Decimal) / optionsettings.Decimal, newPosition)
				local lastValue = optionapi.Value
				local lastPosition = newPosition
		
				local changed = inputService.InputChanged:Connect(function(input)
					if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
						local newPosition = math.clamp((input.Position.X - bkg.AbsolutePosition.X) / bkg.AbsoluteSize.X, 0, 1)
						optionapi:SetValue(math.floor((optionsettings.Min + (optionsettings.Max - optionsettings.Min) * newPosition) * optionsettings.Decimal) / optionsettings.Decimal, newPosition)
						lastValue = optionapi.Value
						lastPosition = newPosition
					end
				end)
		
				local ended
				ended = inputObj.Changed:Connect(function()
					if inputObj.UserInputState == Enum.UserInputState.End then
						if changed then
							changed:Disconnect()
						end
						if ended then
							ended:Disconnect()
						end
						optionapi:SetValue(lastValue, lastPosition, true)
					end
				end)
		
			end
		end)
		slider.MouseEnter:Connect(function()
			tween:Tween(knob, uipallet.Tween, {
				Size = UDim2.fromOffset(16, 16)
			})
		end)
		slider.MouseLeave:Connect(function()
			tween:Tween(knob, uipallet.Tween, {
				Size = UDim2.fromOffset(14, 14)
			})
		end)
		valuebutton.MouseButton1Click:Connect(function()
			valuebutton.Visible = false
			valuebox.Visible = true
			valuebox.Text = optionapi.Value
			valuebox:CaptureFocus()
		end)
		valuebox.FocusLost:Connect(function(enter)
			valuebutton.Visible = true
			valuebox.Visible = false
			if enter and tonumber(valuebox.Text) then
				optionapi:SetValue(tonumber(valuebox.Text), nil, true)
			end
		end)
		
		optionapi.Object = slider
		api.Options[optionsettings.Name] = optionapi
		
		return optionapi
	end,
	Targets = function(optionsettings, children, api)
		local optionapi = {
			Type = 'Targets',
			Default = {
				Players = optionsettings.Players and true or false,
				NPCs = optionsettings.NPCs and true or false,
				Invisible... (291 KB left)
