-- Robust radius-based checkpoint script with debug prints
-- Place this Script INSIDE your checkpoint object (Part or Model)

local CHECK_INTERVAL = 0.15
local TRIGGER_RADIUS = 6
local COOLDOWN = 2

local checkpointSpawn = script.Parent  -- THIS is the SpawnLocation
local Players = game:GetService("Players")

-- helper: find the actual BasePart to use for position & visuals
local function findCheckpointPart(obj)
	if obj:IsA("BasePart") then
		return obj
	end
	-- look for a direct child that is a BasePart
	for _, child in ipairs(obj:GetChildren()) do
		if child:IsA("BasePart") then
			return child
		end
	end
	-- try deeper search (if nested strangely)
	return obj:FindFirstChildWhichIsA("BasePart", true)
end

local checkpointPart = findCheckpointPart(checkpointSpawn )
if not checkpointPart then
	warn("[Checkpoint] No BasePart found under", checkpointSpawn:GetFullName(), "- script cannot run.")
	return
end

-- try to locate particle and label (robust)
local function findParticle(obj)
	-- direct child name
	local p = obj:FindFirstChild("CheckpointEffect")
	if p and p:IsA("ParticleEmitter") then return p end
	-- fallback: any particle emitter child
	for _, c in ipairs(obj:GetDescendants()) do
		if c:IsA("ParticleEmitter") then return c end
	end
	return nil
end

local function findLabel(obj)
	local b = obj:FindFirstChild("CheckpointLabel")
	if b and b:IsA("BillboardGui") then
		local t = b:FindFirstChildWhichIsA("TextLabel", true)
		return b, t
	end
	-- fallback: any BillboardGui descendant
	for _, c in ipairs(obj:GetDescendants()) do
		if c:IsA("BillboardGui") then
			local t = c:FindFirstChildWhichIsA("TextLabel", true)
			return c, t
		end
	end
	return nil, nil
end

local particle = findParticle(checkpointSpawn)
local billboard, textLabel = findLabel(checkpointSpawn)

-- init visuals off
if particle then
	pcall(function() particle.Enabled = false end)
else
	warn("[Checkpoint] No ParticleEmitter named 'CheckpointEffect' found under", checkpointSpawn:GetFullName())
end

if textLabel then
	pcall(function() textLabel.Visible = false end)
else
	warn("[Checkpoint] No TextLabel found inside a 'CheckpointLabel' BillboardGui under", checkpointSpawn:GetFullName())
end

print("[Checkpoint] Script running for:", checkpointSpawn:GetFullName(), "using part:", checkpointPart:GetFullName())

local triggered = false

local CollectionService = game:GetService("CollectionService")

local function resetOtherCheckpoints()
	for _, cp in ipairs(CollectionService:GetTagged("Checkpoint")) do
		if cp ~= checkpointSpawn then

			local part = cp:IsA("BasePart") and cp or cp:FindFirstChildWhichIsA("BasePart", true)
			if part then
				pcall(function()
					part.Color = Color3.fromRGB(255,255,255)
					part.Material = Enum.Material.Plastic
				end)
			end

			local eff = cp:FindFirstChild("CheckpointEffect", true)
			if eff and eff:IsA("ParticleEmitter") then
				eff.Enabled = false
			end

			local gui = cp:FindFirstChild("CheckpointLabel", true)
			if gui then
				local lbl = gui:FindFirstChildWhichIsA("TextLabel", true)
				if lbl then lbl.Visible = false end
			end
		end
	end
end


local function activateForPlayer(player)
	-- set respawn
	local spawnLocation = (checkpointSpawn:IsA("SpawnLocation") and checkpointSpawn) or checkpointSpawn:FindFirstChildWhichIsA("SpawnLocation", true)
	if spawnLocation then
		player.RespawnLocation = spawnLocation
	end
	print("[Checkpoint] Assigned respawn to:", spawnLocation and spawnLocation:GetFullName() or "nil")


	-- reset others
	resetOtherCheckpoints()
	-- visuals on this
	pcall(function()
		checkpointPart.BrickColor = BrickColor.new("Olive")
		checkpointPart.Material = Enum.Material.Neon
		checkpointPart.Color = Color3.fromRGB(77,255,127)
	end)
	if particle then pcall(function() particle.Enabled = true end) end
	if textLabel then
		pcall(function()
			textLabel.Visible = true
			spawn(function()
				task.wait(1.5)
				if textLabel and textLabel.Parent then textLabel.Visible = false end
			end)
		end)
	end
	-- optional: print to output
	print("[Checkpoint] Activated for player:", player.Name, "at checkpoint:", checkpointPart:GetFullName())
end

-- main loop
spawn(function()
	while true do
		task.wait(CHECK_INTERVAL)
		if triggered then continue end
		local pos = checkpointPart.Position
		for _, player in ipairs(Players:GetPlayers()) do
			local char = player.Character
			if char then
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hrp then
					local dist = (hrp.Position - pos).Magnitude
					if dist <= TRIGGER_RADIUS then
						triggered = true
						activateForPlayer(player)
						-- cooldown before allowing re-trigger
						task.delay(COOLDOWN, function() triggered = false end)
						break
					end
				end
			end
		end
	end
end)
