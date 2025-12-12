local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		local humanoid = char:WaitForChild("Humanoid")

		-- Check every second whether player is in water
		while humanoid.Parent do
			task.wait(0.3)

			-- If Humanoid is swimming (Roblox auto detects water)
			if humanoid:GetState() == Enum.HumanoidStateType.Swimming then
				-- Damage the player over time
				humanoid:TakeDamage(5)  -- Adjust damage as needed
			end
		end
	end)
end)


local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	-- Force default spawn on join
	player.RespawnLocation = nil
end)
