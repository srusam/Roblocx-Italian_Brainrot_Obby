local npc = script.Parent
local sound = npc:WaitForChild("TungSound")
local radius = 25
local triggered = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

RunService.Heartbeat:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (player.Character.HumanoidRootPart.Position - npc.PrimaryPart.Position).Magnitude

			if distance <= radius and not triggered then
				triggered = true
				sound:Play()
			end
		end
	end
end)
