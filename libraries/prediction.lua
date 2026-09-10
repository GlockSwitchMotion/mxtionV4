--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.
local module = {}
local eps = 1e-9
local function isZero(d)
	return (d > -eps and d < eps)
end

local function cuberoot(x)
	return (x > 0) and math.pow(x, (1 / 3)) or -math.pow(math.abs(x), (1 / 3))
end

local function solveQuadric(c0, c1, c2)
	local s0, s1

	local p, q, D

	p = c1 / (2 * c0)
	q = c2 / c0
	D = p * p - q

	if isZero(D) then
		s0 = -p
		return s0
	elseif (D < 0) then
		return
	else
		local sqrt_D = math.sqrt(D)

		s0 = sqrt_D - p
		s1 = -sqrt_D - p
		return s0, s1
	end
end

local function solveCubic(c0, c1, c2, c3)
	local s0, s1, s2

	local num, sub
	local A, B, C
	local sq_A, p, q
	local cb_p, D

	A = c1 / c0
	B = c2 / c0
	C = c3 / c0

	sq_A = A * A
	p = (1 / 3) * (-(1 / 3) * sq_A + B)
	q = 0.5 * ((2 / 27) * A * sq_A - (1 / 3) * A * B + C)

	cb_p = p * p * p
	D = q * q + cb_p

	if isZero(D) then
		if isZero(q) then
			s0 = 0
			num = 1
		else
			local u = cuberoot(-q)
			s0 = 2 * u
			s1 = -u
			num = 2
		end
	elseif (D < 0) then
		local phi = (1 / 3) * math.acos(-q / math.sqrt(-cb_p))
		local t = 2 * math.sqrt(-p)

		s0 = t * math.cos(phi)
		s1 = -t * math.cos(phi + math.pi / 3)
		s2 = -t * math.cos(phi - math.pi / 3)
		num = 3
	else
		local sqrt_D = math.sqrt(D)
		local u = cuberoot(sqrt_D - q)
		local v = -cuberoot(sqrt_D + q)

		s0 = u + v
		num = 1
	end

	sub = (1 / 3) * A

	if (num > 0) then s0 = s0 - sub end
	if (num > 1) then s1 = s1 - sub end
	if (num > 2) then s2 = s2 - sub end

	return s0, s1, s2
end

function module.solveQuartic(c0, c1, c2, c3, c4)
	local s0, s1, s2, s3

	local coeffs = {}
	local z, u, v, sub
	local A, B, C, D
	local sq_A, p, q, r
	local num

	A = c1 / c0
	B = c2 / c0
	C = c3 / c0
	D = c4 / c0

	sq_A = A * A
	p = -0.375 * sq_A + B
	q = 0.125 * sq_A * A - 0.5 * A * B + C
	r = -(3 / 256) * sq_A * sq_A + 0.0625 * sq_A * B - 0.25 * A * C + D

	if isZero(r) then
		coeffs[3] = q
		coeffs[2] = p
		coeffs[1] = 0
		coeffs[0] = 1

		local results = {solveCubic(coeffs[0], coeffs[1], coeffs[2], coeffs[3])}
		num = #results
		s0, s1, s2 = results[1], results[2], results[3]
	else
		coeffs[3] = 0.5 * r * p - 0.125 * q * q
		coeffs[2] = -r
		coeffs[1] = -0.5 * p
		coeffs[0] = 1

		s0, s1, s2 = solveCubic(coeffs[0], coeffs[1], coeffs[2], coeffs[3])
		z = s0

		u = z * z - r
		v = 2 * z - p

		if isZero(u) then
			u = 0
		elseif (u > 0) then
			u = math.sqrt(u)
		else
			return
		end
		if isZero(v) then
			v = 0
		elseif (v > 0) then
			v = math.sqrt(v)
		else
			return
		end

		coeffs[2] = z - u
		coeffs[1] = q < 0 and -v or v
		coeffs[0] = 1

		do
			local results = {solveQuadric(coeffs[0], coeffs[1], coeffs[2])}
			num = #results
			s0, s1 = results[1], results[2]
		end

		coeffs[2] = z + u
		coeffs[1] = q < 0 and v or -v
		coeffs[0] = 1

		if (num == 0) then
			local results = {solveQuadric(coeffs[0], coeffs[1], coeffs[2])}
			num = num + #results
			s0, s1 = results[1], results[2]
		end
		if (num == 1) then
			local results = {solveQuadric(coeffs[0], coeffs[1], coeffs[2])}
			num = num + #results
			s1, s2 = results[1], results[2]
		end
		if (num == 2) then
			local results = {solveQuadric(coeffs[0], coeffs[1], coeffs[2])}
			num = num + #results
			s2, s3 = results[1], results[2]
		end
	end

	sub = 0.25 * A

	if (num > 0) then s0 = s0 - sub end
	if (num > 1) then s1 = s1 - sub end
	if (num > 2) then s2 = s2 - sub end
	if (num > 3) then s3 = s3 - sub end

	return {s3, s2, s1, s0}
end

function module.SolveTrajectory(origin, projectileSpeed, gravity, targetPos, targetVelocity, playerGravity, playerHeight, playerJump, params, targetAirborne, horizLead, vertLead, maxTime)
	if type(horizLead) ~= 'number' then horizLead = 1 end
	if type(vertLead) ~= 'number' then vertLead = 1 end
	if type(maxTime) ~= 'number' then maxTime = nil end
	if not projectileSpeed or projectileSpeed <= 0 then return nil end

	targetVelocity = targetVelocity or Vector3.zero
	gravity = gravity or 0
	playerGravity = playerGravity or 0
	playerHeight = playerHeight or 0

	local velX = targetVelocity.X * horizLead
	local velZ = targetVelocity.Z * horizLead
	local velY = math.clamp(targetVelocity.Y * vertLead, -196, 60)

	local airborne = (targetAirborne == true) or (targetVelocity.Y < -12) or (targetVelocity.Y > 12)
	local groundY = targetPos.Y
	if airborne and playerGravity > 0 then
		groundY = nil
		if params then
			local hit = workspace:Raycast(targetPos, Vector3.new(0, -200, 0), params)
			if hit then groundY = hit.Position.Y + playerHeight + 1 end
		end
	end

	local function targetAt(t)
		local py = targetPos.Y + velY * t
		if airborne and playerGravity > 0 then
			py = py - 0.5 * playerGravity * t * t
		end
		if groundY and py < groundY then py = groundY end
		return Vector3.new(targetPos.X + velX * t, py, targetPos.Z + velZ * t)
	end

	local v2 = projectileSpeed * projectileSpeed
	local t = (targetPos - origin).Magnitude / projectileSpeed
	local lastT = -1

	for _ = 1, 8 do
		local toTarget = targetAt(t) - origin
		local dist = Vector3.new(toTarget.X, 0, toTarget.Z).Magnitude
		if dist < eps then return nil end

		if isZero(gravity) then
			t = toTarget.Magnitude / projectileSpeed
		else
			local underRoot = v2 * v2 - gravity * (gravity * dist * dist + 2 * toTarget.Y * v2)
			if underRoot < 0 then return nil end
			local vxz = projectileSpeed * math.cos(math.atan((v2 - math.sqrt(underRoot)) / (gravity * dist)))
			if vxz < eps then return nil end
			t = dist / vxz
		end

		if math.abs(t - lastT) < 0.0005 then break end
		lastT = t
	end

	if maxTime and t > maxTime then return nil end
	if t > 3 or t ~= t then return nil end

	local predicted = targetAt(t)
	local drift = (predicted - targetPos).Magnitude
	local maxDrift = math.max(targetVelocity.Magnitude * t * 1.5, 6)
	if drift > maxDrift then return nil end
	if isZero(gravity) then return predicted, t end

	local toTarget = predicted - origin
	local flat = Vector3.new(toTarget.X, 0, toTarget.Z)
	local dist = flat.Magnitude
	if dist < eps then return nil end

	local underRoot = v2 * v2 - gravity * (gravity * dist * dist + 2 * toTarget.Y * v2)
	if underRoot < 0 then return nil end
	local theta = math.atan((v2 - math.sqrt(underRoot)) / (gravity * dist))
	local launchXZ = projectileSpeed * math.cos(theta)
	if launchXZ < eps then return nil end
	local horizUnit = flat.Unit

	return origin + Vector3.new(horizUnit.X * launchXZ, projectileSpeed * math.sin(theta), horizUnit.Z * launchXZ), t
end

return module
