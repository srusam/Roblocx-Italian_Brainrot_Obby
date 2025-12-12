local npc = script.Parent
local sound = npc:WaitForChild("BalerinaSound")

local radius = 25     -- trigger distance
local triggered = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

RunService.Heartbeat:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")

		if hrp and npc.PrimaryPart then
			local dist = (hrp.Position - npc.PrimaryPart.Position).Magnitude

			if dist <= radius and not triggered then
				triggered = true
				sound:Play()

				-- Once sound ends, allow again next time player leaves & returns
				task.delay(sound.TimeLength, function()
					triggered = false
				end)
			end
		end
	end
end)
