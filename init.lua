if not shared.VapeIndependent then
	if not game:IsLoaded() then
		repeat task.wait() until game:IsLoaded()
	end

	-- Fast Parallel Loader optimized for Bedwars
	local placeId = tostring(game.PlaceId)
	local universalCode, gameCode, premiumCode, publicCode

	task.spawn(function()
		universalCode = downloadFile('mxtionv4/games/universal.lua')
	end)

	task.spawn(function()
		if isfile('mxtionv4/games/' .. placeId .. '.lua') then
			gameCode = readfile('mxtionv4/games/' .. placeId .. '.lua')
		else
			-- Fallback to main Bedwars file if place ID is sub-place
			local targetFile = (placeId == '6872265039' or placeId == '8444591321') and placeId or '6872274481'
			gameCode = downloadFile('mxtionv4/games/' .. targetFile .. '.lua')
		end
	end)

	task.spawn(function()
		premiumCode = downloadFile('mxtionv4/libraries/premium.lua')
	end)

	task.spawn(function()
		pcall(function()
			publicCode = downloadFile('mxtionv4/libraries/publicconfigs.lua')
		end)
	end)

	-- Wait for parallel fetches to complete
	repeat task.wait() until universalCode and gameCode and premiumCode

	-- Execute in memory
	loadstring(universalCode, 'universal')(license)
	loadstring(gameCode, placeId)(license)
	loadstring(premiumCode, 'premium')(license)

	if publicCode then
		pcall(function()
			local publib = loadstring(publicCode, 'publicconfigs')(license)
			if publib and vape then
				vape.Libraries = vape.Libraries or {}
				vape.Libraries.publicconfigs = publib
			end
		end)
	end

	finishLoading()
else
	vape.Init = finishLoading
	return vape
end
