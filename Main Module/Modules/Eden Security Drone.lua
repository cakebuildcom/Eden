droneModel = require(2032081333)
items = script.Parent.Parent.Items

module = {
	Settings = {
		Colors = {
			Neutral = BrickColor.new("Pearl"),
			Armed = BrickColor.new("Bright red"),
		},
		Damage = 10,
		Cooldown = 0.2,
		Range = 200,
		Speed = 40,
		Acceleration = 15,
		ToggleKey = Enum.KeyCode.G,
		ArmKey = Enum.KeyCode.R
	},
	Install = function(product)
		for i,v in pairs (product.Settings) do
			module.Settings[i] = v
		end
		product.Show:Destroy()
		product.Button.MouseClick:Connect(function(player)
			if not player.Character then return end
			if player.Character:FindFirstChild("Drone") then return end
			local newDrone = droneModel:Clone()
			wait()
			newDrone.Parent = player.Character
			newDrone:SetPrimaryPartCFrame(
				product.Platform.CFrame + Vector3.new(0,10,0)
			)
			newDrone.Core:SetNetworkOwner(player)

			local drone = {
				Drone = newDrone,
				Core = newDrone.Core,
				Left = {
					Gun1 = newDrone.Left.Gun1,
					Gun2 = newDrone.Left.Gun2,
					Barrel = newDrone.Left.Barrel,
					Shoulder = newDrone.Left.Shoulder
				},
				Right = {
					Gun1 = newDrone.Right.Gun1,
					Gun2 = newDrone.Right.Gun2,
					Barrel = newDrone.Right.Barrel,
					Shoulder = newDrone.Right.Shoulder
				},
				Eyes = {newDrone.Body.LEye,newDrone.Body.REye}
			}

			spawn(function()
				while drone.Drone and drone.Core do
					wait(math.random(10,30))
					drone.Core.Scan:Play()
				end
			end)

			items.Event:Fire(player,script.Name,"GiveDrone",drone)
			return drone
		end)
	end,

	RemoteFunctions = {
		GetSettings = function(player)
			return module.Settings
		end,

		Eyecolor = function(player,drone,mode)
			for i,eye in pairs (drone.Eyes) do
				eye.BrickColor = module.Settings.Colors[mode]
			end
			if mode == "Armed" then
				drone.Core.Armed:Play()
			end
		end,

		Fire = function(player,drone,tag)
			drone.Core.Fire:Play()
			if tag.Human then
				tag.Human:TakeDamage(module.Settings.Damage)
			end
			for _,p in pairs (game.Players:GetPlayers()) do
				if p ~= player then
					items.Event:Fire(
						p,script.Name,"Laser",{
							drone.Left.Gun1,
							drone.Left.Gun2,
							drone.Right.Gun1,
							drone.Right.Gun2,
						},tag.Hit
					)
				end
			end
		end,

		ToggleLight = function(player,drone)
			drone.Core.SpotLight.Enabled = not drone.Core.SpotLight.Enabled
		end,
	}
}

return module
